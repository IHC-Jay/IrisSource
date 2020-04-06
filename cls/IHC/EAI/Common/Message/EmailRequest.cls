Class IHC.EAI.Common.Message.EmailRequest Extends (%Persistent, %XML.Adaptor, Ens.Util.RequestBodyMethods)
{

/// To for message, list of names to which message will be sent 
Property To As list Of %String(MAXLEN = 8000);

/// Cc for message, list of names to which message will be sent 
Property Cc As list Of %String(MAXLEN = 8000);

/// Bcc for message, list of names to which message will be sent
Property Bcc As list Of %String(MAXLEN = 8000);

/// Who the message is from 
Property From As %String(MAXLEN = 1000);

/// Subject of message 
Property Subject As %String(MAXLEN = 1000);

/// Text data
Property TextData As %Stream.GlobalCharacter;

/// Binary data
Property BinaryData As %Stream.GlobalBinary;

Property IsHTML As %Boolean [ InitialExpression = 1 ];

Property IsBinary As %Boolean [ InitialExpression = 0 ];

Property ContentType As %String [ InitialExpression = "text/html" ];

Storage Default
{
<Data name="EmailRequestDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>To</Value>
</Value>
<Value name="3">
<Value>Cc</Value>
</Value>
<Value name="4">
<Value>Bcc</Value>
</Value>
<Value name="5">
<Value>From</Value>
</Value>
<Value name="6">
<Value>Subject</Value>
</Value>
<Value name="7">
<Value>TextData</Value>
</Value>
<Value name="8">
<Value>BinaryData</Value>
</Value>
<Value name="9">
<Value>IsHTML</Value>
</Value>
<Value name="10">
<Value>IsBinary</Value>
</Value>
<Value name="11">
<Value>ContentType</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Commo3656.EmailRequestD</DataLocation>
<DefaultData>EmailRequestDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Commo3656.EmailRequestD</IdLocation>
<IndexLocation>^IHC.EAI.Commo3656.EmailRequestI</IndexLocation>
<StreamLocation>^IHC.EAI.Commo3656.EmailRequestS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
