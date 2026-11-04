%dw 2.0
output application/json skipNullOn="everywhere"
import * from dw::core::Strings
---
{
  "Records": [
    {
      "Action": vars.info.operation,
      "Id": vars.info.salesforceId,
      "Object": vars.info.object,
      "Props": {
	    "CoNum": if(vars.info.operation == "Insert") "TBD" else payload.data.payload.extrecordid__c,
	    "ExternalConfirmationRef": payload.data.payload.ChangeEventHeader.recordIds[0],
	    ("CustNum": repeat(" ",(7 - sizeOf(payload.data.payload.ERP_CustomerNum__c default ""))) ++ (payload.data.payload.ERP_CustomerNum__c default ""))  if (payload.data.payload.ERP_CustomerNum__c != null),
	    "CustSeq": payload.data.payload.ERP_CustomerSeq__c,
	    "ShipCode": payload.data.payload.DUET__carriercode__c,
	    "TermsCode": ((payload.data.payload.Payment_Terms__c) splitBy  ("~"))[1], 
	    "CustPo": payload.data.payload.PoNumber,
	    "coUf_ShipEarly": payload.data.payload.Pick_Early__c,
	    "coUf_FreightAccount": payload.data.payload.Freight_Account__c,
	    "coUf_Carrier": payload.data.payload.Carrier__c, 
	    "coUf_CarrierSegment": payload.data.payload.Carrier_Segment__c,
	    "coUf_ClassOfService": payload.data.payload.Class_of_Service__c,
	    "coUf_FreightTerms": payload.data.payload.Freight_Terms__c,
	    "coUf_Priority": payload.data.payload.Priority__c,
	    ("coUf_Integrate": if((payload.data.payload.Ship_Release__c default "") as String == "true") 0 else 1) if(payload.data.payload.Ship_Release__c != null)
      }
    }
  ],
  "System": "SalesForce",
 
}