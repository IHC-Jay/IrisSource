Class IHC.EAI.Monitor.Message.Request Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property Name As %String(MAXLEN = 50);

Property Command As %String(VALUELIST = ",CONNECT,DELETE,GET,HEAD,OPTIONS,POST,PUT,TRACE");

Property Server As %String(MAXLEN = 50);

Property Port As %String(MAXLEN = 10);

Property URL As %String(MAXLEN = 250);

Property JSONStream As %Stream.GlobalCharacter;

Property AdditionalInfo As array Of %String;

Storage Default
{
<Data name="AdditionalInfo">
<Attribute>AdditionalInfo</Attribute>
<Structure>subnode</Structure>
<Subscript>"AdditionalInfo"</Subscript>
</Data>
<Data name="RequestDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Command</Value>
</Value>
<Value name="4">
<Value>Server</Value>
</Value>
<Value name="5">
<Value>Port</Value>
</Value>
<Value name="6">
<Value>URL</Value>
</Value>
<Value name="7">
<Value>JSONStream</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Monitor.MeEF8D.RequestD</DataLocation>
<DefaultData>RequestDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Monitor.MeEF8D.RequestD</IdLocation>
<IndexLocation>^IHC.EAI.Monitor.MeEF8D.RequestI</IndexLocation>
<StreamLocation>^IHC.EAI.Monitor.MeEF8D.RequestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
