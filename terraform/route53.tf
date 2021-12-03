
resource "aws_route53_zone" "sub_r53_k8s" {
  name = "yoursubdomain.domain.com"

  tags = {
    Name = "${var.name}-route53-sub-domain"
  }
}

resource "aws_route53_record" "k8s_ns" {
  allow_overwrite = true
  zone_id = aws_route53_zone.main_r53_k8s.zone_id
  name    = "yoursubdomain.domain.com"
  type    = "NS"
  ttl     = "300"
  records = [
      aws_route53_zone.sub_r53_k8s.name_servers[0],
      aws_route53_zone.sub_r53_k8s.name_servers[1],
      aws_route53_zone.sub_r53_k8s.name_servers[2],
      aws_route53_zone.sub_r53_k8s.name_servers[3],
  ]
}

resource "aws_route53_zone" "main_r53_k8s" {
  name = var.domains

  tags = {
    Name = "${var.name}-route53-main-domain"
  }
}

resource "null_resource" "updatens-domain" {
  provisioner "local-exec" {
    command = "aws route53domains update-domain-nameservers --region us-east-1 --domain-name ${var.domains} --nameservers Name=${aws_route53_zone.main_r53_k8s.name_servers.0} Name=${aws_route53_zone.main_r53_k8s.name_servers.1} Name=${aws_route53_zone.main_r53_k8s.name_servers.2} Name=${aws_route53_zone.main_r53_k8s.name_servers.3}"   
  }
  depends_on = [aws_route53_zone.main_r53_k8s]
}