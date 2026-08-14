@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Projection View Transactional'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YRDC_ORDERTP_000
provider contract transactional_query
  as projection on YRDR_OrderTP_000
{
  key Uuid,
      OrderId,
      CustomerId,
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
      /* Associations */
      _Item : redirected to composition child YRDC_ORDERITEMTP_000
}
