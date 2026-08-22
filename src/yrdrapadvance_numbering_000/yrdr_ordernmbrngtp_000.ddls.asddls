@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order transactional View Early Numbering'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YRDR_OrderNmbrngTP_000
  as select from zyrdorder_num000
  composition [0..*] of YRDR_ItemNmbrngTP_000 as _Item
    association [0..1] to YRDI_OrderStatus_VH as _OrderStatusTxt on $projection.Status = _OrderStatusTxt.Status
{
  key order_id              as OrderId,
      customer_id           as CustomerId,
      order_date            as OrderDate,
      status                as Status,
      currency_code         as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      net_amount            as NetAmount,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      _Item ,
      _OrderStatusTxt  // Make association public
}
