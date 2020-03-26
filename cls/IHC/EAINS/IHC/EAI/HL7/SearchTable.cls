Class IHC.EAI.HL7.SearchTable Extends EnsLib.HL7.SearchTable {

XData SearchSpec [ XMLNamespace = "http://www.intersystems.com/EnsSearchTable" ]
{
<Items>
<Item DocType=":ORM_O01"  PropName="OrderNumber" >[OBR:2.1]</Item>
<Item DocType=":ORU_R01"  PropName="OrderNumber" >[OBR:2.1]</Item>
<Item DocType=":ORM_O01"  PropName="OrderNumber" >[OBR:3.1]</Item>
<Item DocType=":ORU_R01"  PropName="OrderNumber" >[OBR:3.1]</Item>
<Item DocType=":ORM_O01"  PropName="UniversalServiceIdentifier" >[OBR:4.1]</Item>
<Item DocType=":ORU_R01"  PropName="UniversalServiceIdentifier" >[OBR:4.1]</Item>
</Items>
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}