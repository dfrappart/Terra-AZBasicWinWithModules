#Variable declaration for Module

#The Agent count
variable "AgentCount" {
  type    = "string"

}

#The Agent Name
variable "AgentName" {
  type    = "string"

}

#The Agent Location (Azure Region)
variable "AgentLocation" {
  type    = "string"

}

#The RG in which the VM resides
variable "AgentRG" {
  type    = "string"

}

#The VM Name
variable "VMName" {
  type    = "list"

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

#Adding customscript extension for windows

resource "azurerm_virtual_machine_extension" "Terra-CustomScriptWinAgent" {
  

  count                = "${var.AgentCount}"
  name                 = "${var.AgentName}${count.index+1}-CustomScript"
  location             = "${var.AgentLocation}"
  resource_group_name  = "${var.AgentRG}"
  virtual_machine_name = "${element(var.VMName,count.index)}"
  publisher            = "microsoft.compute"
  type                 = "customscriptextension"
  type_handler_version = "1.9"

      settings = <<SETTINGS
        {   
        
        "commandToExecute": "powershell -command {$env:computername}"
        }
SETTINGS
    
  tags {
    environment = "${var.EnvironmentTag}"
    usage       = "${var.EnvironmentUsageTag}"
  }
}
