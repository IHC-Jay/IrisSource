Include EAI.Error

Class IHC.EAI.Uptime.Util Extends IHC.EAI.Log.Util
{

ClassMethod GetCurrentMonthTrends(Output pStatus As %Status = {$$$OK}) As %String
{
	Set tLineObj = "{"
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(1,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
		Set tStartDate = $ZD($ZDTH(tStartDate,3),3)
		Set tEndDate = $ZD($ZDTH(tEndDate,3),3)
		
		Set tLineObj = tLineObj _ "element: 'current-month-line',"
		Set tLineObj = tLineObj _ "resize: true,"
	  	Set tLineObj = tLineObj _ "data: ["
	  	
		Set tQuery = 	"SELECT Value,ValueDate " _
						"FROM IHC_EAI_Uptime_Data.UptimePercent " _
						"WHERE " _
							"ValueDate >= ? AND " _
							"ValueDate <= ? AND " _
							"Namespace IS NULL " _
						"ORDER BY ValueDate Asc"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tStartDate,tEndDate)
		
		Set tCount = 0
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tValue = tResultSet.%GetData(1)
			Set tValueDate = tResultSet.%GetData(2)
			
			If (tCount > 0) {
				Set tLineObj = tLineObj _ ",{ ro: '" _ tValueDate _ "', v: '" _ tValue _ "'}"
			} Else {
				Set tLineObj = tLineObj _ "{ ro: '" _ tValueDate _ "', v: '" _ tValue _ "'}"
			}
			Set tCount = tCount + 1
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
		Set tLineObj = tLineObj _ "],"
		
		// xkeys
		Set tLineObj = tLineObj _ "xkey: 'ro',"
		
		Set tItemCount = 0
		Set tYMin = "ymin: 80,"
		Set tYMax = "ymax: 100,"
		Set tYKeys = "ykeys: ['v'],"
		Set tLabels = "labels: ['Total Uptime']"
		
		Set tLineObj = tLineObj _ tYMin _ tYMax _ tYKeys _ tLabels
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Set tLineObj = tLineObj _ "}"
	Quit tLineObj
}

ClassMethod GetPreviousMonthTrends(Output pStatus As %Status = {$$$OK}) As %String
{
	Set tLineObj = "{"
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(2,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
		Set tStartDate = $ZD($ZDTH(tStartDate,3),3)
		Set tEndDate = $ZD($ZDTH(tEndDate,3),3)
		
		Set tLineObj = tLineObj _ "element: 'previous-month-line',"
		Set tLineObj = tLineObj _ "resize: true,"
	  	Set tLineObj = tLineObj _ "data: ["
	  	
		Set tQuery = 	"SELECT Value,ValueDate " _
						"FROM IHC_EAI_Uptime_Data.UptimePercent " _
						"WHERE " _
							"ValueDate >= ? AND " _
							"ValueDate <= ? AND " _
							"Namespace IS NULL " _
						"ORDER BY ValueDate Asc"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tStartDate,tEndDate)
		
		Set tCount = 0
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tValue = tResultSet.%GetData(1)
			Set tValueDate = tResultSet.%GetData(2)
			
			If (tCount > 0) {
				Set tLineObj = tLineObj _ ",{ ro: '" _ tValueDate _ "', v: '" _ tValue _ "'}"
			} Else {
				Set tLineObj = tLineObj _ "{ ro: '" _ tValueDate _ "', v: '" _ tValue _ "'}"
			}
			Set tCount = tCount + 1
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
		Set tLineObj = tLineObj _ "],"
		
		// xkeys
		Set tLineObj = tLineObj _ "xkey: 'ro',"
		
		Set tItemCount = 0
		Set tYMin = "ymin: 80,"
		Set tYMax = "ymax: 100,"
		Set tYKeys = "ykeys: ['v'],"
		Set tLabels = "labels: ['Total Uptime']"
		
		Set tLineObj = tLineObj _ tYMin _ tYMax _ tYKeys _ tLabels
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Set tLineObj = tLineObj _ "}"
	Quit tLineObj
}

ClassMethod GetYTDTrends(Output pStatus As %Status = {$$$OK}) As %String
{
	Set tLineObj = "{"
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(3,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
		Set tStartDate = $ZD($ZDTH(tStartDate,3),3)
		Set tEndDate = $ZD($ZDTH(tEndDate,3),3)
		
		Set tLineObj = tLineObj _ "element: 'year-to-date-line',"
		Set tLineObj = tLineObj _ "resize: true,"
	  	Set tLineObj = tLineObj _ "data: ["
	  	
		Set tQuery = 	"SELECT Value,ValueDate " _
						"FROM IHC_EAI_Uptime_Data.UptimePercent " _
						"WHERE " _
							"ValueDate >= ? AND " _
							"ValueDate <= ? AND " _
							"Namespace IS NULL " _
						"ORDER BY ValueDate Asc"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tStartDate,tEndDate)
		
		Set tCount = 0
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tValue = tResultSet.%GetData(1)
			Set tValueDate = tResultSet.%GetData(2)
			
			If (tCount > 0) {
				Set tLineObj = tLineObj _ ",{ ro: '" _ tValueDate _ "', v: '" _ tValue _ "'}"
			} Else {
				Set tLineObj = tLineObj _ "{ ro: '" _ tValueDate _ "', v: '" _ tValue _ "'}"
			}
			Set tCount = tCount + 1
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
		Set tLineObj = tLineObj _ "],"
		
		// xkeys
		Set tLineObj = tLineObj _ "xkey: 'ro',"
		
		Set tItemCount = 0
		Set tYMin = "ymin: 80,"
		Set tYMax = "ymax: 100,"
		Set tYKeys = "ykeys: ['v'],"
		Set tLabels = "labels: ['Total Uptime']"
		
		Set tLineObj = tLineObj _ tYMin _ tYMax _ tYKeys _ tLabels
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Set tLineObj = tLineObj _ "}"
	Quit tLineObj
}

ClassMethod GetConfigDownMinutes(
	pStartDate As %TimeStamp,
	pEndDate As %TimeStamp,
	pStatus As %Status = {$$$OK}) As %Integer
{
	Set tConfigDownMinutes = 0
	Try {		
		// Get the total from events that started and ended same day
		Set SQLCODE = "", tTempConfigDownMinutes = ""
		&sql(SELECT SUM(DATEDIFF("mi",DownStart,DownEnd)) INTO :tTempConfigDownMinutes 
			FROM IHC_EAI_Uptime_Data.ConfigDownEvent 
			WHERE 
				DownStart >= :pStartDate AND 
				DownEnd <= :pEndDate AND 
				DATEDIFF("mi",DownStart,DownEnd) > 5)
		If ((SQLCODE = 0) && (tTempConfigDownMinutes > 0)) {
			Set tConfigDownMinutes = tConfigDownMinutes + tTempConfigDownMinutes
		}
		
		// Get the events that started previously, but ended on this day
		// We'll need to loop through results and use the endtime to calc the diff from start of day in mins
		Set tQuery = 	"SELECT DownEnd " _
						"FROM IHC_EAI_Uptime_Data.ConfigDownEvent " _
						"WHERE DownStart < ? AND " _
							"DownEnd >= ? AND " _
							"DownEnd <= ? AND " _
							"DATEDIFF(""mi"",DownStart,DownEnd) > 5"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(pStartDate,pStartDate,pEndDate)
		
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tDownEnd = tResultSet.%GetData(1)
			
			Set tTempStartDate = $PIECE(pEndDate," ",1) _ " 00:00:00"
			Set tDiff = $System.SQL.DATEDIFF("mi",tTempStartDate,tDownEnd)
			Set tConfigDownMinutes = tConfigDownMinutes + tDiff
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
		// Get the events that started on this date, but ended on a future date
		// We'll need to loop through results and use the start time to calc the diff from it to end of day in mins
		Set tQuery = 	"SELECT DownStart " _
						"FROM IHC_EAI_Uptime_Data.ConfigDownEvent " _
						"WHERE DownEnd > ? AND " _
							"DownStart >= ? AND " _
							"DownStart <= ? AND " _
							"DATEDIFF(""mi"",DownStart,DownEnd) > 5"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(pEndDate,pStartDate,pEndDate)
		
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tDownEnd = tResultSet.%GetData(1)
			
			Set tTempEndDate = $PIECE(tDownEnd," ",1) _ " 23:59:59"
			Set tDiff = $System.SQL.DATEDIFF("mi",pStartDate,tTempEndDate) + 1	// Extra minute
			Set tConfigDownMinutes = tConfigDownMinutes + tDiff
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tConfigDownMinutes
}

ClassMethod UpdatePreviousUptimePercent() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Get the oldest date we have knowledge of
		Set SQLCODE = "", tDate = ""
		&sql(SELECT MIN(DownStart) INTO :tDate FROM IHC_EAI_Uptime_Data.ConfigDownEvent)
		If (SQLCODE = 0) {
			// Found a min date, continue
			Set tCurrentDate = $ZD($H,3)
			Set tDiff = $System.SQL.DATEDIFF("d",tDate,tCurrentDate)
			
			While (tDiff >= 0) {
				Set tDate = $ZD($ZDTH(tDate,3),3)
				
				Set tStartDate = tDate _ " 00:00:00"
				Set tEndDate = tDate _ " 23:59:59"
				
				Set tComponentCount = ##class(IHC.EAI.Uptime.Util).GetComponentCount(tStartDate,tEndDate,.tStatus)
				$$$ThrowOnError(tStatus)
				
				Set tTotalRangeMinutes = 1440 // One day
				Set tTotalMinutes = tTotalRangeMinutes * tComponentCount
				
				Set tConfigDownMinutes = ##class(IHC.EAI.Uptime.Util).GetConfigDownMinutes(tStartDate,tEndDate,.tStatus)
				$$$ThrowOnError(tStatus)
				
				If (tTotalMinutes > 0) {
					Set tDownPercent = (tConfigDownMinutes/tTotalMinutes) * 100
					Set tUptimePercent = 100 - tDownPercent
					Set tItem = ##class(IHC.EAI.Uptime.Data.UptimePercent).%New()
					Set tItem.ValueDate = tDate
					Set tItem.RecordedOn = tCurrentDate
					Set tItem.Value = tUptimePercent
					Do tItem.%Save()
				}
				
				Set tDate = $System.SQL.DATEADD("d",1,tDate)
				Set tDiff = $System.SQL.DATEDIFF("d",tDate,tCurrentDate)
			}
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetDetailResults(
	pType As %Integer = 1,
	Output pStatus As %Status = {$$$OK}) As %ListOfObjects
{
	Set tList = ##class(%ListOfObjects).%New()
	Try {
		
		Set tDownStart = ""
		Set tDownEnd = ""
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(pType,.tDownStart,.tDownEnd)
		$$$ThrowOnError(pStatus)
		
		Set tQuery = 	"SELECT " _ 
							"%ID " _
						"FROM IHC_EAI_Uptime_Data.ConfigDownEvent " _
						"WHERE " _
							"(DownStart >= ? AND " _
							"DownStart <= ?) OR " _
							"(DownEnd >= ? AND " _
							"DownEnd <= ?) AND " _
							"DATEDIFF(""mi"",DownStart,DownEnd) > 5 " _
						"ORDER BY " _
							"DownStart Asc"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tDownStart,tDownEnd,tDownStart,tDownEnd)
		
		While (tResultSet.%Next(.pStatus)) {
			Set tItemID = tResultSet.%GetData(1)
			Set tItem = ##class(IHC.EAI.Uptime.Data.ConfigDownEvent).%OpenId(tItemID,,.pStatus)
			$$$ThrowOnError(pStatus)
			Do tList.Insert(tItem)
		}
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tList
}

ClassMethod GetNamespaceResults(
	pType As %Integer = 1,
	Output pStatus As %Status = {$$$OK}) As %ListOfDataTypes
{
	Set tList = ##class(%ListOfDataTypes).%New()
	Try {
		
		Set tDownStart = ""
		Set tDownEnd = ""
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(pType,.tDownStart,.tDownEnd)
		$$$ThrowOnError(pStatus)
		
		Set tTotalMinutes = ##class(IHC.EAI.Uptime.Util).GetTotalMinutes(pType,.pStatus)
		$$$ThrowOnError(pStatus)
			
		Set tList = ##class(IHC.EAI.Uptime.Util).GetNamespaceUptime(tTotalMinutes,tDownStart,tDownEnd,.pStatus)
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tList
}

ClassMethod GetNamespaceConfigDownMinutes(
	pNamespace As %String,
	pStartDate As %TimeStamp,
	pEndDate As %TimeStamp,
	Output pStatus As %Status = {$$$OK}) As %Integer
{
	Set tConfigDownMinutes = 0
	Try {		
		// Get the total from events that started and ended same day
		Set SQLCODE = "", tTempConfigDownMinutes = ""
		&sql(SELECT SUM(DATEDIFF("mi",DownStart,DownEnd)) INTO :tTempConfigDownMinutes 
			FROM IHC_EAI_Uptime_Data.ConfigDownEvent 
			WHERE 
				DownStart >= :pStartDate AND 
				DownEnd <= :pEndDate AND 
				DATEDIFF("mi",DownStart,DownEnd) > 5 AND
				Namespace = :pNamespace)
		If ((SQLCODE = 0) && (tTempConfigDownMinutes > 0)) {
			Set tConfigDownMinutes = tConfigDownMinutes + tTempConfigDownMinutes
		}
		
		// Get the events that started previously, but ended on this day
		// We'll need to loop through results and use the endtime to calc the diff from start of day in mins
		Set tQuery = 	"SELECT DownEnd " _
						"FROM IHC_EAI_Uptime_Data.ConfigDownEvent " _
						"WHERE DownStart < ? AND " _
							"DownEnd >= ? AND " _
							"DownEnd <= ? AND " _
							"DATEDIFF(""mi"",DownStart,DownEnd) > 5 AND " _
							"Namespace = ?"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		
		Set tResultSet = tStatement.%Execute(pStartDate,pStartDate,pEndDate,pNamespace)
		
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tDownEnd = tResultSet.%GetData(1)
			
			Set tTempStartDate = $PIECE(pStartDate," ",1) _ " 00:00:00"
			Set tDiff = $System.SQL.DATEDIFF("mi",tTempStartDate,tDownEnd)
			Set tConfigDownMinutes = tConfigDownMinutes + tDiff
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
		// Get the events that started on this date, but ended on a future date
		// We'll need to loop through results and use the start time to calc the diff from it to end of day in mins
		Set tQuery = 	"SELECT DownStart " _
						"FROM IHC_EAI_Uptime_Data.ConfigDownEvent " _
						"WHERE DownEnd > ? AND " _
							"DownStart >= ? AND " _
							"DownStart <= ? AND " _
							"DATEDIFF(""mi"",DownStart,DownEnd) > 5 AND " _
							"Namespace = ?"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(pEndDate,pStartDate,pEndDate,pNamespace)
		
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			Set tDownStart = tResultSet.%GetData(1)
			Set tDiff = $System.SQL.DATEDIFF("mi",tDownStart,pEndDate) + 1	// Extra minute
			Set tConfigDownMinutes = tConfigDownMinutes + tDiff
		}
		$$$ThrowOnError(pStatus)
		Kill tQuery, tStatement, tResultSet
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tConfigDownMinutes
}

ClassMethod GetNamespaceUptime(
	pTotalMinutes As %Integer,
	pStartDate As %TimeStamp,
	pEndDate As %TimeStamp,
	Output pStatus As %Status = {$$$OK}) As %ListOfDataTypes
{
	Set tList = ##class(%ListOfDataTypes).%New()
	Try {
		
		Set tQuery = 	"SELECT DISTINCT(Namespace) " _
						"FROM IHC_EAI_Uptime_Data.ConfigDownEvent " _
						"WHERE " _
							"(DownStart >= ? AND " _
							"DownStart <= ?) OR " _
							"(DownEnd >= ? AND " _
							"DownEnd <= ?) AND " _
							"DATEDIFF(""mi"",DownStart,DownEnd) > 5"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(pStartDate,pEndDate,pStartDate,pEndDate)
		
		While (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			
			Set tNamespace = tResultSet.%GetData(1)
			
			Set tConfigDownMinutes = ##class(IHC.EAI.Uptime.Util).GetNamespaceConfigDownMinutes(tNamespace,pStartDate,pEndDate,.pStatus)
			$$$ThrowOnError(pStatus)
			
			Set tUpPercent = 100.00
			Set tDownPercent = 0
			
			If (pTotalMinutes > 0) {
				Set tDownPercent = (tConfigDownMinutes/pTotalMinutes) * 100
			}
			
			Set tUpPercent = tUpPercent - tDownPercent
			Set tItem = tNamespace _ "|" _ $FNUMBER(tUpPercent,"",3)
			Do tList.Insert(tItem)
			
		}
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tList
}

ClassMethod GetCurrentMonthResults(
	pType As %Integer = 1,
	pStatus As %Status = {$$$OK}) As %Numeric
{
	Set tPercent = 0.000
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(1,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
		
		Set tQuery = "SELECT SUM(Value),COUNT(Value) " _
					"FROM IHC_EAI_Uptime_Data.UptimePercent " _
					"WHERE ValueDate >= ? AND " _
						"ValueDate <= ?"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tStartDate,tEndDate)
		
		If (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			
			Set tSumValue = tResultSet.%GetData(1)
			Set tCountValue = tResultSet.%GetData(2)
			Set tPercent = tSumValue / tCountValue
			Set:(pType = 2) tPercent = 100 - tPercent
		}
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()	
	}
	Quit $FNUMBER(tPercent,"",3)
}

ClassMethod GetPreviousMonthResults(
	pType As %Integer = 1,
	pStatus As %Status = {$$$OK}) As %Numeric
{
	Set tPercent = 0.000
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(2,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
		
		Set tQuery = "SELECT SUM(Value),COUNT(Value) " _
					"FROM IHC_EAI_Uptime_Data.UptimePercent " _
					"WHERE ValueDate >= ? AND " _
						"ValueDate <= ?"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tStartDate,tEndDate)
		
		If (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			
			Set tSumValue = tResultSet.%GetData(1)
			Set tCountValue = tResultSet.%GetData(2)
			Set tPercent = tSumValue / tCountValue
			Set:(pType = 2) tPercent = 100 - tPercent
		}
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()	
	}
	Quit $FNUMBER(tPercent,"",3)
}

ClassMethod GetYTDResults(
	pType As %Integer = 1,
	pStatus As %Status = {$$$OK}) As %Numeric
{
	Set tPercent = 0.000
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(3,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
		
		Set tQuery = "SELECT SUM(Value),COUNT(Value) " _
					"FROM IHC_EAI_Uptime_Data.UptimePercent " _
					"WHERE ValueDate >= ? AND " _
						"ValueDate <= ?"
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = "2"
		Set pStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(pStatus)
		Set tResultSet = tStatement.%Execute(tStartDate,tEndDate)
		
		If (tResultSet.%Next(.pStatus)) {
			$$$ThrowOnError(pStatus)
			
			Set tSumValue = tResultSet.%GetData(1)
			Set tCountValue = tResultSet.%GetData(2)
			Set tPercent = tSumValue / tCountValue
			Set:(pType = 2) tPercent = 100 - tPercent
		}
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()	
	}
	Quit $FNUMBER(tPercent,"",3)
}

ClassMethod GetCurrentMonth() As %String
{
	Quit $PIECE($ZDT($H,9)," ",1) _ " " _ $PIECE($ZDT($H,3),"-",1)
}

ClassMethod GetPreviousMonth() As %String
{
	Quit $PIECE($ZDT($ZDTH($SYSTEM.SQL.DATEADD("month",-1,$H),3),9)," ",1) _ " " _ $PIECE($ZDT($H,3),"-",1)
}

ClassMethod GetYearToDate() As %String
{
	Quit "January " _ $PIECE($ZDT($H,3),"-",1) _ " - " _ ..GetCurrentMonth()
}

ClassMethod GetStartEndDate(
	pType As %Integer = 1,
	Output pStartDate As %TimeStamp,
	Output pEndDate As %TimeStamp) As %Status
{
	Set tStatus = $$$OK
	Try {
		If (pType = 1) {
			Set tCurrentDate = $ZDATE($H,3)
			Set tYear = $PIECE(tCurrentDate,"-",1)
			Set tMonth = $PIECE(tCurrentDate,"-",2)
			Set tDay = $PIECE(tCurrentDate,"-",3)
			Set pStartDate = $ZDT($ZDTH(tYear _ "-" _ tMonth _ "-01" _ " 00:00:00",3),3)
			Set pEndDate = $ZDT($H,3)
		} ElseIf (pType = 2) {
			Set tOneMonthAgoTS = $ZDT($ZDTH($SYSTEM.SQL.DATEADD("month",-1,$H),3),3)
			Set tYear = $PIECE(tOneMonthAgoTS,"-",1)
			Set tMonth = $PIECE(tOneMonthAgoTS,"-",2)
			Set tDay = $PIECE(tOneMonthAgoTS,"-",3)
			Set tOneMonthAgo = tYear _ "-" _ tMonth _ "-01"
			Set pStartDate = $ZDT($ZDTH(tOneMonthAgo _ " 00:00:00",3),3)
			Set pEndDate = $ZDT($SYSTEM.SQL.LASTDAY(tOneMonthAgo),3) _ " 23:59:59"
		} ElseIf (pType = 3) {
			Set tDate = $ZDATE($H,3)
			Set tYear = $PIECE(tDate,"-",1)
			Set tYearStart = tYear _ "-01-01"
			Set pStartDate = $ZDT($ZDTH(tYearStart _ " 00:00:00",3),3)
			Set pEndDate = $ZDT($H,3)
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetTotalMinutes(
	pType As %Integer = 1,
	Output pStatus As %Status = {$$$OK}) As %Integer
{
	Set tTotalMinutes = 0
	Try {
		
		Set pStatus = ##class(IHC.EAI.Uptime.Util).GetStartEndDate(pType,.tStartDate,.tEndDate)
		$$$ThrowOnError(pStatus)
			
		Set tTotalRangeMinutes = $System.SQL.DATEDIFF("mi",tStartDate,tEndDate)
			
		// Mulitply by total number of components
		Set tComponentCount = ##class(IHC.EAI.Uptime.Util).GetComponentCount(tStartDate,tEndDate,.pStatus)
		$$$ThrowOnError(pStatus)
		
		Set tTotalMinutes = tTotalRangeMinutes * tComponentCount
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tTotalMinutes
}

ClassMethod GetComponentCount(
	pStartDate As %TimeStamp,
	pEndDate As %TimeStamp,
	Output pStatus As %Status = {$$$OK}) As %Integer
{
	Set tCount = 0
	Try {
		Set tModdedEndDate = $ZDH(pEndDate,3)
		Set tMaxValueDateADT = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateADT FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||ADT')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateADT FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||ADT')
		}
		If (tMaxValueDateADT '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateADT AND ApplicationGroup = 'Ensemble||ADT')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateADT _ " namespace: ADT"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDateBILLING = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateBILLING FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||BILLING')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateBILLING FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||BILLING')
		}
		If (tMaxValueDateBILLING '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateBILLING AND ApplicationGroup = 'Ensemble||BILLING')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateBILLING _ " namespace: BILLING"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDateDEMOGRAPHICS = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateDEMOGRAPHICS FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||DEMOGRAPHICS')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateDEMOGRAPHICS FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||DEMOGRAPHICS')
		}
		If (tMaxValueDateDEMOGRAPHICS '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateDEMOGRAPHICS AND ApplicationGroup = 'Ensemble||DEMOGRAPHICS')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateDEMOGRAPHICS _ " namespace: DEMOGRAPHICS"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDateLAB = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateLAB FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||LAB')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateLAB FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||LAB')
		}
		If (tMaxValueDateLAB '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateLAB AND ApplicationGroup = 'Ensemble||LAB')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateLAB _ " namespace: LAB"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDateMISC = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateMISC FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||MISC')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateMISC FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||MISC')
		}
		If (tMaxValueDateMISC '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateMISC AND ApplicationGroup = 'Ensemble||MISC')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateMISC _ " namespace: MISC"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDateORDERS = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateORDERS FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||ORDERS')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateORDERS FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||ORDERS')
		}
		If (tMaxValueDateORDERS '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateORDERS AND ApplicationGroup = 'Ensemble||ORDERS')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateORDERS _ " namespace: ORDERS"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDateRESULTS = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateRESULTS FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||RESULTS')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDateRESULTS FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||RESULTS')
		}
		If (tMaxValueDateRESULTS '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDateRESULTS AND ApplicationGroup = 'Ensemble||RESULTS')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDateRESULTS _ " namespace: RESULTS"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDatePAYER = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDatePAYER FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||PAYER')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDatePAYER FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||PAYER')
		}
		If (tMaxValueDatePAYER '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDatePAYER AND ApplicationGroup = 'Ensemble||PAYER')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDatePAYER _ " namespace: PAYER"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
		
		Set tMaxValueDatePROVIDER = ""
		Set SQLCODE = ""
		&sql(SELECT MAX(ValueDate) INTO :tMaxValueDatePROVIDER FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate <= :tModdedEndDate AND ApplicationGroup = 'Ensemble||PROVIDER')
		If (SQLCODE '= 0) {
			Set SQLCODE = ""
			&sql(SELECT MAX(ValueDate) INTO :tMaxValueDatePROVIDER FROM IHC_EAI_KPI_Schema.ComponentCount WHERE ValueDate >= :tModdedEndDate AND ApplicationGroup = 'Ensemble||PROVIDER')
		}
		If (tMaxValueDatePROVIDER '= "") {
			Set SQLCODE = "", tValue = ""
			&sql(SELECT TOP 1 Value INTO :tValue FROM IHC_EAI_KPI_Schema.ComponentCount WHERE Type = 'Total' AND ValueDate = :tMaxValueDatePROVIDER AND ApplicationGroup = 'Ensemble||PROVIDER')
			If (SQLCODE = 0) {
				Set tCount = tCount + tValue
			} Else {
				$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to get component count for date: " _ tMaxValueDatePROVIDER _ " namespace: PROVIDER"))
			}
		} Else {
			$$$ThrowStatus($$$ERROR($$$EAIGeneralError, "Failed to find a valid component count date."))
		}
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tCount
}

}