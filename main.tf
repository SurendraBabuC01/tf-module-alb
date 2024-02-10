resource "aws_security_group" "main" {
  name        = "${var.name}-alb-${var.env}-sg"
  description = "${var.name}-alb-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allow_alb_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb-${var.env}-sg"
  }
}

resource "aws_lb" "main" {
  name               = "${var.name}-alb-${var.env}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-alb" })
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Unauthorised"
      status_code  = "403"
    }
  }
}

