Class IHC.EAI.Report.EventLog.Data.Error Extends %Persistent
{

Property EventLogId As %Integer;

Property MessageId As %Integer;

Property SessionId As %Integer;

Property ConfigName As %String(MAXLEN = 200);

Property FullText As %String(MAXLEN = 1200);

Property TimeLogged As Ens.DataType.UTC;

Index iMessageId On MessageId;

Index iSessionId On SessionId;

Index iTimeLogged On TimeLogged;

/// This callback method is invoked by the <METHOD>%Delete</METHOD> method to 
/// provide notification that the object specified by <VAR>oid</VAR> is being deleted.
/// 
/// <P>If this method returns an error then the object will not be deleted.
ClassMethod %OnDelete(oid As %ObjectIdentity) As %Status [ Abstract, Private, ServerOnly = 1 ]
{
	Set SQLCODE = ""
	&sql(DELETE FROM IHC_EAI_Report_EventLog_Data.ErrorCode WHERE Error = :oid)
	Set ^EAI.Debug("%OnDelete",oid) = SQLCODE
	Quit $$$OK
}

Trigger OnDelete [ Event = DELETE, Time = AFTER ]
{
	New %tID,index,segid
	Set %tID={%%ID}
	Set SQLCODE = ""
	&sql(DELETE FROM IHC_EAI_Report_EventLog_Data.ErrorCode WHERE Error = :%tID)
	Set ^EAI.Debug("OnDelete",%tID) = SQLCODE
	Quit $$$OK
}

Storage Default
{
<Data name="ErrorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>EventLogId</Value>
</Value>
<Value name="3">
<Value>MessageId</Value>
</Value>
<Value name="4">
<Value>SessionId</Value>
</Value>
<Value name="5">
<Value>ConfigName</Value>
</Value>
<Value name="6">
<Value>FullText</Value>
</Value>
<Value name="7">
<Value>TimeLogged</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Report.Event899C.ErrorD</DataLocation>
<DefaultData>ErrorDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Report.Event899C.ErrorD</IdLocation>
<IndexLocation>^IHC.EAI.Report.Event899C.ErrorI</IndexLocation>
<StreamLocation>^IHC.EAI.Report.Event899C.ErrorS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
