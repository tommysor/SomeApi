# SomeApi


## GitHub Action Deploy
### Credentials
`secrets.AZURE_SOMEAPI_DEPLOYER_CREDENTIALS` should contain the output from:

```bash
# Scope / ResourceGroupId can be found by opening ResourceGroup in portal and opening "JSON View"
scope=/subscriptions/<subcriptionId>/resourceGroups/<resourceGroupName>

# Create (or patch) service principal
az ad sp create-for-rbac --name "someapi-deployer" --role contributor \
                            --scopes $scope \
                            --sdk-auth

# Copy output and set secret in GitHub project

## Add permission to add permissions

# Get Id of service principal
az ad sp list --display-name someapi-deployer | jq .[].id
# Assign role
az role assignment create --assignee "6f17d366-db52-47f2-9e0f-b7f0f1f08f7c" \
                          --role "User Access Administrator" \
                          --scope $scope
```

