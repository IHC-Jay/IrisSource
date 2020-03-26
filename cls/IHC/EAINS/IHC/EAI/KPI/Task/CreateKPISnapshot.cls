Class IHC.EAI.KPI.Task.CreateKPISnapshot Extends %SYS.Task.Definition
{

/// This defines the user-visible name of this task;
/// This is defined in subclasses.
Parameter TaskName As STRING = "Create KPI Snapshot";

/// The KPI class name to be executed
Property KPIController As %String(MAXLEN = 250, VALUELIST = ",IHC.EAI.KPI.Controller.TransactionCount,IHC.EAI.KPI.Controller.ComponentCount");

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status {
	Set tStatus = $$$OK
	Try {
		
		// Execute KPI Controller
		Set tStatus = $CLASSMETHOD(..KPIController,"CreateSnapshots",,,,1)
		$$$ThrowOnError(tStatus)
			
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Do ##class(IHC.EAI.KPI.Task.CreateKPISnapshot).InitTasks()
ClassMethod InitTasks() As %Status {
	Set tStatus = $$$OK
	Try {
		// Transaction Count
		Set tTCTask = ""
		Set tFullName = "EAI KPI - Transaction Count"
		Set tTaskID = ##class(%SYS.Task).FindId(tFullName)
		If (tTaskID = "") {
			// Task is not present, need to create one
			Set tTCTask = ##class(%SYS.Task).%New()
			Set tTCTask.Name = tFullName
		} Else {
			// Task has already been defined
			Set tTCTask = ##class(%SYS.Task).%OpenId(tTaskID)
		}
		
		Set tTCTask.NameSpace = "EAI"
		Set tTCTask.MirrorStatus = 1	//Only on primary mirror member
		Set tTCTask.TaskClass = "IHC.EAI.KPI.Task.CreateKPISnapshot"
		Set tTCTask.RunAsUser = "hsadmin"
		Set tTCTask.Type = 2
		Set tTCTask.Description = "Daily transaction count KPI measurements"
		Set tTCTask.TimePeriod = 0			
		Set tTCTask.TimePeriodEvery = "1"   	
		Set tTCTask.TimePeriodDay = ""
		Set tTCTask.DailyFrequency = 0
		Set tTCTask.DailyFrequencyTime = 0
		Set tTCTask.DailyIncrement = ""
		Set tTCTask.DailyStartTime = $ZTH("00:30:00")
		Set tTCTask.DailyEndTime = $ZTH("00:30:00")
		Do tTCTask.EmailOnCompletion.Clear()
		Do tTCTask.EmailOnCompletion.Insert("eaireports@imail.org")
		Do tTCTask.EmailOnError.Clear()
		Do tTCTask.EmailOnError.Insert("eai@imail.org")
		
		If ($ZTH("00:30:00") < $PIECE($H,",",2)) {
			Set tStatus = tTCTask.StartDateSet(+$H + 1)
		} Else {
			Set tStatus = tTCTask.StartDateSet(+$H)
		}
		$$$ThrowOnError(tStatus)
		
		// Settings
		Set tTaskDef = ##class(IHC.EAI.KPI.Task.CreateKPISnapshot).%New()
		Do tTaskDef.SetSettings($LB("KPIController","IHC.EAI.KPI.Controller.TransactionCount"))
		Set tStatus = tTCTask.AssignSettings(tTaskDef)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = tTCTask.%Save()
		$$$ThrowOnError(tStatus)
		
		// Component Count
		Set tCCTask = ""
		Set tFullName = "EAI KPI - Component Count"
		Set tTaskID = ##class(%SYS.Task).FindId(tFullName)
		If (tTaskID = "") {
			// Task is not present, need to create one
			Set tCCTask = ##class(%SYS.Task).%New()
			Set tCCTask.Name = tFullName
		} Else {
			// Task has already been defined
			Set tCCTask = ##class(%SYS.Task).%OpenId(tTaskID)
		}
		
		Set tCCTask.NameSpace = "EAI"
		Set tCCTask.MirrorStatus = 1	//Only on primary mirror member
		Set tCCTask.TaskClass = "IHC.EAI.KPI.Task.CreateKPISnapshot"
		Set tCCTask.RunAsUser = "hsadmin"
		Set tCCTask.Type = 2
		Set tCCTask.Description = "Weekly component count KPI measurements"
		Set tCCTask.TimePeriod = 1			
		Set tCCTask.TimePeriodEvery = "1"   	
		Set tCCTask.TimePeriodDay = "4"
		Set tCCTask.DailyFrequency = 0
		Set tCCTask.DailyFrequencyTime = 0
		Set tCCTask.DailyIncrement = ""
		Set tCCTask.DailyStartTime = $ZTH("23:30:00")
		Set tCCTask.DailyEndTime = $ZTH("23:30:00")
		Set tCCTask.RescheduleOnStart = 1
		Do tCCTask.EmailOnCompletion.Clear()
		Do tCCTask.EmailOnCompletion.Insert("eaireports@imail.org")
		Do tCCTask.EmailOnError.Clear()
		Do tCCTask.EmailOnError.Insert("eai@imail.org")
				
		If ($ZTH("23:30:00") <= $PIECE($H,",",2)) {
			Set tStatus = tCCTask.StartDateSet(+$H + 1)
		} Else {
			Set tStatus = tCCTask.StartDateSet(+$H)
		}
		$$$ThrowOnError(tStatus)
		
		// Settings
		Set tTaskDef = ##class(IHC.EAI.KPI.Task.CreateKPISnapshot).%New()
		Do tTaskDef.SetSettings($LB("KPIController","IHC.EAI.KPI.Controller.ComponentCount"))
		Set tStatus = tCCTask.AssignSettings(tTaskDef)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = tCCTask.%Save()
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
