Class IHC.EAI.Report.CompSettings.Controller Extends IHC.EAI.Report.Util
{

/// Do ##class(IHC.EAI.Report.CompSettings.Controller).RunReport()<br/>
/// Params<br/>
///  pNamespace - 
ClassMethod RunReport(pNamespace As %String = "", pConfigName As %String = "", pBusinessType As %String = "", pSetting As %String = "", pValue As %String = "", pReportName As %String = "EAI.Settings.Report", pDelimiter As %String = {$C(9)}) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	
	Set tStatus = $$$OK
	Try {
		
		If (pNamespace = "") {
			// Run for all namespaces
			Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType)
			$$$ThrowOnError(tStatus)
			
			// Loop through namespace list
			Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE Environment = ? AND InstanceType = ?"
			Set tStatement = ##class(%SQL.Statement).%New()
			Set tStatus = tStatement.%Prepare(tQuery)
			$$$ThrowOnError(tStatus)
			Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceType)
			
			While (tResultSet.%Next(.tStatus)) {
				$$$ThrowOnError(tStatus)	
				
				Set tNamespace = tResultSet.%GetData(1)
				
				Set tStatus = ..RunForNamespace(.tReportFile,tNamespace,pConfigName,pBusinessType,pSetting,pValue,pDelimiter)
				$$$ThrowOnError(tStatus)
			}
			$$$ThrowOnError(tStatus)
		} Else {
			// Run for single namespace
			Set tStatus = ..RunForNamespace(.tReportFile,pNamespace,pConfigName,pBusinessType,pSetting,pValue,pDelimiter)
			$$$ThrowOnError(tStatus)
		}
		
		// Close the report
		Set tStatus = ..Report(.tReportFile,,1)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod RunForNamespace(ByRef pReportFile As %File, pNamespace As %String, pConfigName As %String = "", pBusinessType As %String = "", pSetting As %String = "", pValue As %String = "", pDelimiter As %String = {$C(9)}) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = pNamespace

		// Clean out the report data table
		Set tStatus = ..ClearExistingData()
		$$$ThrowOnError(tStatus)
		
		// Extract and load ens production setting data into DB tables
		Set tStatus = ..ExtractData()
		$$$ThrowOnError(tStatus)

		// Write out to report file
		Set tStatus = ..WriteReport(.pReportFile,pConfigName,pBusinessType,pSetting,pValue,pDelimiter)
		$$$ThrowOnError(tStatus)

	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.Report.CompSettings.Controller).ExtractData()
ClassMethod ExtractData() As %Status
{
	Set tStatus = $$$OK
	Try {
		// Report-level info
		Set tCreatedOn = $ZDATETIME($H,3)
		
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
				Set tConfigBusinessType = $CASE(tConfigBusinessType,
              							1:"BusinessService",
              							2:"BusinessProcess",
              							3:"BusinessOperation",
              							:"Unknown")
	   			
	   			Set tClassName = tProductionDefinition(tConfigName,"ClassName")
	   			Set tConfigItemId = tProductionDefinition(tConfigName,"%Id")
	   			
				// Analyze static settings for this component/config item
				Set tConfigItem = ##class(Ens.Config.Item).%OpenId(tConfigItemId,,.tStatus)
				$$$ThrowOnError(tStatus)
				
				// Process static settings
				Set tStatus = tConfigItem.GetStaticSettings(.tStaticSettings)
				$$$ThrowOnError(tStatus)
				
				If ($DATA(tStaticSettings) = 10) {
					Set tSettingIndex = ""
					For {
						Set tSettingIndex = $ORDER(tStaticSettings(tSettingIndex))
						Quit:(tSettingIndex = "")
						
						Set tSettingList = tStaticSettings(tSettingIndex)
						Set tSettingName = $LG(tSettingList,2)
						
						// Grab the value
						Set tCurrentValue = $LG(tSettingList,3)
						
						// Notes
						Set tNotes = ""
						
						Set tStatus = ##class(IHC.EAI.Report.CompSettings.Data).CreateItem(
													tProductionName,tConfigName,tConfigBusinessType,
													tSettingName,tCurrentValue,tNotes,tCreatedOn)
						$$$ThrowOnError(tStatus)
					} // end For
				} // End if $DATA(tStaticSettings) = 10
				Kill tStaticSettings
				
				// Process host settings
				Set tStatus = ##class(Ens.Director).GetHostSettings(tConfigName,.tHostSettings)
				$$$ThrowOnError(tStatus)
					
				If ($DATA(tHostSettings) = 10) {
					Set tSettingName = ""
					For {
						Set tSettingName = $ORDER(tHostSettings(tSettingName))
						Quit:(tSettingName = "")

						Set tCurrentValue = tHostSettings(tSettingName)
						
						// Notes
						Set tNotes = ""
						
						Set tStatus = ##class(IHC.EAI.Report.CompSettings.Data).CreateItem(
													tProductionName,tConfigName,tConfigBusinessType,
													tSettingName,tCurrentValue,tNotes,tCreatedOn)
						$$$ThrowOnError(tStatus)
					} // End For
				} // End $DATA(tHostSettings) = 10
				Kill tHostSettings
				
				// Process adapter settings
				Set tStatus = ##class(Ens.Director).GetAdapterSettings(tConfigName,.tAdapterSettings)
				$$$ThrowOnError(tStatus)
					
				If ($DATA(tAdapterSettings) = 10) {
					Set tSettingName = ""
					For {
						Set tSettingName = $ORDER(tAdapterSettings(tSettingName))
						Quit:(tSettingName = "")

						Set tCurrentValue = tAdapterSettings(tSettingName)
						
						// Notes
						Set tNotes = ""
						
						Set tStatus = ##class(IHC.EAI.Report.CompSettings.Data).CreateItem(
													tProductionName,tConfigName,tConfigBusinessType,
													tSettingName,tCurrentValue,tNotes,tCreatedOn)
						$$$ThrowOnError(tStatus)
					} // End For
				} // End $DATA(tAdapterSettings) = 10
				Kill tAdapterSettings
				
			} // End For
   		} // End $DATA(tProductionDefinition) = 10
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.Report.CompSettings.Controller).ClearExistingData()
ClassMethod ClearExistingData() As %Status
{
	Set tStatus = $$$OK
	Try {
		// Clear existing report data
		Set SQLCODE = ""
		&sql(DELETE FROM IHC_EAI_Report_CompSettings.Data)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to clear report data."))	
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod WriteReport(ByRef pReportFile As %File, pConfigName As %String = "", pBusinessType As %String = "", pSetting As %String = "", pValue As %String = "", pDelimiter As %String = {$C(9)}) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	
	Set tStatus = $$$OK
	Try {
		
		Set tNamespace = $NAMESPACE
			
		Set tQuery = 	"SELECT Production,ConfigName,BusinessType,Setting,Value,CreatedOn,Notes " _
						"FROM IHC_EAI_Report_CompSettings.Data"
		Set tWhereClause = ""
		If ((pConfigName '= "") || (pBusinessType '= "") || (pSetting '= "") || (pValue '= "")) {
			If (pConfigName '= "") {
				Set tWhereClause = " ConfigName = '" _ pConfigName _ "'"
			}
			
			If (pBusinessType '= "") {
				If (tWhereClause '= "") {
					Set tWhereClause = tWhereClause _ " AND BusinessType = '" _ pBusinessType _ "'"
				} Else {
					Set tWhereClause = " BusinessType = '" _ pBusinessType _ "'"
				}	
			}
			
			If (pSetting '= "") {
				If (tWhereClause '= "") {
					Set tWhereClause = tWhereClause _ " AND Setting = '" _ pSetting _ "'"
				} Else {
					Set tWhereClause = " Setting = '" _ pSetting _ "'"
				}	
			}
			
			If (pValue '= "") {
				If (tWhereClause '= "") {
					Set tWhereClause = tWhereClause _ " AND Value = '" _ pValue _ "'"
				} Else {
					Set tWhereClause = " Value = '" _ pValue _ "'"
				}	
			}
		}
		
		If (tWhereClause '= "") {
			Set tQuery = tQuery _ " WHERE" _ tWhereClause	
		}
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tProduction = tResultSet.%GetData(1)
			Set tConfigName = tResultSet.%GetData(2)
			Set tBusinessType = tResultSet.%GetData(3)
			Set tSetting = tResultSet.%GetData(4)
			Set tValue = tResultSet.%GetData(5)
			Set tCreatedOn = tResultSet.%GetData(6)
			Set tNotes = tResultSet.%GetData(7)
			
			Set tLine = tNamespace _ pDelimiter _ tProduction _ pDelimiter _ tConfigName _ 
						pDelimiter _ tBusinessType _ pDelimiter _ tSetting _ pDelimiter _ tValue _ 
						pDelimiter _ tCreatedOn _ pDelimiter _ tNotes

			Set tStatus = ..Report(.pReportFile,tLine)
			$$$ThrowOnError(tStatus)
		}
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
