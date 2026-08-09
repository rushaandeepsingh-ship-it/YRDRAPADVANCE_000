@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Interface View read-only purpose'
@Metadata.ignorePropagatedAnnotations: true
define view entity YRDR_ORDER_UUID_000
  as select from zyrdorder000
  association [0..1] to YRDI_OrderStatus_VH as _OrderStatusTxt on $projection.Status = _OrderStatusTxt.Status
{
  key uuid                  as Uuid,
      order_id              as OrderId,
      customer_id           as CustomerId,
      order_date            as OrderDate,
      status                as Status,
      currency_code         as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      net_amount            as NetAmount,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _OrderStatusTxt
}
