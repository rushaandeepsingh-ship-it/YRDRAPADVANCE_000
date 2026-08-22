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

    METHODS accept FOR MODIFY
       keys FOR ACTION Order~accept RESULT result.

    METHODS reject FOR MODIFY
       keys FOR ACTION Order~reject RESULT result.
    METHODS copy FOR MODIFY
       keys FOR ACTION Order~copy.
    METHODS changeStatus FOR MODIFY
       keys FOR ACTION Order~changeStatus RESULT result.
    METHODS GetDefaultsForCopy FOR READ
       keys FOR FUNCTION Order~GetDefaultsForCopy RESULT result.

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
                                                                                               ELSE if_abap_behv=>fc-o-enabled )
                       %features-%action-accept         =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-o-enabled
                                                                                               ELSE if_abap_behv=>fc-o-disabled )
                       %features-%action-reject         =   COND #( WHEN ls_data-Status = '03' THEN if_abap_behv=>fc-o-enabled
                                                                                               ELSE if_abap_behv=>fc-o-disabled ) )
                     ).
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    " Ensure Travel ID is not set yet (idempotent)- must be checked when BO is draft-enabled
    LOOP AT entities INTO DATA(ls_entity) WHERE OrderId IS NOT INITIAL.
      APPEND CORRESPONDING #( ls_entity ) TO mapped-order.
    ENDLOOP.

    DATA(lt_entities_wo_orderid) = entities.
    DELETE lt_entities_wo_orderid WHERE OrderId IS NOT INITIAL.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'YRDRAP_ORD'
            quantity          = CONV #( lines( lt_entities_wo_orderid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT lt_entities_wo_orderid INTO DATA(entity).
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %Is_draft = entity-%is_draft
                          %msg = lx_number_ranges
                        ) TO reported-order.

          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %Is_draft = entity-%is_draft
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
    LOOP AT lt_entities_wo_orderid INTO entity.
      lv_order_id_max += 1.
      entity-%key-OrderId = lv_order_id_max .

      APPEND VALUE #( %cid      = entity-%cid
                      %is_draft = entity-%is_draft
                      %key      = entity-%key
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

      " Get highest ItemID from existing Items belonging to Order
      DATA: lv_max         TYPE yrdorderid,
            lv_max_item_id TYPE yrdorderid.
      LOOP AT lt_items INTO DATA(ls_item) WHERE source-OrderId = <ls_order>-OrderId.

        IF shift_left( ls_item-target-ItemId ) > lv_max.
          lv_max = shift_left( ls_item-target-ItemId ).
        ENDIF.
        lv_max_item_id = lv_max.
      ENDLOOP.


      " Assign new ItemIDs if not already assigned
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
  FIELDS ( OrderDate )
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

  METHOD accept.

    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
           ENTITY Order
              UPDATE FIELDS ( Status )
                 WITH VALUE #( FOR key IN keys ( %tky    = key-%tky
                                                 Status  = '03' ) ). " Approved

    " Read changed data for action result
    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
      ENTITY Order
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result ) ).


  ENDMETHOD.

  METHOD reject.


    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
           ENTITY Order
              UPDATE FIELDS ( Status )
                 WITH VALUE #( FOR key IN keys ( %tky    = key-%tky
                                                 Status  = '04' ) ). " Rejected

    " Read changed data for action result
    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
      ENTITY Order
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result ) ).

  ENDMETHOD.

  METHOD copy.

    DATA: lt_order_copy TYPE TABLE FOR CREATE YRDR_OrderNmbrngTP_000\\order,
          lt_item_copy  TYPE TABLE FOR CREATE YRDR_OrderNmbrngTP_000\\Order\_Item.


    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
      ENTITY Order
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(lt_order)
       ENTITY Order BY \_Item
       ALL FIELDS WITH
       CORRESPONDING #( keys )
       RESULT DATA(lt_items).

    LOOP AT keys INTO DATA(key).
      READ TABLE lt_order ASSIGNING FIELD-SYMBOL(<ls_order>) WITH KEY id COMPONENTS %tky = key-%tky.
      IF sy-subrc EQ 0.
        "Fill travel container for creating new travel instance
        APPEND VALUE #( %cid        = key-%cid
                        %is_draft   = key-%param-%is_draft
                        %data       = CORRESPONDING #( <ls_order> EXCEPT orderid ) ) TO lt_order_copy ASSIGNING FIELD-SYMBOL(<ls_new_order>).
        " Update Order Date to current system date
        <ls_new_order>-OrderDate     = key-%param-order_date_param.
        "Update Customer ID from Action input parameter
        <ls_new_order>-CustomerId    = key-%param-CustomerId_param.

        DATA(lv_isitemtocopy) = key-%param-IsItemToCopy.

        IF lv_isitemtocopy IS NOT INITIAL.
          "Fill %cid_ref of Order as instance identifier for cba Item
          APPEND VALUE #( %cid_ref  = key-%cid
                          %is_draft = key-%param-%is_draft ) TO lt_item_copy ASSIGNING FIELD-SYMBOL(<ls_item_cba>).

          LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
            "Fill Item container for creating Items with cba
            APPEND VALUE #( %cid      = key-%cid && shift_left( <ls_item>-ItemId )
                            %is_draft = key-%param-%is_draft
                            %data     = CORRESPONDING #( lt_items[ KEY entity %tky = <ls_item>-%tky ] EXCEPT orderid ) )
              TO <ls_item_cba>-%target ASSIGNING FIELD-SYMBOL(<ls_new_item>).

          ENDLOOP.
        ENDIF.
      ELSE.
        APPEND CORRESPONDING #( key MAPPING %fail = DEFAULT VALUE #( cause = if_abap_behv=>cause-not_found ) ) TO failed-order.
      ENDIF.
    ENDLOOP.


    " Create new BO Instances
    MODIFY ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
    ENTITY Order
    CREATE FIELDS ( CustomerID OrderDate Status CurrencyCode NetAmount )
    WITH lt_order_copy
    ENTITY Order
    CREATE BY \_Item
    FIELDS ( ItemId ProductId Uom ReqQuantity CurrencyCode Amount Status )
    WITH lt_item_copy
    MAPPED DATA(ls_mapped_create).

    mapped-order = ls_mapped_create-order.

  ENDMETHOD.

  METHOD changeStatus.

    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
           ENTITY Order
              UPDATE FIELDS ( Status )
                 WITH VALUE #( FOR key IN keys ( %tky    = key-%tky
                                                 Status  = key-%param-status_param ) ). " Approved

    " Read changed data for action result
    READ ENTITIES OF YRDR_OrderNmbrngTP_000 IN LOCAL MODE
      ENTITY Order
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result ) ).


  ENDMETHOD.

  METHOD GetDefaultsForCopy.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      INSERT INITIAL LINE INTO TABLE result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = CORRESPONDING #( <ls_key> ).
      <ls_result>-%param = VALUE #( IsItemToCopy      =   abap_true
                                    order_date_param  =   cl_abap_context_info=>get_system_date( ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
