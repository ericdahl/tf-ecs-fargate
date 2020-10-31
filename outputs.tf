output "aws_instance_jumphost_public_ip" {
  value = aws_instance.jumphost.public_ip
}

output "httpbin_url" {
  value = join("", aws_lb.httpbin.*.dns_name)
}

output "httbin_url_short" {
  value = join("", aws_route53_record.httpbin.*.fqdn)
}