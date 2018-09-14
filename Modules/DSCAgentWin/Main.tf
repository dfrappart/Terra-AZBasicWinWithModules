

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
