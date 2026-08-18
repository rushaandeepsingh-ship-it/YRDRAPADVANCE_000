CLASS yrdcl_snro_usage DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yrdcl_snro_usage IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.
        cl_numberrange_intervals=>create(
          EXPORTING
            object = 'YRDRAP_ORD'
            interval = VALUE #( ( nrrangenr = '01'
                                  fromnumber = '1000000000'
                                  tonumber   = '1999999999'
                                  procind    = 'I' ) )   " I=内部
          IMPORTING error = data(lv_err) ).

      CATCH cx_number_ranges INTO data(lx_nr).

        out->write( lx_nr->get_longtext(  )  ).
        return.
        "handle exception
    ENDTRY.


    COMMIT WORK.

     out->write( 'Done '  ).

  ENDMETHOD.
ENDCLASS.
