output "jumphost_instance_id" {
  value = aws_instance.jumphost.id
}

output "httpbin_url" {
  value = join("", aws_lb.httpbin.*.dns_name)
}

output "httbin_url_short" {
  value = join("", aws_route53_record.httpbin.*.fqdn)
}