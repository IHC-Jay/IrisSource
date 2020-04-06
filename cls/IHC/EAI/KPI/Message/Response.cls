Class IHC.EAI.KPI.Message.Response Extends (%Persistent, %XML.Adaptor, Ens.Util.ResponseBodyMethods)
{

Property JSONStream As %Stream.GlobalCharacter;

Storage Default
{
<Data name="ResponseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>JSONStream</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI.Message.ResponseD</DataLocation>
<DefaultData>ResponseDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI.Message.ResponseD</IdLocation>
<IndexLocation>^IHC.EAI.KPI.Message.ResponseI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI.Message.ResponseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
