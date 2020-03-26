Class IHC.EAI.Security.Schema.InstanceType Extends %SerialObject
{

/// CLIN type
Property CLIN As %Boolean [ InitialExpression = 0 ];

/// PAYER type
Property PAYER As %Boolean [ InitialExpression = 0 ];

/// PROVIDER type
Property PROVIDER As %Boolean [ InitialExpression = 0 ];

/// MSGBANK type
Property MSGBANK As %Boolean [ InitialExpression = 0 ];

Storage Default
{
<Data name="InstanceTypeState">
<Value name="1">
<Value>CLIN</Value>
</Value>
<Value name="2">
<Value>PAYER</Value>
</Value>
<Value name="3">
<Value>PROVIDER</Value>
</Value>
<Value name="4">
<Value>MSGBANK</Value>
</Value>
</Data>
<State>InstanceTypeState</State>
<StreamLocation>^IHC.EAI.SecurB79D.InstanceTypeS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}
