Class IHC.EAI.Monitor.Mirror.Data.MemberStatus Extends (%Persistent, %XML.Adaptor)
{

/// The virtual server used to obtain the status
Property VirtualServer As %String(MAXLEN = 50) [ Required ];

/// The virtual port used to obtain the status
Property VirtualPort As %Integer [ Required ];

/// The backup or async mirror member name
Property MemberName As %String(MAXLEN = 50);

/// Database Latency
Property DatabaseLatency As %String;

/// Database Time Latency
Property DatabaseTimeLatency As %String;

/// Journal Files Latency
Property JournalLatency As %String;

/// Journal Time Latency
Property JournalTimeLatency As %String;

Property MonitorCreatedOn As %TimeStamp;

Property MonitorUpdatedOn As %TimeStamp;

Property CurrentRole As %String(MAXLEN = 50);

Property Notes As %String(MAXLEN = 250);

Property Status As %String(MAXLEN = 10, VALUELIST = ",Active,Restart,Trouble,Failover,Recovery,Deciding,Exit,Catchup,Async,Inactive,Down");

Index iMainIndex On (VirtualServer, VirtualPort) [ Unique ];

Storage Default
{
<Data name="MemberStatusDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>VirtualServer</Value>
</Value>
<Value name="3">
<Value>VirtualPort</Value>
</Value>
<Value name="4">
<Value>MemberName</Value>
</Value>
<Value name="5">
<Value>DatabaseLatency</Value>
</Value>
<Value name="6">
<Value>DatabaseTimeLatency</Value>
</Value>
<Value name="7">
<Value>JournalLatency</Value>
</Value>
<Value name="8">
<Value>JournalTimeLatency</Value>
</Value>
<Value name="9">
<Value>MonitorCreatedOn</Value>
</Value>
<Value name="10">
<Value>MonitorUpdatedOn</Value>
</Value>
<Value name="11">
<Value>CurrentRole</Value>
</Value>
<Value name="12">
<Value>Notes</Value>
</Value>
<Value name="13">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Monit37FC.MemberStatusD</DataLocation>
<DefaultData>MemberStatusDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Monit37FC.MemberStatusD</IdLocation>
<IndexLocation>^IHC.EAI.Monit37FC.MemberStatusI</IndexLocation>
<StreamLocation>^IHC.EAI.Monit37FC.MemberStatusS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
