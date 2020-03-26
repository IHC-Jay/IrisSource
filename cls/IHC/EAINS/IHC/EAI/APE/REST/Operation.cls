Class IHC.EAI.APE.REST.Operation Extends EnsLib.REST.GenericOperation
{

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	Set tStatus = $$$OK
	
	Try {
		
		Do ##super()
		
		// Determine how to configure the http endpoint
		Set tServerHost = $GET(^EAI.Setting("APEServiceHost"),"lpv-itfapenonprd01")
		Set tServerPort = $GET(^EAI.Setting("APEServicePort"),"8080")
		
		Set:(tServerHost '= "") ..Adapter.HTTPServer = tServerHost
		Set:(tServerPort '= "") ..Adapter.HTTPPort = tServerPort
		
		Set ..Adapter.URL = "/ape/services/rest/ensemble/messagelistenerservice/receive/message.ape"

	} Catch eException {
		Set tStatus = eException.AsStatus()
	}
	
	Quit tStatus
}

}
