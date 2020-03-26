Include Ensemble

Class IHC.EAI.SuspendedMessage.Util Extends (IHC.EAI.Log.Util, %SYS.Task.Definition)
{

Parameter LOGNAME = "EAI.DiscardSuspended";

/// This defines the user-visible name of this task;
/// This is defined in subclasses.
Parameter TaskName As STRING = "PurgeSuspended";

/// Number of days to keep (based on when message was created/added to the queue)
Property DaysToKeep As %Integer [ InitialExpression = 7 ];

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ..DiscardSuspendedMessage(..DaysToKeep)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod DiscardSuspendedMessage(pDaysToKeep As %Integer) As %Status
{
	Set tSC=$$$OK
	Try	{
		Set tSqlobj=##class(%SQL.Statement).%New()
		Set tSql="select ID,MessageBodyClassName,MessageBodyId,SessionId,SourceConfigName,TargetConfigName,TimeCreated,Status from Ens.MessageHeader where Status=5"
		Set tSC=tSqlobj.%Prepare(tSql)
		$$$ThrowOnError(tSC)
		Set tResultSet=tSqlobj.%Execute()
		$$$ThrowOnError(tResultSet)
		Set tSC = ..Log(.pLogFile,..%ClassName(1),"DiscardSuspendedMessage","Begin Discarding the suspended messages in the schema " _ $Namespace,1) $$$ThrowOnError(tSC)
		Set tCount=0
		While (tResultSet.%Next(.tSC)) {
  			$$$ThrowOnError(tSC)
  			Set tDateTime=tResultSet.%Get("TimeCreated")
  			;Ignore the transaction if its created within pDaysToKeep
  			Set tDateDiff = $System.SQL.DATEDIFF("d",tDateTime,$ZDT($H,3))
  			
  			CONTINUE:(tDateDiff <= pDaysToKeep)
  			 			
  			Set tHeaderId=tResultSet.%Get("ID")
  			Set tSource=tResultSet.%Get("SourceConfigName")
  			Set tTarget=tResultSet.%Get("TargetConfigName")
  			
  			Continue:($D(^EAI.Suspended(tSource)))||($D(^EAI.Suspended(tTarget)))
  			
  			Set tObj=##class(Ens.MessageHeader).%OpenId(tHeaderId,,.tStatus)
  			If $ISObject(tObj){
	  			Do tObj.SetStatus($$$eMessageStatusDiscarded)
	  			Set tSave=tObj.%Save()
	  			If tSave {
		  			Set tCount=tCount+1
		  			If tCount=1 {
			  				Set tCoulmn="HeaderID"_$C(9)_$C(9)_"SourceConfigName"
			  				Set tSC = ..Log(.pLogFile,..%ClassName(1),"DiscardSuspendedMessage",tCoulmn,0) $$$ThrowOnError(tSC)
		  			}
		  			Set tMsg=$g(tHeaderId)_$C(9)_$C(9)_$g(tSource)
	  				Set tSC = ..Log(.pLogFile,..%ClassName(1),"DiscardSuspendedMessage",tMsg,0) $$$ThrowOnError(tSC)
	  			}
  			}
  		}
	} Catch exe	{
		Set tSC=exe.AsStatus()
	}
	Set tSC = ..Log(.pLogFile,..%ClassName(1),"DiscardSuspendedMessage","Total messages Discarded : "_tCount,0) $$$ThrowOnError(tSC)
	Set tSC = ..Log(.pLogFile,..%ClassName(1),"DiscardSuspendedMessage","Finished Discarding the Suspended messages in " _ $Namespace,1) $$$ThrowOnError(tSC)
	Quit tSC
}

ClassMethod Log(ByRef pLogFile As %File, pClass As %String, pMethod As %String, pText As %String, pHead As %Integer = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Check on log dir
		;Set tLogDir = ..fixPath($System.Util.ManagerDirectory() _ "EAILogs")
		Set tLogDir = ..fixPath($zu(12) _ "EAILogs")
		
		Set tDirExists = ##class(%File).DirectoryExists(tLogDir)
		If ('tDirExists) {
			Set tCreateDir = ##class(%File).CreateDirectory(tLogDir)
			If ('tCreateDir) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to create EAILogs directory."))
			}
		}
		
		 // Just close ?
 		If ($GET(pClass) = 0) {
	 		Do:+$GET(pLogFile) pLogFile.Close()
	 		Quit
 		}

		// Make logfile object pLogFile
		If ('$DATA(pLogFile)) {
			Set tFilename = ..#LOGNAME _ "_" _ $Namespace _ "_" _ $ZD($H,3)_ ".log"
			Set tFile = ##class(%File).NormalizeFilename(tFilename,tLogDir)
			Set pLogFile = ##class(%File).%New(tFile)
		}

		// Try to (re-)open if not open
		If (+pLogFile && 'pLogFile.IsOpen) {
			Do pLogFile.Open("WSA",2) // try for 2 seconds
			If ('pLogFile.IsOpen) {
				Write !, "Cannot open logfile ", pLogFile.Name
				Set pLogFile = 0
			}
		}

		// Write message to logfile and/or terminal
		Set:pHead tLine = pClass _ ":" _ pMethod _ " " _ pText
		Set:'pHead tLine=pText
		If (+pLogFile) {
			Do pLogFile.WriteLine($ZTIME($PIECE($HOROLOG,",",2),1) _ " " _ tLine)
		}
		If ($LENGTH(pLogFile)) {
			Write !, tLine
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Init this util<br/>
/// Params
///     pDaysToKeep: Number of days to keep
ClassMethod Init(pDaysToKeep As %Integer = 7) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// For each interface namespace on this instance, setup a purge task to run in 15 min increments starting at the specified hour
		
		// Run for all namespaces
		Set tStatus = ..GetEnvironment(.tEnvironment,.tInstanceType,.tInstanceName)
		$$$ThrowOnError(tStatus)
		
		// Don't init tasks in prod or for msgbk
		Quit:(tInstanceType = "MSGBK")
		
		// Loop through namespace list
		Set tQuery = "SELECT DISTINCT Namespace FROM IHC_EAI_System_Data.Namespace WHERE EnvironmentType = ? AND InstanceName = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute(tEnvironment,tInstanceName)
		
		Set tStartTime = $PIECE($System.SQL.DATEADD("d",1,$ZDT($H,3))," ",1) _ " " _ "05:00:00"
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tNamespace = tResultSet.%GetData(1)
		
			Set tStatus = ..CreateTask(tNamespace,pDaysToKeep,tStartTime)
			$$$ThrowOnError(tStatus)
			
			// Add 15 minutes
			Set tStartTime = $System.SQL.DATEADD("mi",15,tStartTime)
		}
		$$$ThrowOnError(tStatus)
		
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Create the util task
ClassMethod CreateTask(pNamespaceName As %String, pDaysToKeep As %Integer, pStartTime As %TimeStamp) As %Status
{
	Set tStatus = $$$OK
	Try {
	
		New $NAMESPACE
		Set $NAMESPACE = "%SYS"
		
		Set tTaskName = "Discard " _ pNamespaceName _ " Suspended Messages"
		Set SQLCODE = "", tCount = 0
		&sql(SELECT COUNT(*) INTO :tCount FROM %SYS.Task WHERE Name = :tTaskName)
		
		If (tCount = 0) {
			// If doesn't already exist, create
			Set tTask = ##class(%SYS.Task).%New()
			Set tTask.Name = tTaskName
			Set tTask.TaskClass = "IHC.EAI.SuspendedMessage.Util"
			Set tTask.Description = "Discard suspended messages in the " _ pNamespaceName _ " namespace"
			Set tTask.NameSpace = pNamespaceName
			Set tTask.TimePeriod = 0
			Set tTask.DailyStartTime = $ZTIMEH($PIECE(pStartTime," ",2))
			Set tTaskDef = ##class(IHC.EAI.SuspendedMessage.Util).%New()
			Set tTaskDef.DaysToKeep = pDaysToKeep
			Set tStatus = tTask.AssignSettings(tTaskDef)
			$$$ThrowOnError(tStatus)
			Set tStatus = tTask.%Save()
			$$$ThrowOnError(tStatus)
		}
	
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
