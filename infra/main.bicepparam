using 'main.bicep'

// Parameters file for dev environment
// Adjust these values for your specific deployment

param location = 'westus3'
param environmentName = 'dev'
param baseName = 'zava'
param dockerImageTag = 'latest'
param enableAI = true
