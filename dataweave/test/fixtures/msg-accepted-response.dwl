%dw 2.0
output application/json
---
if (payload.successful == true) 
{
  "status": "Success",
  "errorCode": "200",
  "errorMessage": "",
  "id": (payload.items[0]).id
  
} else {
  "status": "Failed",
  "errorCode": "500",
  "errorMessage": (payload.items[0]).exception.message
}