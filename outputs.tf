output "aws_instance_jumphost_public_ip" {
  value = aws_instance.jumphost.public_ip
}

output "httpbin_url" {
  value = join("", aws_lb.httpbin.*.dns_name)
}