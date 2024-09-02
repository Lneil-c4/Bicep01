param vmname string

param azlocation string

param adminUName string

@secure()
param adminPword string

param nicID string

param osDiskName string

param computerName string

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
        sku: '2012-R2-Datacenter'
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
