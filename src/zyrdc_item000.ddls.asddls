@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Semantickey: [ 'ItemID' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define view entity ZYRDC_ITEM000
  as projection on ZYRDR_ITEM000
  association [1..1] to ZYRDR_ITEM000 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  ParentUUID,
  ItemID,
  ProductID,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'UnitOfMeasure', 
      Entity.Name: 'I_UnitOfMeasureStdVH', 
      Useforvalidation: true
    } ]
  }
  UOM,
  @Semantics: {
    Quantity.Unitofmeasure: 'UOM'
  }
  ReqQuantity,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
  CurrencyCode,
  @Semantics: {
    Amount.Currencycode: 'CurrencyCode'
  }
  Amount,
  Status,
  _Order000 : redirected to parent ZYRDC_ORDER000000,
  _BaseEntity
}
