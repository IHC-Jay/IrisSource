Class IHC.EAI.Log.Util Extends IHC.EAI.Common.Util
{

Parameter LOGNAME = "EAI.General";

/// Log a message to the InstallLogFile and/or to the Terminal<br/>
/// pLogFile - file to write log into<br/>
///  undefined = not open, try to open $$$InstallLogFile<br/>
///  "" = do not log<br/>
///  0 = log only to terminal<br/>
///  oref = open logfile (append mode)<br/>
///  pClass = 0 means close log<br/>
ClassMethod Log(ByRef pLogFile As %File, pClass As %String, pMethod As %String, pText As %String) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		// Check on log dir
		Set tLogDir = ..fixPath($System.Util.ManagerDirectory() _ "EAILogs")

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
			Set tFilename = ..#LOGNAME _ "_" _ $Namespace _ "_" _ $TR($TR($ZDT($H,3)," ","_"),":","") _ ".log"
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
		Set tLine = pClass _ ":" _ pMethod _ " " _ pText
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
