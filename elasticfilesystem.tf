### EFS security group 
resource "aws_security_group" "efs_sg" {
  name        = "wordpress_efs"
  description = "Allow NFS inbound traffic"
  vpc_id      = aws_vpc.wp_vpc.id
  ingress {
    description     = "inbound traffic to efs"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.wordpress_sg]
}
#wordpress elasticfilesystem

resource "aws_efs_file_system" "wordpress_efs" {
  encrypted = true
  tags = {
    Name = "wordpress"
  }
}
#efs mount target to subnet-1

resource "aws_efs_mount_target" "A" {
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.subnet-1.id
  security_groups = [aws_security_group.efs_sg.id]
  depends_on      = [aws_efs_file_system.wordpress_efs, aws_security_group.efs_sg]
}
# efs mount target to subnet-2

resource "aws_efs_mount_target" "B" {
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.subnet-2.id
  security_groups = [aws_security_group.efs_sg.id]
  depends_on      = [aws_efs_file_system.wordpress_efs, aws_security_group.efs_sg]
}
