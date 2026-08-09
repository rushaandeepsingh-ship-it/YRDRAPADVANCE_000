@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZYRDOrder000', 
  semanticKey: [ 'OrderID' ]
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZYRDC_ORDER000000
  provider contract transactional_query
  as projection on ZYRDR_ORDER000000
  association [1..1] to ZYRDR_ORDER000000 as _BaseEntity on $projection.UUID = _BaseEntity.UUID
{
  key UUID,
  OrderID,
  CustomerID,
  OrderDate,
  Status,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  CurrencyCode,
  @Semantics: {
    amount.currencyCode: 'CurrencyCode'
  }
  NetAmount,
  @Semantics: {
    user.createdBy: true
  }
  LocalCreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  LocalCreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LocalLastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  _Item : redirected to composition child ZYRDC_ITEM000,
  _BaseEntity
}
