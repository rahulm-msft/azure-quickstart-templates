az extension add --source "https://nfadevstorage.blob.core.windows.net/mnfazcliwhl/managednetworkfabric-0.1.0.post31-py3-none-any.whl" -y 

fabric=$(az nf fabric show -g "rahul-nfrg031323" --resource-name "rahul-nf031323" --query "{state:provisioningState}")
echo $fabric
status=$(echo "$fabric" | grep state | cut -d\" -f4)
echo $status