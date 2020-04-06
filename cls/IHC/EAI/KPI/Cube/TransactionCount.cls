/// 
Class IHC.EAI.KPI.Cube.TransactionCount Extends %DeepSee.CubeDefinition [ DependsOn = IHC.EAI.KPI.Schema.TransactionCount, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="EAI_KPI_TransactionCount" displayName="EAI_KPI_TransactionCount" disabled="false" abstract="false" sourceClass="IHC.EAI.KPI.Schema.TransactionCount" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0">
  <dimension name="ApplicationName" disabled="false" hasAll="false" allCaption="All Name" allDisplayName="Name" type="data" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false">
      <level sourceProperty="Application.Name" name="Name" disabled="false" list="false" useDisplayValue="true" useAsFilter="true">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ApplicationGroupName" disabled="false" hasAll="false" allCaption="All Name1" allDisplayName="Name1" type="data" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false">
      <level sourceProperty="ApplicationGroup.Name" name="Name" disabled="false" list="false" useDisplayValue="true" useAsFilter="true">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="TransactionType" disabled="false" hasAll="false" allCaption="All Type" allDisplayName="Type" type="data" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false">
      <level sourceProperty="Type" name="Type" disabled="false" list="false" useDisplayValue="true" useAsFilter="true">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="ValueDate" disabled="false" hasAll="false" allCaption="All ValueDate" allDisplayName="ValueDate" sourceProperty="ValueDate" type="time" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false">
      <level name="MonthYear" disabled="false" timeFunction="MonthYear" list="false" useDisplayValue="true" useAsFilter="true">
      </level>
      <level name="WeekYear" disabled="false" timeFunction="WeekYear" list="false" useDisplayValue="true" useAsFilter="true">
      </level>
    </hierarchy>
  </dimension>
  <measure sourceProperty="Value" name="ValueSUM" disabled="false" aggregate="SUM" type="integer" hidden="false" searchable="false"></measure>
  <measure sourceProperty="Value" name="ValueAVG" disabled="false" aggregate="AVG" type="number" hidden="false" searchable="false"></measure>
</cube>
}

Parameter DOMAIN;

}
