Class IHC.EAI.APE.Transform.EnsAlertToAPEAlert Extends Ens.DataTransform
{

/// Transform from Ens AlertRequest to an JSON APE message
ClassMethod Transform(pSource As Ens.AlertRequest, ByRef pTarget As EnsLib.HTTP.GenericMessage) As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	#Dim tAPEInfo As IHC.ITF.ITFCOMMON.ApeInformation
	
	Set tStatus = $$$OK
	Try {
		Set pTarget = ##class(EnsLib.HTTP.GenericMessage).%New()
		
		#; Create the APE Info object
		Set tStatus = ..CreateAPEInfo(pSource,.tAPEInfo)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ..GetInputData(pSource,.tAPEInfo)
		$$$ThrowOnError(tStatus)
		
  		Set tStatus = ..CreateJSONStream(tAPEInfo,.tJSONStream)
  		$$$ThrowOnError(tStatus)
  		
  		Set tStatus = pTarget.HTTPHeaders.SetAt("application/json","content-type")
  		$$$ThrowOnError(tStatus)
  
    	Set tStatus = pTarget.HTTPHeaders.SetAt(tJSONStream.Size,"content-length")
    	$$$ThrowOnError(tStatus)
    	
    	Set pTarget.Stream = tJSONStream
    
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Get the input data from the message header/body
ClassMethod CreateAPEInfo(pSource As Ens.AlertRequest, Output pAPEInfo As IHC.ITF.ITFCOMMON.ApeInformation) As %Status [ Internal, Private ]
{
	Set tStatus = $$$OK
	Try {
		
		Set pAPEInfo = ##class(IHC.ITF.ITFCOMMON.ApeInformation).%New()
   		Set pAPEInfo.hostname = $SYSTEM.INetInfo.LocalHostName()
   		//Set pAPEInfo.applicationname = "Ensemble"	// Not included yet in APE info obj
   		Set pAPEInfo.groupname = $NAMESPACE
		Set pAPEInfo.comment = pSource.AlertDestination
		Set pAPEInfo.messagedata = pSource.AlertText
		Set pAPEInfo.msgtimestamp = pSource.AlertTime
		//":"2014-04-25 16:17:46.774"
		Set pAPEInfo.msgtimestampformat = "yyyy-mm-dd hh24:mi:ss.ms"
		Set pAPEInfo.processname = pSource.SourceConfigName
		Set pAPEInfo.sessionId = pSource.SessionId
		
		// Determine error type
		Set tErrorType = ..GetErrorType(pSource.AlertText,.tStatus)
		$$$ThrowOnError(tStatus)
		
		$$$TRACE(pSource.AlertText)
		
		// find sub error id
		If (tErrorType = "ITFCOMMON") {
			Set itfErr = "ITFCOMMON:"
   			Set ind = $FIND(pSource.AlertText,itfErr)
			Set ind2 = $FIND(pSource.AlertText,":",ind)
			Set pAPEInfo.issuecode = $EXTRACT(pSource.AlertText,ind-$L(itfErr),ind2-2)
			Set emailMsg = "SendEmailSuccess|SendEmailError"
			Set ind = $LOCATE(pSource.AlertText,emailMsg)
			If (ind > 0) {
				$$$TRACE("Send email message")
				Set emailSub = "emailSubject:"
				Set emailBody = "emailBody:"
				Set ind2 = $FIND(pSource.AlertText,emailSub)
				Set ind3 = $FIND(pSource.AlertText,emailBody)
				If (ind3 > ind2) {
					Set pAPEInfo.emailSubject = $EXTRACT(pSource.AlertText,ind2,ind3-($L(emailBody)+1) )
					Set pAPEInfo.emailBody = $EXTRACT(pSource.AlertText,ind3,*) 
				} Else {
					Set pAPEInfo.emailSubject = $EXTRACT(pSource.AlertText,ind2,*)
				}
				If (ind2 > 1) {
					Set pAPEInfo.messagedata = $EXTRACT(pSource.AlertText,1,ind2-($L(emailSub)+1))
				}
			}
			
		} ElseIf (tErrorType = "EAI") {
			// Parse
			Set tErrorPrefix = "EAI:"
			Set pAPEInfo.issuecode = $PIECE(pSource.AlertText," ",1)
		} Else {
			// Intersystem error
			Set intSysErr = "ERROR #"
			Set ind = $FIND(pSource.AlertText, intSysErr )
			If (ind > 0) {
				Set ind2 = $FIND(pSource.AlertText,":",ind)
				Set pAPEInfo.issuecode = $EXTRACT(pSource.AlertText,ind-$L(intSysErr),ind2-2)
			} Else {
				Set intSysErr = "ERROR"
				Set ind = $FIND(pSource.AlertText,intSysErr)
				If (ind > 0) {
					Set ind2 = $FIND(pSource.AlertText,":")
					If (ind2 > 0) {
						Set pAPEInfo.issuecode = $EXTRACT(pSource.AlertText,ind-$LENGTH(intSysErr),ind2-2)
						Set pAPEInfo.issuecode = $REPLACE(pAPEInfo.issuecode,$CHAR(92)_"u003c","<")
						Set pAPEInfo.issuecode = $REPLACE(pAPEInfo.issuecode, $CHAR(92)_"u003e",">")
					} Else {
						Set pAPEInfo.issuecode = "Unknown"
					}
				} Else {
					$$$TRACE("Search error from Global: ITFCOMMON|IHC.ITF.AlertErrorCodes")
					Set pAPEInfo.issuecode = "Unknown"
					Set issFound  = 0
					If ($DATA(^|"ITFCOMMON"|IHC.ITF.AlertErrorCodes) = 0) { 
						Set ^|"ITFCOMMON"|IHC.ITF.AlertErrorCodes = $LISTBUILD("InactivityTimeoutAlert","QueueCountAlert","QueueWaitAlert")
					}
					For i=1:1:$LISTLENGTH(^|"ITFCOMMON"|IHC.ITF.AlertErrorCodes) {
						Set value = $LIST(^|"ITFCOMMON"|IHC.ITF.AlertErrorCodes,i)

						Set issFound = $F(pSource.AlertText, value)
						If (issFound  > 0) {
							Set pAPEInfo.issuecode = value
						}   
					}
					If (issFound <= 0) {
						$$$LOGERROR("Issue NOT FOUND in Global IHC.ITF.AlertErrorCodes")
					}
				}
			}
			
		}
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod GetErrorType(pAlertText As %String, Output pStatus As %Status = {$$$OK}) As %String
{
	Set tErrorType = "ISC"
	Try {
		Set:($FIND(pAlertText,"ITFCOMMON:")) tErrorType = "ITFCOMMON"
		Set:($FIND(pAlertText,"EAI")) tErrorType = "EAI"
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tErrorType
}

/// Get the input data from the message header/body
ClassMethod GetInputData(pSource As %RegisteredObject, ByRef pAPEInfo As IHC.ITF.ITFCOMMON.ApeInformation) As %Status [ Internal, Private ]
{
	Set tStatus = $$$OK
	Try {
		#; Query for original message body
		Set tQuery = 	"SELECT MessageBodyId,MessageBodyClassName " _
						"FROM Ens.MessageHeader " _
                		"WHERE Type = ? AND TargetConfigName = ? AND SessionId = ?"
		Set tStatement = ##class(%SQL.Statement).%New()
  		Set tStatus = tStatement.%Prepare(tQuery)
  		$$$ThrowOnError(tStatus)
  		
  		Set tResultSet = tStatement.%Execute(1,pSource.SourceConfigName,pSource.SessionId)
  		
  		If (tResultSet.%SQLCODE = 0) {
	  		While (tResultSet.%Next(.tStatus)) {
		  		$$$ThrowOnError(tStatus)
		  		
		  		Set tMessageBodyId = tResultSet.%GetData(1)
		  		Set tMessageBodyClassName = tResultSet.%GetData(2)
		  		//$$$LOGINFO( "Data: " _ tMessageBodyId _ ", type: " _ tMessageBodyClassName)
		  		
		  		If (tMessageBodyClassName = "EnsLib.HL7.Message") {	// @TODO Adjust this to be anything that inherits from HL7 message
			  		// Extract first 2k chars of HL7 message
			  		Set tTmpObject = ##class(EnsLib.HL7.Message).%OpenId(tMessageBodyId,,.tStatus)
			  		$$$ThrowOnError(tStatus)
	 				Set pAPEInfo.inputData  = $EXTRACT(tTmpObject.OutputToString(),1,2000)
	     		} ElseIf(tMessageBodyClassName = "Ens.StreamContainer") {
	     		    // Extract original filename of stream container
	     		    Set tStreamContainer = ##class(Ens.StreamContainer).%OpenId(tMessageBodyId,,.tStatus)
	     		    $$$ThrowOnError(tStatus)
	     			Set pAPEInfo.inputData  = "OriginalFilename: " _ tStreamContainer.OriginalFilename
	     		} ElseIf (tMessageBodyClassName = "Ens.StringRequest") {
	     		    // Extract first 2k chars of string request   
	     		    Set tStringReq = ##class(Ens.StringRequest).%OpenId(tMessageBodyId,,.tStatus)
	     		    $$$ThrowOnError(tStatus)
	     			Set pAPEInfo.inputData = $EXTRACT(tStringReq.StringValue, 1, 2000)
	     		} ElseIf(tMessageBodyClassName = "Ens.StringContainer") {
	     		    // Extract first 2k chars of string request   
	     		    Set tStringContainer = ##class(Ens.StringContainer).%OpenId(tMessageBodyId,,.tStatus)
	     		    $$$ThrowOnError(tStatus)
	     			Set pAPEInfo.inputData  = $EXTRACT(tStringContainer.StringValue, 1, 2000)
	     		} Else {
	     		   Set pAPEInfo.inputData  = "MessageBodyClassName: " _tMessageBodyClassName _ ", MessageBodyId: " _ tMessageBodyId
	     		}
	     	    
	     	    //$$$LOGINFO("Copied Input message: " _ apeInfo.inputData)
	  		}
			$$$ThrowOnError(tStatus)
	  		
	  		Kill tResultSet, tStatement
  		} Else {
	  		Set pAPEInfo.inputData  = "Could not get input record for session: " _ pSource.SessionId _ " for component: " _ pSource.SourceConfigName	
  		}
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

/// Create the APE REST message data stream
ClassMethod CreateJSONStream(ByRef pAPEInfo As IHC.ITF.ITFCOMMON.ApeInformation, Output pJSONStream As %Stream.GlobalBinary) As %Status [ Internal, Private ]
{
	Set tStatus = $$$OK, pJSONStream = ""
	Try {
  		// create data stream
		Set pJSONStream = ##class(%Stream.GlobalBinary).%New()
		
  		Set tStatus = ##class(%ZEN.Auxiliary.jsonProvider).%WriteJSONStreamFromObject(.pJSONStream,pAPEInfo)
  		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

}
