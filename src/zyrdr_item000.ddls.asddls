@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@ObjectModel.semanticKey: [ 'ItemID' ]
define view entity ZYRDR_ITEM000
  as select from ZYRDITEM000 as Item
  association to parent ZYRDR_ORDER000000 as _Order000 on $projection.ParentUuid = _Order000.Uuid
{
  key uuid as UUID,
  parent_uuid as ParentUUID,
  item_id as ItemID,
  product_id as ProductID,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_UnitOfMeasureStdVH', 
    entity.element: 'UnitOfMeasure', 
    useForValidation: true
  } ]
  uom as UOM,
  @Semantics.quantity.unitOfMeasure: 'UOM'
  req_quantity as ReqQuantity,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  currency_code as CurrencyCode,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  amount as Amount,
  status as Status,
  _Order000
}
