Class IHC.EAI.HL7.Schema.Util Extends IHC.EAI.Common.Util {

/// Write ##class(IHC.EAI.HL7.Schema.Util).RefreshSchemas()
ClassMethod RefreshSchemas(pNamespace As %String = "") As %Status {
	Set tStatus = $$$OK
	Try {
		
		// Run from EAI NS
		If ($NAMESPACE '= "EAI") {
			New $NAMESPACE
			Set $NAMESPACE = "EAI"
		}
		
		Set tStatus = ##class(IHC.EAI.System.Data.Namespace).Init(1)
		$$$ThrowOnError(tStatus)
		
		If (pNamespace '= "") {
			Set tStatus = ..ExportImport(pNamespace,1)
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
			$$$ThrowOnError(tStatus)
			
			Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE EnvironmentType = ? AND InstanceName = ?"
			Set tStatement = ##class(%SQL.Statement).%New()
			Set tStatus = tStatement.%Prepare(tQuery)
			$$$ThrowOnError(tStatus)
			Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceName)
			
			Set tIsFirst = 1
			While (tResultSet.%Next(.tStatus)) {
				$$$ThrowOnError(tStatus)
				
				Set tNamespace = tResultSet.%GetData(1)
				Write !, "Refreshing namespace: " _ tNamespace
				Set tStatus = ..ExportImport(tNamespace,1)
				$$$ThrowOnError(tStatus)
				Write !
			}
			$$$ThrowOnError(tStatus)
		}
	
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Write ##class(IHC.EAI.HL7.Schema.Util).ExportImport()
ClassMethod ExportImport(
	pNamespace As %String,
	pCustomOnly As %Boolean = 1,
	pExportDir As %String = "/tmp/",
	pPurgeTempFiles As %Boolean = 1) As %Status {
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tTypeCategories = ""
		If (pCustomOnly) {
			Set tStatus = ##class(EnsLib.HL7.Schema).TypeCategoriesExecute(.tTypeCategories,"+")
			$$$ThrowOnError(tStatus)
		} Else {
			Set tStatus = ##class(EnsLib.HL7.Schema).TypeCategoriesExecute(.tTypeCategories)
			$$$ThrowOnError(tStatus)
		}
		
		If ($DATA(tTypeCategories) = 11) {
			Set tKey = $ORDER(tTypeCategories("ver",""))
			
			While (tKey '= "") {
				Set tTypeCategory = tTypeCategories("ver",tKey)
				
				//Write !, "Category: " _ tTypeCategory
				Set tSchemaFile = ##class(%FileCharacterStream).%New()
				Set tFilename = pExportDir _ tTypeCategory _ "_" _ $NAMESPACE _ "_" _ 
											$REPLACE($REPLACE($REPLACE($ZDT($H,3)," ",""),":",""),"-","") _ ".HL7"
				Set tSchemaFile.Filename = tFilename
				
				// Export
				Write !, "Exporting schema: " _ tTypeCategory
				Set tStatus = ##class(EnsLib.HL7.SchemaXML).Export(tTypeCategory,tSchemaFile)
				$$$ThrowOnError(tStatus)
				
				// Re-Import
				Write !, "Importing file: " _ tFilename
				Set tStatus = ##class(EnsLib.HL7.SchemaXML).Import(tFilename,.tCatImported)
				$$$ThrowOnError(tStatus)
				
				If (pPurgeTempFiles) {
					// Remove after import
					Kill tSchemaFile
					Do ##class(%File).Delete(tFilename)
				}
				Set tKey = $ORDER(tTypeCategories("ver",tKey))
			}
		
		} Else {
			// TypeCategoriesExecute didn't return anything
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}