#wordpress server


#virtual private cloud for the server

resource "aws_vpc" "wp_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "wordpress_vpc"
  }
}
#internet gateway for the sever

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.wp_vpc.id  
 tags = {
    Name = "igw"
 }
  depends_on = [aws_vpc.wp_vpc]
}
# creating subnet-1 in us-east-1a

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.wp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-1"
  }
}
#creating subnet-2 in us-east-1b

resource "aws_subnet" "subnet-2" {
  vpc_id            = aws_vpc.wp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-2"
  }
}
# route table

resource "aws_route_table" "wp_route_table" {
  vpc_id = aws_vpc.wp_vpc.id
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }
}
# route table association to subnet-1
resource "aws_route_table_association" "A" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.wp_route_table.id
}
# route table association to subnet-2

resource "aws_route_table_association" "B" {
  subnet_id      = aws_subnet.subnet-2.id
  route_table_id = aws_route_table.wp_route_table.id
}
# security group for the server

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress"
  description = "inbound traffic on port 443,80, and 22"
  vpc_id      = aws_vpc.wp_vpc.id

  ingress {
    description = "TLS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


