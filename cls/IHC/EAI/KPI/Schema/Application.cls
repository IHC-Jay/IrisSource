Class IHC.EAI.KPI.Schema.Application Extends (%Persistent, %Populate, %XML.Adaptor)
{

Property Name As %String(MAXLEN = 50) [ Required ];

/// ##class(IHC.EAI.KPI.Schema.Application).CreateDefaults()
ClassMethod Init(pReset As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		#; Check if any entries already exists
		Set SQLCODE = "", tRecordCount = 0
		&sql(SELECT COUNT(%Id) INTO :tRecordCount FROM IHC_EAI_KPI_Schema.Application)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed to count Application table"))	
		}
		
		Quit:((pReset = 0) && (tRecordCount > 0))
		
		#; Clear all
		Set SQLCODE = ""
		&sql(DELETE FROM IHC_EAI_KPI_Schema.Application)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed to clear Application table"))	
		}
		
		Set tApp = ##class(IHC.EAI.KPI.Schema.Application).%New()
		Set tApp.Name = "Ensemble"
		Do tApp.%Save()
		
		Set tApp = ##class(IHC.EAI.KPI.Schema.Application).%New()
		Set tApp.Name = "EdifecsSh"
		Do tApp.%Save()
		
		Set tApp = ##class(IHC.EAI.KPI.Schema.Application).%New()
		Set tApp.Name = "EdifecsRco"
		Do tApp.%Save()
		
		Set tApp = ##class(IHC.EAI.KPI.Schema.Application).%New()
		Set tApp.Name = "eGate"
		Do tApp.%Save()
		
		Set tApp = ##class(IHC.EAI.KPI.Schema.Application).%New()
		Set tApp.Name = "BizTalk"
		Do tApp.%Save()
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Index iName On Name [ IdKey, Unique ];

Storage Default
{
<Data name="ApplicationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI.Sc8839.ApplicationD</DataLocation>
<DefaultData>ApplicationDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI.Sc8839.ApplicationD</IdLocation>
<IndexLocation>^IHC.EAI.KPI.Sc8839.ApplicationI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI.Sc8839.ApplicationS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
