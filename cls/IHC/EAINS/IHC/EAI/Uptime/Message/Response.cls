Class IHC.EAI.Uptime.Message.Response Extends (%Persistent, %XML.Adaptor, Ens.Util.ResponseBodyMethods)
{

Property JSONStream As %Stream.GlobalCharacter;

Property AdditionalInfo As array Of %String;

Storage Default
{
<Data name="AdditionalInfo">
<Attribute>AdditionalInfo</Attribute>
<Structure>subnode</Structure>
<Subscript>"AdditionalInfo"</Subscript>
</Data>
<Data name="ResponseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>JSONStream</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Uptime.Me5671.ResponseD</DataLocation>
<DefaultData>ResponseDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Uptime.Me5671.ResponseD</IdLocation>
<IndexLocation>^IHC.EAI.Uptime.Me5671.ResponseI</IndexLocation>
<StreamLocation>^IHC.EAI.Uptime.Me5671.ResponseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}