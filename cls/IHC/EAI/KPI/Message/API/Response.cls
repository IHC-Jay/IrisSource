Class IHC.EAI.KPI.Message.API.Response Extends (%Persistent, %XML.Adaptor, Ens.Util.ResponseBodyMethods)
{

Property RecordIdList As %String(MAXLEN = 200);

Property Message As %String(MAXLEN = 250);

Storage Default
{
<Data name="ResponseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RecordIdList</Value>
</Value>
<Value name="3">
<Value>Message</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI.MessaE02C.ResponseD</DataLocation>
<DefaultData>ResponseDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI.MessaE02C.ResponseD</IdLocation>
<IndexLocation>^IHC.EAI.KPI.MessaE02C.ResponseI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI.MessaE02C.ResponseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
