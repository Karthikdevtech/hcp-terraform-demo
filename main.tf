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
      version = "~> 3.0"
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

# The Resource Group you created earlier
resource "azurerm_resource_group" "rg" {
  name     = "rg-hcp-terraform-dev"
  location = "East US"
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the created Azure Resource Group"
}