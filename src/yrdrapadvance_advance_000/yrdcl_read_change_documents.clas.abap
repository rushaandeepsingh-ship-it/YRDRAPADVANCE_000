CLASS yrdcl_read_change_documents DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yrdcl_read_change_documents IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " read Change document object YRD_ORDER_CD
    TRY.
        DATA(lv_start_date) =  CONV d( cl_abap_context_info=>get_system_date(  ) - 7 ).
        DATA(lv_end_date)   =  cl_abap_context_info=>get_system_date(  ).

        cl_chdo_read_tools=>changedocument_read(
          EXPORTING
            i_objectclass    = 'YRD_ORDER_CDH'
*      it_objectid      =
            i_date_of_change = CONV #( lv_start_date )
*      i_time_of_change =
            i_date_until     = lv_end_date
*      i_time_until     =
*      it_username      =
*      iv_read_archive  =
*      is_read_options  =
      IMPORTING
        et_cdredadd_tab  = DATA(lt_result)
*    CHANGING
*      ct_cdhdr         =
        ).
      CATCH cx_chdo_read_error.
        "handle exception
        out->write( 'Read Error : Auth missing'
*          RECEIVING
*            output =
).
    ENDTRY.

    out->write(
      EXPORTING
        data   = lt_result
        name   = 'Change Documents'
*          RECEIVING
*            output =
    ).

  ENDMETHOD.
ENDCLASS.
