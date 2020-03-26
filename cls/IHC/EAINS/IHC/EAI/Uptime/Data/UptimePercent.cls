Class IHC.EAI.Uptime.Data.UptimePercent Extends %Persistent
{

/// Format: YYYY-MM-DD
Property RecordedOn As %String;

/// Optional namespace specific value
Property Qualifier As %String(MAXLEN = 50, VALUELIST = ",SnapshotAll,SnapshotNamespace") [ InitialExpression = "SnapshotAll" ];

Property Namespace As %String(MAXLEN = 50);

/// Three decimal place number
Property Value As %Numeric(SCALE = 3);

/// Format: YYYY-MM-DD
Property ValueDate As %String;

Index iMain On (RecordedOn, Qualifier) [ Unique ];

Storage Default
{
<Data name="UptimePercentDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RecordedOn</Value>
</Value>
<Value name="3">
<Value>Namespace</Value>
</Value>
<Value name="4">
<Value>Value</Value>
</Value>
<Value name="5">
<Value>Qualifier</Value>
</Value>
<Value name="6">
<Value>ValueDate</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Upti3A33.UptimePercentD</DataLocation>
<DefaultData>UptimePercentDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Upti3A33.UptimePercentD</IdLocation>
<IndexLocation>^IHC.EAI.Upti3A33.UptimePercentI</IndexLocation>
<StreamLocation>^IHC.EAI.Upti3A33.UptimePercentS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}