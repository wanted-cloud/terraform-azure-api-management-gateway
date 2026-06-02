resource "azurerm_api_management_gateway_api" "this" {
  for_each = toset(var.api_ids)

  gateway_id = azurerm_api_management_gateway.this.id
  api_id     = each.value

  # `azurerm_api_management_gateway_api` is a pure association resource and the
  # provider only exposes create/read/delete timeouts (no update).
  timeouts {
    create = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_api"]["create"],
      local.metadata.resource_timeouts["default"]["create"]
    )
    read = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_api"]["read"],
      local.metadata.resource_timeouts["default"]["read"]
    )
    delete = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_api"]["delete"],
      local.metadata.resource_timeouts["default"]["delete"]
    )
  }
}
