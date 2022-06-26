#load balancer for server

resource "aws_elb" "wp_loadbalancer" {
  name            = "wploadbalancer"
  security_groups = [aws_security_group.loadbalancer_sg.id]
  subnets         = [aws_subnet.subnet-1.id, aws_subnet.subnet-2.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:80"
    interval            = 20
  }
  cross_zone_load_balancing = true
  idle_timeout              = 60
  depends_on                = [aws_security_group.loadbalancer_sg]
}
#loadbalancer security group

resource "aws_security_group" "loadbalancer_sg" {
  name        = "loadbalance"
  description = "Allow traffic for lb"
  vpc_id      = aws_vpc.wp_vpc.id
  ingress {
    description = "Allow inbound traffic on the 80 port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }
  depends_on = [aws_security_group.wordpress_sg]

}
