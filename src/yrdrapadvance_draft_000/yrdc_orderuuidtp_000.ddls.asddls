@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Projection View Transactional'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'OrderId' ]
define root view entity YRDC_ORDERUUIDTP_000
provider contract transactional_query
  as projection on YRDR_OrderTP_000
{
  key Uuid,
      OrderId,
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
      _Item : redirected to composition child YRDC_ORDERITEMUUIDTP_000
}
