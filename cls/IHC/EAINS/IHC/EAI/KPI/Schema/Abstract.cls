Class IHC.EAI.KPI.Schema.Abstract Extends (%Persistent, %Populate, %XML.Adaptor) [ Abstract, NoExtent ]
{

/// Application (Ensemble, EdifecsSh, EdifecsRCO, eGate, BizTalk, etc...)
Property Application As IHC.EAI.KPI.Schema.Application [ Required ];

/// Schema/Namespace/Group/etc...
Property ApplicationGroup As IHC.EAI.KPI.Schema.ApplicationGroup [ Required ];

/// Date/time the record was created
Property CreatedOn As %TimeStamp [ Required ];

/// Date/time the record was updated
Property UpdatedOn As %TimeStamp;

}
