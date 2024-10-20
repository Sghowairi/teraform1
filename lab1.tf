# # Configure the AliCloud Provider

# provider "alicloud" {
#   access_key = var.access_key
#   secret_key = var.secret_key
#   region = "me-central-1"
# }

# variable "name" {
#   default = "terraform-alicloud"
# }

# data "alicloud_zones" "default" {
#   available_disk_category     = "cloud_efficiency"
#   available_resource_creation = "VSwitch"
# }

# # Create a new ECS instance for VPC
# resource "alicloud_vpc" "vpc" {
#   vpc_name   = "myvpc2"
#   cidr_block = "10.0.0.0/8"
# }

# resource "alicloud_vswitch" "public" {
#   vpc_id       = alicloud_vpc.vpc.id
#   cidr_block   = "10.0.8.0/24"
#   zone_id      = data.alicloud_zones.default.zones.0.id
# #   vswitch_name = "public-vswitch"
# }

# resource "alicloud_vswitch" "private" {
#   vpc_id       = alicloud_vpc.vpc.id
#   cidr_block   = "10.0.7.0/24"
#   zone_id      = data.alicloud_zones.default.zones.0.id
# #  vswitch_name = "private-vswitch"
# }


# # Create a new Security in a VPC
# resource "alicloud_security_group" "http_node1" {
#   name        = "http"
#   description = "http allow"
#   vpc_id      = alicloud_vpc.vpc.id
# }

# # Create a new Security in a VPC
# resource "alicloud_security_group" "http_node2" {
#   name        = "http"
#   description = "http allow"
#   vpc_id      = alicloud_vpc.vpc.id
# }



# resource "alicloud_nat_gateway" "nat" {
#   vpc_id           = alicloud_vpc.vpc.id
#   nat_gateway_name = "nat1"
#   payment_type     = "PayAsYouGo"
#   vswitch_id       = alicloud_vswitch.public.id
#   nat_type         = "Enhanced"
# }


# resource "alicloud_eip_address" "ipnat" {
#   description               = "NAT"
#   address_name              = "NAT"
#   netmode                   = "public"
#   bandwidth                 = "100"
#   payment_type              = "PayAsYouGo"
#   internet_charge_type      = "PayByTraffic"
# }


# resource "alicloud_eip_association" "example" {
#   allocation_id = alicloud_eip_address.ipnat.id
#   instance_id   = alicloud_nat_gateway.nat.id
# }

# resource "alicloud_snat_entry" "snat" {
#   snat_table_id     = alicloud_nat_gateway.nat.snat_table_ids
#   source_vswitch_id = alicloud_vswitch.private.id
#   snat_ip           = alicloud_eip_address.ipnat.ip_address
# }

# resource "alicloud_route_table" "privateroute" {
#   description      = "test-description"
#   vpc_id           = alicloud_vpc.vpc.id
#   route_table_name = var.name
#   associate_type   = "VSwitch"
# }

# resource "alicloud_route_entry" "entry" {
#   route_table_id = alicloud_route_table.privateroute.id
#   destination_cidrblock = "0.0.0.0/0"
#   nexthop_type   = "NatGateway"
#   nexthop_id     = alicloud_nat_gateway.nat.id
#   }

# resource "alicloud_route_table_attachment" "foo" {
#   vswitch_id     = alicloud_vswitch.private.id
#   route_table_id = alicloud_route_table.privateroute.id
# }



# resource "alicloud_security_group_rule" "allow_all_http" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   policy            = "accept"
#   port_range        = "80/80"
#   priority          = 1
#   security_group_id = alicloud_security_group.http_node1.id
#   cidr_ip           = "0.0.0.0/0"
# }

# resource "alicloud_security_group_rule" "allow_all_ssh" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   policy            = "accept"
#   port_range        = "22/22"
#   priority          = 1
#   security_group_id = alicloud_security_group.http_node1.id
#   cidr_ip           = "0.0.0.0/0"
# }


# resource "alicloud_security_group_rule" "allow_all_sshRDS" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   policy            = "accept"
#   port_range        = "22/22"
#   priority          = 1
#   security_group_id = alicloud_security_group.http_node2.id
#   source_security_group_id = alicloud_security_group.http_node1.id
# }

# resource "alicloud_security_group_rule" "allow_all_redis" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   policy            = "accept"
#   port_range        = "6379/6379"
#   priority          = 1
#   security_group_id = alicloud_security_group.http_node2.id
#   source_security_group_id = alicloud_security_group.http_node1.id
# }

# resource "alicloud_ecs_key_pair" "publickey" {
#   key_pair_name = "publickey"
#   key_file = "key2.pem"
# }


# # Create a new public instance for VPC
# resource "alicloud_instance" "node1" {
#   # cn-beijing
#   availability_zone = data.alicloud_zones.default.zones.0.id
#   security_groups   = [alicloud_security_group.http_node1.id]

#   # series III
#   instance_type              = "ecs.g6.large"
#   system_disk_category       = "cloud_essd"
#   system_disk_name           = "shahad"
#   system_disk_size           = 40
#   system_disk_description    = "system_disk_description"
#   image_id                   = "ubuntu_22_04_x64_20G_alibase_20240926.vhd"
#   instance_name              = "node1"
#   vswitch_id                 = alicloud_vswitch.public.id
#   internet_max_bandwidth_out = 100
#   internet_charge_type       = "PayByTraffic"
#   instance_charge_type       = "PostPaid"
#   key_name                   = alicloud_ecs_key_pair.publickey.key_pair_name
#   user_data = base64encode(file("dock.sh"))
# }



# # Create a new private instance for VPC
# resource "alicloud_instance" "node2" {
#   # cn-beijing
#   availability_zone = data.alicloud_zones.default.zones.0.id
#   security_groups   = [alicloud_security_group.http_node2.id]

#   # series III
#   instance_type              = "ecs.g6.large"
#   system_disk_category       = "cloud_essd"
#   system_disk_name           = "shahad"
#   system_disk_size           = 40
#   system_disk_description    = "system_disk_description"
#   image_id                   = "ubuntu_22_04_x64_20G_alibase_20240926.vhd"
#   instance_name              = "node2"
#   vswitch_id                 = alicloud_vswitch.private.id
#   internet_max_bandwidth_out = 0
#   internet_charge_type       = "PayByTraffic"
#   instance_charge_type       = "PostPaid"
#   key_name                   = alicloud_ecs_key_pair.publickey.key_pair_name
#   user_data = base64encode(file("dock.sh"))
# }


# output "node1_ip" {
#   value = alicloud_instance.node1.public_ip
  
# }

# output "node2_ip" {
#   value = alicloud_instance.node2.private_ip
  
# }