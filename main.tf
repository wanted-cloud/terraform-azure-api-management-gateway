/*
 * # wanted-cloud/terraform-azure-api-management-gateway
 *
 * Terraform building block that provisions the **APIM-side registration of a self-hosted API Management gateway**: the gateway record on the parent API Management service, the API bindings attached to it, the trusted certificate authorities it accepts, and the custom host name configurations it exposes.
 *
 * The module is intentionally narrow. It does not create the API Management service, it does not manage APIs, and it does not deploy the gateway runtime. It is meant to be composed with the sibling building blocks (`terraform-azure-api-management`, `terraform-azure-api-management-api`).
 *
 * ## Prerequisite — the gateway runtime is yours to run
 *
 * A self-hosted gateway is a containerised process that must run somewhere you control: a Kubernetes cluster, a plain Docker host, a virtual machine, an edge appliance, another cloud, or on-premises hardware. This module only provisions the **APIM-side registration** — the gateway record on the API Management service plus its API bindings, certificate authorities, and host name configurations. It does **not** deploy or manage the gateway container itself.
 *
 * After `terraform apply` you still need to:
 *
 * 1. Pull the gateway image (`mcr.microsoft.com/azure-api-management/gateway`).
 * 2. Fetch the registration token and endpoint from the APIM blade for the gateway record this module created.
 * 3. Deploy the container to your runtime of choice, passing the token and endpoint as environment variables.
 *
 * ## When to use this module
 *
 * Most API Management deployments do **not** need a self-hosted gateway — the managed gateway shipped with the APIM service is the right default. Reach for a self-hosted gateway only when traffic must terminate **outside Azure**: on-premises datacentres, edge locations, regulatory boundaries, other clouds, or air-gapped environments.
 *
 * If your APIs are happy living in Azure, use the managed gateway and skip this module.
 */

resource "azurerm_api_management_gateway" "this" {
  name              = var.name
  api_management_id = var.api_management_id
  description       = var.description != "" ? var.description : null

  location_data {
    name     = var.location_data.name
    city     = var.location_data.city
    district = var.location_data.district
    region   = var.location_data.region
  }

  timeouts {
    create = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway"]["create"],
      local.metadata.resource_timeouts["default"]["create"]
    )
    read = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway"]["read"],
      local.metadata.resource_timeouts["default"]["read"]
    )
    update = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway"]["update"],
      local.metadata.resource_timeouts["default"]["update"]
    )
    delete = try(
      local.metadata.resource_timeouts["azurerm_api_management_gateway"]["delete"],
      local.metadata.resource_timeouts["default"]["delete"]
    )
  }
}
