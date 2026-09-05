@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Transactional view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YRDR_CustomerTP_000
  as select from yrd_customer_000
//  composition [0..*] of YRDR_PaymentTP_000 as _Payment
  composition [0..*] of YRDR_AddressTP_000 as _Address
  association [0..*] to YRDR_OrderTP_000 as _Order on $projection.Uuid = _Order.customeruuid
{
  key uuid                  as Uuid,
      customer_id           as CustomerId,
      name                  as Name,
      email                 as Email,
      mobileno              as Mobileno,
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
//      _Payment,
      _Address,
      _Order // Make association public
}
