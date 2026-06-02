resource "azurerm_api_management_gateway_host_name_configuration" "this" {
  for_each = { for h in var.host_name_configurations : h.host_name => h }

  api_management_id = var.api_management_id
  gateway_name      = azurerm_api_management_gateway.this.name
  # Derive a deterministic resource name from the host name (dots are not valid
  # in APIM child resource names) so users only need to supply the host name.
  name      = replace(each.value.host_name, ".", "-")
  host_name = each.value.host_name

  certificate_id                     = each.value.certificate_id
  http2_enabled                      = each.value.http2_enabled
  request_client_certificate_enabled = each.value.request_client_certificate_enabled
  tls10_enabled                      = each.value.tls10_enabled
  tls11_enabled                      = each.value.tls11_enabled

  timeouts {
    create = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_host_name_configuration"]["create"],
      local.metadata.resource_timeouts["default"]["create"]
    )
    read = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_host_name_configuration"]["read"],
      local.metadata.resource_timeouts["default"]["read"]
    )
    update = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_host_name_configuration"]["update"],
      local.metadata.resource_timeouts["default"]["update"]
    )
    delete = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway_host_name_configuration"]["delete"],
      local.metadata.resource_timeouts["default"]["delete"]
    )
  }
}
