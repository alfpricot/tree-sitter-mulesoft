%dw 2.0
output application/json
---
{
	errorCodeSource: error.errorType.namespace as String default "" ++ ":" ++ error.errorType.identifier as String default "",
	errorMessageSource: error.description as String default "",
	errorDescriptionSource: error.detailedDescription as String default "",
	failingComponentSource: error.failingComponent as String default "",
	correlationId: vars.info.correlationId default "",
	apiName: vars.info.apiName default "",
}