output "web_app_address" {
  value = aws_lb.alb_main.dns_name
}
