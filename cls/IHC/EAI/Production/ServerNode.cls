Class IHC.EAI.Production.ServerNode Extends Ens.Enterprise.Production
{

XData ProductionDefinition
{
<Production Name="IHC.EAI.Production.ServerNode" LogGeneralTraceEvents="false">
  <Description>This production is designed to run as a server node in support of a group of interface node productions.</Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="MetricsAPI" Category="Metrics" ClassName="IHC.EAI.KPI.Service.API.Metrics" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="IHC.EAI.KPI.Process.API.Metrics" Category="Metrics" ClassName="IHC.EAI.KPI.Process.API.Metrics" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="IHC.EAI.Monitor.Mirror.Service" Category="Mirror" ClassName="IHC.EAI.Monitor.Mirror.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">900</Setting>
  </Item>
  <Item Name="IHC.EAI.Monitor.Mirror.Operation" Category="Mirror" ClassName="IHC.EAI.Monitor.Mirror.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials">ITF_Services</Setting>
  </Item>
  <Item Name="IHC.EAI.Monitor.Mirror.Process" Category="Mirror" ClassName="IHC.EAI.Monitor.Mirror.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="Recipient">InterfaceSupport@imail.org</Setting>
    <Setting Target="Host" Name="TriggerAlert">1</Setting>
    <Setting Target="Host" Name="DatabaseLatencyMax">50</Setting>
    <Setting Target="Host" Name="JournalFilesLatencyMax">50</Setting>
  </Item>
  <Item Name="IHC.EAI.Common.Operation.Email" Category="Common" ClassName="IHC.EAI.Common.Operation.Email" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials">hsadmin_email</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtp.co.ihc.com</Setting>
  </Item>
  <Item Name="Ens.Alert" Category="APE" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="Validation"></Setting>
    <Setting Target="Host" Name="BusinessRuleName">IHC.EAI.APE.Rule.Alert</Setting>
  </Item>
  <Item Name="Out-APE-Alert-REST" Category="APE" ClassName="IHC.EAI.APE.REST.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Ens.Enterprise.MonitorService" Category="" ClassName="Ens.Enterprise.MonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">10</Setting>
  </Item>
  <Item Name="UptimeEventsAPI" Category="" ClassName="IHC.EAI.Uptime.Service.API.Events" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
