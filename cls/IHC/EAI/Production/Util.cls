Class IHC.EAI.Production.Util Extends %RegisteredObject
{

ClassMethod ConfigStart(pConfigName As %String, pDoUpdate As %Boolean = 1) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Do ##class(Ens.Director).EnableConfigItem(pConfigName,1,pDoUpdate)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ConfigStop(pConfigName As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tTimeout = $GET(^EAI.Production.Util("UpdateTimeout"),10)
		
		Set tStatus = ##class(Ens.Director).EnableConfigItem(pConfigName,0,0)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(Ens.Director).UpdateProduction(tTimeout,1)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ConfigRestart(pConfigName As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tTimeout = $GET(^EAI.Production.Util("UpdateTimeout"),10)
	
		Set tStatus = ##class(Ens.Director).EnableConfigItem(pConfigName,0,0)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(Ens.Director).UpdateProduction(tTimeout,1)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(Ens.Director).EnableConfigItem(pConfigName,1,0)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(Ens.Director).UpdateProduction(tTimeout,1)
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ConfigUpdate(ByRef pProduction As Ens.Config.Production, pConfigName As %String, pSettingName As %String, pSettingValue As %String, pDoUpdate As %Boolean = 1, pDisable As %Boolean = 0) As %Status
{
	#Dim tConfigItem As Ens.Config.Item
	
	Set tStatus = $$$OK
	Try {
		
		Set tConfigItem = pProduction.FindItemByConfigName(pConfigName,.tStatus)
		$$$ThrowOnError(tStatus)
		Set tAdapterClassName = tConfigItem.AdapterClassName()
		
		Set tWasEnabled = 0
		If (pDisable && tWasEnabled) {
			// Disable the component before making the changes
			Set tStatus = ..ConfigStop(pConfigName,0)
			$$$ThrowOnError(tStatus)
		}
		
		// Check static settings
		Set tStatus = tConfigItem.GetStaticSettings(.tStaticSettings)
		$$$ThrowOnError(tStatus)
		
		Set tPropertySet = 0
		If ($DATA(tStaticSettings) = 10) {
			Set tSettingIndex = ""
			For {
				Set tSettingIndex = $ORDER(tStaticSettings(tSettingIndex))
				If ((tSettingIndex = "") && (tPropertySet = 0)) {
					Quit
				}

				Set tSettingName = $LISTGET(tStaticSettings(tSettingIndex),2)
				
				// We'll never change these...
				If (($ZCONVERT(tSettingName,"U") = "CLASSNAME") || ($ZCONVERT(tSettingName,"U") = "DESCRIPTION") || 
					($ZCONVERT(tSettingName,"U") = "ADAPTERCLASSNAME") || ($ZCONVERT(tSettingName,"U") = "ADAPTERDESCRIPTION")) {
					CONTINUE
				}
				
				If (tSettingName = pSettingName) {
					Set tCurrentValue = $PROPERTY(tConfigItem,tSettingName)
	
					If (tCurrentValue '= pSettingValue) {
						Set $PROPERTY(tConfigItem,tSettingName) = pSettingValue
						Set tPropertySet = 1
					}
				}
			} // End For
		} // End $DATA(tItemSettings) = 10
		
		If (tPropertySet = 0) {
			// Check host settings
			Set tSetting = tConfigItem.FindSettingByName(pSettingName,"Host")

			If $IsObject(tSetting) {
				If (tSetting.Value '= pSettingValue) {
					Set tSetting.Value = pSettingValue
					Set tPropertySet = 1
				}
			} Else {
				Set tSetting = ##class(Ens.Config.Setting).%New()
				Set tSetting.Name = pSettingName
				Set tSetting.Target = "Host"
				Set tSetting.Value = pSettingValue
				Do tConfigItem.Settings.Insert(tSetting)
				Set tPropertySet = 1
			}
		}
		
		If ((tPropertySet = 0) && (tAdapterClassName '= "")) {
			// Check host settings
			Set tSetting = tConfigItem.FindSettingByName(pSettingName,"Adapter")

			If $IsObject(tSetting) {
				If (tSetting.Value '= pSettingValue) {
					Set tSetting.Value = pSettingValue
					Set tPropertySet = 1
				}
			} Else {
				Set tSetting = ##class(Ens.Config.Setting).%New()
				Set tSetting.Name = pSettingName
				Set tSetting.Target = "Adapter"
				Set tSetting.Value = pSettingValue
				Do tConfigItem.Settings.Insert(tSetting)
				Set tPropertySet = 1
			}
		}
		
		// Hide behind boolean?
		If (tPropertySet) {
			Set tStatus = tConfigItem.%Save()
			$$$ThrowOnError(tStatus)
		}
		
		If (pDisable && tWasEnabled) {
			// Re-enable
			Set tStatus = ..ConfigStart(pConfigName,0)
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Take action on config items based on JSON instructions
ClassMethod ConfigActionByJSONList(pJSON As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		/* *** SAMPLE JSON ***
		Set pJSON = "{""action"": ""update"",""setting"": ""QueueCountAlert"",""value"": 1000,""configItems"": [""Op-Cdr-CHECKMMI0"",""Op-Cdr-CHECKMMI1""," _ 
			"""Op-Cdr-CHECKMMI2"",""Op-Cdr-CHECKMMI3"",""Op-Cdr-CHECKMMI4"",""Op-Cdr-CHECKMMI5"",""Op-Cdr-CHECKMMI6"",""Op-Cdr-CHECKMMI7"",""Op-Cdr-CHECKMMI8"",""Op-Cdr-CHECKMMI9""]}"
		*/
		
		Set tObj = ##class(%DynamicAbstractObject).%FromJSON(pJSON)
		
		Set tAction = tObj.action
		Set tSettingName = tObj.setting
		Set tSettingValue = tObj.value
		
		// Get the production
		Set tProductionName = ##class(Ens.Director).GetActiveProductionName()
	
		Set tProduction = ##class(Ens.Config.Production).%OpenId(tProductionName,,.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set tDoUpdate = 0, tDoSave = 0
		Set tConfigArray = tObj.configItems
		Set tIterator = tConfigArray.%GetIterator()
		While (tIterator.%GetNext(.tKey,.tConfigName)) {
			
			If ($ZCONVERT(tAction,"U") = "UPDATE") {
				// Update
				Set tStatus = ..ConfigUpdate(.tProduction,tConfigName,tSettingName,tSettingValue,0,1)
				$$$ThrowOnError(tStatus)
				Set tDoUpdate = 1
			} ElseIf ($ZCONVERT(tAction,"U") = "START") {
				// Start
				Set tStatus = ..ConfigStart(tConfigName,0)
				$$$ThrowOnError(tStatus)
				Set tDoUpdate = 1
			} ElseIf ($ZCONVERT(tAction,"U") = "STOP") {
				// Stop
				Set tStatus = ..ConfigStop(tConfigName,0)
				$$$ThrowOnError(tStatus)
				Set tDoUpdate = 1
			} ElseIf ($ZCONVERT(tAction,"U") = "RESTART") {
				// Restart
				Set tStatus = ..ConfigRestart(tConfigName,0)
				$$$ThrowOnError(tStatus)
				Set tDoUpdate = 1
			}
		}
		
		If (tDoUpdate) {
			Set tTimeout = $GET(^EAI.Production.Util("UpdateTimeout"),30)
			Set tStatus = ##class(Ens.Director).UpdateProduction(tTimeout,1)
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.Production.Util).RestartBusinessServices("[NS]") <br>
/// Lists are pipe-delimited
ClassMethod RestartBusinessServices(pNamespace As %String, pAffectedAdaptersList As %String, pDisableOnlyList As %String = "") As %Status
{
	Set tStatus = $$$OK, tRestartCount = 0, tStopOnlyCount = 0
	Try {
		
		Set pAffectedAdaptersList = "|EnsLib.HL7.Adapter.TCPInboundAdapter|EnsLib.TCP.FramedInboundAdapter|EnsLib.SOAP.InboundAdapter|EnsLib.HTTP.InboundAdapter|"
		Set pDisableOnlyList = "|In-Cern-OrdLab-Hl7tcp|In-Ord-Hl7-BRIDGE-Ens-FROM-EgLab-Sunquest|"
		
		New $Namespace
		Set $Namespace = pNamespace
		
		Write !, "Starting script: " _ $ZDT($H,3)
		Write !, "Processing " _ pNamespace _ " namespace"
		
		Set tProductionName = ##class(Ens.Director).GetActiveProductionName()
   		
   		Set tProduction = ##class(Ens.Config.Production).%OpenId(tProductionName,,.tStatus)
   		$$$ThrowOnError(tStatus)
   		
   		Set tStatus = ##class(Ens.Director).getProductionItems(tProduction,.tProductionDefinition)
   		$$$ThrowOnError(tStatus)
   		If ($DATA(tProductionDefinition) = 10) {
	   		Set tConfigName = ""
			For { 
				Set tConfigName = $ORDER(tProductionDefinition(tConfigName))
				Quit:(tConfigName = "")
				
				Set tConfigBusinessType = tProductionDefinition(tConfigName,"BusinessType")
				
				If (tConfigBusinessType = 1) {
					// Business service - is enabled?
					
					Set tConfigItemId = tProductionDefinition(tConfigName,"%Id")
					
					Set tConfigItem = ##class(Ens.Config.Item).%OpenId(tConfigItemId,,.tStatus)
					$$$ThrowOnError(tStatus)
					
					If (tConfigItem.Enabled) {
						// Is enabled
						
						If ($ZCONVERT(tConfigName,"U") [ "ISERIES") {
							// Is iSeries...skip
							CONTINUE	
						} Else {
						
							Set tClassName = tProductionDefinition(tConfigName,"ClassName")
							Set tAdapter = $CLASSMETHOD(tClassName,"%GetParameter","ADAPTER")
							
							//Write !, tClassName _ ":" _ tAdapter
							
							If (pAffectedAdaptersList [ tAdapter) {
								// Affected adaper
								
								If (pDisableOnlyList [ tConfigName) {
									Write !, "Stopping: " _ tConfigName
									Set tStatus = ..ConfigStop(tConfigName)
									$$$ThrowOnError(tStatus)
									Set tStopOnlyCount = tStopOnlyCount + 1
								} Else {
									// Restart config
									Write !, "Restarting: " _ tConfigName
									Set tStatus = ..ConfigRestart(tConfigName)
									$$$ThrowOnError(tStatus)
									Set tRestartCount = tRestartCount + 1
								}
							}
						}
					}
				}
			}
   		}
   		
   		Write !,!, "Restarted:" _ tRestartCount _ "|Stopped:" _ tStopOnlyCount, !
		Write !, "Stopping script: " _ $ZDT($H,3)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
