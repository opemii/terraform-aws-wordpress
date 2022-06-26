resource "aws_autoscaling_group" "wp_asg" {
  name_prefix               = "wordpress_asg"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.server_conf.name
  vpc_zone_identifier       = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  load_balancers            = [aws_elb.wp_loadbalancer.name]
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_elb.wp_loadbalancer, aws_launch_configuration.server_conf, aws_efs_mount_target.A, aws_efs_mount_target.B]
}

resource "aws_cloudwatch_metric_alarm" "cpuhigh" {
  alarm_name                = "cpuhigh"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions     = [aws_autoscaling_policy.asg_scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpulow" {
  alarm_name                = "cpulow"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions     = [aws_autoscaling_policy.asg_scale_in.arn]
}

resource "aws_autoscaling_policy" "asg_scale_out" {
  name                   = "add_one_unit_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wp_asg.name
}

resource "aws_autoscaling_policy" "asg_scale_in" {
  name                   = "delete_one_unit_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wp_asg.name
}