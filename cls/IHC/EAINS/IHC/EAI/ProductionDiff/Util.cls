Class IHC.EAI.ProductionDiff.Util Extends IHC.EAI.Log.Util
{

Parameter LOGNAME = "EAI.ProductionDiff";

Parameter FILEDIR = "/itf-admin/ensemble/diff";

ClassMethod DiffAll() As %Status {
	Set tStatus = $$$OK
	Try {
		
		// Run for all namespaces
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		Set tResultsFilename = tInstanceType _ "_" _ $TR($TR($ZDT($H,3)," ","_"),":","") _ ".txt"
		Set tFile = ##class(%File).NormalizeFilename(tResultsFilename,..#FILEDIR)
		Set tResultsFile = ##class(%File).%New(tFile)
		Do tResultsFile.Open("WSA",2)
		
		// Loop through namespace list
		Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE EnvironmentType = ? AND InstanceName = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceName)
		
		While (tResultSet.%Next(.tStatus)) {
			Set tNamespace = tResultSet.%GetData(1)
			Do tResultsFile.WriteLine("Namespace: " _ tNamespace)
			
			Set tStatus = ..ExportProductionDefinition(tNamespace,,.tNewDefId)
			$$$ThrowOnError(tStatus)
			
			Set tStatus = ..DiffResults(tNamespace,tNewDefId,.tResults)
			$$$ThrowOnError(tStatus)
			
			If (tResults '= "") {
				Do tResultsFile.WriteLine(tResults)
			}
		}
		$$$ThrowOnError(tStatus)
	
		Do tResultsFile.Close()
		Do tResultsFile.%Save()
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod DiffResults(pNamespace As %String,pNewDef As IHC.EAI.ProductionDiff.Schema.Definition,Output pResults As %String) As %Status {
	Set tStatus = $$$OK
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tCreatedOn = pNewDef.CreatedOn
		
		// Find the next oldest before pNewDefId
		Set SQLCODE = "", tOldDefId = ""
		DO $SYSTEM.SQL.SetSelectMode(0)
		&sql(SELECT %Id INTO :tOldDefId FROM IHC_EAI_ProductionDiff_Schema.Definition WHERE CreatedOn < :tCreatedOn)
		
		If ((SQLCODE = 0) && (tOldDefId '= "")) {
			// Found the next oldest entry. Do the compare and store the results
			Set tStatus = ..DiffProductionItems(tOldDefId,pNewDef.%Id(),.pResults)
			$$$ThrowOnError(tStatus)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	} Quit tStatus
}

/// Track production settings in db schema
/// If filename is defined, also push to file
/// Write ##class(IHC.EAI.ProductionDiff.Controller).ExportProductionDefinition()
ClassMethod ExportProductionDefinition(pNamespace As %String, pFilename As %String = "",Output pProductionDef As IHC.EAI.ProductionDiff.Schema.Definition) As %Status
{
	Set tStatus = $$$OK
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
	
		// Export the production settings for current namespace and push to the db (and possibly also file)
		Set tProductionName = ##class(Ens.Director).GetActiveProductionName()
		Set tProduction = ##class(Ens.Config.Production).%OpenId(tProductionName,,.tStatus)
		$$$ThrowOnError(tStatus)
		If $IsObject(tProduction) {
			// Export the current production to a stream
			Set tStatus = ##class(Ens.Util.XML.XDataEntityResolver).EntityFromXDATA(.tStream,tProduction.Name,"ProductionDefinition")
			$$$ThrowOnError(tStatus)
			
			// Create the db verson
			// Check the most recent. If day matches, overwrite. If not, create new.
			Set SQLCODE = "", tRecentProdDiff = ""
			&sql(SELECT TOP 1 %Id INTO :tRecentProdDiff FROM IHC_EAI_ProductionDiff_Schema.Definition ORDER BY ID Desc)
			
			Set tProductionDef = ""
			If ((SQLCODE = 0) && (tRecentProdDiff '= "")) {
				Set tProductionDefTemp = ##class(IHC.EAI.ProductionDiff.Schema.Definition).%OpenId(tRecentProdDiff,,.tStatus)
				$$$ThrowOnError(tStatus)
				
				Set tCreatedOnDate = $PIECE(tProductionDefTemp.CreatedOn," ",1)
				If (tCreatedOnDate = $PIECE($ZDT($H,3)," ",1)) {
					Set tProductionDef = tProductionDefTemp
				}
			}
			
			If (tProductionDef = "") {
				Set tProductionDef = ##class(IHC.EAI.ProductionDiff.Schema.Definition).%New()
				Set tProductionDef.Name = tProduction.Name
			}
			
			Set tProductionDef.CreatedOn = $ZDT($H,3)
			Set tProductionDef.Stream = ##class(%Stream.GlobalBinary).%New()
			Do tProductionDef.Stream.CopyFrom(tStream)
			Do tProductionDef.Stream.Rewind()
			Set tProductionDef.StreamHash = ##class(HS.IHE.Util).StreamHash(tProductionDef.Stream)
			Set tStatus = tProductionDef.%Save()
			$$$ThrowOnError(tStatus)
			
			Set pProductionDef = tProductionDef
			
			// Write to file
			If (pFilename '= "") {
				Do tStream.Rewind()
				Set tFileStream = ##class(%Stream.FileCharacter).%New()
				Set tFileStream.Filename = pFilename
				Do tFileStream.CopyFrom(tStream)
				Set tStatus = tFileStream.%Save()
				$$$ThrowOnError(tStatus)
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Write ##class(IHC.EAI.ProductionDiff.Controller).DiffProductionItems(1,2)
ClassMethod DiffProductionItems(pProductionDefinitionID1 As %String, pProductionDefinitionID2 As %String, Output pResults As %String, pVerbose As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tProdDef1TempFile = ##class(%Library.File).TempFilename()
		Set tProdDef2TempFile = ##class(%Library.File).TempFilename()
		Do:(##class(%File).Exists(tProdDef1TempFile)) ##class(%Library.File).Delete(tProdDef1TempFile)
		Do:(##class(%File).Exists(tProdDef1TempFile)) ##class(%Library.File).Delete(tProdDef2TempFile)
		
		// Create the temp files from the stream in the db
		Set tProdDef1 = ##class(IHC.EAI.ProductionDiff.Schema.Definition).%OpenId(pProductionDefinitionID1,,.tStatus)
		$$$ThrowOnError(tStatus)
		Set tProdDef1FileStream = ##class(%Stream.FileCharacter).%New()
		Set tProdDef1FileStream.Filename = tProdDef1TempFile
		Do tProdDef1FileStream.CopyFrom(tProdDef1.Stream)
		Set tStatus = tProdDef1.%Save()
		$$$ThrowOnError(tStatus)
		
		Set tProdDef2 = ##class(IHC.EAI.ProductionDiff.Schema.Definition).%OpenId(pProductionDefinitionID2,,.tStatus)
		$$$ThrowOnError(tStatus)
		Set tProdDef2FileStream = ##class(%Stream.FileCharacter).%New()
		Set tProdDef2FileStream.Filename = tProdDef2TempFile
		Do tProdDef2FileStream.CopyFrom(tProdDef2.Stream)
		Set tStatus = tProdDef1.%Save()
		$$$ThrowOnError(tStatus)
		
		// Run the diff on the two temp files and push it to the diff file
		Set tDiffTempFile = ##class(%Library.File).TempFilename()
		Do:(##class(%File).Exists(tDiffTempFile)) ##class(%Library.File).Delete(tDiffTempFile)
		
		Set tCmd = "diff -w -B --suppress-common-lines " _ tProdDef1TempFile _ " " _ tProdDef2TempFile _ " > " _ tDiffTempFile
	    Set tStat = $ZF(-1, tCmd)
		
		Set tDiffTempFileStream = ##class(%Stream.FileCharacter).%New()
		Set tStatus = tDiffTempFileStream.LinkToFile(tDiffTempFile)
		$$$ThrowOnError(tStatus)
		
		// Commit diffs to the db
		Set tProdDiffResults = ##class(IHC.EAI.ProductionDiff.Schema.Results).%New()
		Set tProdDiffResults.CreatedOn = $ZDT($H,3)
		Set tProdDiffResults.ProductionDefinition1 = tProdDef1
		Set tProdDiffResults.ProductionDefinition2 = tProdDef2
		Set tProdDiffResults.ResultsStream = ##class(%Stream.GlobalBinary).%New()
		Do tProdDiffResults.ResultsStream.CopyFrom(tDiffTempFileStream)
		Do tDiffTempFileStream.Rewind()
		Set tResultsText = ""
		While ('tDiffTempFileStream.AtEnd) {
			Set tLine = tDiffTempFileStream.Read()
			// Process the chunk here
			Set tResultsText = tResultsText _ tLine
		}
		Set:($LENGTH(tResultsText) = 0) tResultsText = "Production snapshots match"
		Set tProdDiffResults.ResultsText = tResultsText
		
		Set tStatus = tProdDiffResults.%Save()
		$$$ThrowOnError(tStatus)
		
		Write:(pVerbose) !, "Diff Results: ", !, tResultsText, !
		Set pResults = tResultsText
		
		// Cleanup diff temp file
		Set tSuccess = ##class(%Library.File).Delete(tDiffTempFile)
		If ('tSuccess) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to delete temp diff file: " _ tDiffTempFile))	
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}


/// Init this util<br/>
ClassMethod Init() As %Status {
	Set tStatus = $$$OK
	Try {
		
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"
		
		Set tTaskName = "Diff All Productions"
		Set SQLCODE = "", tCount = 0
		&sql(SELECT COUNT(*) INTO :tCount FROM %SYS.Task WHERE Name = :tTaskName)
		
		If (tCount = 0) {
			// If doesn't already exist, create
			Set tTask = ##class(%SYS.Task).%New()
			Set tTask.Name = tTaskName
			Set tTask.TaskClass = "IHC.EAI.ProductionDiff.Task.DiffAll"
			Set tTask.Description = "Diff the productions in all namespaces. Store the results."
			Set tTask.NameSpace = "EAI"
			Set tTask.TimePeriod = 0
			Set tStartTime = $PIECE($System.SQL.DATEADD("d",1,$ZDT($H,3))," ",1) _ " " _ "23:00:00"
			Set tTask.DailyStartTime = $ZTIMEH($PIECE(tStartTime," ",2))
			Set tStatus = tTask.%Save()
			$$$ThrowOnError(tStatus)
		}
		
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
