@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Consumption View Early Numbering'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YRDC_ITEMNMBRNGDRAFTTP_000
  as projection on YRDR_ItemNmbrngTP_000
{
  key ItemId,
  key OrderId,
      ProductId,
      Uom,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      ReqQuantity,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Amount,
      Status,
      /* Associations */
      _Order : redirected to parent YRDC_ORDERNMBRNGDRAFTTP_000
}
