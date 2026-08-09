@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item status value help'
@Metadata.ignorePropagatedAnnotations: true
define view entity YRDI_ItemStatus_VH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE  ( p_domain_name: 'YRDITEMSTATUS' )   as values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'YRDITEMSTATUS' )   as texts on  texts.domain_name    = values.domain_name
                                                                                             and texts.value_position = values.value_position
                                                                                             and texts.language       = $session.system_language
{
  key values.value_low as Status,
      @Semantics.text: true
      texts.text       as StatusText
}
