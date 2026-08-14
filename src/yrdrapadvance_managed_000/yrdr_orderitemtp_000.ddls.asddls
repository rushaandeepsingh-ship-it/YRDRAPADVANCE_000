@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Transactional View'
@Metadata.ignorePropagatedAnnotations: true
define view entity YRDR_OrderItemTP_000
  as select from zyrditem000
  association to parent YRDR_OrderTP_000 as _Order
      on $projection.ParentUuid = _Order.Uuid
{

  key uuid          as Uuid,
      parent_uuid   as ParentUuid,
      item_id       as ItemId,
      product_id    as ProductId,
      uom           as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      req_quantity  as ReqQuantity,
      currency_code as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      amount        as Amount,
      status        as Status,
      _Order
}
