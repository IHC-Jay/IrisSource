Class IHC.EAI.HL7.Search.Criteria Extends %RegisteredObject
{

/// Examples: 
///  2016-11-21 16:00:00 - 4pm 11/21/2016
///  $System.SQL.DATEADD("h",-1,$ZDT($H,3)) - 1 hour ago
Property TimeCreatedStart As %String(MAXLEN = 50);

/// Examples: 
///  $ZDT($H,3) - Now
///  $System.SQL.DATEADD("h",-1,$ZDT($H,3)) - 1 hour ago
Property TimeCreatedEnd As %String(MAXLEN = 50);

Property SourceConfigName As %String(MAXLEN = 100);

Property TargetConfigName As %String(MAXLEN = 100);

/// The HL7 Message Type
Property MessageType As %String(MAXLEN = 10);

/// The HL7 Segment Type
///  PID, MSH, PV1, etc...
Property SegmentType As %String(MAXLEN = 10);

/// The HL7 Field Name
Property FieldName As %String(MAXLEN = 100);

/// The HL7 Field Value
Property FieldValue As %String(MAXLEN = 100);

}
