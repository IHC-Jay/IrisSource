Class IHC.EAI.KPI.Message.Request Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property Command As %String(MAXLEN = 4, VALUELIST = ",CONNECT,DELETE,GET,HEAD,OPTIONS,POST,PUT,TRACE");

Property JSONStream As %Stream.GlobalCharacter;

Property Name As %String(MAXLEN = 50);

Property URL As %String(MAXLEN = 1000);

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
<Value>JSONStream</Value>
</Value>
<Value name="4">
<Value>Name</Value>
</Value>
<Value name="5">
<Value>URL</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI.Message.RequestD</DataLocation>
<DefaultData>RequestDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI.Message.RequestD</IdLocation>
<IndexLocation>^IHC.EAI.KPI.Message.RequestI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI.Message.RequestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
