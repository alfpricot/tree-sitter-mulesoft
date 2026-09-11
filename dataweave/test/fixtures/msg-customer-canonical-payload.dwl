%dw 2.0
output application/json skipNullOn="everywhere"

import * from dw::core::Strings
---
{
  "Action": if (vars.info.operation == "CREATE") "Insert" else if (vars.info.operation == "UPDATE") "Update" else if (vars.info.operation == "DELETE") "Delete" else vars.info.operation ,	
  "Object": vars.object,
  "Id": payload.Properties.AccountId.Value,
  "Records": [
    {
      "Object": vars.info.object,
      "Props": {
		
		    "Addr_1": payload.Properties.Addr_1.Value,
		    "CustNum": if(vars.info.operation == "CREATE") "?" else payload.Properties.CustNum.Value,
		    "DefaultShipTo": if(vars.info.operation == "CREATE") 0 else payload.Properties.DefaultShipTo.Value default 0,
		    "City": payload.Properties.City.Value,
		    "CustSeq": payload.Properties.CustSeq.Value as Number,
		    "State": payload.Properties.State.Value,
		    "Country": payload.Properties.Country.Value, 
		    "Zip": payload.Properties.Zip.Value,
		    "Phone_3": payload.Properties.Phone_3.Value,
		    "FaxNum": payload.data.payload.Fax,
		    "ExternalEmailAddr": payload.Properties.ExternalEmailAddr.Value, 
		    "InternetUrl": payload.Properties.InternetUrl.Value,
		    "TermsCode": payload.data.payload.PaymentTerm__c,
		    "PayType" : if(payload.data.payload.PaymentMethod__c == "Check") "C" else if (payload.data.payload.PaymentMethod__c == "Wire") "W" else if (payload.data.payload.PaymentMethod__c == "Draft") "D" else null,
		    "CreditHold": payload.data.payload.StatusCode__c,
		    "ISOCurrencyCode": payload.Properties.ISOCurrencyCode.Value,
            "TerritoryCode": payload.data.payload.Territory__c,
            "Name": payload.Properties.Name.Value,
            "TermDescription": payload.data.payload.TermDescription__c,
            "TermsDiscountPercent": payload.data.payload.TermDiscount__c,
            "DerSalesmanName": payload.Properties.DerSalesmanName.Value,
            "CustType": payload.Properties.CustType.Value,
            "Slsman": payload.Properties.Slsman.Value,
            "CreditLimit": payload.Properties.CreditLimit.Value,
           "ContractSignedDate": if (payload.Properties.Dealer_Agreement_Start__c.Value != null) ((payload.Properties.Dealer_Agreement_Start__c.Value as Date {format: "MMMM d, yyyy"}) as String {format: "yyyy-MM-dd"}) ++ " 00:00:00.000"else null,
            "ContractSigned": if(payload.Properties.Dealer_Agreement_Start__c.Value == null) 0 else 1,
            "ActiveCustomer": if(vars.info.operation == "CREATE") 1 else null
            
            
 
            
            }
    }
  ],
  "System": "SalesForce",
 
}