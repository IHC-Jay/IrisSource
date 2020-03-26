Include Ensemble

Class IHC.EAI.System.Data.Namespace Extends (%Persistent, %Populate, %XML.Adaptor)
{

/// The namespace name
Property Namespace As %String(MAXLEN = 50);

/// The name of the instance
Property InstanceName As %String(MAXLEN = 50);

/// The environment
Property EnvironmentType As %String(MAXLEN = 4);

Index iMain On (Namespace, InstanceName, EnvironmentType) [ IdKey ];

/// Do ##class(IHC.EAI.System.Data.Namespace).Init()
ClassMethod Init(pReset As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		#; Check if any entries already exists
		Set SQLCODE = "", tRecordCount = 0
		&sql(SELECT COUNT(%Id) INTO :tRecordCount FROM IHC_EAI_System_Data.Namespace)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed to count Namespace table"))	
		}
		
		Quit:((pReset = 0) && (tRecordCount > 0))
		
		#; Clear all
		Set SQLCODE = ""
		&sql(DELETE FROM IHC_EAI_System_Data.Namespace)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed to clear Instance table"))	
		}
		
		#; DEV
		Set tStatus = ..InitClin("DEV","CLINDEV01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitClin("DEV","CLINDEV02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("DEV","PAYERDEV01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("DEV","PAYERDEV02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("DEV","PROVIDERDEV01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("DEV","PROVIDERDEV02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitMSGBANK("DEV","MSGBKDEV")
		$$$ThrowOnError(tStatus)
		
		#; QA
		Set tStatus = ..InitClin("QA","CLINQA01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitClin("QA","CLINQA02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("QA","PAYERQA01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("QA","PAYERQA02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("QA","PROVIDERQA01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("QA","PROVIDERQA02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitMSGBANK("QA","MSGBKQA")
		$$$ThrowOnError(tStatus)
		
		#; UAT
		Set tStatus = ..InitClin("UAT","CLINUATLP01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitClin("UAT","CLINUATLP02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("UAT","PAYERUATLP01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("UAT","PAYERUATLP02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("UAT","PROVIDERUATLP01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("UAT","PROVIDERUATLP02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitMSGBANK("UAT","MSGBKUAT")
		$$$ThrowOnError(tStatus)
		
		#; PROD
		Set tStatus = ..InitClin("PROD","CLINPRDLP01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitClin("PROD","CLINPRDLP02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("PROD","PAYERPRDLP01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitPayer("PROD","PAYERPRDLP02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("PROD","PROVIDERPRDLP01")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitProvider("PROD","PROVIDERPRDLP02")
		$$$ThrowOnError(tStatus)
		Set tStatus = ..InitMSGBANK("PROD","MSGBKPRD")
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod InitClin(pEnvironmentType As %String, pInstanceName As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "ADT"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "ADTIN"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "ADTLEGACY"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "ADTMISC"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "BILLING"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "DEMOGRAPHICS"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "LAB"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "MISC"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "ORDERS"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "RESULTS"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod InitPayer(pEnvironmentType As %String, pInstanceName As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "PAYER"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod InitProvider(pEnvironmentType As %String, pInstanceName As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
		Set tNamespace.Namespace = "PROVIDER"
		Set tNamespace.InstanceName = pInstanceName
		Set tNamespace.EnvironmentType = pEnvironmentType
		Set tStatus = tNamespace.%Save()
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod InitMSGBANK(pEnvironmentType As %String, pInstanceName As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		//MSGBK
		If (pEnvironmentType = "DEV") {
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGCLIN"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPAYER"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPROV"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
		} ElseIf (pEnvironmentType = "QA") {
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGCLIN"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPAYER"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPROV"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
		} ElseIf (pEnvironmentType = "UAT") {
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGCLIN"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPAYER"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPROV"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
		} ElseIf (pEnvironmentType = "PROD") {
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGCLIN"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPAYER"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = ##class(IHC.EAI.System.Data.Namespace).%New()
			Set tNamespace.Namespace = "MSGPROV"
			Set tNamespace.InstanceName = pInstanceName
			Set tNamespace.EnvironmentType = pEnvironmentType
			Set tStatus = tNamespace.%Save()
			$$$ThrowOnError(tStatus)
			
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Storage Default
{
<Data name="NamespaceDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.System.Data.NamespaceD</DataLocation>
<DefaultData>NamespaceDefaultData</DefaultData>
<IdLocation>^IHC.EAI.System.Data.NamespaceD</IdLocation>
<IndexLocation>^IHC.EAI.System.Data.NamespaceI</IndexLocation>
<StreamLocation>^IHC.EAI.System.Data.NamespaceS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
