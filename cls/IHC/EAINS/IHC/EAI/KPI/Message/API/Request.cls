Class IHC.EAI.KPI.Message.API.Request Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

Property JSONStream As %Stream.GlobalCharacter;

Property Name As %String(MAXLEN = 50);

Storage Default
{
<Data name="RequestDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>JSONStream</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI.MessagE02C.RequestD</DataLocation>
<DefaultData>RequestDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI.MessagE02C.RequestD</IdLocation>
<IndexLocation>^IHC.EAI.KPI.MessagE02C.RequestI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI.MessagE02C.RequestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
