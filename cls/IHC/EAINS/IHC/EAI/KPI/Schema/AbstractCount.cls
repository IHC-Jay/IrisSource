Class IHC.EAI.KPI.Schema.AbstractCount Extends IHC.EAI.KPI.Schema.Abstract [ Abstract, NoExtent ]
{

/// Type of count<br/>
/// Possible options:<br/>
///  In, Out, Total, Enabled, Disabled, etc...<br/>
Property Type As %String(MAXLEN = 50);

/// A user-defined qualifier field
Property Qualifier As %String(MAXLEN = 100);

/// The date for the count value
Property ValueDate As %Date(FORMAT = 3) [ Required ];

/// The count value
Property Value As %Integer [ Required ];

}
