@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Address Projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YRDC_AddressTP_000
  as projection on YRDR_AddressTP_000
{
  key Uuid,
      CustomerUuid,
      AddressCode,
      DefaultAddress,
      Street,
      PostalCode,
      City,
      CountryCode,
      /* Associations */
      _Customer : redirected to parent YRDRC_CustomerTP_000
}
