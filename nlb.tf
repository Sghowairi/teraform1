resource "alicloud_nlb_load_balancer" "http" {
  load_balancer_name = "http"
  load_balancer_type = "Network"
  address_type       = "Internet"
  address_ip_version = "Ipv4"
  vpc_id             = alicloud_vpc.vpc2.id
  zone_mappings {
    vswitch_id = alicloud_vswitch.publicv.id
    zone_id      = data.alicloud_zones.default.zones.0.id
  }
  zone_mappings {
    vswitch_id = alicloud_vswitch.publicv2.id
    zone_id      = data.alicloud_zones.default.zones.1.id
  }
}


resource "alicloud_nlb_server_group" "http-server" {
  server_group_name        = "http"
  server_group_type        = "Instance"
  vpc_id                   = alicloud_vpc.vpc2.id
  scheduler                = "rr"
  protocol                 = "TCP"
  connection_drain_enabled = true
  connection_drain_timeout = 60
  address_ip_version       = "Ipv4"
  health_check {
    health_check_enabled         = true
    health_check_type            = "TCP"
    health_check_connect_port    = 0
    healthy_threshold            = 2
    unhealthy_threshold          = 2
    health_check_connect_timeout = 5
    health_check_interval        = 10
    http_check_method            = "GET"
    health_check_http_code       = ["http_2xx", "http_3xx", "http_4xx"]
  }

}


resource "alicloud_nlb_server_group_server_attachment" "http-server-attachment" {
  count = length(alicloud_instance.httpnode1) 
  server_type     = "Ecs"
  server_id       = alicloud_instance.httpnode1[count.index].id
  description     = "http"
  port            = 80
  server_group_id = alicloud_nlb_server_group.http-server.id
  weight          = 100
}

resource "alicloud_nlb_listener" "http-listen" {
  listener_protocol      = "TCP"
  listener_port          = "80"
  listener_description   = "http"
  load_balancer_id       = alicloud_nlb_load_balancer.http.id
  server_group_id        = alicloud_nlb_server_group.http-server.id
  idle_timeout           = "900"
  proxy_protocol_enabled = "false"
  cps                    = "0"
  mss                    = "0"
}

output "NLB-URL" {
  value = alicloud_nlb_load_balancer.http.dns_name
}