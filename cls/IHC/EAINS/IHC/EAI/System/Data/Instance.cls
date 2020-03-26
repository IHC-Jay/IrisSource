Include EAI.Common

Class IHC.EAI.System.Data.Instance Extends (%Persistent, %Populate, %XML.Adaptor)
{

/// The instance name
Property Name As %String(MAXLEN = 50);

/// The type of node<br>
///  Interface = Where the interfaces run<br/>
///  Server = Message bank or any instance other than one that runs interfaces
Property NodeType As %String(MAXLEN = 50, VALUELIST = ",INTERFACE,SERVER");

/// The instance type
Property InstanceType As %String(MAXLEN = 50);

/// The instance type
Property EnvironmentType As %String(MAXLEN = 50);

/// The physical host/server address
Property PhysicalHost As %String(MAXLEN = 50);

/// The physical host/server port
Property PhysicalPort As %Integer;

/// The virtual host/server address
Property VirtualHost As %String(MAXLEN = 50);

/// The virtual host/server port
Property VirtualPort As %Integer;

/// The server host/server address (the EAI NS on the message bank, generally)
Property ServerHost As %String(MAXLEN = 50);

/// The virtual host/server port
Property ServerPort As %Integer;

ClassMethod Init(pReset As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		#; Check if any entries already exists
		Set SQLCODE = "", tRecordCount = 0
		&sql(SELECT COUNT(%Id) INTO :tRecordCount FROM IHC_EAI_System_Data.Instance)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed to count Instance table"))	
		}
		
		Quit:((pReset = 0) && (tRecordCount > 0))
		
		#; Clear all
		Set SQLCODE = ""
		&sql(DELETE FROM IHC_EAI_System_Data.Instance)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError,"Failed to clear Instance table"))	
		}
		
		#; SANDBOX
		// Sandbox nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "EAISANDBOX"
		Set tInstance.InstanceType = $$$InstanceType5
		Set tInstance.EnvironmentType = "SANDBOX"
		Set tInstance.PhysicalHost = "lpv-itfdev02"
		Set tInstance.PhysicalPort = "26975"
		Set tInstance.VirtualHost = ""
		Set tInstance.VirtualPort = ""
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "DEVSANDBOX"
		Set tInstance.InstanceType = $$$InstanceType5
		Set tInstance.EnvironmentType = "SANDBOX"
		Set tInstance.PhysicalHost = "lpv-itfdev01"
		Set tInstance.PhysicalPort = "26975"
		Set tInstance.VirtualHost = ""
		Set tInstance.VirtualPort = ""
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		#; DEV
		// Interface nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINDEV01"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfdev01"
		Set tInstance.PhysicalPort = "26972"
		Set tInstance.VirtualHost = "lp-itfdevvp1"
		Set tInstance.VirtualPort = "26972"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		// Interface nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINDEV02"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfdev02"
		Set tInstance.PhysicalPort = "26972"
		Set tInstance.VirtualHost = "lp-itfdevvp1"
		Set tInstance.VirtualPort = "26972"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERDEV01"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfdev01"
		Set tInstance.PhysicalPort = "26973"
		Set tInstance.VirtualHost = "lp-itfdevvp2"
		Set tInstance.VirtualPort = "26973"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERDEV02"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfdev02"
		Set tInstance.PhysicalPort = "26973"
		Set tInstance.VirtualHost = "lp-itfdevvp2"
		Set tInstance.VirtualPort = "26973"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERDEV01"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfdev01"
		Set tInstance.PhysicalPort = "26974"
		Set tInstance.VirtualHost = "lp-itfdevvp3"
		Set tInstance.VirtualPort = "26974"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERDEV02"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfdev02"
		Set tInstance.PhysicalPort = "26974"
		Set tInstance.VirtualHost = "lp-itfdevvp3"
		Set tInstance.VirtualPort = "26974"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		// Server nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "MSGBKDEV"
		Set tInstance.InstanceType = $$$InstanceType4
		Set tInstance.EnvironmentType = "DEV"
		Set tInstance.PhysicalHost = "lp-itfuatfs01"
		Set tInstance.PhysicalPort = "24972"
		Set tInstance.VirtualHost = ""
		Set tInstance.VirtualPort = ""
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24972"
		Set tInstance.NodeType = "SERVER"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		#; QA
		// Interface nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINQA01"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfqa01"
		Set tInstance.PhysicalPort = "25972"
		Set tInstance.VirtualHost = "lp-itfqavp1"
		Set tInstance.VirtualPort = "25972"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINQA02"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfqa02"
		Set tInstance.PhysicalPort = "25972"
		Set tInstance.VirtualHost = "lp-itfqavp1"
		Set tInstance.VirtualPort = "25972"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERQA01"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfqa01"
		Set tInstance.PhysicalPort = "25973"
		Set tInstance.VirtualHost = "lp-itfqavp2"
		Set tInstance.VirtualPort = "25973"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERQA02"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfqa02"
		Set tInstance.PhysicalPort = "25973"
		Set tInstance.VirtualHost = "lp-itfqavp2"
		Set tInstance.VirtualPort = "25973"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERQA01"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfqa01"
		Set tInstance.PhysicalPort = "25974"
		Set tInstance.VirtualHost = "lp-itfqavp3"
		Set tInstance.VirtualPort = "25974"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERQA02"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfqa02"
		Set tInstance.PhysicalPort = "25974"
		Set tInstance.VirtualHost = "lp-itfqavp3"
		Set tInstance.VirtualPort = "25974"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		// Server nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "MSGBKQA"
		Set tInstance.InstanceType = $$$InstanceType4
		Set tInstance.EnvironmentType = "QA"
		Set tInstance.PhysicalHost = "lp-itfuatfs01"
		Set tInstance.PhysicalPort = "24973"
		Set tInstance.VirtualHost = ""
		Set tInstance.VirtualPort = ""
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24973"
		Set tInstance.NodeType = "SERVER"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		#; UAT
		// Interface nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINUATLP01"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuat01"
		Set tInstance.PhysicalPort = "24972"
		Set tInstance.VirtualHost = "lp-itfuatvp1"
		Set tInstance.VirtualPort = "24972"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINUATLP02"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuat02"
		Set tInstance.PhysicalPort = "24972"
		Set tInstance.VirtualHost = "lp-itfuatvp1"
		Set tInstance.VirtualPort = "24972"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERUATLP01"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuat01"
		Set tInstance.PhysicalPort = "24973"
		Set tInstance.VirtualHost = "lp-itfuatvp2"
		Set tInstance.VirtualPort = "24973"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERUATLP02"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuat02"
		Set tInstance.PhysicalPort = "24973"
		Set tInstance.VirtualHost = "lp-itfuatvp2"
		Set tInstance.VirtualPort = "24973"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERUATLP01"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuat01"
		Set tInstance.PhysicalPort = "24974"
		Set tInstance.VirtualHost = "lp-itfuatvp3"
		Set tInstance.VirtualPort = "24974"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERUATLP02"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuat02"
		Set tInstance.PhysicalPort = "24974"
		Set tInstance.VirtualHost = "lp-itfuatvp3"
		Set tInstance.VirtualPort = "24974"
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		// Server nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "MSGBKUAT"
		Set tInstance.InstanceType = $$$InstanceType4
		Set tInstance.EnvironmentType = "UAT"
		Set tInstance.PhysicalHost = "lp-itfuatfs01"
		Set tInstance.PhysicalPort = "24974"
		Set tInstance.VirtualHost = ""
		Set tInstance.VirtualPort = ""
		Set tInstance.ServerHost = "lp-itfuatfs01"
		Set tInstance.ServerPort = "24974"
		Set tInstance.NodeType = "SERVER"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		#; PRD
		// Interface nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINPRDLP01"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprd01"
		Set tInstance.PhysicalPort = "23972"
		Set tInstance.VirtualHost = "lp-itfprdvp1"
		Set tInstance.VirtualPort = "23972"
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "CLINPRDLP02"
		Set tInstance.InstanceType = $$$InstanceType1
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprd02"
		Set tInstance.PhysicalPort = "23972"
		Set tInstance.VirtualHost = "lp-itfprdvp1"
		Set tInstance.VirtualPort = "23972"
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERPRDLP01"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprd01"
		Set tInstance.PhysicalPort = "23973"
		Set tInstance.VirtualHost = "lp-itfprdvp2"
		Set tInstance.VirtualPort = "23973"
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PAYERPRDLP02"
		Set tInstance.InstanceType = $$$InstanceType2
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprd02"
		Set tInstance.PhysicalPort = "23973"
		Set tInstance.VirtualHost = "lp-itfprdvp2"
		Set tInstance.VirtualPort = "23973"
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERPRDLP01"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprd01"
		Set tInstance.PhysicalPort = "23974"
		Set tInstance.VirtualHost = "lp-itfprdvp3"
		Set tInstance.VirtualPort = "23974"
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "PROVIDERPRDLP02"
		Set tInstance.InstanceType = $$$InstanceType3
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprd02"
		Set tInstance.PhysicalPort = "23974"
		Set tInstance.VirtualHost = "lp-itfprdvp3"
		Set tInstance.VirtualPort = "23974"
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "INTERFACE"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
		// Server nodes
		Set tInstance = ##class(IHC.EAI.System.Data.Instance).%New()
		Set tInstance.Name = "MSGBKPRD"
		Set tInstance.InstanceType = $$$InstanceType4
		Set tInstance.EnvironmentType = "PROD"
		Set tInstance.PhysicalHost = "lp-itfprdfs01"
		Set tInstance.PhysicalPort = "23972"
		Set tInstance.VirtualHost = ""
		Set tInstance.VirtualPort = ""
		Set tInstance.ServerHost = "lp-itfprdfs01"
		Set tInstance.ServerPort = "23972"
		Set tInstance.NodeType = "SERVER"
		Set tStatus = tInstance.%Save()
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Storage Default
{
<Data name="InstanceDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>NodeType</Value>
</Value>
<Value name="4">
<Value>InstanceType</Value>
</Value>
<Value name="5">
<Value>EnvironmentType</Value>
</Value>
<Value name="6">
<Value>PhysicalHost</Value>
</Value>
<Value name="7">
<Value>PhysicalPort</Value>
</Value>
<Value name="8">
<Value>VirtualHost</Value>
</Value>
<Value name="9">
<Value>VirtualPort</Value>
</Value>
<Value name="10">
<Value>ServerHost</Value>
</Value>
<Value name="11">
<Value>ServerPort</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.System.Data.InstanceD</DataLocation>
<DefaultData>InstanceDefaultData</DefaultData>
<IdLocation>^IHC.EAI.System.Data.InstanceD</IdLocation>
<IndexLocation>^IHC.EAI.System.Data.InstanceI</IndexLocation>
<StreamLocation>^IHC.EAI.System.Data.InstanceS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
