
# Create a new Security in a VPC
resource "alicloud_security_group" "http_node1" {
  name        = "http"
  description = "http allow"
  vpc_id      = alicloud_vpc.vpc2.id
}


resource "alicloud_security_group_rule" "allow_http_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.http_node1.id
  source_security_group_id = alicloud_security_group.http_bastion.id
}


