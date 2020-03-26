Class IHC.EAI.Uptime.Message.Request Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property Name As %String(MAXLEN = 50);

Property Command As %String(VALUELIST = ",CONNECT,DELETE,GET,HEAD,OPTIONS,POST,PUT,TRACE");

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
<Value>URL</Value>
</Value>
<Value name="5">
<Value>JSONStream</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Uptime.Mes5671.RequestD</DataLocation>
<DefaultData>RequestDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Uptime.Mes5671.RequestD</IdLocation>
<IndexLocation>^IHC.EAI.Uptime.Mes5671.RequestI</IndexLocation>
<StreamLocation>^IHC.EAI.Uptime.Mes5671.RequestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}