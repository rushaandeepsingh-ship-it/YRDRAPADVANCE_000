@EndUserText.label: 'Custom entity sample'
@ObjectModel.query.implementedBy: 'ABAP:YRDCL_CHGDOCORDER_QUERY1'

define custom entity YRDC_Custom_entity_000
{
  key objectid  : abap.char(90);
  key changenr  : abap.char(10);
  key tabkey    : abap.char(70);
  key chngind   : abap.char(1);
  key fname     : abap.char(30);
      tabname   : abap.char( 30 );
      ftext     : abap.char(60);
      f_old     : abap.char(254);
      f_new     : abap.char(254);
      username  : abap.char(12);
      udate     : abap.datn;
      utime     : abap.timn;
      StartDate : abap.datn;
      EndDate   : abap.datn;
  
}
