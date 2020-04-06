Class IHC.EAI.KPI.Util.Metrics Extends %RegisteredObject
{

/// Add or update a transaction count KPI
ClassMethod AddUpdateTransCount(pInboundTC As %ZEN.proxyObject, Output pStatus As %Status = {$$$OK}) As IHC.EAI.KPI.Schema.TransactionCount
{
	#Dim tTransactionCount As IHC.EAI.KPI.Schema.TransactionCount
	
	Set tTransactionCount = ""
	Try {
		// If exists, open
		// Expect pInboundTC.valueDate to be in "20XX-XX-XX format"
		Set tTempValueDate = $ZDH(pInboundTC.valueDate,3)
		
		Set tGroupKey = pInboundTC.application _ "||" _ pInboundTC.group
		Set SQLCODE = "", tExistingId = ""
		&sql(SELECT %Id INTO :tExistingId FROM IHC_EAI_KPI_Schema.TransactionCount 
				WHERE Application = :pInboundTC.application AND 
					ApplicationGroup = :tGroupKey AND 
					Type = :pInboundTC.type AND 
					ValueDate = :tTempValueDate)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to query transaction count for existing entry. type: " _ pInboundTC.type _ "|valueDate: " _ tTempValueDate))
		}
		
		Set tTransactionCount = ""
		If (tExistingId '= "") {
			Set tTransactionCount = ##class(IHC.EAI.KPI.Schema.TransactionCount).%OpenId(tExistingId,,.pStatus)
			$$$ThrowOnError(pStatus)	
			Set tTransactionCount.UpdatedOn = $ZDT($H,3)
		} Else {
			Set tTransactionCount = ##class(IHC.EAI.KPI.Schema.TransactionCount).%New()
			Set tApplication = ##class(IHC.EAI.KPI.Schema.Application).%OpenId(pInboundTC.application,,.tStatus)
			$$$ThrowOnError(tStatus)
			Set tTransactionCount.Application = tApplication
			Set tGroup = ##class(IHC.EAI.KPI.Schema.ApplicationGroup).%OpenId(tGroupKey,,.tStatus)
			If ($$$ISERR(tStatus)) {
				Set tStatus = $$$OK
				Set tGroup = ##class(IHC.EAI.KPI.Schema.ApplicationGroup).%New()
				Set tGroup.Application = tApplication
				Set tGroup.Name = pInboundTC.group
				Set tStatus = tGroup.%Save()
				$$$ThrowOnError(tStatus)
			}
			Set tTransactionCount.ApplicationGroup = tGroup
			Set tTransactionCount.CreatedOn = $ZDT($H,3)
			Set tTransactionCount.Type = pInboundTC.type
			Set tTransactionCount.ValueDate = tTempValueDate
		}
		
		// Supplement data
		Set tTransactionCount.Value = pInboundTC.value
		Set tTransactionCount.Type = pInboundTC.type
		Set tTransactionCount.Qualifier = pInboundTC.qualifier
		Set pStatus = tTransactionCount.%Save()
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tTransactionCount
}

/// Add or update a component count KPI
ClassMethod AddUpdateCompCount(pInboundCC As IHC.EAI.KPI.Schema.ComponentCount, Output pStatus As %Status = {$$$OK}) As IHC.EAI.KPI.Schema.ComponentCount
{
	#Dim tComponentCount As IHC.EAI.KPI.Schema.ComponentCount
	
	Set tComponentCount = ""
	Try {
		
		// If exists, open
		// Expect pInboundCC.valueDate to be in "20XX-XX-XX format"
		Set tTempValueDate = $ZDH(pInboundCC.valueDate,3)
		
		Set tGroupKey = pInboundCC.application _ "||" _ pInboundCC.group
		Set SQLCODE = "", tExistingId = ""
		&sql(SELECT %Id INTO :tExistingId FROM IHC_EAI_KPI_Schema.ComponentCount 
				WHERE Application = :pInboundCC.application AND 
					ApplicationGroup = :tGroupKey AND 
					Type = :pInboundCC.type AND 
					ValueDate = :tTempValueDate)
		If ((SQLCODE '= 0) && (SQLCODE '= 100)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Failed to query component count for existing entry. type: " _ pInboundCC.type _ "|valueDate: " _ tTempValueDate))
		}
		
		Set tComponentCount = ""
		If (tExistingId '= "") {
			Set tComponentCount = ##class(IHC.EAI.KPI.Schema.ComponentCount).%OpenId(tExistingId,,.pStatus)
			$$$ThrowOnError(pStatus)	
			Set tComponentCount.UpdatedOn = $ZDT($H,3)
		} Else {
			Set tComponentCount = ##class(IHC.EAI.KPI.Schema.ComponentCount).%New()
			Set tApplication = ##class(IHC.EAI.KPI.Schema.Application).%OpenId(pInboundCC.application,,.tStatus)
			$$$ThrowOnError(tStatus)
			Set tComponentCount.Application = tApplication
			Set tGroup = ##class(IHC.EAI.KPI.Schema.ApplicationGroup).%OpenId(tGroupKey,,.tStatus)
			If ($$$ISERR(tStatus)) {
				Set tStatus = $$$OK
				Set tGroup = ##class(IHC.EAI.KPI.Schema.ApplicationGroup).%New()
				Set tGroup.Application = tApplication
				Set tGroup.Name = pInboundCC.group
				Set tStatus = tGroup.%Save()
				$$$ThrowOnError(tStatus)
			}
			Set tComponentCount.ApplicationGroup = tGroup
			Set tComponentCount.CreatedOn = $ZDT($H,3)
			Set tComponentCount.Type = pInboundCC.type
			Set tComponentCount.ValueDate = tTempValueDate
		}
		
		// Supplement data
		Set tComponentCount.Value = pInboundCC.value
		Set tComponentCount.Type = pInboundCC.type
		Set tComponentCount.Qualifier = pInboundCC.qualifier
		Set pStatus = tComponentCount.%Save()
		$$$ThrowOnError(pStatus)
		
	} Catch eException {
		Set pStatus = eException.AsStatus()
	}
	Quit tComponentCount
}

}
