##############################################################
#This file create FE Web servers
##############################################################

#NSG rules for FE servers

module "AllowHTTPFromInternetFEIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"

    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_FE_Subnet.Name}"
    NSGRuleName = "AllowHTTPFromInternetFEIn"
    NSGRulePriority = 101
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 80
    NSGRuleSourceAddressPrefix = "Internet"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
}

module "AllowRDPFromBastiontoFEIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_FE_Subnet.Name}"
    NSGRuleName = "AllowRDPFromBastiontoFEIn"
    NSGRulePriority = 102
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 3389
    NSGRuleSourceAddressPrefix = "${lookup(var.SubnetAddressRange, 2)}"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
}

module "AllowSQLFromFEtoBEOut" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_FE_Subnet.Name}"
    NSGRuleName = "AllowMySQLFromFEtoBEOut"
    NSGRulePriority = 103
    NSGRuleDirection = "Outbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "*"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = "1433-1434"
    NSGRuleSourceAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 1)}"
}

module "AllowAllFEtoInternetOut" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_FE_Subnet.Name}"
    NSGRuleName = "AllowAllFEtoInternetOut"
    NSGRulePriority = 104
    NSGRuleDirection = "Outbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "*"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = "*"
    NSGRuleSourceAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
    NSGRuleDestinationAddressPrefix = "Internet"
}

#Azure Load Balancer public IP Creation

module "LBWebPublicIP" {

    #Module source
    #source = "./Modules/10 PublicIP"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//10 PublicIP"


    #Module variables
    PublicIPCount           = "1"
    PublicIPName            = "lbwebpip"
    PublicIPLocation        = "${var.AzureRegion}"
    RGName                  = "${module.ResourceGroup.Name}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"


}

module "LBWebFE" {

    #Module source
    #source = "./Modules/15 External LB"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//15 External LB"


    #Module variables
    LBCount             = "1"
    ExtLBName           = "LBWebFE"
    AzureRegion         = "${var.AzureRegion}"
    RGName              = "${module.ResourceGroup.Name}"
    FEConfigName        = "LBWebFEConfig"
    PublicIPId          = ["${module.LBWebPublicIP.Ids}"]
    LBBackEndPoolName   = "LBWebFE_BEPool"
    LBProbeName         = "LBWebFE_Probe"
    LBProbePort         = "80"
    FERuleName          = "LBWebFEHTTPRule"
    FERuleProtocol      = "tcp"
    FERuleFEPort        = "80"
    FERuleBEPort        = "80"
    TagEnvironment      = "${var.EnvironmentTag}"
    TagUsage            = "${var.EnvironmentUsageTag}"


} 

#Availability set creation


module "AS_FEWEB" {

    #Module source

    source = "./Modules/AvailabilitySet"
    #source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//13 AvailabilitySet"


    #Module variables
    ASName                  = "AS_FEWEB"
    RGName                  = "${module.ResourceGroup.Name}"
    ASLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"

}


#NIC Creation

module "NICs_FEWEB" {

    #module source

    #source = "./Modules/09 NICWithoutPIPWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//09 NICWithoutPIPWithCount"


    #Module variables

    NICcount            = "3"
    NICName             = "NIC_FEWEB"
    NICLocation         = "${var.AzureRegion}"
    RGName              = "${module.ResourceGroup.Name}"
    SubnetId            = "${module.FE_Subnet.Id}"
    IsLoadBalanced      = "1"
    LBBackEndPoolid     = ["${module.LBWebFE.LBBackendPoolIds}"]
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

#Datadisk creation

module "DataDisks_FEWEB" {

    #Module source

    #source = "./Modules/06 ManagedDiskswithcount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//06 ManagedDiskswithcount"


    #Module variables

    Manageddiskcount    = "3"
    ManageddiskName     = "DataDisk_FEWEB"
    RGName              = "${module.ResourceGroup.Name}"
    ManagedDiskLocation = "${var.AzureRegion}"
    StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 0)}"
    CreateOption        = "Empty"
    DiskSizeInGB        = "63"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

#VM creation

module "VMs_FEWEB" {

    #module source

    #source = "./Modules/WinVMWithCount"
    source = "github.com/dfrappart/Terra-AZBasicWinWithModules//Modules//WinVMWithCount"


    #Module variables

    VMCount                     = "3"
    VMName                      = "WEB-FE"
    VMLocation                  = "${var.AzureRegion}"
    VMRG                        = "${module.ResourceGroup.Name}"
    VMNICid                     = ["${module.NICs_FEWEB.LBIds}"]
    VMSize                      = "${lookup(var.VMSize, 0)}"
    ASID                        = "${module.AS_FEWEB.Id}"
    VMStorageTier               = "${lookup(var.Manageddiskstoragetier, 0)}"
    VMAdminName                 = "${var.VMAdminName}"
    VMAdminPassword             = "${var.VMAdminPassword}"
    DataDiskId                  = ["${module.DataDisks_FEWEB.Ids}"]
    DataDiskName                = ["${module.DataDisks_FEWEB.Names}"]
    DataDiskSize                = ["${module.DataDisks_FEWEB.Sizes}"]
    VMPublisherName             = "${lookup(var.PublisherName, 0)}"
    VMOffer                     = "${lookup(var.Offer, 0)}"
    VMsku                       = "${lookup(var.sku, 0)}"
    DiagnosticDiskURI           = "${module.DiagStorageAccount.PrimaryBlobEP}"
    EnvironmentTag              = "${var.EnvironmentTag}"
    EnvironmentUsageTag         = "${var.EnvironmentUsageTag}"

}

#VM Agent

#Network Watcher Agent

module "NetworkWatcherAgentForFEWeb" {

    #Module Location
    #source = "./Modules/NetworkWatcherAgentWin"
    source = "github.com/dfrappart/Terra-AZBasicWinWithModules//Modules//NetworkWatcherAgentWin"


    #Module variables
    AgentCount              = "3"
    AgentName               = "NetworkWatcherAgentForFEWeb"
    AgentLocation           = "${var.AzureRegion}"
    AgentRG                 = "${module.ResourceGroup.Name}"
    VMName                  = ["${module.VMs_FEWEB.Name}"]
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}

