Class IHC.EAI.Queue.Task.PurgeQueues Extends %SYS.Task.Definition {
	
/// This defines the user-visible name of this task;
/// This is defined in subclasses.
Parameter TaskName As STRING = "Purge Queues";

/// Number of days to keep (based on when message was created/added to the queue)
Property DaysToKeep As %Integer [ InitialExpression = 7 ];

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status {
	Set tStatus = $$$OK
	Try {
		
		Set tStatus = ##class(IHC.EAI.Queue.Util).PurgeQueues(..DaysToKeep,1)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}