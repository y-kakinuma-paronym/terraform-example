# デプロイ時にelbのドメイン名をターミナルに出力する
output "elb_dns_name" {
  value = aws_elb.terraform-example-elb.dns_name
}