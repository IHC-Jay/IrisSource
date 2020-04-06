Class IHC.EAI.Report.CompSettings.Data Extends (%Persistent, %Populate, %XML.Adaptor)
{

Property Production As %String;

Property ConfigName As %String(MAXLEN = 100);

Property BusinessType As %String(MAXLEN = 50);

Property Setting As %String(MAXLEN = 100);

Property Value As %String(MAXLEN = 1000);

Property Notes As %String(MAXLEN = 500);

Property CreatedOn As %TimeStamp;

Index iConfigName On ConfigName;

Index iBusinessType On BusinessType;

Index iSetting On Setting;

ClassMethod CreateItem(pProduction As %String, pConfigName As %String, pBusinessType As %String, pSetting As %String, pValue As %String, pNotes As %String, pCreatedOn As %TimeStamp) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tItem = ##class(IHC.EAI.Report.CompSettings.Data).%New()
		Set tItem.Production = pProduction
		Set tItem.ConfigName = pConfigName
		Set tItem.BusinessType = pBusinessType
		Set tItem.Setting = pSetting
		Set tItem.Value = pValue
		Set tItem.Notes = pNotes
		Set tItem.CreatedOn = pCreatedOn
		
		Set tStatus = tItem.%Save()
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Storage Default
{
<Data name="DataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Production</Value>
</Value>
<Value name="3">
<Value>ConfigName</Value>
</Value>
<Value name="4">
<Value>BusinessType</Value>
</Value>
<Value name="5">
<Value>Setting</Value>
</Value>
<Value name="6">
<Value>Value</Value>
</Value>
<Value name="7">
<Value>Notes</Value>
</Value>
<Value name="8">
<Value>CreatedOn</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Report.CompSeC9FA.DataD</DataLocation>
<DefaultData>DataDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Report.CompSeC9FA.DataD</IdLocation>
<IndexLocation>^IHC.EAI.Report.CompSeC9FA.DataI</IndexLocation>
<StreamLocation>^IHC.EAI.Report.CompSeC9FA.DataS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
