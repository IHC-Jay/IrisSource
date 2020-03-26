/// 
Class IHC.EAI.Rule.ApeAlert Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="" disabled="false">
<when condition="Document.AlertText[&quot;ERROR #5803:&quot;">
<send transform="WRC.Demo.LockQueryDTL" target="WRC.Util.LockQueryOperation"></send>
<return></return>
</when>
</rule>
<rule name="ApeAlert" disabled="false">
</rule>
<trace value="&quot;Alert received, sending to APE&quot;"></trace>
<send transform="IHC.EAI.Transform.ApeAlert" target="Out-APE-Alert-REST"></send>
</ruleSet>
</ruleDefinition>
}

}
