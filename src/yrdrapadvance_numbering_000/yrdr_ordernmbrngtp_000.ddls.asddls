@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order transactional View Early Numbering'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YRDR_OrderNmbrngTP_000
  as select from zyrdorder_num000
  composition [0..*] of YRDR_ItemNmbrngTP_000 as _Item
{
  key order_id              as OrderId,
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
      _Item // Make association public
}
