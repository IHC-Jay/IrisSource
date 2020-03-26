Class IHC.EAI.Security.Schema.Environment Extends %SerialObject
{

/// DEV environment
Property DEV As %Boolean [ InitialExpression = 0 ];

/// QA environment
Property QA As %Boolean [ InitialExpression = 0 ];

/// UAT environment
Property UAT As %Boolean [ InitialExpression = 0 ];

/// PROD environment
Property PROD As %Boolean [ InitialExpression = 0 ];

Storage Default
{
<Data name="EnvironmentState">
<Value name="1">
<Value>DEV</Value>
</Value>
<Value name="2">
<Value>QA</Value>
</Value>
<Value name="3">
<Value>UAT</Value>
</Value>
<Value name="4">
<Value>PROD</Value>
</Value>
</Data>
<State>EnvironmentState</State>
<StreamLocation>^IHC.EAI.SecuriB79D.EnvironmentS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}
