az extension add --source "$WHEEL_FILE_URL" -y
az nf device update --resource-group "$RESOURCEGROUP" --location "$LOCATION" --resource-name "$DEVICENAME" --serial-number "$SERIALNUMBER"
result=$(az nf device show --resource-group "$RESOURCEGROUP" --resource-name "$DEVICENAME")