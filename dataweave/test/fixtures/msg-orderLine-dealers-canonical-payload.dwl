%dw 2.0
output application/json skipNullOn="everywhere"
import * from dw::core::Strings
---
{ 
  "Action": if (vars.dealerPayload.CFM_Row_Pointer__c == null) "Insert" else if (vars.dealerPayload.CFM_Row_Pointer__c__c != "null") "Update" else if (vars.info.operation == "DELETE") "Delete" else vars.info.operation ,	
  "Object": vars.info.object,
  "Id": vars.info.salesforceId,
  "Records": [
    {
      "Object": vars.info.object,
      "Props": {
		"CoNum" :if(payload.data.payload.Order.extrecordid__c  == null) vars.coNumQuery[0].Order.extrecordid__c else payload.data.payload.Order.extrecordid__c,
		"CoLine": payload.data.payload.LineNumber,
	    "Description": payload.data.payload.Description,
	    "Item": payload.data.payload.Product2.StockKeepingUnit,
	    "QtyOrderedConv": payload.data.payload.Quantity,
	    "PromiseDate": payload.data.payload.Request_Date__c, 
	    "DueDate": payload.data.payload.Request_Date__c,
	    "Disc": payload.data.payload.discount__c,
	    "QtyShipped": payload.data.payload.Quantity_Shipped__c,	    
	    "PriceConv": payload.data.payload.ListPrice,
	    "UM": payload.data.payload.Unit_of_Measure__c,
	    "SalesChannelType" : vars.orderLookup.SalesChannel.'Type',
	    "OrderID": vars.OrderId,
	    "OrderRowPointer": vars.orderLookup.ERP_RowPointer__c,
	    "OrderItemId":vars.info.salesforceId,
	    "salesforce_account_id":vars.accountId,
	    "Stat": if( p('salesforce.tourAccountId') == (if (vars.orderLookup is Array) vars.orderLookup[0].AccountId else vars.orderLookup.AccountId) ) "O"  else null,
	    "UnitPriceAdjusted": (vars.dealerPayload.TotalPrice/payload.data.payload.Quantity)

	    }
    }
  ],
  "System": "SalesForce",
 
}

