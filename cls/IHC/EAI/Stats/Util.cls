Class IHC.EAI.Stats.Util Extends %RegisteredObject {

/// Do ##class(IHC.EAI.Stats.Util).ExtractAllConfigInactivityStats()
ClassMethod ExtractAllConfigInactivityStats(pConfigBusinessType As %Integer = 1) As %Status {
	Set tStatus = $$$OK
	Try {
	
		// Feature not available
		Write !, "This feature is not yet available. Please execute for an individual component."
		Quit
		
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
				
				If ((pConfigBusinessType '= 0) && (pConfigBusinessType '= tConfigBusinessType)) {
					// Not all and not this business type...continue
					CONTINUE
				}
				
				Set tStatus = ..ExtractConfigInactivityStats(tConfigName)
				$$$ThrowOnError(tStatus)
				
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ExtractConfigInactivityStats(pConfigName As %String, pNumberOfDaysBack As %Integer = 7) As %Status {
	Set tStatus = $$$OK
	Try {
		
		// Cleanup existing entries
		Kill ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack)
		
		// We are interested in analyzing this business type
		Set tStartDateTime = $System.SQL.DATEADD("d",$FNUMBER("-"_pNumberOfDaysBack,"+"),$ZDT($H,3))
		Set ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"StartDateTime") = tStartDateTime
		Set ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"ExtractedOn") = $ZDT($H,3)
		
		// Retrieve all messages for this time period
		Set tQuery = 	"SELECT " _
							"mh.%Id,mh.SessionId,DATEDIFF('s',mh.TimeCreated,mh.TimeProcessed) AS ProcessingTime,mh.TimeCreated,mh.TimeProcessed,mh.SourceConfigName " _
						"FROM Ens.MessageHeader AS mh " _
						"WHERE " _
							"mh.SourceConfigName = ? AND " _
							"mh.%Id >= (SELECT TOP 1 mh1.%Id FROM Ens.MessageHeader AS mh1 WHERE mh1.TimeCreated >= ? ORDER BY mh1.TimeCreated ASC) " _
						"ORDER BY mh.TimeCreated Asc"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = 2
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(pConfigName,tStartDateTime)
		
		Set tPreviousTimeCreated = tStartDateTime
		Set tPrevioustMsgHeaderId = ""
		While(tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tMsgHeaderId = tResultSet.%GetData(1)
			Set tSessionId = tResultSet.%GetData(2)
			Set tProcessingTime= tResultSet.%GetData(3)
			Set tTimeCreated = tResultSet.%GetData(4)
			Set tTimeProcessed = tResultSet.%GetData(5)
			Set tSourceConfigName = tResultSet.%GetData(6)
			
			Set tStatus = ..IsAfterHours(tPreviousTimeCreated,tTimeCreated,.IsAfterHours,.IsWeekend)
			$$$ThrowOnError(tStatus)
			
			Set tDiffInSeconds = $System.SQL.DATEDIFF("s",tPreviousTimeCreated,tTimeCreated)
			
			Set ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"Data",tDiffInSeconds) = 	IsAfterHours _ "|" _ 
																										IsWeekend _ "|" _ 
																										tPreviousTimeCreated _ "|" _ 
																										tTimeCreated

			Set tPrevioustMsgHeaderId = tMsgHeaderId
			Set tPreviousTimeCreated = tTimeCreated
		}
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.Stats.Util).PublishAllConfigInactivityStats()
ClassMethod PublishAllConfigInactivityStats(pConfigBusinessType As %Integer = 1) As %Status {
	Set tStatus = $$$OK
	Try {
	
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
				
				If ((pConfigBusinessType '= 0) && (pConfigBusinessType '= tConfigBusinessType)) {
					// Not all and not this business type...continue
					CONTINUE
				}
				
				Set tStatus = ..PublishConfigInactivityStats(tConfigName)
				$$$ThrowOnError(tStatus)
				
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod PublishConfigInactivityStats(pConfigName As %String, pNumberOfDaysBack As %Integer = 7) As %Status {
	Set tStatus = $$$OK
	Try {
		
	   	Set tCount = 0, tMax = "", tMin = "", tTotal = 0
		Set tKey = $ORDER(^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"Data",""),-1)
		
		Set tStartDateTime = ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"StartDateTime")
		Set tExtractedOn = ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"ExtractedOn")
		If (tKey '= "") {
			Write !, "----------------------------------------------------------------------------------------------------"
			Write !, "Inactivity Data for " _ pConfigName
			Write !, "----------------------------------------------------------------------------------------------------"
			Write !,!, "Top 10 Gaps"
			Write !, $REVERSE($JUSTIFY($REVERSE("Gap (in seconds)"),25)) _ $REVERSE($JUSTIFY($REVERSE("Start"),25)) _ $REVERSE($JUSTIFY($REVERSE("End"),25)) _ $REVERSE($JUSTIFY($REVERSE("Flags"),25))
		}
		For {
		
			Quit:(tKey = "")
			Set:(tMax = "") tMax = tKey
			
			Set tDetails = ^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"Data",tKey)
			
			Set tIsAfterHours = $PIECE(tDetails,"|",1)
			Set tIsWeekend = $PIECE(tDetails,"|",2)
			Set tLastMsgDT = $PIECE(tDetails,"|",3)
			Set tCurrentMsgDT = $PIECE(tDetails,"|",4)
			
			If (tCount <= 10) {
				
				Write !, $REVERSE($JUSTIFY($REVERSE(tKey),25)) _ $REVERSE($JUSTIFY($REVERSE(tLastMsgDT),25)) _ $REVERSE($JUSTIFY($REVERSE(tCurrentMsgDT),25)) 
				
				Set tFlags = ""
				If (tIsAfterHours) { 
					Set tFlags = tFlags _ "|After Hours"
				}
				If (tIsWeekend) { 
					Set tFlags = tFlags _ "|Weekend"
				}
				Write $REVERSE($JUSTIFY($REVERSE(tFlags),25))
			}
			Set tMin = tKey
			Set tTotal = tTotal + tKey
			Set tCount = tCount + 1
			
			Set tKey = $ORDER(^EAI.Stats.Config(pConfigName,"Inactivity",pNumberOfDaysBack,"Data",tKey),-1)
		}
		
		If (tCount > 0) {
			Write !,!, "Summary"
			Write !, $REVERSE($JUSTIFY($REVERSE("Data extracted on:"),20)) _ tExtractedOn
			Write !, $REVERSE($JUSTIFY($REVERSE("Days back:"),20)) _ pNumberOfDaysBack
			Write !, $REVERSE($JUSTIFY($REVERSE("Row count:"),20)) _ tCount
			Write !, $REVERSE($JUSTIFY($REVERSE("Max:"),20)) _ tMax
			Write !, $REVERSE($JUSTIFY($REVERSE("Min:"),20)) _ tMin
			Write !, $REVERSE($JUSTIFY($REVERSE("Average:"),20)) _ $FNUMBER(tTotal / tCount,"",2),!
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}


/// Do ##class(IHC.EAI.Stats.Util).IsAfterHours()
ClassMethod IsAfterHours(pStartDateTime As %TimeStamp,pEndDateTime As %TimeStamp,Output pIsAfterHours As %Boolean = 0, Output pIsWeekend As %Boolean = 0) As %Status {
	Set tStatus = $$$OK
	Try {
		Set tStartWeekDay = $System.SQL.DATEPART("dw",pStartDateTime)
		Set tEndWeekDay = $System.SQL.DATEPART("dw",pEndDateTime)
		If (((tStartWeekDay = 1) || (tStartWeekDay = 7)) || ((tEndWeekDay = 1) || (tEndWeekDay = 7))) {
			Set pIsWeekend = 1
			Quit
		}
		Set tStartHour = $System.SQL.DATEPART("hh",pStartDateTime)
		Set tEndHour = $System.SQL.DATEPART("hh",pEndDateTime)
		
		If (((tStartHour < 8) || (tStartHour > 5)) || ((tEndHour < 8) || (tEndHour > 5))) {
			Set pIsAfterHours = 1
			Quit
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}


/// Do ##class(IHC.EAI.Stats.Util).ExtractAllEnsConfigStats()
/// ***NOT FEASIBLE...need this to go to a file or just not include it at all***
ClassMethod ExtractAllProcessingStats(pConfigBusinessType As %Integer = 0) As %Status {
	Set tStatus = $$$OK
	Try {
		// Feature not available
		Write !, "This feature is not yet available. Please execute for an individual component."
		Quit
		
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
				
				If ((pConfigBusinessType '= 0) && (pConfigBusinessType '= tConfigBusinessType)) {
					// Not all and not this business type...continue
					CONTINUE
				}
				
				Set tStatus = ..ExtractProcessingStats(tConfigName)
				$$$ThrowOnError(tStatus)
				
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.Stats.Util).ExtractProcessingStats("[ComponentName]")
ClassMethod ExtractProcessingStats(pConfigName As %String, pNumberOfDaysBack As %Integer = 10, pMinIntervalMinutes As %Integer = 60) As %Status {
	Set tStatus = $$$OK
	Try {
	
		// Cleanup existing entries
		Kill ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack)
		
		Set tNow = $ZDT($H,3)
		Set tQueryDateTime = $System.SQL.DATEADD("d",$FNUMBER("-"_pNumberOfDaysBack,"+"),tNow)
		
		Set ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"StartDateTime") = tQueryDateTime
		Set ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"ExtractedOn") = tNow
		
		// Loop every pMinIntervalMinutes until we hit the time marked as present
		Set tDateDiff = $System.SQL.DATEDIFF("s",tQueryDateTime,tNow)
		While (tDateDiff > 0) {
			// Retrieve all messages for this time period
			
			Set tQuery = 	"SELECT TOP 1 mh.%Id,mh.SessionId,DATEDIFF('s',mh.TimeCreated,mh.TimeProcessed) AS ProcessingTime,mh.TimeCreated,mh.TimeProcessed,mh.SourceConfigName " _ 
							"FROM Ens.MessageHeader AS mh " _ 
							"WHERE mh.SourceConfigName = ? AND " _
								"mh.%Id >= (SELECT TOP 1 %Id FROM Ens.MessageHeader AS mh1 WHERE mh1.TimeCreated >= ? ORDER BY mh1.TimeCreated ASC)"
			
			Set tStatement = ##class(%SQL.Statement).%New()
			Set tStatement.%SelectMode = 2
			Set tStatus = tStatement.%Prepare(tQuery)
			$$$ThrowOnError(tStatus)
			Set tResultSet = tStatement.%Execute(pConfigName,tQueryDateTime)
			
			Set tNewMinDateTime = ""
			While (tResultSet.%Next(.tStatus)) {
				$$$ThrowOnError(tStatus)
				
				Set tMsgHeaderId = tResultSet.%GetData(1)
				Set tSessionId = tResultSet.%GetData(2)
				Set tProcessingTime = tResultSet.%GetData(3)
				Set tTimeCreated = tResultSet.%GetData(4)
				Set tTimeProcessed = tResultSet.%GetData(5)
				Set tSourceConfigName = tResultSet.%GetData(6)
				
				Set tDateIndex = $ZDTH(tTimeCreated,3)
				
				Set ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"Data",tMsgHeaderId) =	tSessionId _ "|" _ 
																										tProcessingTime _ "|" _ 
																										tTimeCreated _ "|" _ 
																										tTimeProcessed
				
				Set tNewMinDateTime = tTimeProcessed
			}
			$$$ThrowOnError(tStatus)
			
			Quit:(tNewMinDateTime = "")
			
			Set tQueryDateTime = $System.SQL.DATEADD("mi",pMinIntervalMinutes,tNewMinDateTime)
			Set tDateDiff = $System.SQL.DATEDIFF("s",tQueryDateTime,tNow)
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.Stats.Util).PublishAllProcessingStats()
ClassMethod PublishAllProcessingStats(pConfigBusinessType As %Integer = 0) As %Status {
	Set tStatus = $$$OK
	Try {
	
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
				
				If ((pConfigBusinessType '= 0) && (pConfigBusinessType '= tConfigBusinessType)) {
					// Not all and not this business type...continue
					CONTINUE
				}
				
				Set tStatus = ..PublishProcessingStats(tConfigName)
				$$$ThrowOnError(tStatus)
				
			}
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod PublishProcessingStats(pConfigName As %String, pNumberOfDaysBack As %Integer = 10) As %Status {
	Set tStatus = $$$OK
	Try {
		
	   	Set tCount = 0, tMax = "", tMin = "", tTotal = 0
		Set tKey = $ORDER(^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"Data",""))
		
		Set tStartDateTime = ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"StartDateTime")
		Set tExtractedOn = ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"ExtractedOn")
		If (tKey '= "") {
			Write !, "----------------------------------------------------------------------------------------------------"
			Write !, "Processing Data for " _ pConfigName
			Write !, "----------------------------------------------------------------------------------------------------"
			//Write !, $REVERSE($JUSTIFY($REVERSE("Processing Time (in seconds)"),30)) _ $REVERSE($JUSTIFY($REVERSE("Time Created"),25)) _ $REVERSE($JUSTIFY($REVERSE("Time Processed"),25)) _ $REVERSE($JUSTIFY($REVERSE("Message Id"),25))
			Write !,!, "Processing Time" _ ","_ "Time Created" _ "," _ "Time Processed" _ "," _ "Message Id"
			
		}
		For {
		
			Quit:(tKey = "")
			
			Set tDetails = ^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"Data",tKey)
			
			Set tSessionId = $PIECE(tDetails,"|",1)
			Set tProcessingTime = $PIECE(tDetails,"|",2)
			Set tTimeCreated = $PIECE(tDetails,"|",3)
			Set tTimeProcessed = $PIECE(tDetails,"|",4)
			
			Write !, tProcessingTime _ "," _ tTimeCreated _ "," _ tTimeProcessed _ "," _ tKey
			
			Set:(tMax = "") tMax = tProcessingTime
			Set:(tMax < tProcessingTime) tMax = tProcessingTime
			Set:(tMin = "") tMin = tProcessingTime
			Set:(tProcessingTime < tMin) tMin = tProcessingTime
			Set tTotal = tTotal + tProcessingTime
			Set tCount = tCount + 1
			
			Set tKey = $ORDER(^EAI.Stats.Config(pConfigName,"Processing",pNumberOfDaysBack,"Data",tKey))
		}
		
		If (tCount > 0) {
			Write !,!, "Summary"
			Write !, $REVERSE($JUSTIFY($REVERSE("Data extracted on:"),20)) _ tExtractedOn
			Write !, $REVERSE($JUSTIFY($REVERSE("Days back:"),20)) _ pNumberOfDaysBack
			Write !, $REVERSE($JUSTIFY($REVERSE("Row count:"),20)) _ tCount
			Write !, $REVERSE($JUSTIFY($REVERSE("Max:"),20)) _ tMax
			Write !, $REVERSE($JUSTIFY($REVERSE("Min:"),20)) _ tMin
			Write !, $REVERSE($JUSTIFY($REVERSE("Average:"),20)) _ $FNUMBER(tTotal / tCount,"",2),!
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
