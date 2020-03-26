Class IHC.EAI.Report.Util Extends IHC.EAI.Log.Util
{

Parameter REPORTNAME = "EAI.Report";

/// Write a report line to the designated report file and/or to the Terminal<br/>
/// pReportFile - file to write line into<br/>
///  undefined = not open, try to open ---<br/>
///  "" = do not write <br/>
///  0 = write only to terminal<br/>
///  oref = open report file (append mode)<br/>
///  pClass = 0 means close report file<br/>
ClassMethod Report(ByRef pReportFile As %File, pReportName As %String, pLine As %String, pCloseReport As %Boolean = 0) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Check on log dir
		Set tLogDir = ..fixPath($System.Util.ManagerDirectory() _ "EAIReports")

		Set tDirExists = ##class(%File).DirectoryExists(tLogDir)
		If ('tDirExists) {
			Set tCreateDir = ##class(%File).CreateDirectory(tLogDir)
			If ('tCreateDir) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to create EAILogs directory."))
			}
		}
		 // Just close ?
 		If (pCloseReport) {
	 		Do:+$GET(pReportFile) pReportFile.Close()
	 		Write !, "Report created: " _ pReportFile.Name
	 		Quit
 		}

		// Make report file obj
		If ('$DATA(pReportFile)) {
			If ($LENGTH(pReportName)) = 0 {
				Set tFilename = ..#REPORTNAME _ "." _ $I(^%SYS("EAI","Report"))_".txt"
			} Else {
				Set tFilename = pReportName _ "." _ $I(^%SYS("EAI","Report"))_".txt"
			}
			Set tFile = ##class(%File).NormalizeFilename(tFilename,tLogDir)
			Set pReportFile = ##class(%File).%New(tFile)
		}

		// Try to (re-)open if not open
		If (+pReportFile && 'pReportFile.IsOpen) {
			Do pReportFile.Open("WSA",2) // try for 2 seconds
			If ('pReportFile.IsOpen) {
				Write !, "Cannot open report file ", pReportFile.Name
				Set pReportFile = 0
			}
		}

		// Write message to report file
		If (+pReportFile) {
			Do pReportFile.WriteLine(pLine)
		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Append '/' to <var>pPath</var> if it is missing and we are not running on VMS.
ClassMethod fixPath(pPath As %String) As %String
{
	If ""'=pPath {
		If $$$isVMS {
			Quit ##Class(%File).NormalizeDirectory(pPath)
		} ElseIf $$$isUNIX {
			Set pPath = $Translate(pPath,"\","/")
			Quit:("/" '= $E(pPath,*)) pPath_"/"
		} Else {
			Set pPath = $Translate(pPath,"/","\")
			Quit:("\" '= $E(pPath,*)) pPath_"\"
		}
	}
	Quit pPath
}

}
