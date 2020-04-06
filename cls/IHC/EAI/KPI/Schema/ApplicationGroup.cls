Class IHC.EAI.KPI.Schema.ApplicationGroup Extends (%Persistent, %Populate, %XML.Adaptor)
{

Property Application As IHC.EAI.KPI.Schema.Application [ Required ];

Property Name As %String(MAXLEN = 150) [ Required ];

Index iMain On (Application, Name) [ IdKey ];

Storage Default
{
<Data name="ApplicationGroupDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KP8839.ApplicationECE0D</DataLocation>
<DefaultData>ApplicationGroupDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KP8839.ApplicationECE0D</IdLocation>
<IndexLocation>^IHC.EAI.KP8839.ApplicationECE0I</IndexLocation>
<StreamLocation>^IHC.EAI.KP8839.ApplicationECE0S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
