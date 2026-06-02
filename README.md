<!-- BEGIN_TF_DOCS -->
# wanted-cloud/terraform-azure-api-management-gateway

Terraform building block that provisions the **APIM-side registration of a self-hosted API Management gateway**: the gateway record on the parent API Management service, the API bindings attached to it, the trusted certificate authorities it accepts, and the custom host name configurations it exposes.

The module is intentionally narrow. It does not create the API Management service, it does not manage APIs, and it does not deploy the gateway runtime. It is meant to be composed with the sibling building blocks (`terraform-azure-api-management`, `terraform-azure-api-management-api`).

## Prerequisite — the gateway runtime is yours to run

A self-hosted gateway is a containerised process that must run somewhere you control: a Kubernetes cluster, a plain Docker host, a virtual machine, an edge appliance, another cloud, or on-premises hardware. This module only provisions the **APIM-side registration** — the gateway record on the API Management service plus its API bindings, certificate authorities, and host name configurations. It does **not** deploy or manage the gateway container itself.

After `terraform apply` you still need to:

1. Pull the gateway image (`mcr.microsoft.com/azure-api-management/gateway`).
2. Fetch the registration token and endpoint from the APIM blade for the gateway record this module created.
3. Deploy the container to your runtime of choice, passing the token and endpoint as environment variables.

## When to use this module

Most API Management deployments do **not** need a self-hosted gateway — the managed gateway shipped with the APIM service is the right default. Reach for a self-hosted gateway only when traffic must terminate **outside Azure**: on-premises datacentres, edge locations, regulatory boundaries, other clouds, or air-gapped environments.

If your APIs are happy living in Azure, use the managed gateway and skip this module.

## Table of contents

- [Requirements](#requirements)
- [Providers](#providers)
- [Variables](#inputs)
- [Outputs](#outputs)
- [Resources](#resources)
- [Usage](#usage)
- [Contributing](#contributing)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>=4.60.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>=4.60.0)

## Required Inputs

The following input variables are required:

### <a name="input_api_management_id"></a> [api\_management\_id](#input\_api\_management\_id)

Description: Resource ID of the parent API Management service the self-hosted gateway is registered against.

Type: `string`

### <a name="input_location_data"></a> [location\_data](#input\_location\_data)

Description: Physical location metadata for the gateway. Used by API Management for traffic routing decisions across multiple self-hosted gateways. `name` is required; the remaining fields are free-form labels (city, district, region) that the service surfaces to operators.

Type:

```hcl
object({
    name     = string
    city     = optional(string)
    district = optional(string)
    region   = optional(string)
  })
```

### <a name="input_name"></a> [name](#input\_name)

Description: Name of the self-hosted gateway registration on the API Management service.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_api_ids"></a> [api\_ids](#input\_api\_ids)

Description: Resource IDs of API Management APIs to bind to this gateway. APIs are managed externally (see `terraform-azure-api-management-api` outputs) — this module only attaches existing APIs to the gateway.

Type: `list(string)`

Default: `[]`

### <a name="input_certificate_authorities"></a> [certificate\_authorities](#input\_certificate\_authorities)

Description: Trusted certificate authority bindings keyed by APIM certificate resource ID. Each entry marks an existing service-scoped certificate as a (un)trusted CA for this gateway.

Type:

```hcl
list(object({
    certificate_id = string
    is_trusted     = bool
  }))
```

Default: `[]`

### <a name="input_description"></a> [description](#input\_description)

Description: Optional human-readable description of the gateway.

Type: `string`

Default: `""`

### <a name="input_host_name_configurations"></a> [host\_name\_configurations](#input\_host\_name\_configurations)

Description: Custom host name configurations exposed by the self-hosted gateway. Each entry binds a host name to an APIM-scoped certificate and toggles transport-layer features. TLS 1.0/1.1 and client certificate enforcement default to off (secure-by-default); HTTP/2 defaults to on.

Type:

```hcl
list(object({
    host_name                          = string
    certificate_id                     = string
    http2_enabled                      = optional(bool, true)
    request_client_certificate_enabled = optional(bool, false)
    tls10_enabled                      = optional(bool, false)
    tls11_enabled                      = optional(bool, false)
  }))
```

Default: `[]`

### <a name="input_metadata"></a> [metadata](#input\_metadata)

Description: Metadata definitions for the module, this is optional construct allowing override of the module defaults defintions of validation expressions, error messages, resource timeouts and default tags.

Type:

```hcl
object({
    resource_timeouts = optional(
      map(
        object({
          create = optional(string, "30m")
          read   = optional(string, "5m")
          update = optional(string, "30m")
          delete = optional(string, "30m")
        })
      ), {}
    )
    tags                     = optional(map(string), {})
    validator_error_messages = optional(map(string), {})
    validator_expressions    = optional(map(string), {})
  })
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_bound_api_ids"></a> [bound\_api\_ids](#output\_bound\_api\_ids)

Description: Resource IDs of the APIs bound to this gateway, in iteration order of the `azurerm_api_management_gateway_api` resources.

### <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id)

Description: Resource ID of the self-hosted gateway registration.

### <a name="output_gateway_name"></a> [gateway\_name](#output\_gateway\_name)

Description: Name of the self-hosted gateway registration.

## Resources

The following resources are used by this module:

- [azurerm_api_management_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_gateway) (resource)
- [azurerm_api_management_gateway_api.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_gateway_api) (resource)
- [azurerm_api_management_gateway_certificate_authority.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_gateway_certificate_authority) (resource)
- [azurerm_api_management_gateway_host_name_configuration.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/api_management_gateway_host_name_configuration) (resource)

## Usage

> For more detailed examples navigate to `examples` folder of this repository.

Module was also published via Terraform Registry and can be used as a module from the registry.

```hcl
module "example" {
  source  = "wanted-cloud/..."
  version = "x.y.z"
}
```

### Basic usage example

The minimal usage for the module is as follows:

```hcl
variable "apim_id" {
  description = "Resource ID of an existing API Management service."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim"
}

variable "api_ids" {
  description = "Resource IDs of APIs to attach to the gateway."
  type        = list(string)
  default = [
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/orders",
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/apis/customers",
  ]
}

module "gateway" {
  source = "../.."

  api_management_id = var.apim_id
  name              = "edge-eu-west"
  description       = "Self-hosted edge gateway in EU West."

  location_data = {
    name   = "eu-west-edge"
    region = "EU"
  }

  api_ids = var.api_ids
}
```
## Contributing

_Contributions are welcomed and must follow [Code of Conduct](https://github.com/wanted-cloud/.github?tab=coc-ov-file) and common [Contributions guidelines](https://github.com/wanted-cloud/.github/blob/main/docs/CONTRIBUTING.md)._

> If you'd like to report security issue please follow [security guidelines](https://github.com/wanted-cloud/.github?tab=security-ov-file).
---
<sup><sub>_2025 &copy; All rights reserved - WANTED.solutions s.r.o._</sub></sup>
<!-- END_TF_DOCS -->
