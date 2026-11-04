%dw 2.0
output application/json skipNullOn="everywhere"
import * from dw::core::Strings
---
{
  "Action": if (vars.holdPayload.shelfRef == null) "Insert" else if (vars.holdPayload.shelfRefPrior != "null") "Update" else if (vars.info.operation == "DELETE") "Delete" else vars.info.operation ,
  "Collection": vars.info.collection,
  "Id": vars.info.itemId,
  "Entries": [
    {
      "Collection": vars.info.collection,
      "Fields": {
		"LoanNum" :if(payload.body.item.loan.loanNumber  == null) vars.loanQuery[0].loan.loanNumber else payload.body.item.loan.loanNumber,
		"LoanLine": payload.body.item.lineNumber,
	    "Title": payload.body.item.title,
	    "Isbn": payload.body.item.edition.isbn,
	    "CopiesRequested": payload.body.item.copies,
	    "ReadyDate": payload.body.item.requestedDate,
	    "DueDate": payload.body.item.requestedDate,
	    "FineRate": payload.body.item.fineRate,
	    "CopiesReturned": payload.body.item.copiesReturned,
	    "ReplacementCost": payload.body.item.replacementCost,
	    "Format": payload.body.item.format,
	    "ShelfType" : vars.loanLookup.Shelf.'Type',
	    "LoanID": vars.LoanId,
	    "LoanShelfRef": vars.loanLookup.shelfRef,
	    "LoanItemId":vars.info.itemId,
	    "patron_card_id":vars.cardId,
	    "Stat": if( p('circulation.staffCardId') == (if (vars.loanLookup is Array) vars.loanLookup[0].CardId else vars.loanLookup.CardId) ) "S"  else null,
	    "CostPerCopy": (vars.holdPayload.TotalCost/payload.body.item.copies)

	    }
    }
  ],
  "Source": "circulation",

}
