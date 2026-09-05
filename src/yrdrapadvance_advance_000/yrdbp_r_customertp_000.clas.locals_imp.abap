CLASS lhc_Customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Customer RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Customer RESULT result.
    METHODS set_customer_id FOR DETERMINE ON MODIFY
       keys FOR Customer~set_customer_id.

ENDCLASS.

CLASS lhc_Customer IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD set_customer_id.

    "Ensure idempotence
    READ ENTITIES OF YRDR_CustomerTP_000 IN LOCAL MODE
      ENTITY Customer
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_customer).

    DELETE lt_customer WHERE CustomerId IS NOT INITIAL.
    CHECK lt_customer IS NOT INITIAL.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'YRDNR_CUS'
            quantity          = CONV #( lines( lt_customer ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT lt_customer INTO DATA(entity).
          APPEND VALUE #( %tky = entity-%tky
                          %msg = lx_number_ranges
                        ) TO reported-customer.

        ENDLOOP.
        EXIT.
    ENDTRY.

    DATA(lv_customer_id_max) = CONV yrdcustomerid( number_range_key - number_range_returned_quantity ).
    lv_customer_id_max += 1.


    "update involved instances
    MODIFY ENTITIES OF YRDR_CustomerTP_000 IN LOCAL MODE
      ENTITY Customer
        UPDATE FIELDS ( CustomerId )
        WITH VALUE #( FOR ls_customer IN lt_customer INDEX INTO i (
                           %tky         = ls_customer-%tky
                           CustomerId   = shift_left( lv_customer_id_max  ) ) ).


  ENDMETHOD.

ENDCLASS.
