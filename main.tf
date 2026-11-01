terraform {
  cloud {
    organization = "karthikdevopstech" # Replace with your HCP organization name

    workspaces {
      name = "hcp-terraform-demo"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Or your preferred version >= 1.5.0
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example Azure Resource Group to test your deployment
resource "azurerm_resource_group" "rg" {
  name     = "rg-hcp-terraform-dev"
  location = "East US" # Change to your preferred Azure region
}

resource "random_pet" "server" {
  length = 2
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the created Azure Resource Group"
}