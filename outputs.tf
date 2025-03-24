output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_vpc.default.id
}

output "alb_vswitch_ids" {
  description = "The IDs of the ALB VSwitches."
  value       = [for key, value in alicloud_vswitch.alb : value.id]
}

output "app_vswitch_ids" {
  description = "The IDs of the App VSwitches."
  value       = [for key, value in alicloud_vswitch.app : value.id]
}

output "security_group_id" {
  description = "The ID of the security group."
  value       = alicloud_security_group.default.id
}

output "instance_ids" {
  description = "The IDs of the ECS instances."
  value       = [for key, value in alicloud_instance.default : value.id]
}

output "ipv6_gateway_id" {
  description = "The ID of the IPv6 gateway."
  value       = alicloud_vpc_ipv6_gateway.default.id
}

output "bandwidth_package_id" {
  description = "The ID of the common bandwidth package."
  value       = local.bandwidth_package_id
}

output "alb_load_balancer_id" {
  description = "The ID of the ALB load balancer."
  value       = alicloud_alb_load_balancer.default.id
}

output "alb_server_group_id" {
  description = "The ID of the ALB server group."
  value       = alicloud_alb_server_group.default.id
}

output "alb_listener_id" {
  description = "The ID of the ALB listener."
  value       = alicloud_alb_listener.default.id
}
