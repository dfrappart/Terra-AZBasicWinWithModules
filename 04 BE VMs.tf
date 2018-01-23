##############################################################
#This file creates BE DB servers
##############################################################

#NSG Rules

module "AllowSQLFromFEtoBEIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_BE_Subnet.Name}"
    NSGRuleName = "AllowMySQLFromFEtoBEIn"
    NSGRulePriority = 101
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "*"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = "1433-1434"
    NSGRuleSourceAddressPrefix = "${lookup(var.SubnetAddressRange, 0)}"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 1)}"
}

module "AllowRDPFromBastiontoBEIn" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_BE_Subnet.Name}"
    NSGRuleName = "AllowSSHFromBastiontoBEIn"
    NSGRulePriority = 102
    NSGRuleDirection = "Inbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "Tcp"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = 3389
    NSGRuleSourceAddressPrefix = "${lookup(var.SubnetAddressRange, 2)}"
    NSGRuleDestinationAddressPrefix = "${lookup(var.SubnetAddressRange, 1)}"
}

module "AllowAllBEtoInternetOut" {

    #Module source
    #source = "./Modules/08 NSGRule"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//08 NSGRule"


    #Module variable
    RGName = "${module.ResourceGroup.Name}"
    NSGReference = "${module.NSG_BE_Subnet.Name}"
    NSGRuleName = "AllowAllBEtoInternetOut"
    NSGRulePriority = 103
    NSGRuleDirection = "Outbound"
    NSGRuleAccess = "Allow"
    NSGRuleProtocol = "*"
    NSGRuleSourcePortRange = "*"
    NSGRuleDestinationPortRange = "*"
    NSGRuleSourceAddressPrefix = "${lookup(var.SubnetAddressRange, 1)}"
    NSGRuleDestinationAddressPrefix = "Internet"
}

#Availability set creation


module "AS_BEDB" {

    #Module source

    source = "./Modules/AvailabilitySet"
    #source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//13 AvailabilitySet"


    #Module variables
    ASName                  = "AS_BEDB"
    RGName                  = "${module.ResourceGroup.Name}"
    ASLocation              = "${var.AzureRegion}"
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"

}


#NIC Creation

module "NICs_BEDB" {

    #module source

    #source = "./Modules/09 NICWithoutPIPWithCount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//09 NICWithoutPIPWithCount"


    #Module variables

    NICcount            = "2"
    NICName             = "NIC_BEDB"
    NICLocation         = "${var.AzureRegion}"
    RGName              = "${module.ResourceGroup.Name}"
    SubnetId            = "${module.BE_Subnet.Id}"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

#Datadisk creation

module "DataDisks_BEDB" {

    #Module source

    #source = "./Modules/06 ManagedDiskswithcount"
    source = "github.com/dfrappart/Terra-AZBasiclinuxWithModules//Modules//06 ManagedDiskswithcount"


    #Module variables

    Manageddiskcount    = "2"
    ManageddiskName     = "DataDisk_BEDB"
    RGName              = "${module.ResourceGroup.Name}"
    ManagedDiskLocation = "${var.AzureRegion}"
    StorageAccountType  = "${lookup(var.Manageddiskstoragetier, 0)}"
    CreateOption        = "Empty"
    DiskSizeInGB        = "63"
    EnvironmentTag      = "${var.EnvironmentTag}"
    EnvironmentUsageTag = "${var.EnvironmentUsageTag}"


}

#VM creation

module "VMs_BEDB" {

    #module source

    #source = "./Modules/WinVMWithCount"
    source = "github.com/dfrappart/Terra-AZBasicWinWithModules//Modules//WinVMWithCount"


    #Module variables

    VMCount                     = "2"
    VMName                      = "DB-BE"
    VMLocation                  = "${var.AzureRegion}"
    VMRG                        = "${module.ResourceGroup.Name}"
    VMNICid                     = ["${module.NICs_BEDB.Ids}"]
    VMSize                      = "${lookup(var.VMSize, 0)}"
    ASID                        = "${module.AS_BEDB.Id}"
    VMStorageTier               = "${lookup(var.Manageddiskstoragetier, 0)}"
    VMAdminName                 = "${var.VMAdminName}"
    VMAdminPassword             = "${var.VMAdminPassword}"
    DataDiskId                  = ["${module.DataDisks_BEDB.Ids}"]
    DataDiskName                = ["${module.DataDisks_BEDB.Names}"]
    DataDiskSize                = ["${module.DataDisks_BEDB.Sizes}"]
    VMPublisherName             = "${lookup(var.PublisherName, 1)}"
    VMOffer                     = "${lookup(var.Offer, 1)}"
    VMsku                       = "${lookup(var.sku, 1)}"
    DiagnosticDiskURI           = "${module.DiagStorageAccount.PrimaryBlobEP}"
    EnvironmentTag              = "${var.EnvironmentTag}"
    EnvironmentUsageTag         = "${var.EnvironmentUsageTag}"

}

#VM Agent

#Network Watcher Agent

module "NetworkWatcherAgentForBEDB" {

    #Module Location
    #source = "./Modules/NetworkWatcherAgentWin"
    source = "github.com/dfrappart/Terra-AZBasicWinWithModules//Modules//NetworkWatcherAgentWin"

    #Module variables
    AgentCount              = "2"
    AgentName               = "NetworkWatcherAgentForBEDB"
    AgentLocation           = "${var.AzureRegion}"
    AgentRG                 = "${module.ResourceGroup.Name}"
    VMName                  = ["${module.VMs_BEDB.Name}"]
    EnvironmentTag          = "${var.EnvironmentTag}"
    EnvironmentUsageTag     = "${var.EnvironmentUsageTag}"
}

