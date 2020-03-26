Class IHC.EAI.Common.Operation.Email Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.EMail.OutboundAdapter";

Property Adapter As EnsLib.EMail.OutboundAdapter;

Parameter INVOCATION = "Queue";

XData MessageMap
{
<MapItems>
  <MapItem MessageType="IHC.EAI.Common.Message.EmailRequest">
    <Method>SendEmail</Method>
  </MapItem>
</MapItems>
}

Method SendEmail(pRequest As IHC.EAI.Common.Message.EmailRequest, Output pResponse As IHC.EAI.Common.Message.EmailResponse) As %Status
{
	Set tStatus = $$$OK
	Try {
		Set pResponse = ##class(IHC.EAI.Common.Message.EmailResponse).%New()
		
		Set tMessage = ##class(%Net.MailMessage).%New()
		Set tMessage.Subject = pRequest.Subject
		Set tMessage.From = pRequest.From
		Set tMessage.IsBinary = pRequest.IsBinary
		Set tMessage.IsHTML = pRequest.IsHTML
		Set tMessage.ContentType = pRequest.ContentType
		
		For i=1:1:pRequest.To.Count() {
			Do tMessage.To.Insert(pRequest.To.GetAt(i))	
		}
		
		For i=1:1:pRequest.Cc.Count() {
			Do tMessage.Cc.Insert(pRequest.Cc.GetAt(i))	
		}
		
		For i=1:1:pRequest.Bcc.Count() {
			Do tMessage.Bcc.Insert(pRequest.Bcc.GetAt(i))	
		}
		
		// Copy the body content
		Set tStatus = tMessage.BinaryData.CopyFrom(pRequest.BinaryData)
		$$$ThrowOnError(tStatus)
		Do tMessage.TextData.CopyFrom(pRequest.TextData)
		$$$ThrowOnError(tStatus)
		
		Set tStatus = ..Adapter.SendMail(tMessage,.tFailedRecipients)
		$$$ThrowOnError(tStatus)
		
		Set pResponse.FailedRecipients = tFailedRecipients
		
	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
  	Quit tStatus
}

}
