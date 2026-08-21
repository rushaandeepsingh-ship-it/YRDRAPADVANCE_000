@EndUserText.label: 'Parameter view for status change action'
define abstract entity YRD_D_OrderStatusP
{
  @Consumption.valueHelpDefinition: [{ entity: {name:     'YRDI_OrderStatus_VH',
                                                element:    'Status' } }]
  @EndUserText.label: 'Status'                                              
  status_param : yrdorderstatus;

}
