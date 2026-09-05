@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Address Transactional view'
@Metadata.ignorePropagatedAnnotations: true
define view entity YRDR_AddressTP_000
  as select from yrd_address_000
  association to parent YRDR_CustomerTP_000 as _Customer on $projection.CustomerUuid = _Customer.Uuid
{
  key uuid                  as Uuid,
      customer_uuid         as CustomerUuid,
      address_type          as AddressCode,
      default_address       as DefaultAddress,
      street                as Street,
      postal_code           as PostalCode,
      city                  as City,
      country_code          as CountryCode,
      addr_last_changed_at  as AddrLastChangedAt,
      _Customer
}
