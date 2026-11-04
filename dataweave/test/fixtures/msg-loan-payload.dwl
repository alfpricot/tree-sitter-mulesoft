%dw 2.0
output application/json skipNullOn="everywhere"
import * from dw::core::Strings
---
{
  "Entries": [
    {
      "Action": vars.info.operation,
      "Id": vars.info.loanId,
      "Collection": vars.info.collection,
      "Fields": {
	    "LoanNum": if(vars.info.operation == "Insert") "TBD" else payload.body.loan.loanNumber,
	    "ReceiptRef": payload.body.loan.header.receiptIds[0],
	    ("CardNumber": repeat(" ",(7 - sizeOf(payload.body.loan.cardNumber default ""))) ++ (payload.body.loan.cardNumber default ""))  if (payload.body.loan.cardNumber != null),
	    "HouseholdSeq": payload.body.loan.householdSeq,
	    "PickupDesk": payload.body.loan.pickupDesk,
	    "LoanPeriod": ((payload.body.loan.loanPolicy) splitBy  ("~"))[1],
	    "RequestRef": payload.body.loan.requestNumber,
	    "ExpressPickup": payload.body.loan.expressPickup,
	    "CourierAccount": payload.body.loan.courierAccount,
	    "Courier": payload.body.loan.courier,
	    "CourierRoute": payload.body.loan.courierRoute,
	    "DeliveryClass": payload.body.loan.deliveryClass,
	    "ReturnTerms": payload.body.loan.returnTerms,
	    "Priority": payload.body.loan.priority,
	    ("Renewable": if((payload.body.loan.renewal default "") as String == "true") 0 else 1) if(payload.body.loan.renewal != null)
      }
    }
  ],
  "Source": "circulation",

}
