@EndUserText.label: 'Parameter view for status change action'
define root abstract entity YRD_D_ORDERCOPYP
{
  @EndUserText.label:'Customer ID'
  CustomerId_param : abap.char(10);
  
  @EndUserText.label:'Order Date'
  order_date_param : abap.datn;
  
  @EndUserText.label:'Copy Item'
  IsItemToCopy : abap_boolean;

}
