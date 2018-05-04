#Variable declaration for Module

#The Agent count
variable "AgentCount" {
  type    = "string"
  default = "1"
}

#The Agent Name
variable "AgentName" {
  type = "string"
}

#The Agent Location (Azure Region)
variable "AgentLocation" {
  type = "string"
}

#The RG in which the VM resides
variable "AgentRG" {
  type = "string"
}

#The VM Name
variable "VMName" {
  type = "list"
}

#Tag info

variable "EnvironmentTag" {
  type    = "string"
  default = "Poc"
}

variable "EnvironmentUsageTag" {
  type    = "string"
  default = "Poc usage only"
}

#Adding DSC agent

resource "azurerm_virtual_machine_extension" "Terra-DSCAgentWin" {
  count                = "${var.AgentCount}"
  name                 = "${var.AgentName}${count.index+1}-DSCAgentWin"
  location             = "${var.AgentLocation}"
  resource_group_name  = "${var.AgentRG}"
  virtual_machine_name = "${element(var.VMName,count.index)}"
  publisher            = "microsoft.powershell"
  type                 = "dsc"
  type_handler_version = "2.9"

  settings = <<SETTINGS
        {   
        
        "commandToExecute": ""
        }
SETTINGS

  tags {
    environment = "${var.EnvironmentTag}"
    usage       = "${var.EnvironmentUsageTag}"
  }
}
