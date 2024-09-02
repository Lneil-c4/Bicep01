@description('Main VNet Name')
param mainvnet string = 'bicep-eus-vnet'

@description('Azure Location')
param azlocation string = 'eastus'

@description('Subnets')
param subnets object = {
  subnet1: {
    prefix: '10.0.0.0/24'
  }
  subnet2: {
    prefix: '10.0.1.0/24'
  }
  subnet3: {
    prefix: '10.0.3.0/24'
  }
}

@description('List of VMs with its subnets')
param vmlist object = {
  'vm-bicep-eus-01':{
    subnetName: 'subnet1'
  }
  'vm-bicep-eus-02':{
    subnetName: 'subnet1'
  }
}

@description('Tags of Azure Resources')
param tags object = {
  Task: 'IaC Activity'
}

@description('NSG Rules')
param nsgrules object = {
  allow3389: {
    destinationPortRange: 3389
    priority: 500
  }
  allow443: {
    destinationPortRange: 443
    priority: 600
  }
}

/*param vms array = [
  {
    vmName: 'vm-eus-01'
    subnetName: 'subneta'
  }
  {
    vmName: 'vm-eus-02'
    subnetName: 'subneta'
  }
]*/

@description('VM Accounts')
param vmUName string = 'demoadmin'

@secure()
@minLength(12)
param vmPword string

targetScope = 'resourceGroup'

resource mainVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: mainvnet
  location: azlocation
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      for subnet in objectKeys(subnets): {
        name: subnet
        properties: {
          addressPrefix: subnets[subnet].prefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
    
  }
}

resource prodNetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for vm in objectKeys(vmlist): {
  dependsOn: [
    mainVirtualNetwork
  ]
  name: '${vm}-nic'
  location: azlocation
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'Internal'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', mainvnet, vmlist[vm].subnetName)
          }
        }
      }
    ]
  }
}]

/*resource prodwindowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for vm in objectKeys(vmlist): {
  dependsOn: [
    prodNetworkInterface
  ]
  name: vm
  location: azlocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: vm
      adminUsername: vmUName
      adminPassword: vmPword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2012-R2-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${vm}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          //id: prodNetworkInterface[i].id
          id: resourceId('Microsoft.Network/networkInterfaces', '${vm}-nic')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
        //storageUri:  'storageUri'
      }
    }
  }
}]
  */

  module winVMs './module/vm/winvm.bicep' = [ for vm in objectKeys(vmlist): {
    name: 'WindowsVMDeployment-${vm}'
    scope: resourceGroup()
    params: {
      adminPword: vmPword
      adminUName: vmUName
      azlocation: azlocation
      nicID: resourceId('Microsoft.Network/networkInterfaces', '${vm}-nic')
      vmname: vm
      osDiskName: '${vm}-osdisk'
       computerName: vm
        tags: tags
    }
  }]
  
//https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/modules/nsg.bicep
/*resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'name'
  location: azlocation
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'nsgRule'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}
*/

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'NSG01'
  location: azlocation
  tags: tags
  properties: {
    securityRules: [ for nsgrulename in objectKeys(nsgrules): {
        name: nsgrulename
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: nsgrules[nsgrulename].destinationPortRange
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: nsgrules[nsgrulename].priority
          direction: 'Inbound'
        }
      }
    ]
  }
}


//output diskname
