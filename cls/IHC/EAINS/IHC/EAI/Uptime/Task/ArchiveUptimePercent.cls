Class IHC.EAI.Uptime.Task.ArchiveUptimePercent Extends %SYS.Task.Definition {
	
/// This defines the user-visible name of this task;
/// This is defined in subclasses.
Parameter TaskName As STRING = "Archive Uptime Percent";
	
/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status {
	Set tStatus = $$$OK
	Try {
		
		// Get yesterday date
		Set tToday = $ZD($H,3)
		Set tStartDate = $System.SQL.DATEADD("d",-1,tToday)
		Set tEndDate = $PIECE(tStartDate," ",1) _ " 23:59:59"
		
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
			Set tItem.RecordedOn = tToday
			Set tItem.ValueDate = $PIECE(tStartDate," ",1)
			Set tItem.Value = tUptimePercent
			Do tItem.%Save()
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}