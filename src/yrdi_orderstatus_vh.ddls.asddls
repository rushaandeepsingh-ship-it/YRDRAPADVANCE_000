@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item status value help'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
//@ObjectModel.resultSet.sizeCategory: #XS
define view entity YRDI_OrderStatus_VH
  as select from    DDCDS_CUSTOMER_DOMAIN_VALUE  ( p_domain_name: 'YRDORDERSTATUS' ) as values
    left outer join DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'YRDORDERSTATUS' ) as texts on  texts.domain_name    = values.domain_name
                                                                                              and texts.value_position = values.value_position
                                                                                              and texts.language       = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  key values.value_low as Status,
      @Semantics.text: true
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      texts.text       as StatusText
}
