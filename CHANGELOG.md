# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial release of the self-hosted gateway building block.
- `azurerm_api_management_gateway` provisioning with `location_data` for traffic routing.
- `azurerm_api_management_gateway_api` bindings between this gateway and externally-managed APIs.
- `azurerm_api_management_gateway_certificate_authority` configuration for trusted client CAs.
- `azurerm_api_management_gateway_host_name_configuration` for custom hostnames with TLS toggles.
