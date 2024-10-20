
#Create a new ECS instance for VPC
resource "alicloud_vpc" "vpc2" {
  vpc_name   = "myvpc3"
  cidr_block = "10.0.0.0/8"
}

 resource "alicloud_vswitch" "publicv" {
  vpc_id       = alicloud_vpc.vpc2.id
  cidr_block   = "10.0.9.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
  vswitch_name = "public-vswitch"
}

resource "alicloud_vswitch" "publicv2" {
  vpc_id       = alicloud_vpc.vpc2.id
  cidr_block   = "10.0.12.0/24"
  zone_id      = data.alicloud_zones.default.zones.1.id
  vswitch_name = "public2-vswitch"
}

resource "alicloud_vswitch" "privatev" {
  vpc_id       = alicloud_vpc.vpc2.id
  cidr_block   = "10.0.10.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
#  vswitch_name = "private-vswitch"
}


resource "alicloud_nat_gateway" "nat" {
  vpc_id           = alicloud_vpc.vpc2.id
  nat_gateway_name = "nat1"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.publicv.id
  nat_type         = "Enhanced"
}


resource "alicloud_eip_address" "ipnat" {
  description               = "NAT"
  address_name              = "NAT"
  netmode                   = "public"
  bandwidth                 = "100"
  payment_type              = "PayAsYouGo"
  internet_charge_type      = "PayByTraffic"
}


resource "alicloud_eip_association" "example" {
  allocation_id = alicloud_eip_address.ipnat.id
  instance_id   = alicloud_nat_gateway.nat.id
}

resource "alicloud_snat_entry" "snat" {
  snat_table_id     = alicloud_nat_gateway.nat.snat_table_ids
  source_vswitch_id = alicloud_vswitch.privatev.id
  snat_ip           = alicloud_eip_address.ipnat.ip_address
}

resource "alicloud_route_table" "privateroute" {
  description      = "test-description"
  vpc_id           = alicloud_vpc.vpc2.id
  route_table_name = "privateroute"
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "entry" {
  route_table_id = alicloud_route_table.privateroute.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type   = "NatGateway"
  nexthop_id     = alicloud_nat_gateway.nat.id
  }

resource "alicloud_route_table_attachment" "foo" {
  vswitch_id     = alicloud_vswitch.privatev.id
  route_table_id = alicloud_route_table.privateroute.id
}

