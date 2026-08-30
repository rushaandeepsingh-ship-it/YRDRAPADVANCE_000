CLASS yrdcl_update_ordstatus_000 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yrdcl_update_ordstatus_000 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    "Get the Order UUID
    SELECT SINGLE * FROM zyrdorder000 WHERE order_id = '1000000054' INTO @DATA(ls_order).
    IF sy-subrc = 0.

      MODIFY ENTITIES OF YRDR_OrderTP_000
      ENTITY YRDR_OrderTP_000
      UPDATE
      FIELDS ( Status OrderDate )
      WITH VALUE #( ( %tky       = CORRESPONDING #( ls_order )
                      Status     = '01'
                      OrderDate  = ls_order-order_date - 10  ) )
      FAILED DATA(lt_update_failed)
      REPORTED DATA(lt_update_reported).

      IF lt_update_failed IS INITIAL.
        " Call static method to raise side effect event
        yrdbp_r_ordertp_000=>raise_orderstatusupdated( it_events = VALUE #( ( Uuid = ls_order-uuid ) ) ).

        COMMIT ENTITIES
        RESPONSE OF YRDR_OrderTP_000
        FAILED DATA(lt_failed_commit)
        REPORTED DATA(lt_reported_commit).

        IF lt_failed_commit IS NOT INITIAL.
          out->write(
              EXPORTING
              data   = lt_failed_commit
              name   = 'FAILED' ).

          out->write(
            EXPORTING
            data   = lt_reported_commit
            name   = 'REPORTED' ).
        ELSE.
          out->write( |Order updated succefully| ).
        ENDIF.

      ELSE.
        out->write(
            EXPORTING
            data   = lt_update_failed
            name   = 'FAILED' ).

        out->write(
          EXPORTING
          data   = lt_update_failed
          name   = 'REPORTED' ).
      ENDIF.

    ENDIF.


  ENDMETHOD.
ENDCLASS.
