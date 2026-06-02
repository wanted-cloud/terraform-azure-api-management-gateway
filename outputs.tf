output "gateway_id" {
  description = "Resource ID of the self-hosted gateway registration."
  value       = azurerm_api_management_gateway.this.id
}

output "gateway_name" {
  description = "Name of the self-hosted gateway registration."
  value       = azurerm_api_management_gateway.this.name
}

output "bound_api_ids" {
  description = "Resource IDs of the APIs bound to this gateway, in iteration order of the `azurerm_api_management_gateway_api` resources."
  value       = [for k, v in azurerm_api_management_gateway_api.this : v.api_id]
}
