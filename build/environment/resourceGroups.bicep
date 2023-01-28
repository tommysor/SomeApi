targetScope = 'subscription'

param location string
param environmentRgName string
param apiRgName string
param processingRgName string

resource environment 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  name: environmentRgName
}

resource api 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  name: apiRgName
}

resource processing 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  name: processingRgName
}
