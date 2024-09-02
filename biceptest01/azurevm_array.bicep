@description('Main VNet Name')
param mainvnet string = 'mainvnet'

@description('Azure Location')
param azlocation string = 'eastus'

@description('Subnets')
param subnets array = [
  {
    name: 'subneta'
    addressPrefix: '10.0.0.0/24'
  }
  {
    name: 'subnetb'
    addressPrefix: '10.0.1.0/24'
  }
]

@description('VMs')
param vms array = [
  {
    vmName: 'vm-eus-01'
    subnetName: 'subneta'
  }
  {
    vmName: 'vm-eus-02'
    subnetName: 'subneta'
  }
]

@description('VM Accounts')
param vmUName string = 'testuser'

@secure()
param vmPword string

targetScope = 'resourceGroup'

resource mainVirtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: mainvnet
  location: azlocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
  }
}

resource prodNetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for vm in vms: {
  name: '${vm.vmName}-nic'
  location: azlocation
  properties: {
    ipConfigurations: [
      {
        name: 'Internal'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', mainvnet, vm.subnetName)
          }
        }
      }
    ]
  }
}]

resource prodwindowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for (vm, i) in vms: {
  name: vm.vmName
  location: azlocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: vm.vmName
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
        name: '${vm.vmName}-osdisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: prodNetworkInterface[i].id
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

//https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.machinelearningservices/machine-learning-end-to-end-secure/modules/nsg.bicep
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'name'
  location: azlocation
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


//output diskname
