@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Consumption View read-only purpose'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity YRDC_OrderItem_000
  as select from YRDR_OrderItem_000
{
  key UUID,
      ParentUUID,
      ItemID,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      ProductID,
      UOM,
      @Semantics.quantity.unitOfMeasure: 'UOM'
      ReqQuantity,
      CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Amount,
      @ObjectModel.text.element: [ 'ItemStatusText' ]
      Status,
      @Semantics.text
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      _ItemStatusTxt.StatusText as ItemStatusText,
      /* Associations */
      _Order,
      _ItemStatusTxt
}
