Class IHC.EAI.Sync.REST.Response Extends (%Persistent, %XML.Adaptor, Ens.Util.ResponseBodyMethods) {

/// Single result value
Property Value As %String(MAXLEN = "");

/// Single record properties or list of records' single values
Property Properties As array Of %String(MAXLEN = "");

/// For the record: submitted Request URL
Property RequestURL As %String(MAXLEN = "") [ Internal ];

/// For the record: raw HTTP response body resulting from request URL
Property RawResponse As %Stream.GlobalCharacter [ Internal ];

/// For the record: ID of the session used to retrieve this response
Property SessionId As %String;

Storage Default
{
<Data name="Properties">
<Attribute>Properties</Attribute>
<Structure>subnode</Structure>
<Subscript>"Properties"</Subscript>
</Data>
<Data name="ResponseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Value</Value>
</Value>
<Value name="3">
<Value>RequestURL</Value>
</Value>
<Value name="4">
<Value>RawResponse</Value>
</Value>
<Value name="5">
<Value>SessionId</Value>
</Value>
</Data>
<DataLocation>^IHC.EAI.Sync.REST.ResponseD</DataLocation>
<DefaultData>ResponseDefaultData</DefaultData>
<IdLocation>^IHC.EAI.Sync.REST.ResponseD</IdLocation>
<IndexLocation>^IHC.EAI.Sync.REST.ResponseI</IndexLocation>
<StreamLocation>^IHC.EAI.Sync.REST.ResponseS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}