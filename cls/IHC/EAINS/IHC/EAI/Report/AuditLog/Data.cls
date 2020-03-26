Class IHC.EAI.Report.AuditLog.Data Extends (%Persistent, %Populate, %XML.Adaptor)
{

Property AuditLogId As %String(MAXLEN = 250);

Property EventData As %String(MAXLEN = 1000);

Property LocalTimeStamp As %TimeStamp;

Property Description As %String(MAXLEN = 1000);

Property Pid As %Integer;

Property EventSource As %String(MAXLEN = 50);

Property EventType As %String(MAXLEN = 50);

Property EventName As %String(MAXLEN = 50);

Property Username As %String(MAXLEN = 50);

Property DescriptionKey As %String(MAXLEN = 1000);

Property CreatedOn As %TimeStamp;

Property Namespace As %String(MAXLEN = 50);

Property EventDataKey As %String(MAXLEN = 1000);

Index iEventSource On EventSource;

Index iEventType On EventType;

Index iEventName On EventName;

Index iUsername On Username;

Storage Default
{
<Data name="DataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>AuditLogId</Value>
</Value>
<Value name="3">
<Value>EventData</Value>
</Value>
<Value name="4">
<Value>LocalTimeStamp</Value>
</Value>
<Value name="5">
<Value>Description</Value>
</Value>
<Value name="6">
<Value>Pid</Value>
</Value>
<Value name="7">
<Value>EventSource</Value>
</Value>
<Value name="8">
<Value>EventType</Value>
</Value>
<Value name="9">
<Value>EventName</Value>
</Value>
<Value name="10">
<Value>Username</Value>
</Value>
<Value name="11">
<Value>DescriptionKey</Value>
</Value>
<Value name="12">
<Value>CreatedOn</Value>
</Value>
<Value name="13">
<Value>Namespace</Value>
</Value>
<Value name="14">
<Value>EventDataKey</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Report.AuditLog.DataD</DataLocation>
<DefaultData>DataDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Report.AuditLog.DataD</IdLocation>
<IndexLocation>^IHC.EAI.Report.AuditLog.DataI</IndexLocation>
<StreamLocation>^IHC.EAI.Report.AuditLog.DataS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
