Terraform module to Implement NAT64 based on ALB for Alibaba Cloud

terraform-alicloud-nat64-based-on-alb
======================================

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-nat64-based-on-alb/blob/main/README-CN.md)

Faced with the requirements of IPv6 transformation, some enterprises will adopt the "NAT64" solution. This involves converting IPv6 access requests from clients into the IPv4 protocol and forwarding them to the server, helping application systems quickly and easily gain IPv6 access capability.

This Module deploy a dual-stack version of the ALB to provide "NAT64” capabilities for cloud-based application systems.

Architecture Diagram:

![image](https://raw.githubusercontent.com/alibabacloud-automation/terraform-alicloud-nat64-based-on-alb/main/scripts/diagram.png)

## Usage

```hcl
provider "alicloud" {
  region = "cn-shanghai"
}

module "complete" {
  source = "alibabacloud-automation/nat64-based-on-alb/alicloud"
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
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-nat64-based-on-alb/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_alb_listener.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/alb_listener) | resource |
| [alicloud_alb_load_balancer.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/alb_load_balancer) | resource |
| [alicloud_alb_server_group.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/alb_server_group) | resource |
| [alicloud_common_bandwidth_package.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/common_bandwidth_package) | resource |
| [alicloud_instance.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_security_group.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_vpc.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vpc_ipv6_gateway.default](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vpc_ipv6_gateway) | resource |
| [alicloud_vswitch.alb](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_vswitch.app](https://registry.terraform.io/providers/hashicorp/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_listener"></a> [alb\_listener](#input\_alb\_listener) | The parameters of alb listener. | <pre>object({<br>    listener_protocol = optional(string, "HTTP")<br>    listener_port     = optional(number, 80)<br>  })</pre> | `{}` | no |
| <a name="input_alb_load_balancer"></a> [alb\_load\_balancer](#input\_alb\_load\_balancer) | The parameters of alb load balancer. | <pre>object({<br>    load_balancer_edition = optional(string, "Standard")<br>    load_balancer_name    = optional(string, null)<br>    pay_type              = optional(string, "PayAsYouGo")<br>  })</pre> | `{}` | no |
| <a name="input_alb_server_group"></a> [alb\_server\_group](#input\_alb\_server\_group) | The parameters of alb server group. | <pre>object({<br>    server_group_name = string<br>    scheduler         = optional(string, "Wrr")<br>    protocol          = optional(string, "HTTP")<br>    sticky_session_config = optional(object({<br>      sticky_session_enabled = optional(bool, true)<br>      sticky_session_type    = optional(string, "Insert")<br>    }), {})<br>    health_check_config = optional(object({<br>      health_check_enabled      = optional(bool, true)<br>      health_check_connect_port = optional(number, 46325)<br>      health_check_host         = optional(string, "ipv6-example.com")<br>      health_check_codes        = optional(list(string), ["http_2xx", "http_3xx", "http_4xx"])<br>      health_check_http_version = optional(string, "HTTP1.1")<br>      health_check_interval     = optional(number, 2)<br>      health_check_method       = optional(string, "HEAD")<br>      health_check_path         = optional(string, "/ipv6-example")<br>      health_check_protocol     = optional(string, "HTTP")<br>      health_check_timeout      = optional(number, 5)<br>      healthy_threshold         = optional(number, 3)<br>      unhealthy_threshold       = optional(number, 3)<br>    }), {})<br>    servers_port = optional(number, 80)<br>  })</pre> | <pre>{<br>  "server_group_name": "alb_server_group"<br>}</pre> | no |
| <a name="input_alb_vswitches"></a> [alb\_vswitches](#input\_alb\_vswitches) | The vswitches used for nlb. | <pre>list(object({<br>    zone_id              = string<br>    cidr_block           = string<br>    ipv6_cidr_block_mask = number<br>    vswitch_name         = optional(string, null)<br>  }))</pre> | n/a | yes |
| <a name="input_app_vswitches"></a> [app\_vswitches](#input\_app\_vswitches) | The vswitches used for application server. | <pre>list(object({<br>    zone_id              = string<br>    cidr_block           = string<br>    ipv6_cidr_block_mask = number<br>    vswitch_name         = optional(string, null)<br>  }))</pre> | n/a | yes |
| <a name="input_common_bandwidth_package"></a> [common\_bandwidth\_package](#input\_common\_bandwidth\_package) | The parameters of common bandwidth package. | <pre>object({<br>    name                 = optional(string, null)<br>    internet_charge_type = optional(string, "PayBy95")<br>    ratio                = optional(number, 20)<br>    isp                  = optional(string, "BGP")<br>    bandwidth            = optional(string, "1000")<br>  })</pre> | `{}` | no |
| <a name="input_create_common_bandwidth_package"></a> [create\_common\_bandwidth\_package](#input\_create\_common\_bandwidth\_package) | Whether to create common bandwidth package. | `bool` | `true` | no |
| <a name="input_ecs_config"></a> [ecs\_config](#input\_ecs\_config) | The parameters of ecs instance. | <pre>object({<br>    instance_type              = optional(string, "ecs.g6e.large")<br>    system_disk_category       = optional(string, "cloud_essd")<br>    image_id                   = optional(string, "ubuntu_24_04_x64_20G_alibase_20250113.vhd")<br>    instance_name              = optional(string, null)<br>    internet_max_bandwidth_out = optional(number, 0)<br>    ipv6_address_count         = optional(number, 1)<br>  })</pre> | `{}` | no |
| <a name="input_exsiting_common_bandwidth_package_id"></a> [exsiting\_common\_bandwidth\_package\_id](#input\_exsiting\_common\_bandwidth\_package\_id) | The id of existing common bandwidth package. If `create_common_bandwidth_package` is false, this value is required. | `string` | `null` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | The name of security group. | `string` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of vpc and vswitches. | <pre>object({<br>    cidr_block = string<br>    vpc_name   = optional(string, null)<br>    ipv6_isp   = optional(string, "BGP")<br>  })</pre> | n/a | yes |
| <a name="input_vpc_ipv6_gateway_name"></a> [vpc\_ipv6\_gateway\_name](#input\_vpc\_ipv6\_gateway\_name) | The name of vpc ipv6 gateway. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_listener_id"></a> [alb\_listener\_id](#output\_alb\_listener\_id) | The ID of the ALB listener. |
| <a name="output_alb_load_balancer_id"></a> [alb\_load\_balancer\_id](#output\_alb\_load\_balancer\_id) | The ID of the ALB load balancer. |
| <a name="output_alb_server_group_id"></a> [alb\_server\_group\_id](#output\_alb\_server\_group\_id) | The ID of the ALB server group. |
| <a name="output_alb_vswitch_ids"></a> [alb\_vswitch\_ids](#output\_alb\_vswitch\_ids) | The IDs of the ALB VSwitches. |
| <a name="output_app_vswitch_ids"></a> [app\_vswitch\_ids](#output\_app\_vswitch\_ids) | The IDs of the App VSwitches. |
| <a name="output_bandwidth_package_id"></a> [bandwidth\_package\_id](#output\_bandwidth\_package\_id) | The ID of the common bandwidth package. |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | The IDs of the ECS instances. |
| <a name="output_ipv6_gateway_id"></a> [ipv6\_gateway\_id](#output\_ipv6\_gateway\_id) | The ID of the IPv6 gateway. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
