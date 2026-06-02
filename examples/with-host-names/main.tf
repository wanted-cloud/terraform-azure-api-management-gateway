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
  ]
}

variable "client_root_ca_certificate_id" {
  description = "Resource ID of an existing APIM service-scoped certificate used as a trusted client CA."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/certificates/client-root-ca"
}

variable "gateway_tls_certificate_id" {
  description = "Resource ID of an existing APIM service-scoped certificate presented by the gateway for the custom host name."
  type        = string
  default     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example-rg/providers/Microsoft.ApiManagement/service/example-apim/certificates/gateway-tls"
}

module "gateway" {
  source = "../.."

  api_management_id = var.apim_id
  name              = "edge-eu-west"
  description       = "Self-hosted edge gateway in EU West with mTLS."

  location_data = {
    name     = "eu-west-edge"
    city     = "Amsterdam"
    district = "North Holland"
    region   = "EU"
  }

  api_ids = var.api_ids

  certificate_authorities = [
    {
      certificate_id = var.client_root_ca_certificate_id
      is_trusted     = true
    },
  ]

  host_name_configurations = [
    {
      host_name                          = "edge.api.example.com"
      certificate_id                     = var.gateway_tls_certificate_id
      http2_enabled                      = true
      request_client_certificate_enabled = true
      tls10_enabled                      = false
      tls11_enabled                      = false
    },
  ]
}
