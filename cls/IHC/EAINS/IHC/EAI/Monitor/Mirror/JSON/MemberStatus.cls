/// Example JSON string:
Class IHC.EAI.Monitor.Mirror.JSON.MemberStatus Extends %RegisteredObject
{

/// Member Name
Property memberName As %String(MAXLEN = 50);

/// Current Role
Property currentRole As %String(MAXLEN = 50);

/// Current Status
Property currentStatus As %String(MAXLEN = 50);

/// Journal Latency
Property journalLatency As %String(MAXLEN = 50);

/// Database Latency
Property databaseLatency As %String(MAXLEN = 50);

/// Journal Time Latency
Property journalTimeLatency As %String(MAXLEN = 50);

/// Database Time Latency
Property databaseTimeLatency As %String(MAXLEN = 50);

/// Display Type
Property displayType As %String(MAXLEN = 50);

/// Display Status
Property displayStatus As %String(MAXLEN = 50);

}
