Class IHC.EAI.KPI.Task.GenerateAndSendReport Extends %SYS.Task.Definition
{

/// This defines the user-visible name of this task;
/// This is defined in subclasses.
Parameter TaskName As STRING = "Generate and Send KPI Report";

/// Comma-delimited list of email addresses
Property ToList As %String(MAXLEN = "");

/// Comma-delimited list of email addresses
Property CcList As %String(MAXLEN = "");

/// Comma-delimited list of email addresses
Property BccList As %String(MAXLEN = "");

/// The KPI class name to be executed
Property Report As %String(MAXLEN = 250, VALUELIST = ",IHC.EAI.KPI.Report.MonthlyCounts");

/// This method is responsible for executing the task.<br>
/// At the scheduled time, the Task Manager creates an instance of this object,
/// sets any property values using the stored "settings" for the task, and then
/// invokes this method to execute the task.<br>
/// In order to execute a real task, override this method in a subclass.
Method OnTask() As %Status
{
	Set tStatus = $$$OK
	Try {
		Set tToListTemp = $LISTFROMSTRING(..ToList)
		Set tToList = ##class(%ListOfDataTypes).%New()
		For i=1:1:$LISTLENGTH(tToListTemp) {
			Do tToList.Insert($LISTGET(tToListTemp,i))
		}
		Set tCcListTemp = $LISTFROMSTRING(..CcList)
		Set tCcList = ##class(%ListOfDataTypes).%New()
		For i=1:1:$LISTLENGTH(tCcListTemp) {
			Do tCcList.Insert($LISTGET(tCcListTemp,i))
		}
		Set tBccListTemp = $LISTFROMSTRING(..BccList)
		Set tBccList = ##class(%ListOfDataTypes).%New()
		For i=1:1:$LISTLENGTH(tBccListTemp) {
			Do tBccList.Insert($LISTGET(tBccListTemp,i))
		}
		
		Set tStatus = $CLASSMETHOD(..Report,"SendReport",tToList,tCcList,tBccList)
		$$$ThrowOnError(tStatus)
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
