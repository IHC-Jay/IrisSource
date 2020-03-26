Class IHC.EAI.Uptime.Process.Events Extends (Ens.BusinessProcess, Ens.Util.JSON, IHC.EAI.Log.Util)
{

Parameter LOGNAME = "EAI.Monitor";

Parameter SETTINGS = "TargetConfigName,ConfigDownURL:ConfigDownEvents,ConfigDownThrottle:ConfigDownEvents,ConfigDownEventTimeMinimum:ConfigDownEvents";

/// Target Config
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "IHC.EAI.Uptime.Operation.Events" ];

/// URL to PUT config down events
Property ConfigDownURL As %String [ InitialExpression = "/eai/UptimeEventsAPI/events/configdown/" ];

/// Number of minutes to throttle to PUT config down events out to the server<br/>
/// Used to help reduce amount of HTTP traffic this feature will utilize
Property ConfigDownThrottle As %Integer [ InitialExpression = 10 ];

/// Minimum total event time in seconds to qualify for storing config down event<br/>
/// This value 
Property ConfigDownEventTimeMinimum As %Integer [ InitialExpression = 300 ];

/// Handle monitor requests
Method OnRequest(
	pRequest As %Library.Persistent,
	Output pResponse As %Library.Persistent) As %Status
{
	Set tStatus = $$$OK
	Try {
		If (pRequest.%IsA("IHC.EAI.Uptime.Message.Request")) {
			If (pRequest.Name = "CheckEnsConfigItems") {
				// Call this every interval to check items in all relevant namespaces
				Set tStatus = ..CheckEnsConfigItems(pRequest)
				$$$ThrowOnError(tStatus)
				
				// Should we gather and send the events?
				Set tLastPUT = $GET(^EAI.Uptime("LastPUT"))
				Set tProcessEvents = 0
				If (tLastPUT '= "") {
					Set tLastPUTPlusThrottle = $System.SQL.DATEADD("mi",..ConfigDownThrottle,tLastPUT)
					Set tDateDiff = $System.SQL.DATEDIFF("mi",$ZDATETIME($HOROLOG,3),tLastPUTPlusThrottle)
					If (tDateDiff < 0) {
						// Time to process again
						Set tProcessEvents = 1	
					}
				} Else {
					Set tProcessEvents = 1	
				}
				
				If (tProcessEvents) {
					Set tStatus = ..ProcessConfigDownEvents(.tSuccess,.tMessage)
					$$$ThrowOnError(tStatus)
					If (tSuccess) {
						$$$LOGINFO(tMessage)
					} Else {
						// For now, just log warning
						$$$LOGWARNING(tMessage)	
					}
				}
				
				
			} Else {
				$$$ThrowStatus($$$ERROR($$$EnsErrRequestNotHandled, pRequest.Name))	
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EnsErrRequestNotHandled, pRequest.%ClassName(1)))
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Check all namespaces for down events
Method CheckEnsConfigItems(pRequest As IHC.EAI.Uptime.Message.Request) As %Status
{
	#Dim tDownEventsList As %ListOfDataTypes
	#Dim tPUTRequest As IHC.EAI.Uptime.Message.Request
	
	Set tStatus = $$$OK
	
	Try {
		
		Set tConfigDownEventsList = ##class(%ListOfDataTypes).%New()
		
		// Run for all namespaces
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		// Loop through namespace list
		Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE EnvironmentType = ? AND InstanceName = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceName)
		
		Set tIsFirst = 1
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
		
			Set tNamespace = tResultSet.%GetData(1)
			
			Set tStatus = ..CheckEnsConfigItemsForNamespace(tNamespace,.tConfigDownEventsList)
			$$$ThrowOnError(tStatus)
			
		}
		$$$ThrowOnError(tStatus)
		
		// Store the events to an EAI global
		For i=1:1:tConfigDownEventsList.Count() {
			Set tDownEvent = tConfigDownEventsList.GetAt(i)
			
			Set tCounter = $INCREMENT(^EAI.Uptime.DownEventCounter)
			Set ^EAI.Uptime.DownEvent(tDownEvent) = tDownEvent
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Process the queued up down events
Method ProcessConfigDownEvents(
	Output pSuccess As %Boolean = 0,
	Output pMessage As %String = "") As %Status
{
	#Dim tPUTResponse As IHC.EAI.KPI.Message.Response
	
	Set tStatus = $$$OK
	Try {
		
			Set tJSONStream = ##class(%Stream.GlobalCharacter).%New()
			Do tJSONStream.Write("[")
			
			Set tDownEventIndex = "", tFirstEntry = 1, tEventsToSendCount = 0
			For {
				Set tDownEventIndex = $ORDER(^EAI.Uptime.DownEvent(tDownEventIndex))
				Quit:(tDownEventIndex = "")
				
				Set tDownEventList = ^EAI.Uptime.DownEvent(tDownEventIndex)
				Set tName = $LISTGET(tDownEventList,1)
				Set tBusinessType = $LISTGET(tDownEventList,2)
				Set tNamespace = $LISTGET(tDownEventList,3)
				Set tStart = $LISTGET(tDownEventList,4)
				Set tEnd = $LISTGET(tDownEventList,5)
				Set tReason = $LISTGET(tDownEventList,6)
				
				// Ignore if less than minimum required to record event
				Set tTotalDiff = $System.SQL.DATEDIFF("s",tStart,tEnd)
				If (tTotalDiff >= ..ConfigDownEventTimeMinimum) {
				
					If ('tFirstEntry) {
						Do tJSONStream.Write(" , ")
					}
					Do tJSONStream.Write("{""ConfigName"": """)
					Do tJSONStream.Write(tName _ """,""Namespace"": """)
					Do tJSONStream.Write(tNamespace _ """,""BusinessType"": """)
					Do tJSONStream.Write(tBusinessType _ """,""DownStart"": """)
					Do tJSONStream.Write(tStart _ """,""DownEnd"": """)
					Do tJSONStream.Write(tEnd _ """,""Reason"": """)
					Do tJSONStream.Write(tReason _ """}")
					
					Set tFirstEntry = 0
					Set tEventsToSendCount = tEventsToSendCount + 1
				}
			}
			
			Do tJSONStream.Write("]")
			Do tJSONStream.Rewind()
			
			If (tEventsToSendCount > 0) {
				Set tPUTRequest = ##class(IHC.EAI.Uptime.Message.Request).%New()
				Set tPUTRequest.Name = "PUTConfigDownEvents"
				Do tPUTRequest.JSONStream.CopyFrom(tJSONStream)
				Set tPUTRequest.Command = "PUT"
				Set tPUTRequest.URL = ..ConfigDownURL
				
				Set tStatus = ..SendRequestSync(..TargetConfigName,.tPUTRequest,.tPUTResponse)
				$$$ThrowOnError(tStatus)
				
				// Analyze PUT response...clean up global on success
				If ($$$IsdefObject(tPUTResponse)) {
					Do tPUTResponse.JSONStream.Rewind()
					Set tConsumedJSON = ##class(%Library.DynamicAbstractObject).%FromJSON(tPUTResponse.JSONStream)
					Set pSuccess = tConsumedJSON.success
					Set pMessage = tConsumedJSON.message
					
					If (pSuccess) {
						Set ^EAI.Uptime("LastPUT") = $ZDATETIME($HOROLOG,3)
						Kill ^EAI.Uptime.DownEvent
					}
				} Else {
				Set pMessage = "Tried to send " _ tEventsToSendCount _ " events, but no successful response received."
			}
		} Else {
			Set pMessage = "No event messages found to send"
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Method CheckEnsConfigItemsForNamespace(
	pNamespace As %String,
	ByRef pConfigDownEventList As %ListOfDataTypes) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tProductionName = ##class(Ens.Director).GetActiveProductionName()
   		
   		Set tProduction = ##class(Ens.Config.Production).%OpenId(tProductionName,,.tStatus)
   		$$$ThrowOnError(tStatus)
		
		Set tProductionDefinition = ""
		Set tStatus = ##class(Ens.Director).getProductionItems(tProduction,.tProductionDefinition)
		$$$ThrowOnError(tStatus)
   			
		// Query and log
		Set tQuery = "SELECT Name,ClassName FROM Ens_Config.Item WHERE Production = ?" 
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tProductionName)
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tName = tResultSet.%GetData(1)
			Set tClassName = tResultSet.%GetData(2)
						
			Set tConfigBusinessType = tProductionDefinition(tName,"BusinessType")
			Set tConfigBusinessType = $CASE(tConfigBusinessType,
          							1:"BusinessService",
          							2:"BusinessProcess",
          							3:"BusinessOperation",
          							:"Unknown")
			
			Set tReason = ""
			
			// Get current status (host and adapter)
			Set tHostStatus = "", tJobStatus = ""
			Set tStatus = ##class(IHC.EAI.Uptime.Process.Events).GetConfigStatus(tName,.tHostStatus,.tJobStatus)
			$$$ThrowOnError(tStatus)
						
			Set tAnyJobsConnected = 0, tAnyJobsListening = 0, tAnyJobsDisconnected = 0
			If ((tConfigBusinessType = "BusinessService") || (tConfigBusinessType = "BusinessOperation")) {
				Set tStatus = ##class(IHC.EAI.Uptime.Process.Events).GetAdapterStatus(tName,.tAnyJobsConnected,.tAnyJobsListening,.tAnyJobsDisconnected)
				$$$ThrowOnError(tStatus)
			}
			
			Set tWasDown = $GET(^EAI.Uptime.Config(pNamespace,tName,"IsDown"))
			Set tRecordEvent = 0

			// Host and job status...
			// Update: ignore host status for now, worry about job only
			// If ((tHostStatus '= "OK") || ((tJobStatus '= "dequeuing") && (tJobStatus '= "running"))) {
			If (((tJobStatus '= "dequeuing") && (tJobStatus '= "running")) || (tHostStatus = "Retry")) {
				Set ^EAI.Uptime.Config(pNamespace,tName,"IsDown") = 1
				Set:($GET(^EAI.Uptime.Config(pNamespace,tName,"DownStart")) = "") ^EAI.Uptime.Config(pNamespace,tName,"DownStart") = $HOROLOG
				Set:(tJobStatus = "NF") ^EAI.Uptime.Config(pNamespace,tName,"Reason") = "DISABLED"
				Set:(tHostStatus = "Retry") ^EAI.Uptime.Config(pNamespace,tName,"Reason") = "RETRYING"
			} Else {
				Set ^EAI.Uptime.Config(pNamespace,tName,"IsDown") = 0	
				If (tWasDown) {
					Set ^EAI.Uptime.Config(pNamespace,tName,"DownEnd") = $HOROLOG
					Set tRecordEvent = 1
				}
			}
			Set ^EAI.Uptime.Config(pNamespace,tName,"HostStatus") = tHostStatus
			Set ^EAI.Uptime.Config(pNamespace,tName,"JobStatus") = tJobStatus
			
			If (((tConfigBusinessType = "BusinessService") || (tConfigBusinessType = "BusinessOperation")) &&
				 ($GET(^EAI.Uptime.Config(pNamespace,tName,"IsDown")) '= 1) &&
				 (tJobStatus '= "NF")) {
					 
					 
				Set tStatus = ..GetAdapterMeta(tProductionDefinition,tName,.tAdapterClassname,.tAdapterType,.tStayConnected)
				$$$ThrowOnError(tStatus)
												 
				// Adapter status...
				If ((tAdapterType = "TCP") || (tAdapterType = "FTP")) {
					If ((tAnyJobsDisconnected && tStayConnected) || 
						('tAnyJobsConnected && 'tAnyJobsListening && tStayConnected) ||
						(tAnyJobsListening && tStayConnected)) {
							Set ^EAI.Uptime.Config(pNamespace,tName,"IsDown") = 1
							Set:($GET(^EAI.Uptime.Config(pNamespace,tName,"DownStart")) = "") ^EAI.Uptime.Config(pNamespace,tName,"DownStart") = $HOROLOG
							Set ^EAI.Uptime.Config(pNamespace,tName,"DownEnd") = ""
							Set ^EAI.Uptime.Config(pNamespace,tName,"Reason") = "DISCONNECTED"
					} Else {
						// Presume running since we are connected at some level or don't need to be
						Set ^EAI.Uptime.Config(pNamespace,tName,"IsDown") = 0	
						If (tWasDown) {
							Set ^EAI.Uptime.Config(pNamespace,tName,"DownEnd") = $HOROLOG
							Set tRecordEvent = 1
						}
					}
				}
				
				Set ^EAI.Uptime.Config(pNamespace,tName,"AnyJobsConnected") = tAnyJobsConnected
				Set ^EAI.Uptime.Config(pNamespace,tName,"AnyJobsListening") = tAnyJobsListening
				Set ^EAI.Uptime.Config(pNamespace,tName,"AnyJobsDisconnected") = tAnyJobsDisconnected
			
			}
			
			Set:((tWasDown = "") || (tWasDown = 0)) tRecordEvent = 0
			
			If (tRecordEvent) {
				//Set tCounter = $INCREMENT(^EAI.Uptime.DownEventCounter)
				Set tConfigDownEventList = $LISTBUILD(tName,tConfigBusinessType,$NAMESPACE,
																$ZDT($GET(^EAI.Uptime.Config(pNamespace,tName,"DownStart")),3),
																$ZDT($GET(^EAI.Uptime.Config(pNamespace,tName,"DownEnd")),3),
																$GET(^EAI.Uptime.Config(pNamespace,tName,"Reason")))
				Set tStatus = pConfigDownEventList.Insert(tConfigDownEventList)
				$$$ThrowOnError(tStatus)
				
				// Clear times on global
				Set ^EAI.Uptime.Config(pNamespace,tName,"DownStart") = ""
				Set ^EAI.Uptime.Config(pNamespace,tName,"DownEnd") = ""
				Set ^EAI.Uptime.Config(pNamespace,tName,"Reason") = ""
			}
		}
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Method GatherDownEvents(
	pNamespace As %String,
	ByRef pDownList) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tKey = $ORDER(^EAI.Uptime.DownEvent(""))
		While (tKey '= "") {
			
			Set tValue = ^EAI.Uptime.DownEvent(tKey)
			Set pDownList(tKey) = tValue
			
			Set tKey = $ORDER(^EAI.Uptime.DownEvent(tKey))
		}
		
		Kill ^EAI.Uptime.DownEvent
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetAdapterStatus(
	pConfigName As %String = "",
	Output pAnyJobsConnected As %Boolean = 0,
	Output pAnyJobsListening As %Boolean = 0,
	Output pAnyJobsDisconnected As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		
		#; Count connected jobs for the given ConfigName
		Set tCountConnected = 0, tCountDisconnected = 0, tCountListening = 0
		Set tJob = "" 
		For { 
			Set tJob = $$$OrderHostMonitor(pConfigName,$$$eMonitorJob,tJob)
			Quit:(tJob = "")
			Set tConn = $EXTRACT($$$GetJobMonitor(pConfigName,tJob,$$$eMonitorConnected))
			If (tConn = 1) {
				Set tCountConnected = tCountConnected + 1
			} ElseIf (tConn = 0) {
				Set tCountDisconnected = tCountDisconnected + 1
			} ElseIf (tConn = ".") {
				Set tCountListening = tCountListening + 1
			}
		}
		
		If (tCountConnected > 0) {
			Set pAnyJobsConnected = 1	
		}
		If (tCountDisconnected > 0) {
			Set pAnyJobsDisconnected = 1
		}
		If (tCountListening > 0) {
			Set pAnyJobsListening = 1
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Host Status:
/// 	Error, OK, Retry
/// Job Status:
/// 		dequeuing, running
/// Do ##class(IHC.EAI.Test.Uptime).IsConfigRunning("Cern-Adt-Hl7_ConnectRx",.tHostStatus,.tJobStatus,.tConnectionState)
/// ADT>zw ^CacheTemp.EnsHostMonitor("ADT","Cern-Adt-Hl7_ConnectRx","%Status")
/// ^CacheTemp.EnsHostMonitor("ADT","Cern-Adt-Hl7_ConnectRx","%Status")="Error"
ClassMethod GetConfigStatus(
	pConfigName As %String = "",
	Output pHostStatus As %String,
	Output pJobStatus As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set pHostStatus = "", pJobStatus = ""
		Set pAreAnyConnected = 0, pAreAnyListening = 0, pAreAnyDisconnected = 0
		
		
		Quit:("" = pConfigName)
	
		Do ##class(Ens.Job).MarkDeadJobs()

		#; See if any running job is for the given ConfigName
		Set tIsRunning = 0, tJobStatus = "", tJob = ""
		
		For { 
			Set tJob = $ORDER($$$EnsJobStatus($$$SystemName,tJob))
			Quit:(tJob = "")
			Continue:(pConfigName '= $G($$$EnsJobStatus($$$SystemName,tJob,$$$eJobStartConfigName)))
			Set tJobStatus = $$$EnsJobStatus($$$SystemName,tJob,$$$eJobStatus)
			Set tIsRunning = '$G($$$EnsJobStatus($$$SystemName,tJob,$$$eJobIsDead))
			Quit:(tIsRunning)
		}
		
		Set pHostStatus = $$$GetHostMonitor(pConfigName,$$$eMonitorStatus)
		
		If (tJobStatus = "") {
			Set pJobStatus = "NF"	// Seems to be disabled?
		} Else {
			Set pJobStatus = tJobStatus
		}
		
		If (('tIsRunning) || pJobStatus = "NF") {
			Quit	
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetAdapterMeta(
	pProductionDefinition,
	pConfigName As %String,
	Output pAdapterClassname As %String = "",
	pAdapterType As %String = "",
	pStayConnected As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		// Adapter
		Set tConfigObj = ##class(Ens.Host).GetShadowInstance(pConfigName,.tStatus)
		$$$ThrowOnError(tStatus)
		
		If (tConfigObj.Adapter '= "") {
			Set pAdapterClassname = tConfigObj.Adapter.%ClassName(1)
			
			Set:($ZCONVERT(pAdapterClassname,"U") [ "FILE") pAdapterType = "FILE"
			Set:($ZCONVERT(pAdapterClassname,"U") [ "TCP") pAdapterType = "TCP"
			Set:($ZCONVERT(pAdapterClassname,"U") [ "FTP") pAdapterType = "FTP"
			Set:($ZCONVERT(pAdapterClassname,"U") [ "JAVAGATEWAY") pAdapterType = "JAVAGATEWAY"
			Set:($ZCONVERT(pAdapterClassname,"U") [ "EMAIL") pAdapterType = "EMAIL"
			Set:(pAdapterType = "") pAdapterType = "UNKNOWN"
			
			#; Production settings data
			Set pStayConnected = $GET(pProductionDefinition(pConfigName,"Setting","Adapter","StayConnected"),0)
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

Storage Default
{
<Data name="EventsDefaultData">
<Subscript>"Events"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
<Value name="2">
<Value>ConfigDownURL</Value>
</Value>
<Value name="3">
<Value>ConfigDownThrottle</Value>
</Value>
<Value name="4">
<Value>ConfigDownEventTimeMinimum</Value>
</Value>
</Data>
<DefaultData>EventsDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}