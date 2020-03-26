Class IHC.EAI.Sync.Util Extends IHC.EAI.Common.Util {

ClassMethod GetSSLConfigs(Output pStatus As %Status = { $$$OK }) As %DynamicArray {
	
	Set tSSLConfigs = []
	Try {
	
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"
		
		Set tCall = "Call Security.SSLConfigs_ListNames()"
		Set tStatement = ##class(%SQL.Statement).%New()
  		Set pStatus = tStatement.%Prepare(tCall)
  		$$$ThrowOnError(pStatus)
  		Set tResultSet = tStatement.%Execute()
  		While tResultSet.%Next(.pStatus) {
			$$$ThrowOnError(pStatus)
			
			Set tSSLConfigName = tResultSet.%Get("Name")
			
			Set tConfigObj = {}
			
			Set pStatus = ##class(Security.SSLConfigs).Get(tSSLConfigName,.tProperties)
			$$$ThrowOnError(pStatus)
			
			Set tConfigObj.Name = tSSLConfigName
			Set tConfigObj.CAFile = tProperties("CAFile")
			Set tConfigObj.CAPath = tProperties("CAPath")
			Set tConfigObj.CRLFile = tProperties("CRLFile")
			Set tConfigObj.CertificateFile = tProperties("CertificateFile")
			Set tConfigObj.CipherList = tProperties("CipherList")
			Set tConfigObj.Description = tProperties("Description")
			Set tConfigObj.Enabled = tProperties("Enabled")
			Set tConfigObj.PrivateKeyFile = tProperties("PrivateKeyFile")
			Set tConfigObj.PrivateKeyPassword = tProperties("PrivateKeyPassword")
			Set tConfigObj.PrivateKeyType = tProperties("PrivateKeyType")
			Set tConfigObj.Protocols = tProperties("Protocols")
			Set tConfigObj.Type = tProperties("Type")
			Set tConfigObj.VerifyDepth = tProperties("VerifyDepth")
			Set tConfigObj.VerifyPeer = tProperties("VerifyPeer")
			
			Do tSSLConfigs.%Push(tConfigObj)
			
		}
		$$$ThrowOnError(pStatus)
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tSSLConfigs
}

ClassMethod DeleteSSLConfigs() As %Status {
	
	Set tStatus = $$$OK
	Try {
	
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"
		
		Set tCall = "Call Security.SSLConfigs_ListNames()"
		Set tStatement = ##class(%SQL.Statement).%New()
  		Set tStatus = tStatement.%Prepare(tCall)
  		$$$ThrowOnError(tStatus)
  		Set tResultSet = tStatement.%Execute()
  		While tResultSet.%Next(.tStatus) {
			$$$ThrowOnError(tStatus)
			
			Set tSSLConfigName = tResultSet.%Get("Name")
			
			Set tStatus = ##class(Security.SSLConfigs).Delete(tSSLConfigName)
			$$$ThrowOnError(tStatus)
		}
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod CreateSSLConfig(pName As %String, pProperties) As %Status {
	
	Set tStatus = $$$OK
	Try {
	
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"
		
		Set tStatus = ##class(Security.SSLConfigs).Create(pName,.pProperties)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetBackupMemberInfo(Output pBackupMemberList As %ListOfDataTypes) As %Status {
	Set tStatus = $$$OK
	Try {
		Set pBackupMemberList = ##class(%ListOfDataTypes).%New()
	
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"

		Set tMirrorName = ##class(Config.Mirrors).GetMirrorName()
		
		Set tResultSet = ##class(%ResultSet).%New("SYS.Mirror:MemberStatusList")
		Set tStatus = tResultSet.Execute()
		$$$ThrowOnError(tStatus)
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			Set tName = tResultSet.%Get("MemberName")
			Set tRole = tResultSet.%Get("CurrentRole")
			If ((tRole = "Backup") || (tRole = "Async")) {
			
				Set tStatus = ##class(Config.MapMirrors).Get(tMirrorName,tName,.tProperties)
				$$$ThrowOnError(tStatus)
				
				Set tMirrorAddress = tProperties("MirrorAddress")
				
				Set tWebServerPort = ..GetWebServerPort(tMirrorAddress,.tStatus)
				$$$ThrowOnError(tStatus)
				
				Set tListItem = tMirrorAddress _ "|" _ tWebServerPort
				Do pBackupMemberList.Insert(tListItem)
			}
		}
		$$$ThrowOnError(tStatus)
		Kill tResultSet
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetWebServerPort(pPhysicalHost As %String, Output pStatus As %Status = { $$$OK }) As %Integer {
	Set tWebServerPort = ""
	Try {
		New $NAMESPACE
		Set $NAMESPACE = "EAI"
		
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		Set tQuery = 	"SELECT PhysicalPort " _
						"FROM IHC_EAI_System_Data.Instance " _ 
						"WHERE EnvironmentType = ? AND InstanceType = ? AND PhysicalHost = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tEnvironment,InstanceType,pPhysicalHost)
		
		If (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tWebServerPort = tResultSet.%GetData(1)
		}
		$$$ThrowOnError(pStatus)
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tWebServerPort
}

}