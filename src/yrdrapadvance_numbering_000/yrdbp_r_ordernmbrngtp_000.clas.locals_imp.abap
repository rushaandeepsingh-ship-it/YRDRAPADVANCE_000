CLASS lhc_Order DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR Order RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Order RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Order RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
       entities FOR CREATE Order.

    METHODS earlynumbering_cba_Item FOR NUMBERING
       entities FOR CREATE Order\_Item.

    METHODS fill_status FOR DETERMINE ON MODIFY
       keys FOR Order~fill_status.

    METHODS check_order_date FOR VALIDATE ON SAVE
       keys FOR Order~check_order_date.

ENDCLASS.

CLASS lhc_Order IMPLEMENTATION.

  METHOD get_instance_features.
    " READ the Order instance based on keys
    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
    ENTITY Order
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Set the result table for features
    " When Order status = '02'
    " Field NetAmount must be read-only
    " Creation of Items must be disabled

    result = VALUE #( FOR ls_data IN lt_result
                     ( %tky                             =   ls_data-%tky
                       %features-%field-NetAmount       =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-f-read_only
                                                                                               ELSE if_abap_behv=>fc-f-unrestricted  )
                       %features-%field-CurrencyCode    =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-f-read_only
                                                                                               ELSE if_abap_behv=>fc-f-unrestricted  )
                       %features-%assoc-_Item           =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-o-disabled
                                                                                               ELSE if_abap_behv=>fc-o-enabled  )
                       )
                     ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'YRDRAP_ORD'
            quantity          = CONV #( lines( entities ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities INTO DATA(entity).
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = lx_number_ranges
                        ) TO reported-order.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                        ) TO failed-order.
        ENDLOOP.
        EXIT.
    ENDTRY.

*    CASE number_range_return_code.
*      WHEN '1'.
*        " 1 - the returned number is in a critical range (specified under “percentage warning” in the object definition)
*        LOOP AT entities INTO entity.
*          APPEND VALUE #( %cid = entity-%cid
*                          %key = entity-%key
*                          %msg = new_message(
*                              id        = '/DMO/CM_FLIGHT'
*                              number    = '019'
*                              severity  = if_abap_behv_message=>severity-warning )
*                        ) TO reported-order.
*        ENDLOOP.
*
*      WHEN '2' OR '3'.
*        " 2 - the last number of the interval was returned
*        " 3 - if fewer numbers are available than requested,  the return code is 3
*        LOOP AT entities INTO entity.
*          APPEND VALUE #( %cid = entity-%cid
*                          %key = entity-%key
*                          %msg = new_message(
*                          id   = '/DMO/CM_FLIGHT'
*                          number = '018'
*                          severity = if_abap_behv_message=>severity-warning )
*                        ) TO reported-order.
*          APPEND VALUE #( %cid        = entity-%cid
*                          %key        = entity-%key
*                          %fail-cause = if_abap_behv=>cause-conflict
*                        ) TO failed-order.
*        ENDLOOP.
*        EXIT.
*    ENDCASE.

    DATA(lv_order_id_max) = CONV yrdorderid( number_range_key - number_range_returned_quantity ).

    " Set Order ID
    LOOP AT entities INTO entity.
      lv_order_id_max += 1.
      entity-OrderId = lv_order_id_max .

      APPEND VALUE #( %cid = entity-%cid
                      %key = entity-%key
                    ) TO mapped-order.
    ENDLOOP.


  ENDMETHOD.

  METHOD earlynumbering_cba_Item.

    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
      ENTITY Order
      BY \_Item
      FROM CORRESPONDING #( entities )
      LINK DATA(lt_items).

    " Loop over all unique OrderIDs
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_order>) GROUP BY <ls_order>-OrderId.

      " Get highest booking_id from existing bookings belonging to travel
      DATA(lv_max_item_id) = REDUCE #( INIT max = CONV yrdorderid( '0' )
                                 FOR  ls_item IN lt_items USING KEY entity WHERE ( source-OrderId  = <ls_order>-OrderId )
                                 NEXT max = COND yrdorderid( WHEN ls_item-target-ItemId > max
                                                                    THEN ls_item-target-ItemId
                                                                    ELSE max )
                               ).
      " Get highest assigned booking_id from incoming entities, eg from internal operations
      lv_max_item_id = REDUCE #( INIT max = lv_max_item_id
                                 FOR  entity IN entities USING KEY entity WHERE ( OrderId  = <ls_order>-OrderId )
                                 FOR  target IN entity-%target
                                 NEXT max = COND yrdorderid( WHEN   target-ItemId > max
                                                                    THEN target-ItemId
                                                                    ELSE max )
                               ).

      " Assign new booking-ids if not already assigned
      LOOP AT <ls_order>-%target ASSIGNING FIELD-SYMBOL(<item_wo_numbers>).
        APPEND CORRESPONDING #( <item_wo_numbers> ) TO mapped-item ASSIGNING FIELD-SYMBOL(<mapped_item>).
        IF <item_wo_numbers>-ItemId IS INITIAL.
          lv_max_item_id += 1 .
          <mapped_item>-ItemId = lv_max_item_id .
        ENDIF.
      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD fill_status.

    " 1. READ the order instance based on keys
    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
  ENTITY Order
  FIELDS ( Status )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_result)
  FAILED DATA(lt_failed).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_data>).
      <ls_data>-Status = '01'.
    ENDLOOP.

    "3. MODIFY the order status in buffer
    MODIFY ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
    ENTITY Order
    UPDATE FIELDS ( Status )
    WITH CORRESPONDING #( lt_result ).

  ENDMETHOD.

  METHOD check_order_date.
    " Check if Order date is past date compared to system date

    " 1. READ the order instance based on keys
    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
  ENTITY Order
  FIELDS ( Status )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_result)
  FAILED DATA(lt_failed).

    IF lt_failed IS INITIAL.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_data>).
        APPEND VALUE #( %tky          = <ls_data>-%tky
                        %state_area   = 'VALIDATE_DATE' )
          TO reported-order.
        IF <ls_data>-OrderDate < cl_abap_context_info=>get_system_date( ).
          APPEND VALUE #( %tky = <ls_data>-%tky ) TO failed-order.

          APPEND VALUE #( %tky                = <ls_data>-%tky
                          %state_area         = 'VALIDATE_DATE'
                          %msg                = new_message_with_text(
                          severity  = if_abap_behv_message=>severity-error
                          text      = |Order Date can not be in past| )
                          %element-OrderDate = if_abap_behv=>mk-on
                        ) TO reported-order.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
