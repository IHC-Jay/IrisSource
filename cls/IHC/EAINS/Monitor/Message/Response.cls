Class IHC.EAI.Monitor.Message.Response Extends (%Persistent, %XML.Adaptor, Ens.Util.ResponseBodyMethods)
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
<DataLocation>^IHC.EAI.Monitor.MEF8D.ResponseD</DataLocation>
<DefaultData>ResponseDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Monitor.MEF8D.ResponseD</IdLocation>
<IndexLocation>^IHC.EAI.Monitor.MEF8D.ResponseI</IndexLocation>
<StreamLocation>^IHC.EAI.Monitor.MEF8D.ResponseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
