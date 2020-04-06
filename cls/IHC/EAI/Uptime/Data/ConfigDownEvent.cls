Class IHC.EAI.Uptime.Data.ConfigDownEvent Extends %Persistent {

Property ConfigName As %String(MAXLEN = 250);

Property Namespace As %String(MAXLEN = 50);

Property BusinessType As %String(MAXLEN = 50);

Property DownStart As %TimeStamp [ InitialExpression = {$ZDT($H,3)} ];

Property DownEnd As %TimeStamp;

Property Reason As %String(MAXLEN = 50, VALUELIST = ",DISABLED,DISCONNECTED,RETRYING");

Index iConfigName On ConfigName;

Query CurrentMonthDowntimeTotal() As %SQLQuery(CONTAINID = 0, SELECTMODE = "RUNTIME") [ SqlName = Current_Month_Downtime_Total, SqlProc ]
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
<Data name="ConfigDownEventDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ConfigName</Value>
</Value>
<Value name="3">
<Value>Namespace</Value>
</Value>
<Value name="4">
<Value>BusinessType</Value>
</Value>
<Value name="5">
<Value>DownStart</Value>
</Value>
<Value name="6">
<Value>DownEnd</Value>
</Value>
<Value name="7">
<Value>Reason</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Up3A33.ConfigDownE3CB0D</DataLocation>
<DefaultData>ConfigDownEventDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Up3A33.ConfigDownE3CB0D</IdLocation>
<IndexLocation>^IHC.EAI.Up3A33.ConfigDownE3CB0I</IndexLocation>
<StreamLocation>^IHC.EAI.Up3A33.ConfigDownE3CB0S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}