@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Draft query view for YRD_CUSTOMER_D'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity YRDR_CUSTOMERDRAFTTP_000
  as select from yrd_customer_d
{
  key uuid                          as Uuid,
      customerid                    as Customerid,
      name                          as Name,
      email                         as Email,
      mobileno                      as Mobileno,
      localcreatedby                as Localcreatedby,
      localcreatedat                as Localcreatedat,
      locallastchangedby            as Locallastchangedby,
      locallastchangedat            as Locallastchangedat,
      lastchangedat                 as Lastchangedat,
      draftentitycreationdatetime   as Draftentitycreationdatetime,
      draftentitylastchangedatetime as Draftentitylastchangedatetime,
      draftadministrativedatauuid   as Draftadministrativedatauuid,
      draftentityoperationcode      as Draftentityoperationcode,
      hasactiveentity               as Hasactiveentity,
      draftfieldchanges             as Draftfieldchanges
}
