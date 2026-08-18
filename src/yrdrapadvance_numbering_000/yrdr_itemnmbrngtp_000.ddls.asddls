@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Interface View Early Numbering'
@Metadata.ignorePropagatedAnnotations: true
define view entity YRDR_ItemNmbrngTP_000
  as select from zyrditem_num000
  association to parent YRDR_OrderNmbrngTP_000 as _Order on $projection.OrderId = _Order.OrderId
{
  key item_id       as ItemId,
  key order_id      as OrderId,
      product_id    as ProductId,
      uom           as Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      req_quantity  as ReqQuantity,
      currency_code as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      amount        as Amount,
      status        as Status,
      _Order // Make association public
}
