@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: [ 'CustomerId' ]
define root view entity YRDRC_CustomerTP_000
provider contract transactional_query
  as projection on YRDR_CustomerTP_000
{
  key Uuid,
      CustomerId,
      Name,
      Email,
      Mobileno,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Address : redirected to composition child YRDC_AddressTP_000,
//      _Payment : redirected to composition child YRDC_PaymentTP_000,
      _Order   : redirected to  YRDC_OrderDependentTP_000
}
