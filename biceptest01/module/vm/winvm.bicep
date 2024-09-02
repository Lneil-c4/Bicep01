@description('Virtual Machine Name')
param vmname string

@description('Azure Location')
param azlocation string

@description('Admin UserName')
param adminUName string

@description('Admin Password')
@minLength(12)
@secure()
param adminPword string

@description('The OS version of the VM.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('Network Interface Card ID')
param nicID string

@description('Name of the VM OS Disk')
param osDiskName string

@description('Computer Name')
param computerName string

@description('Tags assigned to resources')
param tags object

resource windowsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmname
  location: azlocation
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUName
      adminPassword: adminPword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        name: osDiskName
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicID
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
}
