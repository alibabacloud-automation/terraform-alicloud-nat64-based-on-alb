provider "alicloud" {
  region = "cn-shanghai"
}

module "complete" {
  source = "../.."
  vpc_config = {
    cidr_block = "10.0.0.0/8"
    ipv6_isp   = "BGP"
  }

  alb_vswitches = [{
    vswitch_name         = "ipv6-alb-vsw1"
    ipv6_cidr_block_mask = 1
    zone_id              = "cn-shanghai-g"
    cidr_block           = "10.0.0.0/25"
    }, {
    vswitch_name         = "ipv6-alb-vsw2"
    ipv6_cidr_block_mask = 2
    zone_id              = "cn-shanghai-l"
    cidr_block           = "10.0.0.128/25"
  }]

  app_vswitches = [{
    vswitch_name         = "ipv6-app-vsw3"
    ipv6_cidr_block_mask = 3
    zone_id              = "cn-shanghai-g"
    cidr_block           = "10.0.1.0/24"
    }, {
    vswitch_name         = "ipv6-app-vsw4"
    ipv6_cidr_block_mask = 4
    zone_id              = "cn-shanghai-l"
    cidr_block           = "10.0.2.0/24"
  }]

}
