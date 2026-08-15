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
                       %features-%field-NetAmount       =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-f-read_only
                                                                                               ELSE if_abap_behv=>fc-f-unrestricted  )
                       %features-%field-CurrencyCode    =   COND #( WHEN ls_data-Status = '02' THEN if_abap_behv=>fc-f-read_only
                                                                                               ELSE if_abap_behv=>fc-f-unrestricted  )
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
  FIELDS ( Status )
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

ENDCLASS.
