Class IHC.EAI.Sync.REST.Request Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods) {

/// The command to use for this REST call
Property Command As %String(MAXLEN = 6, VALUELIST = ",PUT,GET,POST,DELETE");

/// The type of sync to perform for this REST call
Property SyncType As %String(MAXLEN = 10, VALUELIST = ",all,ssl,tasks,hl7schemas,sqlgateway");

/// The JSON body payload
Property JSONContent As %Stream.GlobalCharacter;

/// The URL location to use for this REST call
Property URL As %String(MAXLEN = 500);

/// The Server address to use for this REST call
Property Server As %String(MAXLEN = 50);

/// The Port to use for this REST call
Property Port As %String(MAXLEN = 10);

Storage Default
{
<Data name="RequestDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Command</Value>
</Value>
<Value name="3">
<Value>SyncType</Value>
</Value>
<Value name="4">
<Value>JSONContent</Value>
</Value>
<Value name="5">
<Value>URL</Value>
</Value>
<Value name="6">
<Value>Server</Value>
</Value>
<Value name="7">
<Value>Port</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Sync.REST.RequestD</DataLocation>
<DefaultData>RequestDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Sync.REST.RequestD</IdLocation>
<IndexLocation>^IHC.EAI.Sync.REST.RequestI</IndexLocation>
<StreamLocation>^IHC.EAI.Sync.REST.RequestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}