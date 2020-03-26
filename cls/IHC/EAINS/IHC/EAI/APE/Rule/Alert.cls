/// APE alert rule
Class IHC.EAI.APE.Rule.Alert Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="AlertRule" disabled="false">
</rule>
<trace value="&quot;Alert recived, sending to File and APE&quot;"></trace>
<send transform="IHC.EAI.APE.Transform.EnsAlertToAPEAlert" target="Out-APE-Alert-REST"></send>
</ruleSet>
</ruleDefinition>
}

}
