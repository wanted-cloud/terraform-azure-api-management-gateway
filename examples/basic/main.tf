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
