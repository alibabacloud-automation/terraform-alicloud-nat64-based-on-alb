resource "alicloud_vpc" "default" {
  vpc_name    = var.vpc_config.vpc_name
  cidr_block  = var.vpc_config.cidr_block
  enable_ipv6 = true
  ipv6_isp    = var.vpc_config.ipv6_isp
}

resource "alicloud_vswitch" "alb" {
  for_each = { for i, value in var.alb_vswitches : value.cidr_block => value }

  vpc_id               = alicloud_vpc.default.id
  cidr_block           = each.key
  zone_id              = each.value.zone_id
  ipv6_cidr_block_mask = each.value.ipv6_cidr_block_mask
  vswitch_name         = each.value.vswitch_name
  enable_ipv6          = true
}

resource "alicloud_vswitch" "app" {
  for_each = { for i, value in var.app_vswitches : value.cidr_block => value }

  vpc_id               = alicloud_vpc.default.id
  cidr_block           = each.key
  zone_id              = each.value.zone_id
  ipv6_cidr_block_mask = each.value.ipv6_cidr_block_mask
  vswitch_name         = each.value.vswitch_name
  enable_ipv6          = true
}

resource "alicloud_security_group" "default" {
  security_group_name = var.security_group_name
  vpc_id              = alicloud_vpc.default.id
}

resource "alicloud_instance" "default" {
  for_each = alicloud_vswitch.app

  availability_zone          = each.value.zone_id
  vswitch_id                 = each.value.id
  security_groups            = [alicloud_security_group.default.id]
  instance_type              = var.ecs_config.instance_type
  system_disk_category       = var.ecs_config.system_disk_category
  image_id                   = var.ecs_config.image_id
  instance_name              = var.ecs_config.instance_name
  internet_max_bandwidth_out = var.ecs_config.internet_max_bandwidth_out
  ipv6_address_count         = var.ecs_config.ipv6_address_count
}

resource "alicloud_vpc_ipv6_gateway" "default" {
  ipv6_gateway_name = var.vpc_ipv6_gateway_name
  vpc_id            = alicloud_vpc.default.id
}

resource "alicloud_common_bandwidth_package" "default" {
  count = var.create_common_bandwidth_package ? 1 : 0

  bandwidth_package_name = var.common_bandwidth_package.name
  isp                    = var.common_bandwidth_package.isp
  bandwidth              = var.common_bandwidth_package.bandwidth
  ratio                  = var.common_bandwidth_package.ratio
  internet_charge_type   = var.common_bandwidth_package.internet_charge_type
}

locals {
  bandwidth_package_id = var.create_common_bandwidth_package ? alicloud_common_bandwidth_package.default[0].id : var.exsiting_common_bandwidth_package_id
}

resource "alicloud_alb_load_balancer" "default" {
  load_balancer_edition  = var.alb_load_balancer.load_balancer_edition
  address_type           = "Internet"
  ipv6_address_type      = "Internet"
  vpc_id                 = alicloud_vpc.default.id
  load_balancer_name     = var.alb_load_balancer.load_balancer_name
  address_allocated_mode = "Fixed"
  address_ip_version     = "DualStack"
  bandwidth_package_id   = local.bandwidth_package_id
  load_balancer_billing_config {
    pay_type = var.alb_load_balancer.pay_type
  }
  dynamic "zone_mappings" {
    for_each = alicloud_vswitch.alb
    content {
      vswitch_id = zone_mappings.value.id
      zone_id    = zone_mappings.value.zone_id
    }
  }

}

resource "alicloud_alb_server_group" "default" {
  protocol          = var.alb_server_group.protocol
  vpc_id            = alicloud_vpc.default.id
  server_group_name = var.alb_server_group.server_group_name
  server_group_type = "Instance"
  scheduler         = var.alb_server_group.scheduler
  sticky_session_config {
    sticky_session_enabled = var.alb_server_group.sticky_session_config.sticky_session_enabled
    sticky_session_type    = var.alb_server_group.sticky_session_config.sticky_session_type
  }
  health_check_config {
    health_check_connect_port = var.alb_server_group.health_check_config.health_check_connect_port
    health_check_enabled      = var.alb_server_group.health_check_config.health_check_enabled
    health_check_host         = var.alb_server_group.health_check_config.health_check_host
    health_check_codes        = var.alb_server_group.health_check_config.health_check_codes
    health_check_http_version = var.alb_server_group.health_check_config.health_check_http_version
    health_check_interval     = var.alb_server_group.health_check_config.health_check_interval
    health_check_method       = var.alb_server_group.health_check_config.health_check_method
    health_check_path         = var.alb_server_group.health_check_config.health_check_path
    health_check_protocol     = var.alb_server_group.health_check_config.health_check_protocol
    health_check_timeout      = var.alb_server_group.health_check_config.health_check_timeout
    healthy_threshold         = var.alb_server_group.health_check_config.healthy_threshold
    unhealthy_threshold       = var.alb_server_group.health_check_config.unhealthy_threshold
  }
  dynamic "servers" {
    for_each = alicloud_instance.default
    content {
      port        = var.alb_server_group.servers_port
      server_id   = servers.value.id
      server_ip   = servers.value.private_ip
      server_type = "Ecs"
      weight      = 10
    }
  }
}

resource "alicloud_alb_listener" "default" {
  listener_protocol = var.alb_listener.listener_protocol
  listener_port     = var.alb_listener.listener_port
  load_balancer_id  = alicloud_alb_load_balancer.default.id
  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.default.id
      }
    }
  }
}
