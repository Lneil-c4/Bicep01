@description('Main VNet Name')
param mainvnet string = 'mainvnet'

@description('Azure Location')
param azlocation string = 'eastus'

@description('Subnet Name')
param subnets array = [
  {
    subnetName: 'subneta'
    addressPrefix: '10.0.0.0/24'
  }
  {
    subnetName: 'subnetb'
    addressPrefix: '10.0.1.0/24'
  }
]

@description('VM Name')
param vms array = [
  {
    vmName: 'vm-eus-01'
  }
  {
    vmName: 'vm-eus-02'
  }
]

@description('VM Accounts')
param vmUName string = 'testuser'

@secure()
param vmPword string

var selectedSubnet = subnets[0] 
//@description('VM Network Interface Card')
//param nicName string 

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
    subnets: [ for subnet in subnets: {
        name: subnet.subnetName
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
  }
}

resource prodwindowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = [for vm in vms:{
  name: vm.vmName
  location: azlocation
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: 'computerName'
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
        name: 'name'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: 'id'
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri:  'storageUri'
      }
    }
  }
}
]

resource prodNetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = [for vm in vms:{
  name: '${vm.vmName}-nic'
  location: azlocation
  properties: {
    ipConfigurations: [
      {
        name: 'Internal'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${mainVirtualNetwork.id}/subnets/subnet[0].subnetName'
            //id: resourceId('Microsoft.Network/virtualNetworks/subnets',mainvnet, 'subneta')
           // id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetname, 'subneta')
          }
        }
      }
    ]
  }
}
]

/*output NicID array = [
  for nic in Microsoft.Network/networkInterface
]*/

