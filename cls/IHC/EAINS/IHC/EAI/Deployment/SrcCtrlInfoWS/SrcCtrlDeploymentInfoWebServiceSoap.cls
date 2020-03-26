Class IHC.EAI.Deployment.SrcCtrlInfoWS.SrcCtrlDeploymentInfoWebServiceSoap Extends %SOAP.WebClient [ ProcedureBlock ]
{

/// This is the URL used to access the web service.
Parameter LOCATION = "http://lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.cls";

/// This is the namespace used by the Service
Parameter NAMESPACE = "lp-itfprdfs01:23974/csp/healthshare/itfcommon";

/// Use xsi:type attribute for literal types.
Parameter OUTPUTTYPEATTRIBUTE = 1;

/// Determines handling of Security header.
Parameter SECURITYIN = "ALLOW";

/// This is the name of the Service
Parameter SERVICENAME = "SrcCtrlDeploymentInfoWebService";

/// This is the SOAP version supported by the service.
Parameter SOAPVERSION = 1.1;

Method GetClassInformation(clsName As %String, env As %String, revNum As %String) As %ListOfDataTypes(ELEMENTTYPE="%String",XMLITEMNAME="GetClassInformationResultItem",XMLNAME="GetClassInformationResult") [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("GetClassInformation").Invoke($this,"lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.GetClassInformation",.clsName,.env,.revNum)
}

Method GetClassesForComponent(compNm As %String, nmSp As %String, rev As %String) As %ListOfDataTypes(ELEMENTTYPE="%String",XMLITEMNAME="GetClassesForComponentResultItem",XMLNAME="GetClassesForComponentResult") [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("GetClassesForComponent").Invoke($this,"lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.GetClassesForComponent",.compNm,.nmSp,.rev)
}

Method GetLastImplementationDetails(compName As %String, env As %String, nmSp As %String) As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("GetLastImplementationDetails").Invoke($this,"lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.GetLastImplementationDetails",.compName,.env,.nmSp)
}

Method Test() As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("Test").Invoke($this,"lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.Test")
}

Method UpdateClassItem(clNm As %String, componentNm As %String, nmSp As %String, DeploymentFile As %String, fileVersion As %String, fileInfo As %String, env As %String, dt As %String, usrNm As %String) As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("UpdateClassItem").Invoke($this,"lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.UpdateClassItem",.clNm,.componentNm,.nmSp,.DeploymentFile,.fileVersion,.fileInfo,.env,.dt,.usrNm)
}

Method UpdateComponentImpl(componentNm As %String, nmSp As %String, DeploymentFile As %String, fileVersion As %String, fileInfo As %String, env As %String, dt As %String, usrNm As %String) As %xsd.base64Binary [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("UpdateComponentImpl").Invoke($this,"lp-itfprdfs01:23974/csp/healthshare/itfcommon/IHC.ITF.SrcCtrlPkg.SrcCtrlDeploymentWS.UpdateComponentImpl",.componentNm,.nmSp,.DeploymentFile,.fileVersion,.fileInfo,.env,.dt,.usrNm)
}

}
