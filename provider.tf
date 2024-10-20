# Configure the AliCloud Provider

provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "me-central-1"
}

variable "name" {
  default = "terraform-alicloud"
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
}
