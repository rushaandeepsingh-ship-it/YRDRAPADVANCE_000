@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Consumption View transactional'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YRDC_ORDERITEMTP_000
  as projection on YRDR_OrderItemTP_000
{
  key Uuid,
      ParentUuid,
      ItemId,
      ProductId,
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Amount,
      Status,
      /* Associations */
      _Order : redirected to parent YRDC_ORDERTP_000
}
