@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Dependent Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YRDC_OrderDependentTP_000
  provider contract transactional_query
  as projection on YRDR_OrderTP_000
{
  key Uuid,
      OrderId,
      CustomerId,
      customeruuid,
      OrderDate,
      Status,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      NetAmount,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _OrderStatusTxt,
      _Customer : redirected to YRDRC_CustomerTP_000
}
