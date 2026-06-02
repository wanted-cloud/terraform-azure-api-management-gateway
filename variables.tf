variable "api_management_id" {
  description = "Resource ID of the parent API Management service the self-hosted gateway is registered against."
  type        = string
}

variable "name" {
  description = "Name of the self-hosted gateway registration on the API Management service."
  type        = string
}

variable "description" {
  description = "Optional human-readable description of the gateway."
  type        = string
  default     = ""
}

variable "location_data" {
  description = "Physical location metadata for the gateway. Used by API Management for traffic routing decisions across multiple self-hosted gateways. `name` is required; the remaining fields are free-form labels (city, district, region) that the service surfaces to operators."
  type = object({
    name     = string
    city     = optional(string)
    district = optional(string)
    region   = optional(string)
  })
}

variable "api_ids" {
  description = "Resource IDs of API Management APIs to bind to this gateway. APIs are managed externally (see `terraform-azure-api-management-api` outputs) — this module only attaches existing APIs to the gateway."
  type        = list(string)
  default     = []
}

variable "certificate_authorities" {
  description = "Trusted certificate authority bindings keyed by APIM certificate resource ID. Each entry marks an existing service-scoped certificate as a (un)trusted CA for this gateway."
  type = list(object({
    certificate_id = string
    is_trusted     = bool
  }))
  default = []

  validation {
    condition     = length(var.certificate_authorities) == length(distinct([for ca in var.certificate_authorities : ca.certificate_id]))
    error_message = "Each entry in `certificate_authorities` must have a unique `certificate_id`."
  }
}

variable "host_name_configurations" {
  description = "Custom host name configurations exposed by the self-hosted gateway. Each entry binds a host name to an APIM-scoped certificate and toggles transport-layer features. TLS 1.0/1.1 and client certificate enforcement default to off (secure-by-default); HTTP/2 defaults to on."
  type = list(object({
    host_name                          = string
    certificate_id                     = string
    http2_enabled                      = optional(bool, true)
    request_client_certificate_enabled = optional(bool, false)
    tls10_enabled                      = optional(bool, false)
    tls11_enabled                      = optional(bool, false)
  }))
  default = []

  validation {
    condition     = length(var.host_name_configurations) == length(distinct([for h in var.host_name_configurations : h.host_name]))
    error_message = "Each entry in `host_name_configurations` must have a unique `host_name`."
  }

  # Two host names that differ only in punctuation (e.g. `api.example.com` and
  # `api-example.com`) would collide once the derived resource name swaps dots
  # for dashes. Reject up-front instead of letting the for_each fail.
  validation {
    condition     = length(var.host_name_configurations) == length(distinct([for h in var.host_name_configurations : replace(h.host_name, ".", "-")]))
    error_message = "Host names must produce distinct derived resource names (dots are replaced with dashes when constructing the APIM child resource name)."
  }
}
