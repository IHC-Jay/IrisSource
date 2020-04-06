/// Class that stores a snaphsot of data required for KPI generation/mgt reports
Class IHC.EAI.KPI.Schema.ComponentCount Extends IHC.EAI.KPI.Schema.AbstractCount
{

Index iMain On (Application, ApplicationGroup, Type, ValueDate) [ Unique ];

/// Index of the date this value is for
Index iValueDate On ValueDate;

Query MonthlyCompByApp() As %SQLQuery(CONTAINID = 0, SELECTMODE = "RUNTIME") [ SqlName = Monthly_Component_By_Application, SqlProc ]
{
	SELECT 
		cc1.Application,
		YEAR(cc1.ValueDate),
		MONTH(cc1.ValueDate),
		SUM(cc1.Value)
	FROM IHC_EAI_KPI_Schema.ComponentCount cc1
	WHERE NOT EXISTS (SELECT 1
	    FROM IHC_EAI_KPI_Schema.ComponentCount cc2 WHERE cc2.ValueDate > cc1.ValueDate
	    AND MONTH(cc2.ValueDate) = MONTH(cc1.ValueDate)
	    AND YEAR(cc2.ValueDate) = YEAR(cc1.ValueDate)) AND
	    cc1.Type = 'Total'
	GROUP BY cc1.Application,cc1.ValueDate
	ORDER BY cc1.ValueDate
}

Storage Default
{
<Data name="ComponentCountDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Application</Value>
</Value>
<Value name="3">
<Value>ApplicationGroup</Value>
</Value>
<Value name="4">
<Value>CreatedOn</Value>
</Value>
<Value name="5">
<Value>UpdatedOn</Value>
</Value>
<Value name="6">
<Value>Qualifier</Value>
</Value>
<Value name="7">
<Value>Type</Value>
</Value>
<Value name="8">
<Value>Value</Value>
</Value>
<Value name="9">
<Value>ValueDate</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.KPI8839.ComponentCountD</DataLocation>
<DefaultData>ComponentCountDefaultData</DefaultData>
<IdLocation>^IHC.EAI.KPI8839.ComponentCountD</IdLocation>
<IndexLocation>^IHC.EAI.KPI8839.ComponentCountI</IndexLocation>
<StreamLocation>^IHC.EAI.KPI8839.ComponentCountS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
