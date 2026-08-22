@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Projection View Early Numbering'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YRDC_ORDERNMBRNGDRAFTTP_000
  provider contract transactional_query
  as projection on YRDR_OrderNmbrngTP_000
  
{
  key OrderId,
      CustomerId,
      OrderDate,
      @ObjectModel.text.element: [ 'OrderStatusText' ]
      Status,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      NetAmount,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _OrderStatusTxt.StatusText as OrderStatusText,
      /* Associations */
      _Item : redirected to composition child YRDC_ITEMNMBRNGDRAFTTP_000
}
