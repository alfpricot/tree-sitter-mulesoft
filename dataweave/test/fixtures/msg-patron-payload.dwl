%dw 2.0
output application/json skipNullOn="everywhere"

import * from dw::core::Strings
---
{
  "Action": if (vars.info.operation == "CREATE") "Register" else if (vars.info.operation == "UPDATE") "Amend" else if (vars.info.operation == "DELETE") "Close" else vars.info.operation ,
  "Collection": vars.collection,
  "Id": payload.fields.patronId.value,
  "Entries": [
    {
      "Collection": vars.info.collection,
      "Fields": {

		    "Street": payload.fields.street.value,
		    "CardNumber": if(vars.info.operation == "CREATE") "?" else payload.fields.cardNumber.value,
		    "HomeLibrary": if(vars.info.operation == "CREATE") 0 else payload.fields.homeLibrary.value default 0,
		    "Town": payload.fields.town.value,
		    "HouseholdSeq": payload.fields.householdSeq.value as Number,
		    "Region": payload.fields.region.value,
		    "Country": payload.fields.country.value,
		    "PostalCode": payload.fields.postalCode.value,
		    "Phone": payload.fields.phone.value,
		    "AltPhone": payload.body.patron.altPhone,
		    "Email": payload.fields.email.value,
		    "Homepage": payload.fields.homepage.value,
		    "NoticePreference": payload.body.patron.noticePreference,
		    "FeeMethod" : if(payload.body.patron.feeMethod == "Cash") "C" else if (payload.body.patron.feeMethod == "Card") "K" else if (payload.body.patron.feeMethod == "Waived") "W" else null,
		    "BorrowingBlocked": payload.body.patron.blockCode,
		    "Language": payload.fields.language.value,
            "AgeGroup": payload.body.patron.ageGroup,
            "DisplayName": payload.fields.displayName.value,
            "BlockReason": payload.body.patron.blockReason,
            "FineCapPercent": payload.body.patron.fineCap,
            "LibrarianName": payload.fields.librarianName.value,
            "CardType": payload.fields.cardType.value,
            "Librarian": payload.fields.librarian.value,
            "LoanLimit": payload.fields.loanLimit.value,
           "CardIssuedDate": if (payload.fields.cardIssued.value != null) ((payload.fields.cardIssued.value as Date {format: "MMMM d, yyyy"}) as String {format: "yyyy-MM-dd"}) ++ " 00:00:00.000"else null,
            "CardIssued": if(payload.fields.cardIssued.value == null) 0 else 1,
            "ActivePatron": if(vars.info.operation == "CREATE") 1 else null




            }
    }
  ],
  "Source": "circulation",

}
