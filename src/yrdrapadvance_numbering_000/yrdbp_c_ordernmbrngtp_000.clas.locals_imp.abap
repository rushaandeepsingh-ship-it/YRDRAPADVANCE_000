CLASS lhc_Order DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS precheck_accept FOR PRECHECK
       keys FOR ACTION Order~accept.

ENDCLASS.

CLASS lhc_Order IMPLEMENTATION.

  METHOD precheck_accept.

    READ ENTITIES OF YRDR_OrderNmbrngTP_000
    ENTITY Order
       ALL FIELDS WITH
       CORRESPONDING #( keys )
     RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_data>).
      IF <ls_data>-NetAmount > 100.
        APPEND VALUE #( %tky = <ls_data>-%tky ) TO failed-order.

        APPEND VALUE #( %tky                = <ls_data>-%tky
                        %msg                = new_message_with_text(
                        severity  = if_abap_behv_message=>severity-error
                        text      = |Order amount exceeded and can't be approved| )
                      ) TO reported-order.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
