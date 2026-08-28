CLASS lhc_yrdr_orderitemtp_000 DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS set_item_id FOR DETERMINE ON SAVE
       keys FOR YRDR_OrderItemTP_000~set_item_id.
    METHODS calculateOrderprice FOR DETERMINE ON MODIFY
       keys FOR YRDR_OrderItemTP_000~calculateOrderprice.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR YRDR_OrderItemTP_000 RESULT result.
    METHODS checkmandatoryfields FOR VALIDATE ON SAVE
       keys FOR yrdr_orderitemtp_000~checkmandatoryfields.

ENDCLASS.

CLASS lhc_yrdr_orderitemtp_000 IMPLEMENTATION.

  METHOD set_item_id.

    DATA:
      max_bookingid   TYPE yrdorderid,
      bookings_update TYPE TABLE FOR UPDATE YRDR_OrderTP_000\\YRDR_OrderItemTP_000,
      booking         TYPE STRUCTURE FOR READ RESULT YRDR_OrderItemTP_000.

    "Read all travels for the requested bookings
    " If multiple bookings of the same travel are requested, the travel is returned only once.
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderItemTP_000 BY \_Order
        FIELDS ( Uuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    " Read all bookings for all affected travels
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderTP_000 BY \_Item
        ALL FIELDS
        WITH CORRESPONDING #( travels )
        LINK DATA(booking_links)
      RESULT DATA(bookings).

    " Process all affected travels.
    LOOP AT travels INTO DATA(travel).

      " find max used bookingID in all bookings of this travel
      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = travel-%tky.
        " Short dump occurs if link table does not match read table, which must never happen
        booking = bookings[ KEY id  %tky = booking_link-target-%tky ].
        IF booking-ItemId > max_bookingid.
          max_bookingid = booking-ItemId.
        ENDIF.
      ENDLOOP.

      "Provide a booking ID for all bookings of this travel that have none.
      LOOP AT booking_links INTO booking_link USING KEY id WHERE source-%tky = travel-%tky.
        " Short dump occurs if link table does not match read table, which must never happen
        booking = bookings[ KEY id  %tky = booking_link-target-%tky ].
        IF booking-ItemId IS INITIAL.
          max_bookingid += 1.
          APPEND VALUE #( %tky      = booking-%tky
                          itemid    = max_bookingid
                        ) TO bookings_update.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " Provide a booking ID for all bookings that have none.
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderItemTP_000
        UPDATE FIELDS ( ItemId )
        WITH bookings_update.

  ENDMETHOD.

  METHOD calculateOrderprice.

    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
     ENTITY YRDR_OrderItemTP_000 BY \_Order
       FIELDS ( Uuid )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_order).

    " Trigger Re-Calculation on Root Node
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    EXECUTE CalctNetAmount
    FROM CORRESPONDING #( lt_order ).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderItemTP_000 BY \_Order
        FIELDS ( Uuid )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_order).


    result = VALUE #( FOR ls_key IN keys ( %tky                       = ls_key-%tky
                                           %features-%field-ProductId = COND #( WHEN ls_key-%is_draft = if_abap_behv=>mk-on
                                                                                                   THEN if_abap_behv=>fc-f-mandatory )
*                                           %features-%update          = COND #( WHEN lt_order[ 1 ]-Status = '02'
*                                                                                THEN if_abap_behv=>fc-o-disabled
*                                                                                ELSE if_abap_behv=>fc-o-enabled )
                                           ) ).

  ENDMETHOD.

  METHOD checkMandatoryFields.

    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderItemTP_000
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item).

    GET PERMISSIONS OF YRDR_OrderTP_000
    ENTITY YRDR_OrderItemTP_000
    FROM CORRESPONDING #( keys )
    REQUEST VALUE #( %field-ProductId = if_abap_behv=>mk-on )
    RESULT DATA(ls_permission).

    LOOP AT lt_item ASSIGNING FIELD-SYMBOL(<ls_item>).

      " Check which fields are set mandatory in feature control
      READ TABLE ls_permission-instances ASSIGNING FIELD-SYMBOL(<ls_persmission>) WITH KEY %tky = <ls_item>-%tky.
      IF sy-subrc = 0 AND <ls_persmission>-%field-ProductId = if_abap_behv=>fc-f-mandatory.
        APPEND VALUE #( %tky          = <ls_item>-%tky
                        %state_area   = 'VALIDATE_MANDATORY' ) TO reported-yrdr_orderitemtp_000.
        IF <ls_item>-ProductId IS INITIAL.
          APPEND VALUE #( %tky = <ls_item>-%tky ) TO failed-yrdr_orderitemtp_000.

          APPEND VALUE #( %tky                = <ls_item>-%tky
                          %state_area         = 'VALIDATE_MANDATORY'
                          %msg                = new_message_with_text(
                                                  severity  = if_abap_behv_message=>severity-error
                                                  text      = |Enter a value for "Product ID"| )
                          %element-productid  = if_abap_behv=>mk-on
                          %path-YRDR_OrderTP_000 = VALUE #( uuid = <ls_item>-ParentUuid %is_draft = <ls_item>-%is_draft )

                        ) TO reported-yrdr_orderitemtp_000.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_YRDR_OrderTP_000 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR YRDR_OrderTP_000 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR YRDR_OrderTP_000 RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR YRDR_OrderTP_000 RESULT result.
    METHODS check_order_date FOR VALIDATE ON SAVE
       keys FOR yrdr_ordertp_000~check_order_date.
    METHODS fill_status FOR DETERMINE ON MODIFY
       keys FOR yrdr_ordertp_000~fill_status.
    METHODS set_order_id FOR DETERMINE ON SAVE
       keys FOR yrdr_ordertp_000~set_order_id.
    METHODS getdefaultsforcopy FOR READ
       keys FOR FUNCTION yrdr_ordertp_000~getdefaultsforcopy RESULT result.

    METHODS changestatus FOR MODIFY
       keys FOR ACTION yrdr_ordertp_000~changestatus RESULT result.

    METHODS copy FOR MODIFY
       keys FOR ACTION yrdr_ordertp_000~copy.
    METHODS calctnetamount FOR MODIFY
       keys FOR ACTION yrdr_ordertp_000~calctnetamount.

ENDCLASS.

CLASS lhc_YRDR_OrderTP_000 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.

    " READ the Order instance based on keys
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    " Set the result table for features
    " When Order status = '02'
    " Field NetAmount must be read-only
    " Creation of Items must be disabled

    result = VALUE #( FOR ls_data IN lt_result
                     ( %tky                             =   ls_data-%tky
*                       %features-%field-NetAmount       =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-f-read_only
*                                                                                               ELSE if_abap_behv=>fc-f-unrestricted  )
*                       %features-%field-CurrencyCode    =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-f-read_only
*                                                                                               ELSE if_abap_behv=>fc-f-unrestricted  )
                       %features-%assoc-_Item           =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-o-disabled
                                                                                               ELSE if_abap_behv=>fc-o-enabled  )

                       )
                     ).

  ENDMETHOD.

  METHOD check_order_date.

    " Check if Order date is past date compared to system date

    " 1. READ the order instance based on keys
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
  ENTITY YRDR_OrderTP_000
  FIELDS ( OrderDate )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_result)
  FAILED DATA(lt_failed).

    IF lt_failed IS INITIAL.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_data>).
        APPEND VALUE #( %tky          = <ls_data>-%tky
                        %state_area   = 'VALIDATE_DATE' )
          TO reported-yrdr_ordertp_000.
        IF <ls_data>-OrderDate < cl_abap_context_info=>get_system_date( ).
          APPEND VALUE #( %tky = <ls_data>-%tky ) TO failed-yrdr_ordertp_000.

          APPEND VALUE #( %tky                = <ls_data>-%tky
                          %state_area         = 'VALIDATE_DATE'
                          %msg                = new_message_with_text(
                          severity  = if_abap_behv_message=>severity-error
                          text      = |Order Date can not be in past| )
                          %element-OrderDate = if_abap_behv=>mk-on
                        ) TO reported-yrdr_ordertp_000.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD fill_status.

    " 1. READ the order instance based on keys
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
  ENTITY YRDR_OrderTP_000
  FIELDS ( Status )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_result)
  FAILED DATA(lt_failed).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_data>).
      <ls_data>-Status = '01'.
    ENDLOOP.

    "3. MODIFY the order status in buffer
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    UPDATE FIELDS ( Status )
    WITH CORRESPONDING #( lt_result ).


  ENDMETHOD.

  METHOD set_order_id.

    "Ensure idempotence
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderTP_000
        FIELDS ( OrderId )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DELETE lt_orders WHERE OrderId IS NOT INITIAL.
    CHECK lt_orders IS NOT INITIAL.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'YRDRAP_ORD'
            quantity          = CONV #( lines( lt_orders ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT lt_orders INTO DATA(entity).
          APPEND VALUE #( %tky = entity-%tky
                          %msg = lx_number_ranges
                        ) TO reported-yrdr_ordertp_000.

        ENDLOOP.
        EXIT.
    ENDTRY.

    DATA(lv_order_id_max) = CONV yrdorderid( number_range_key - number_range_returned_quantity ).

*    "Get max active travelID
*    SELECT SINGLE FROM zyrdorder000 FIELDS MAX( order_id ) INTO @DATA(lv_max_orderid).
*
*    "Get max draft travelID
*    SELECT SINGLE FROM zyrdorder000_d FIELDS MAX( orderid ) INTO @DATA(lv_max_orderid_draft).



    "update involved instances
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderTP_000
        UPDATE FIELDS ( OrderId )
        WITH VALUE #( FOR ls_order IN lt_orders INDEX INTO i (
                           %tky      = ls_order-%tky
                           OrderId   = lv_order_id_max + 1 ) ).
*                           OrderId   = nmax( val1 = lv_max_orderid val2 = lv_max_orderid_draft ) + i ) ).

  ENDMETHOD.

  METHOD GetDefaultsForCopy.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      INSERT INITIAL LINE INTO TABLE result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = CORRESPONDING #( <ls_key> ).
      <ls_result>-%param = VALUE #( IsItemToCopy      =   abap_true
                                    order_date_param  =   cl_abap_context_info=>get_system_date( ) ).
    ENDLOOP.


  ENDMETHOD.

  METHOD changeStatus.

    " Modify in local mode: BO-related updates that are not relevant for authorization checks
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
           ENTITY YRDR_OrderTP_000
              UPDATE FIELDS ( Status )
                 WITH VALUE #( FOR key IN keys ( %tky    = key-%tky
                                                 Status  = key-%param-status_param ) ). " Approved

    " Read changed data for action result
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderTP_000
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                   %param = ls_result ) ).


  ENDMETHOD.

  METHOD copy.

    DATA: lt_order_copy TYPE TABLE FOR CREATE YRDR_OrderTP_000\\YRDR_OrderTP_000,
          lt_item_copy  TYPE TABLE FOR CREATE YRDR_OrderTP_000\\YRDR_OrderTP_000\_Item.


    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
      ENTITY YRDR_OrderTP_000
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(lt_order)
       ENTITY YRDR_OrderTP_000 BY \_Item
       ALL FIELDS WITH
       CORRESPONDING #( keys )
       RESULT DATA(lt_items).

    LOOP AT keys INTO DATA(key).
      READ TABLE lt_order ASSIGNING FIELD-SYMBOL(<ls_order>) WITH KEY id COMPONENTS %tky = key-%tky.
      IF sy-subrc EQ 0.
        "Fill Order container for creating new Order instance
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
                            %data     = CORRESPONDING #( lt_items[ KEY id %tky = <ls_item>-%tky ] ) )
              TO <ls_item_cba>-%target ASSIGNING FIELD-SYMBOL(<ls_new_item>).

          ENDLOOP.
        ENDIF.
      ELSE.
        APPEND CORRESPONDING #( key MAPPING %fail = DEFAULT VALUE #( cause = if_abap_behv=>cause-not_found ) ) TO failed-yrdr_ordertp_000.
      ENDIF.
    ENDLOOP.


    " Create new BO Instances
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    CREATE FIELDS ( CustomerID OrderDate Status CurrencyCode NetAmount )
    WITH lt_order_copy
    ENTITY YRDR_OrderTP_000
    CREATE BY \_Item
    FIELDS ( ItemId ProductId Uom ReqQuantity CurrencyCode Amount Status )
    WITH lt_item_copy
    MAPPED DATA(ls_mapped_create).

    mapped-yrdr_ordertp_000 = ls_mapped_create-yrdr_ordertp_000.

  ENDMETHOD.

  METHOD CalctNetAmount.

    DATA: lv_amount TYPE /dmo/total_price.
    " Read Order details
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_order).

    "Read all linked Items
    READ ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    BY \_Item
    ALL FIELDS WITH CORRESPONDING #( lt_order )
    LINK DATA(lt_item_links)
    RESULT DATA(lt_items).

    LOOP AT lt_order ASSIGNING FIELD-SYMBOL(<ls_order>).
      LOOP AT lt_item_links INTO DATA(ls_link) WHERE source-%tky = <ls_order>-%tky.
        DATA(ls_item) = lt_items[ KEY id %tky = ls_link-target-%tky ].
        lv_amount += ls_item-Amount.
      ENDLOOP.
      <ls_order>-NetAmount = lv_amount.
      <ls_order>-CurrencyCode = ls_item-CurrencyCode.
    ENDLOOP.

    " Modify Net amount
    MODIFY ENTITIES OF YRDR_OrderTP_000 IN LOCAL MODE
    ENTITY YRDR_OrderTP_000
    UPDATE
    FIELDS ( NetAmount CurrencyCode )
    WITH CORRESPONDING #( lt_order ).

  ENDMETHOD.

ENDCLASS.
