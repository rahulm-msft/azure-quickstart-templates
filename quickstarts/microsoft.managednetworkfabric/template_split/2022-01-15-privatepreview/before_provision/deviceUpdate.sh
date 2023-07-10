az extension add --source "$WHEEL_FILE_URL" -y
response=$(az nf device show -g "$RESOURCEGROUP" --resource-name "$DEVICENAME" --query "{role:networkDeviceRole, sku:networkDeviceSku}") 
role=$(echo "$response" | grep role | cut -d\" -f4)
sku=$(echo "$response" | grep sku | cut -d\" -f4)
az nf device update --resource-group "$RESOURCEGROUP"  --location "$LOCATION"  --resource-name "$DEVICENAME" --serial-number "$SERIALNUMBER" --network-device-sku "$sku" --network-device-role "$role"