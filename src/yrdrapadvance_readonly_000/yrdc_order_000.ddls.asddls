@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Consumption View read-only purpose'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity YRDC_Order_000
  as select from YRDR_Order_000
  association [1..*] to YRDC_OrderItem_000 as _Item on $projection.Uuid = _Item.ParentUUID
{
  key Uuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      OrderId,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      CustomerId,
      OrderDate,
      @ObjectModel.text.element: [ 'OrderStatusText' ]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      Status,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      NetAmount,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      @Semantics.text
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      _OrderStatusTxt.StatusText as OrderStatusText,
      /* Associations */
      @Search.defaultSearchElement: true
      _Item
}
