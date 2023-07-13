az extension add --source "$WHEEL_FILE_URL" -y
az networkfabric device update --resource-group "$RESOURCEGROUP" --resource-name "$DEVICENAME" --serial-number "$SERIALNUMBER"