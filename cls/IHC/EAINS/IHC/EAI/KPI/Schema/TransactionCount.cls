/// Class that stores a snaphsot of daily transaction count data
Class IHC.EAI.KPI.Schema.TransactionCount Extends IHC.EAI.KPI.Schema.AbstractCount
{

/// Type of count<br/>
/// Possible options:<br/>
/// 		In, Out, ...<br/>
Property Type As %String(MAXLEN = 50);

/// A user-defined qualifier field
Property Qualifier As %String(MAXLEN = 100);

Index iMain On (Application, ApplicationGroup, Type, ValueDate) [ Unique ];

Index iValueDate On ValueDate;

Query MonthlyTransByApp() As %SQLQuery(CONTAINID = 0, SELECTMODE = "RUNTIME") [ SqlName = Monthly_Transaction_By_Application, SqlProc ]
{
	SELECT 
		Application,
		YEAR(ValueDate),
		MONTH(ValueDate),
		SUM(Value) 
	FROM IHC_EAI_KPI_Schema.TransactionCount 
	WHERE 
		(Type = 'Out' OR Type IS NULL) 
	GROUP By 
		Application,
		YEAR(ValueDate),
		MONTH(ValueDate)
}

Storage Default
{
<Data name="TransactionCountDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Application</Value>
</Value>
<Value name="3">
<Value>ApplicationGroup</Value>
</Value>
<Value name="4">
<Value>CreatedOn</Value>
</Value>
<Value name="5">
<Value>UpdatedOn</Value>
</Value>
<Value name="6">
<Value>Qualifier</Value>
</Value>
<Value name="7">
<Value>Type</Value>
</Value>
<Value name="8">
<Value>Value</Value>
</Value>
<Value name="9">
<Value>ValueDate</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KP8839.TransactionEC14D</DataLocation>
<DefaultData>TransactionCountDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KP8839.TransactionEC14D</IdLocation>
<IndexLocation>^IHC.EAI.KP8839.TransactionEC14I</IndexLocation>
<StreamLocation>^IHC.EAI.KP8839.TransactionEC14S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
