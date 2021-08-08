provider "aws" {
  profile = "default" # default = .aws/credentialsのdefaultを使用する
  region  = "ap-northeast-1"
}

# EC2起動
resource "aws_launch_configuration" "terraform-example" {
  image_id      = "ami-09ebacdc178ae23b7"
  instance_type = "t2.micro"

  #   インスタンス作成後に実行されるbashスクリプト
  user_data = <<-EOF
    #! /bin/bash
    sudo yum update
    sudo yum install -y httpd
    sudo yum install -y vim git
    sudo chkconfig httpd on
    sudo service httpd start
    echo "<h1>hello world</h1>" | sudo tee /var/www/html/index.html
    EOF

  # セキュリティーグループ
  security_groups = ["${aws_security_group.terraform-example-sg.id}"]

  lifecycle {
    # 何らかの変更を実行した際に、既存のインスタンスを破棄する
    create_before_destroy = true
  }

}

# セキュリティグループ
resource "aws_security_group" "terraform-example-sg" {
  name = "terraform-example-sg"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    # 何らかの変更を実行した際に、既存のインスタンスを破棄する
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

# ASG (Auto Scaling Group)
resource "aws_autoscaling_group" "terraform-example-asg" {
  launch_configuration = "${aws_launch_configuration.terraform-example.id}"

  availability_zones = data.aws_availability_zones.all.names

  min_size = 2
  max_size = 3

  load_balancers    = ["${aws_elb.terraform-example-elb.name}"]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-example-asg"
    propagate_at_launch = true
  }

}

# ELB
resource "aws_elb" "terraform-example-elb" {
  name               = "terraform-example-elb"
  availability_zones = data.aws_availability_zones.all.names
  security_groups    = ["${aws_security_group.elb-sg.id}"]

  listener {
    lb_port           = var.server_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 60
    target              = "HTTP:${var.server_port}/"
  }
}

# ELB用セキュリティグループ
resource "aws_security_group" "elb-sg" {
  name = "terraform-example-elb"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
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