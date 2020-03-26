Class IHC.EAI.Report.EventLog.Data.ErrorCode Extends %Persistent
{

Property Error As IHC.EAI.Report.EventLog.Data.Error;

Property ErrorCode As %String(MAXLEN = 150);

Index iErrorCode On ErrorCode;


Storage Default
{
<Data name="ErrorCodeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Error</Value>
</Value>
<Value name="3">
<Value>ErrorCode</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Report.E899C.ErrorCodeD</DataLocation>
<DefaultData>ErrorCodeDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Report.E899C.ErrorCodeD</IdLocation>
<IndexLocation>^IHC.EAI.Report.E899C.ErrorCodeI</IndexLocation>
<StreamLocation>^IHC.EAI.Report.E899C.ErrorCodeS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
