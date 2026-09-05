@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Draft query view Order'
define root view entity YRDR_OrderDraftTP_000
  as select from zyrdorder000_d
{
  key uuid                          as Uuid,
      orderid                       as OrderId,
      customerid                    as CustomerId,
      customeruuid                  as customeruuid,
      orderdate                     as OrderDate,
      status                        as Status,
      currencycode                  as CurrencyCode,
      netamount                     as NetAmount,
      localcreatedby                as LocalCreatedBy,
      localcreatedat                as LocalCreatedAt,
      locallastchangedby            as LocalLastChangedBy,
      locallastchangedat            as LocalLastChangedAt,
      lastchangedat                 as LastChangedAt,
      draftentitycreationdatetime   as draftentitycreationdatetime,
      draftentitylastchangedatetime as draftentitylastchangedatetime,
      draftadministrativedatauuid   as draftadministrativedatauuid,
      draftentityoperationcode      as draftentityoperationcode,
      hasactiveentity               as hasactiveentity,
      draftfieldchanges             as draftfieldchanges
}
