Class IHC.EAI.Common.Message.EmailResponse Extends (%Persistent, %XML.Adaptor, Ens.Util.ResponseBodyMethods)
{

Property FailedRecipients As %ListOfDataTypes;

Storage Default
{
<Data name="EmailResponseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FailedRecipients</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Comm3656.EmailResponseD</DataLocation>
<DefaultData>EmailResponseDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Comm3656.EmailResponseD</IdLocation>
<IndexLocation>^IHC.EAI.Comm3656.EmailResponseI</IndexLocation>
<StreamLocation>^IHC.EAI.Comm3656.EmailResponseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
