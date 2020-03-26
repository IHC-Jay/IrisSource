Class IHC.EAI.ProductionDiff.Schema.Results Extends %Persistent
{

Property CreatedOn As %TimeStamp [ Required ];

Property ProductionDefinition1 As IHC.EAI.ProductionDiff.Schema.Definition [ Required ];

Property ProductionDefinition2 As IHC.EAI.ProductionDiff.Schema.Definition [ Required ];

Property ResultsText As %String(MAXLEN = "") [ Required ];

Property ResultsStream As %Stream.GlobalBinary [ Required ];

Index iCreatedOn On CreatedOn;

Index iProductionDefs On (ProductionDefinition1, ProductionDefinition2);

Storage Default
{
<Data name="ResultsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CreatedOn</Value>
</Value>
<Value name="3">
<Value>ProductionDefinition1</Value>
</Value>
<Value name="4">
<Value>ProductionDefinition2</Value>
</Value>
<Value name="5">
<Value>ResultsText</Value>
</Value>
<Value name="6">
<Value>ResultsStream</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Production26BC.ResultsD</DataLocation>
<DefaultData>ResultsDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Production26BC.ResultsD</IdLocation>
<IndexLocation>^IHC.EAI.Production26BC.ResultsI</IndexLocation>
<StreamLocation>^IHC.EAI.Production26BC.ResultsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
