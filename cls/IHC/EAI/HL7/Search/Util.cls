Class IHC.EAI.HL7.Search.Util Extends IHC.EAI.Log.Util
{

Parameter LOGNAME = "EAI.HL7.Search";

/// This message will scan the message history for HL7 messages <br/>
/// Params:<br/>
///   pMessageCount: The total number of matches found<br/>
///   pLogLevel:<br/>
///     0 = No log, 1 = Matches and total matches count, 2 = All (including non-matches)<br/>
///   pTimeCreatedStart: TimeStamp format; TimeCreated message header field - required<br/>
///     **TimeCreated range defaults to last 1 hour. To increase range, use the following syntax:<br/>
///     **pTimeCreatedStart = $System.SQL.DATEADD("h",-6,$ZDT($H,3))	<- Increase to last 6 hours
///   pTimeCreatedEnd: TimeStamp format; TimeCreated message header field - required<br/>
///   pSourceConfigName: The business component config name that is the source of the message<br/>
///   pTargetConfigName: The business component config name that is the target of the message<br/>
///   pHL7MessageType: The HL7 message type; e.g., ADT^A01<br/>
///   pHL7SegmentType: The Segment type; e.g., PID; (used in combo with FieldName and FieldValue)<br/>
///   pHL7FieldName: The HL7 FieldName; e.g., 2.1 or PatientID.ID; (used in combo with SegmentType and FieldValue)<br/>
///   pHL7FieldValue: The HL7 FieldValue; e.g., a patient name, account num, or other identifier; (used in combo with SegmentType and FieldName)<br/>
/// Examples:<br/>
///   1) All A08 messages from Cern-Adt-Hl7_Legacy to Cern-Adt-Hl7_Webcollect during the last hour<br/>
///     Set tStatus = ##class(IHC.EAI.HL7.Search.Util).Search(.tCount,.tLogFile,1,0,,,"Cern-Adt-Hl7_Legacy","Cern-Adt-Hl7_Webcollect","ADT^A08")<br/>
///   2) All messages involving patient with EMPI 123123123 (PID:3(1).1 to Cern legacy) during the last 3 hour<br/>
///      Set tStatus = ##class(IHC.EAI.HL7.Search.Util).Search(.tCount,.tLogFile,1,0,$System.SQL.DATEADD("h",-3,$ZDT($H,3)),,,"Cern-Adt-Hl7_Legacy",,"PID","3(1).1","123123123")<br/>
ClassMethod Search(Output pMessageCount As %Integer, Output pLogFile As %File, pLogLevel As %Integer = 0, pExtractMessageDetails As %Boolean = 0, pTimeCreatedStart As %TimeStamp = { $System.SQL.DATEADD("h",-1,$ZDT($H,3))}, pTimeCreatedEnd As %TimeStamp = { $ZDT($H,3)}, pSourceConfigName As %String = "", pTargetConfigName As %String = "", pHL7MessageType As %String = "", pHL7SegmentType As %String = "", pHL7FieldName As %String = "", pHL7FieldValue As %String = "") As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	#Dim tHL7Message As EnsLib.HL7.Message
	
	Set tStatus = $$$OK, pMessageCount = 0
	Try {
		Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Search","---BEGIN: " _ $ZDT($H,3) _ "---")
		// Develop the initial query based on the timestamps
		Set tMHQuery = 	"SELECT mh.%Id,mh.MessageBodyClassName,mh.MessageBodyId " _
						"FROM Ens.MessageHeader mh " _ 
						"WHERE " _
							"mh.%Id >= (SELECT TOP 1 ID FROM Ens.MessageHeader AS mh1 WHERE mh1.TimeCreated >= '" _ pTimeCreatedStart _ "' ORDER BY mh1.TimeCreated ASC) AND " _
							"mh.%Id <= (SELECT TOP 1 ID FROM Ens.MessageHeader AS mh2 WHERE mh2.TimeCreated <= '" _ pTimeCreatedEnd _ "' ORDER BY mh2.TimeCreated DESC) AND " _
							"mh.MessageBodyId IS NOT NULL AND mh.Type = 'Request'"
		
		If (pSourceConfigName '= "") {
			Set tMHQuery = tMHQuery _ " AND mh.SourceConfigName = '" _ pSourceConfigName _ "'"
		}
		
		If (pTargetConfigName '= "") {
			Set tMHQuery = tMHQuery _ " AND mh.TargetConfigName = '" _ pTargetConfigName _ "'"
		}
		
		Do:(pLogLevel >= 3) ..Log(.pLogFile,$Classname(),"Search","Query: " _ tMHQuery)
		
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatement.%SelectMode = 2
		Set tStatus = tStatement.%Prepare(tMHQuery)
		$$$ThrowOnError(tStatus)
		Set tResultSet = tStatement.%Execute()
		
		While (tResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tMHId = tResultSet.%GetData(1)
			Set tMBClassName = tResultSet.%GetData(2)
			Set tMBId = tResultSet.%GetData(3)
			
			CONTINUE:(tMBClassName = "")
			CONTINUE:(tMBId = "")
			
			Set tIsAHL7Message = $CLASSMETHOD(tMBClassName,"%IsA","EnsLib.HL7.Message")
			Set tExtendsHL7Message = $CLASSMETHOD(tMBClassName,"%Extends","EnsLib.HL7.Message")
			
			If ((tIsAHL7Message) || (tExtendsHL7Message)) {
				
				// Open the object
				Set tHL7Message = $CLASSMETHOD(tMBClassName,"%OpenId",tMBId,,.tStatus)
				$$$ThrowOnError(tStatus)
				
				// Message type
				Set tMessageType = tHL7Message.GetValueAt("MSH:9.1") _ "^" _ tHL7Message.GetValueAt("MSH:9.2")
				If ((pHL7MessageType '= "") && (pHL7MessageType '= tMessageType)) {
					Do:(pLogLevel >= 3) ..Log(.pLogFile,$Classname(),"Search","Message type does not match: " _ tMHId _ "|" _ tMBClassName _ "|" _ tMBId _ "|" _ tMessageType)					
					CONTINUE
				}
				
				// Field value
				Set tFieldValuePath = pHL7SegmentType _ ":" _ pHL7FieldName
				Set tFieldValue = tHL7Message.GetValueAt(tFieldValuePath)
				
				If ((pHL7FieldValue '= "") && (pHL7FieldValue '= tFieldValue)) {
					Do:(pLogLevel >= 3) ..Log(.pLogFile,$Classname(),"Search","Field does not match: " _ tMHId _ "|" _ tMBClassName _ "|" _ tMBId _ "|" _ tFieldValuePath _ "|" _ tFieldValue)
					CONTINUE
				}
				
				// Found a match...count it
				Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"Search",tMHId _ "|" _ tMBClassName _ "|" _ tMBId  _ "|" _ tMessageType _ "|" _ tFieldValuePath _ "|" _ tFieldValue)
				Set pMessageCount = pMessageCount + 1
				
				If (pExtractMessageDetails) {
					Set tStatus = ..MessageDetails(.tDetailSummary,tMHId)
					$$$ThrowOnError(tStatus)
					
					Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"Search","*** Detail Summary ***" _ tDetailSummary)
				}
				
			} Else {
				CONTINUE
			}
		}
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Search","Total match count: " _ pMessageCount)
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"Search","---END " _ $ZDT($H,3) _ "---")
	Quit tStatus
}

/// Set tStatus = ##class(IHC.EAI.HL7.Search.Util).IndexedSearch(.tMessageCount,.tLogFile,1,0,"PatientName","RoGeR")
/// MSHControlID,MSHTypeName,PatientAcct,PatientID,PatientName
ClassMethod IndexedSearch(Output pMessageCount As %Integer = 0, Output pLogFile As %File, pLogLevel As %Integer = 0, pExtractMessageDetails As %Boolean = 0, pPropName As %String = "", pPropValue As %String = "", pSourceConfigName As %String = "", pTargetConfigName As %String = "") As %Status
{
	#Dim tResultSet As %SQL.StatementResult
	#Dim tHL7Message As EnsLib.HL7.Message
	
	
	Set tStatus = $$$OK
	Try {
		
		// Develop the query
		Set tIdxQuery = "SELECT " _
							"st.ID AS SearchTableID, " _
							"st.DocId AS DocId " _
						"FROM EnsLib_HL7.SearchTable AS st " _ 
						"INNER JOIN Ens_Config.SearchTableProp AS stp ON " _
							"stp.PropId = st.PropId AND " _
							"stp.ClassExtent = 'EnsLib.HL7.SearchTable' " _
						"WHERE " _
							"stp.Name = ? AND " _
							"st.PropValue [ LOWER(?)"
		
		Do:(pLogLevel >= 2) ..Log(.pLogFile,$Classname(),"IndexedSearch","IdxQuery: " _ tIdxQuery)
		Set tIdxStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tIdxStatement.%Prepare(tIdxQuery)
		$$$ThrowOnError(tStatus)
		Set tIdxResultSet = tIdxStatement.%Execute(pPropName,pPropValue)
		
		While (tIdxResultSet.%Next(.tStatus)) {
			$$$ThrowOnError(tStatus)
			
			Set tSTId = tIdxResultSet.%GetData(1)
			Set tDocId = tIdxResultSet.%GetData(2)
			
			// Query the mh table for this doc id
			Set tMHQuery = "SELECT %Id,MessageBodyClassName,MessageBodyId FROM Ens.MessageHeader WHERE MessageBodyId = ?"
			If (pSourceConfigName '= "") {
				Set tMHQuery = tMHQuery _ " AND SourceConfigName = '" _ pSourceConfigName _ "'"
			}
			If (pTargetConfigName '= "") {
				Set tMHQuery = tMHQuery _ " AND TargetConfigName = '" _ pTargetConfigName _ "'"
			}
			
			Set tMHStatement = ##class(%SQL.Statement).%New()
			Set tStatus = tMHStatement.%Prepare(tMHQuery)
			$$$ThrowOnError(tStatus)
			Set tMHResultSet = tMHStatement.%Execute(tDocId)
			
			While (tMHResultSet.%Next(.tStatus)) {
				$$$ThrowOnError(tStatus)
				
				Set tMHId = tMHResultSet.%GetData(1)
				Set tMBClassName = tMHResultSet.%GetData(2)
				Set tMBId = tMHResultSet.%GetData(3)
				
				CONTINUE:(tMBClassName = "")
				CONTINUE:(tMBId = "")
				
				Set tIsAHL7Message = $CLASSMETHOD(tMBClassName,"%IsA","EnsLib.HL7.Message")
				Set tExtendsHL7Message = $CLASSMETHOD(tMBClassName,"%Extends","EnsLib.HL7.Message")
				
				If ((tIsAHL7Message) || (tExtendsHL7Message)) {
					
					// Open the object
					Set tHL7Message = $CLASSMETHOD(tMBClassName,"%OpenId",tMBId,,.tStatus)
					$$$ThrowOnError(tStatus)
					
					// Found a match...count it
					Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"IndexedSearch",tMHId _ "|" _ tMBClassName _ "|" _ tMBId)
					Set pMessageCount = pMessageCount + 1
					
					If (pExtractMessageDetails) {
						Set tStatus = ..MessageDetails(.tDetailSummary,tMHId)
						$$$ThrowOnError(tStatus)
						
						Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"IndexedSearch","*** Detail Summary ***" _ tDetailSummary)
					}
					
				} Else {
					CONTINUE
				}
			}
			$$$ThrowOnError(tStatus)
		}
		$$$ThrowOnError(tStatus)
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	
	Do:(pLogLevel >= 1) ..Log(.pLogFile,$Classname(),"IndexedSearch","Total match count: " _ pMessageCount)
	Quit tStatus
}

/// Collect and output the message details for an HL7 message body and associated header<br/>
/// Set tStatus = ##class(IHC.EAI.HL7.Search.Util).MessageDetails(.tDetailSummary,1224298879)
ClassMethod MessageDetails(Output pDetailSummary As %String = "", pMessageHeaderId As %Integer = -1) As %Status
{
	Set tStatus = $$$OK
	Try {
		
		Set tMessageHeader = ##class(Ens.MessageHeader).%OpenId(pMessageHeaderId,,.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set pDetailSummary = $C(13,10) _ "--- Message Header ---" _ $C(13,10)
		
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("MessageHeaderId"),25)) _ pMessageHeaderId _ $C(13,10)
		Set tSessionId = tMessageHeader.SessionId
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("SessionId"),25)) _ tSessionId _ $C(13,10)
		Set tTimeCreated = ..ConvertUTCToLocal(tMessageHeader.TimeCreated)
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("TimeCreated"),25)) _ tTimeCreated _ $C(13,10)
		Set tTimeProcessed = ..ConvertUTCToLocal(tMessageHeader.TimeProcessed)
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("TimeProcessed"),25)) _ tTimeProcessed _ $C(13,10)
		Set tSourceConfigName = tMessageHeader.SourceConfigName
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("SourceConfigName"),25)) _ tSourceConfigName _ $C(13,10)
		Set tSourceBusinessType = tMessageHeader.SourceBusinessType
		Set tSourceBusinessType = $CASE(tSourceBusinessType,0:"Unknown",1:"BusinessService",2:"BusinessProcess",3:"BusinessOperation","":"Unknown")
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("SourceBusinessType"),25)) _ tSourceBusinessType _ $C(13,10)
		Set tTargetConfigName = tMessageHeader.TargetConfigName
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("TargetConfigName"),25)) _ tTargetConfigName _ $C(13,10)
		Set tTargetBusinessType = tMessageHeader.TargetBusinessType
		Set tTargetBusinessType = $CASE(tTargetBusinessType,0:"Unknown",1:"BusinessService",2:"BusinessProcess",3:"BusinessOperation","":"Unknown")
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("TargetBusinessType"),25)) _ tTargetBusinessType _ $C(13,10)
		Set tMessageHeaderStatus = ..MHStatusLogicalToDisplay(tMessageHeader.Status)
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("Status"),25)) _ tMessageHeaderStatus _ $C(13,10)
		
		Set pDetailSummary = pDetailSummary _ $C(13,10) _ "--- Message Body ---" _ $C(13,10)
		Set tMessageBodyClassName = tMessageHeader.MessageBodyClassName
		
		If (tMessageBodyClassName '= "EnsLib.HL7.Message") {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Unrecognized message body class: " _ tMessageBodyClassName))	
		}
		
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("MessageBodyClassName"),25)) _ tMessageBodyClassName _ $C(13,10)
		Set tMessageBodyId = tMessageHeader.MessageBodyId
		Set pDetailSummary = pDetailSummary _ $RE($J($RE("MessageBodyId"),25)) _ tMessageBodyId _ $C(13,10)
		
		Set tMessageBody = ##class(EnsLib.HL7.Message).%OpenId(tMessageBodyId,,.tStatus)
		$$$ThrowOnError(tStatus)
		
		
		Set tSeg = tMessageBody.GetSegmentAt(1)
		Set tSeparators = $S($IsObject(tSeg):tSeg.Separators,1:"")
		Set:$E(tMessageBody.Separators,1,$L(tSeparators))'=$E(tSeparators,1,$L(tMessageBody.Separators)) tSeparators=$E(tMessageBody.Separators,1,$L(tSeparators))_$E(tSeparators,1+$L(tMessageBody.Separators),*)
		Set:$C(10)'=$E(tSeparators,*) tSeparators=tSeparators_$C(10)
		Set:$C(13)'=$E(tSeparators,*-1) tSeparators=$E(tSeparators,1,*-1)_$C(13,10)
		Set tMessageString = tMessageBody.OutputToString(tSeparators,,.tStatus)
		$$$ThrowOnError(tStatus)
		
		Set pDetailSummary = pDetailSummary _ $C(13,10) _ tMessageString _ $C(13,10)
		
		//Write !, pDetailSummary
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	Quit tStatus
}

ClassMethod ConvertUTCToLocal(pUTC As %String) As %String [ Internal ]
{
 	QUIT $ZDT($zu(193,$ZDTH(pUTC,3),0),3,,3)
}

ClassMethod MHStatusLogicalToDisplay(pStatus As %Integer) As %String [ Internal ]
{
	Quit $CASE(pStatus,1:"Created",2:"Queued",3:"Delivered",4:"Discarded",5:"Suspended",6:"Deferred",7:"Aborted",8:"Error",9:"Completed")
}

}
