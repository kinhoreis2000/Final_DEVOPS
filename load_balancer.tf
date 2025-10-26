resource "aws_lb" "web_lb" {
  name               = "LoadBalancer-DevOps2"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.main_a.id, aws_subnet.main_b.id]
}

resource "aws_lb_target_group" "web_tg" {
  name                      = "web-tg"
  port                      = 80
  protocol                  = "HTTP"
  vpc_id   = aws_vpc.main.id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}