resource "azurerm_api_management_gateway_certificate_authority" "this" {
  for_each = { for ca in var.certificate_authorities : ca.certificate_id => ca }

  api_management_id = var.api_management_id
  gateway_name      = azurerm_api_management_gateway.this.name
  # The provider expects the certificate's APIM-scoped *name*, not the full
  # Azure resource ID. Derive it from the input ID by taking the last path
  # segment.
  certificate_name = reverse(split("/", each.value.certificate_id))[0]
  is_trusted       = each.value.is_trusted

  timeouts {
    create = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_certificate_authority"]["create"],
      local.metadata.resource_timeouts["default"]["create"]
    )
    read = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_certificate_authority"]["read"],
      local.metadata.resource_timeouts["default"]["read"]
    )
    update = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_certificate_authority"]["update"],
      local.metadata.resource_timeouts["default"]["update"]
    )
    delete = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_certificate_authority"]["delete"],
      local.metadata.resource_timeouts["default"]["delete"]
    )
  }
}
