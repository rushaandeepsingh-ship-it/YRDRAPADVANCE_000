@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Test'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YRDC_Order_001 as select from YRDR_Order_000
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
    _Item,
    _OrderStatusTxt
}
