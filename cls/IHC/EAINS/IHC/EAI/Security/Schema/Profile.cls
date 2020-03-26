Class IHC.EAI.Security.Schema.Profile Extends IHC.EAI.Security.Schema.AbstractObject
{

/// The name of this ITF Role or User (Username)
Property Name As %String(MAXLEN = 100);

/// The role description or username comment.<br/>
/// Primarily used for creating new, which generally<br/>
/// only happens when creating test roles/users.
Property Description As %String(MAXLEN = 100);

/// List of granted roles (ITF or System)<br/>
Property GrantedRoles As array Of %String(MAXLEN = "") [ SqlFieldName = GrantedRoles ];

}
