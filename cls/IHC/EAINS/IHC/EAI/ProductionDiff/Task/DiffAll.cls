Class IHC.EAI.ProductionDiff.Task.DiffAll Extends %SYS.Task.Definition {

/// This defines the user-visible name of this task;
/// This is defined in subclasses.
Parameter TaskName As STRING = "Generate and Diff Production XML";

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Export the production XML and create the diff results if a previous export exists
		Set tStatus = ##class(IHC.EAI.ProductionDiff.Util).DiffAll()
		$$$ThrowOnError(tStatus)
			
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}