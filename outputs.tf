output "jumphost_instance_id" {
  value = aws_instance.jumphost.id
}

output "httpbin_url" {
  value = aws_lb.httpbin.dns_name
}
