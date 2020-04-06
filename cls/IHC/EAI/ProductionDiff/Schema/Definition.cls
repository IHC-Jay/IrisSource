Class IHC.EAI.ProductionDiff.Schema.Definition Extends %Persistent
{

Property Name As %String(MAXLEN = 150) [ Required ];

Property CreatedOn As %TimeStamp [ Required ];

Property Stream As %Stream.GlobalBinary [ Required ];

Property StreamHash As %String(MAXLEN = 250) [ Required ];

Index iCreatedOn On CreatedOn;

Storage Default
{
<Data name="DefinitionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>CreatedOn</Value>
</Value>
<Value name="4">
<Value>Stream</Value>
</Value>
<Value name="5">
<Value>StreamHash</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Product26BC.DefinitionD</DataLocation>
<DefaultData>DefinitionDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Product26BC.DefinitionD</IdLocation>
<IndexLocation>^IHC.EAI.Product26BC.DefinitionI</IndexLocation>
<StreamLocation>^IHC.EAI.Product26BC.DefinitionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
