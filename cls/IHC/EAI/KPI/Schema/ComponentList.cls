Class IHC.EAI.KPI.Schema.ComponentList Extends (%Persistent, %XML.Adaptor)
{

/// Namespace where the instance of the component is running
Property Namespace As %String [ Required ];

/// The configured name of the component
Property ConfigName As %String [ Required ];

/// Options:
/// 	0 = Whitelist
/// 	1 = Blacklist
/// 	2 = Other
Property ListType As %Integer [ Required ];

/// KPI class name
Property KPI As %String(MAXLEN = 150);

Property BusinessType As %String(MAXLEN = 50, VALUELIST = ",BusinessService,BusinessProcess,BusinessOperation");

Index iUnique On (Namespace, ConfigName, ListType);

/// Do ##class(IHC.EAI.KPI.Schema.ComponentList).CreateDefaults()
ClassMethod CreateDefaults() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set SQLCODE = ""
		&sql(DELETE FROM IHC_EAI_KPI_Schema.ComponentList)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to clear component list. SQLCODE = " _ SQLCODE))	
		}
		
		Set tItem = ##class(IHC.EAI.KPI.Schema.ComponentList).%New()
		Set tItem.Namespace = "All"
		Set tItem.ConfigName = "HddInterfaceWebserviceOperation"
		Set tItem.ListType = 1
		Set tItem.KPI = "IHC.EAI.KPI.Controller.TransactionCount"
		Set tItem.BusinessType = "BusinessOperation"
		Set tStatus = tItem.%Save()
		
		Set tItem = ##class(IHC.EAI.KPI.Schema.ComponentList).%New()
		Set tItem.Namespace = "All"
		Set tItem.ConfigName = "Out-APE-Alert-REST"
		Set tItem.ListType = 1
		Set tItem.KPI = "IHC.EAI.KPI.Controller.TransactionCount"
		Set tItem.BusinessType = "BusinessOperation"
		Set tStatus = tItem.%Save()
		
		Set tItem = ##class(IHC.EAI.KPI.Schema.ComponentList).%New()
		Set tItem.Namespace = "All"
		Set tItem.ConfigName = "PagerAlert"
		Set tItem.ListType = 1
		Set tItem.KPI = "IHC.EAI.KPI.Controller.TransactionCount"
		Set tItem.BusinessType = "BusinessOperation"
		Set tStatus = tItem.%Save()
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Storage Default
{
<Data name="ComponentListDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Namespace</Value>
</Value>
<Value name="3">
<Value>ConfigName</Value>
</Value>
<Value name="4">
<Value>ListType</Value>
</Value>
<Value name="5">
<Value>KPI</Value>
</Value>
<Value name="6">
<Value>BusinessType</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI8839.ComponentListD</DataLocation>
<DefaultData>ComponentListDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI8839.ComponentListD</IdLocation>
<IndexLocation>^IHC.EAI.KPI8839.ComponentListI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI8839.ComponentListS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
