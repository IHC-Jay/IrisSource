/// Example JSON string:
/// {
/// 		"application": "ENSEMBLE",
/// 		"group": "ADT",
/// 		"valueDate": "2016-07-11",
/// 		"valueTime": "",
/// 		"value": 15615,
/// 		"type": "Out",
/// 		"qualifier": ""
/// }
Class IHC.EAI.KPI.JSON.TransactionCount Extends %RegisteredObject
{

/// The persistent object id
Property id As %String(MAXLEN = 50);

/// Application name
Property application As %String(MAXLEN = 50);

/// Group name (Schema/Namespace/etc...)
Property group As %String(MAXLEN = 100);

/// The datetime this record was created<br/>
/// In %TimeStamp format (@@FIX -> UTC?)
Property createdOn As %String;

/// The datetime this value was updated<br/>
/// In %TimeStamp format (@@FIX -> UTC?)
Property updatedOn As %String;

/// The date of this count 
Property valueDate As %String;

/// The count value
Property value As %Integer;

/// Type of count (In/Out/etc...)
Property type As %String(MAXLEN = 50);

/// User-defined qualifier
Property qualifier As %String(MAXLEN = 50);

}
