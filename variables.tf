variable "vpc_config" {
  description = "The parameters of vpc and vswitches."
  type = object({
    cidr_block = string
    vpc_name   = optional(string, null)
    ipv6_isp   = optional(string, "BGP")
  })
}


variable "alb_vswitches" {
  description = "The vswitches used for nlb."
  type = list(object({
    zone_id              = string
    cidr_block           = string
    ipv6_cidr_block_mask = number
    vswitch_name         = optional(string, null)
  }))
}

variable "app_vswitches" {
  description = "The vswitches used for application server."
  type = list(object({
    zone_id              = string
    cidr_block           = string
    ipv6_cidr_block_mask = number
    vswitch_name         = optional(string, null)
  }))
}

variable "security_group_name" {
  description = "The name of security group."
  type        = string
  default     = null
}

variable "ecs_config" {
  description = "The parameters of ecs instance."
  type = object({
    instance_type              = optional(string, "ecs.g6e.large")
    system_disk_category       = optional(string, "cloud_essd")
    image_id                   = optional(string, "ubuntu_24_04_x64_20G_alibase_20250113.vhd")
    instance_name              = optional(string, null)
    internet_max_bandwidth_out = optional(number, 0)
    ipv6_address_count         = optional(number, 1)
  })
  default = {}
}

variable "vpc_ipv6_gateway_name" {
  description = "The name of vpc ipv6 gateway."
  type        = string
  default     = null
}

variable "create_common_bandwidth_package" {
  description = "Whether to create common bandwidth package."
  type        = bool
  default     = true
}

variable "common_bandwidth_package" {
  description = "The parameters of common bandwidth package."
  type = object({
    name                 = optional(string, null)
    internet_charge_type = optional(string, "PayBy95")
    ratio                = optional(number, 20)
    isp                  = optional(string, "BGP")
    bandwidth            = optional(string, "1000")
  })
  default = {}
}

variable "exsiting_common_bandwidth_package_id" {
  description = "The id of existing common bandwidth package. If `create_common_bandwidth_package` is false, this value is required."
  type        = string
  default     = null
}

variable "alb_load_balancer" {
  description = "The parameters of alb load balancer."
  type = object({
    load_balancer_edition = optional(string, "Standard")
    load_balancer_name    = optional(string, null)
    pay_type              = optional(string, "PayAsYouGo")
  })
  default = {}
}

variable "alb_server_group" {
  description = "The parameters of alb server group."
  type = object({
    server_group_name = string
    scheduler         = optional(string, "Wrr")
    protocol          = optional(string, "HTTP")
    sticky_session_config = optional(object({
      sticky_session_enabled = optional(bool, true)
      sticky_session_type    = optional(string, "Insert")
    }), {})
    health_check_config = optional(object({
      health_check_enabled      = optional(bool, true)
      health_check_connect_port = optional(number, 46325)
      health_check_host         = optional(string, "ipv6-example.com")
      health_check_codes        = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])
      health_check_http_version = optional(string, "HTTP1.1")
      health_check_interval     = optional(number, 2)
      health_check_method       = optional(string, "HEAD")
      health_check_path         = optional(string, "/ipv6-example")
      health_check_protocol     = optional(string, "HTTP")
      health_check_timeout      = optional(number, 5)
      healthy_threshold         = optional(number, 3)
      unhealthy_threshold       = optional(number, 3)
    }), {})
    servers_port = optional(number, 80)
  })
  default = {
    server_group_name = "alb_server_group"
  }
}

variable "alb_listener" {
  description = "The parameters of alb listener."
  type = object({
    listener_protocol = optional(string, "HTTP")
    listener_port     = optional(number, 80)
  })
  default = {}
}
