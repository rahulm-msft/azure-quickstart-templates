@minLength(3)
@maxLength(24)
param stringValue string

@minValue(1)
@maxValue(12)
param intValue int

@allowed([
  'one'
  'two'
])
param allowedValue string

param test int

output s string = stringValue
output i int = intValue
output a string = allowedValue
