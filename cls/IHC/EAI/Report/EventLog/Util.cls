Class IHC.EAI.Report.EventLog.Util Extends IHC.EAI.Report.Util {

Parameter REPORTNAME = "EAI.Report.EventLog";

ClassMethod ReportErrorCodes(pNamespace As %String) As %Status {
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ##class(IHC.EAI.Report.EventLog.Util).ExtractErrorData(pNamespace)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(IHC.EAI.Report.EventLog.Util).PublishErrorCodeCounts(pNamespace)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ReportConfigErrors(pNamespace As %String) As %Status {
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ##class(IHC.EAI.Report.EventLog.Util).ExtractErrorData(pNamespace)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ##class(IHC.EAI.Report.EventLog.Util).PublishConfigErrorCounts(pNamespace)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod PublishErrorCodeCounts(pNamespace As %String, pWithDetails As %Boolean = 0) As %Status {
	Set tStatus = $$$OK
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tReportName = "ErrorCodes_" _ pNamespace
		
		Set tLine = $REVERSE($JUSTIFY($REVERSE("Namespace: " _ pNamespace),95))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		Set tLine = $REVERSE($JUSTIFY($REVERSE(""),95))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		Set tLine = $REVERSE($JUSTIFY($REVERSE("Error Code"),75)) _ $REVERSE($JUSTIFY($REVERSE("Count (Last 7 days)"),20))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		Set tLine = $REVERSE($JUSTIFY($REVERSE("--------------------------------------------------------------------------"),75)) _ $REVERSE($JUSTIFY($REVERSE("--------------------"),20))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		
		Set tErrorQuery =	"SELECT ErrorCode, COUNT(ErrorCode) AS ErrorCodeCount " _
							"FROM IHC_EAI_Report_EventLog_Data.ErrorCode " _
							"GROUP BY ErrorCode " _
							"ORDER BY ErrorCodeCount DESC"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = 2
		Set tStatus = tStatement.%Prepare(tErrorQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		While(tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tErrorCode = tResultSet.%GetData(1)
			Set tErrorCodeCount = tResultSet.%GetData(2)
			Set tLine = $REVERSE($JUSTIFY($REVERSE(tErrorCode),75)) _ $REVERSE($JUSTIFY($REVERSE(tErrorCodeCount),20))
			Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		}
		$$$ThrowOnError(tStatus)
		
		// Close the report
		Set tStatus = ..Report(.tReportFile,tReportName,,1)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod PublishConfigErrorCounts(pNamespace As %String, pWithDetails As %Boolean = 0) As %Status {
	Set tStatus = $$$OK
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tReportName = "ConfigErrorCounts_" _ pNamespace
		
		Set tLine = $REVERSE($JUSTIFY($REVERSE("Namespace: " _ pNamespace),95))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		Set tLine = $REVERSE($JUSTIFY($REVERSE(""),95))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		Set tLine = $REVERSE($JUSTIFY($REVERSE("Config Name"),75)) _ $REVERSE($JUSTIFY($REVERSE("Count (Last 7 days)"),20))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		Set tLine = $REVERSE($JUSTIFY($REVERSE("--------------------------------------------------------------------------"),75)) _ $REVERSE($JUSTIFY($REVERSE("--------------------"),20))
		Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		
		Set tErrorQuery =	"SELECT e.ConfigName, COUNT(e.%Id) AS ErrorConfigCount " _
							"FROM IHC_EAI_Report_EventLog_Data.Error e " _
							"GROUP BY e.ConfigName " _ 
							"ORDER BY ErrorConfigCount DESC"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = 2
		Set tStatus = tStatement.%Prepare(tErrorQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		While(tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tConfigName = tResultSet.%GetData(1)
			Set tErrorCodeCount = tResultSet.%GetData(2)
			Set tLine = $REVERSE($JUSTIFY($REVERSE(tConfigName),75)) _ $REVERSE($JUSTIFY($REVERSE(tErrorCodeCount),20))
			Set tStatus = ..Report(.tReportFile,tReportName,tLine) $$$ThrowOnError(tStatus)
		}
		$$$ThrowOnError(tStatus)
		
		// Close the report
		Set tStatus = ..Report(.tReportFile,tReportName,,1)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod PublishGeneralError(pNamespace As %String) As %Status {
	Set tStatus = $$$OK
	Try {
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		Set tReportName = "ConfigErrorCounts_" _ pNamespace
		
		Set tDistinctConfigQuery = "SELECT DISTINCT ConfigName FROM IHC_EAI_Report_EventLog_Data.Error"
		Set tDistinctConfigStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tDistinctConfigStatement.%Prepare(tDistinctConfigQuery)
		$$$ThrowOnError(tStatus)
		Set tDistinctConfigResultSet = tDistinctConfigStatement.%Execute()
		
		While (tDistinctConfigResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			Set tConfigName = tDistinctConfigResultSet.%GetData(1)
			
			CONTINUE:(tConfigName = "")
			
			Write !, "--------------------------------------------------------------------------------------------------------------"
			Write !, "Name: " _ tConfigName
			
			// Total Error Count
			Set SQLCODE = "", tErrorCount = 0
			&sql(SELECT COUNT(*) INTO :tErrorCount FROM IHC_EAI_Report_EventLog_Data.Error WHERE ConfigName = :tConfigName)
			If (SQLCODE '= 0) {
				$$$ThrowOnError($$$ERROR($$$GeneralError, "Failed to get total error count for " _ tConfigName))
			}
			
			Write !, "Error Count: " _ tErrorCount
			
			Write !,!, "Error Code Summary"
			Set tLine = $REVERSE($JUSTIFY($REVERSE("Code"),50)) _ $REVERSE($JUSTIFY($REVERSE("Count"),10)) _ $REVERSE($JUSTIFY($REVERSE("EventLogIds"),100))
			Write !, tLine
			
			Set tErrorCodeQuery = "SELECT DISTINCT ErrorCode FROM IHC_EAI_Report_EventLog_Data.ErrorCode WHERE Error->ConfigName = ?"
			Set tErrorCodeStatement = ##class(%SQL.Statement).%New()
			Set tStatus = tErrorCodeStatement.%Prepare(tErrorCodeQuery)
			$$$ThrowOnError(tStatus)
			Set tErrorCodeResultSet = tErrorCodeStatement.%Execute(tConfigName)
			
			While (tErrorCodeResultSet.%Next(.tStatus)) {
				$$$ThrowOnError(tStatus)
				
				Set tErrorCode = tErrorCodeResultSet.%GetData(1)
				Set SQLCODE = "", tErrorCodeCount = 0
				&sql(SELECT COUNT(*) INTO :tErrorCodeCount FROM IHC_EAI_Report_EventLog_Data.ErrorCode WHERE Error->ConfigName = :tConfigName AND ErrorCode = :tErrorCode)
				If (SQLCODE '= 0) {
					$$$ThrowOnError($$$ERROR($$$GeneralError, "Failed to get error code count for " _ tConfigName _ " code " _ tErrorCode))
				}
				
				Set tEventLogIds = ""
				Set tEventLogIdQuery = 	"SELECT DISTINCT EventLogId " _
										"FROM IHC_EAI_Report_EventLog_Data.Error AS e " _
											"INNER JOIN IHC_EAI_Report_EventLog_Data.ErrorCode AS ec ON ec.Error = e.%Id " _
										"WHERE " _
											"e.ConfigName = ? AND " _
											"ec.ErrorCode = ?"


				Set tEventLogIdStatement = ##class(%SQL.Statement).%New()
				Set tStatus = tEventLogIdStatement.%Prepare(tEventLogIdQuery)
				$$$ThrowOnError(tStatus)
				Set tEventLogIdResultSet = tEventLogIdStatement.%Execute(tConfigName,tErrorCode)
				
				While (tEventLogIdResultSet.%Next(.tStatus)) {
					$$$ThrowOnError(tStatus)
					
					Set tEventLogId = tEventLogIdResultSet.%GetData(1)
					If (tEventLogIds = "") {
						Set tEventLogIds = tEventLogId
					} Else {
						Set tEventLogIds = tEventLogIds _ "," _ tEventLogId
					}
				}
				$$$ThrowOnError(tStatus)
				
				Set tLine = $REVERSE($JUSTIFY($REVERSE(tErrorCode),50)) _ $REVERSE($JUSTIFY($REVERSE(tErrorCodeCount),10)) _ $REVERSE($JUSTIFY($REVERSE(tEventLogIds),100))
				Write !, tLine
			}
			$$$ThrowOnError(tStatus)
			
			Write !
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}


/// Do ##class(IHC.EAI.Report.EventLog.Util).ExtractErrorData()
ClassMethod ExtractErrorData(pNamespace As %String) As %Status {
	#Dim tEvent As Ens.Util.Log
	
	Set tStatus = $$$OK
	Try {
	
		New $NAMESPACE
		Set $NAMESPACE = pNamespace
		
		// Clear the previous data
		Set SQLCODE = ""
		&sql(DELETE FROM IHC_EAI_Report_EventLog_Data.Error)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to clear error data table."))
		}
		
		Set tStartDate = $System.SQL.DATEADD("d",-7,$ZDT($H,3))
		
		//Set tErrorQuery = "SELECT ID FROM Ens_Util.Log WHERE Type = 'Error'"
		Set tErrorQuery =	"SELECT %Id FROM Ens_Util.Log AS log " _
						 	"WHERE " _
						 		"log.Type = 'Error' AND " _
						 		"log.%Id >= (SELECT TOP 1 ID FROM Ens_Util.Log AS log1 WHERE log1.TimeLogged >= ? ORDER BY log1.TimeLogged ASC)"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = 2
		Set tStatus = tStatement.%Prepare(tErrorQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tStartDate)
		Set tIndex = 0
		While(tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tEventId = tResultSet.%GetData(1)
			
			Set tEvent = ##class(Ens.Util.Log).%OpenId(tEventId,,.tStatus)
			$$$ThrowOnError(tStatus)
			
			Set tError = ##class(IHC.EAI.Report.EventLog.Data.Error).%New()
			Set tError.EventLogId = tEvent.%Id()
			Set tError.MessageId = tEvent.MessageId
			Set tError.SessionId = tEvent.SessionId
			Set tError.ConfigName = tEvent.ConfigName
			Set tError.FullText = tEvent.Text
			Set tError.TimeLogged = tEvent.TimeLogged
			Set tStatus = tError.%Save()
			$$$ThrowOnError(tStatus)
			
			Set tTempText = tEvent.Text
			Set tSafetyCount = 0
			Do {
				Set tFindError = $FIND(tTempText,"ERROR <")
				If (tFindError) {
					// Found code(s) with <
					Set tStartPos = tFindError - $LENGTH("ERROR <")
					Set tNewTempText = $EXTRACT(tTempText,tStartPos,$LENGTH(tTempText))
					Set tErrorCode = $PIECE(tNewTempText,":",1)
					Set tErrorCodeObj = ##class(IHC.EAI.Report.EventLog.Data.ErrorCode).%New()
					Set tErrorCodeObj.Error = tError
					Set tErrorCodeObj.ErrorCode = tErrorCode
					Set tStatus = tErrorCodeObj.%Save()
					$$$ThrowOnError(tStatus)
					Set tTempText = $REPLACE(tTempText,tErrorCode,"")
				}
				Set tSafetyCount = tSafetyCount + 1
				Quit:(tSafetyCount > 0)
			} While (tFindError '= 0)
			
			Set tTempText = tEvent.Text
			Set tSafetyCount = 0
			Do {
				Set tFindError = $FIND(tTempText,"ERROR #")
				
				If (tFindError) {
					// Found code(s) with <
					Set tStartPos = tFindError - $LENGTH("ERROR #")
					Set tNewTempText = $EXTRACT(tTempText,tStartPos,$LENGTH(tTempText))
					Set tErrorCode = $PIECE(tNewTempText,":",1)
					Set tErrorCode2 = $PIECE(tNewTempText,":",2)
					Set tSubCodeExtract = $EXTRACT(tErrorCode2,0,3)
					If (tSubCodeExtract = "101") {
						Set tErrorCode = tErrorCode _ ":" _ $PIECE(tErrorCode2,": ","1")
					}
					Set tErrorCodeObj = ##class(IHC.EAI.Report.EventLog.Data.ErrorCode).%New()
					Set tErrorCodeObj.Error = tError
					Set tErrorCodeObj.ErrorCode = tErrorCode
					Set tStatus = tErrorCodeObj.%Save()
					$$$ThrowOnError(tStatus)
					Set tTempText = $REPLACE(tTempText,tErrorCode,"")
				}
				Set tSafetyCount = tSafetyCount + 1
				Quit:(tSafetyCount > 0)
			} While (tFindError '= 0)
			
			Set tTempText = tEvent.Text
			Set tSafetyCount = 0
			Do {
				Set tFindError = $FIND(tTempText,"<ZJGTW>")
				
				If (tFindError) {
					// Found code(s) with <
					Set tStartPos = tFindError - $LENGTH("<ZJGTW>")
					Set tNewTempText = $EXTRACT(tTempText,tStartPos,$LENGTH(tTempText))
					Set tErrorCode = $PIECE(tNewTempText,";",1)
					Set tErrorCodeObj = ##class(IHC.EAI.Report.EventLog.Data.ErrorCode).%New()
					Set tErrorCodeObj.Error = tError
					Set tErrorCodeObj.ErrorCode = tErrorCode
					Set tStatus = tErrorCodeObj.%Save()
					$$$ThrowOnError(tStatus)
					Set tTempText = $REPLACE(tTempText,tErrorCode,"")
				}
				Set tSafetyCount = tSafetyCount + 1
				Quit:(tSafetyCount > 0)
			} While (tFindError '= 0)
			
			
			Set tIndex = tIndex + 1
		}
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
