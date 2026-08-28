CLASS lhc_YRDC_ORDERUUIDTP_000 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR yrdc_orderuuidtp_000 RESULT result.

    METHODS augment_cba_Item FOR MODIFY
       entities FOR CREATE yrdc_orderuuidtp_000\_Item.

    METHODS addMultipleItems FOR MODIFY
       keys FOR ACTION yrdc_orderuuidtp_000~addMultipleItems RESULT result.

    METHODS precheck_changeStatus FOR PRECHECK
       keys FOR ACTION yrdc_orderuuidtp_000~changeStatus.

ENDCLASS.

CLASS lhc_YRDC_ORDERUUIDTP_000 IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
       ALL FIELDS WITH
       CORRESPONDING #( keys )
     RESULT DATA(lt_result).

    result = VALUE #( FOR ls_data IN lt_result
                       (   %tky                                =   ls_data-%tky
                           %features-%action-addMultipleItems  =   COND #( WHEN ls_data-%is_draft = '01'
                                                                           AND  ls_data-Status NE '02'
                                                                           THEN if_abap_behv=>fc-o-enabled
                                                                           ELSE if_abap_behv=>fc-o-disabled )

                        ) ).

  ENDMETHOD.

  METHOD augment_cba_Item.

    DATA: lt_items_new TYPE TABLE FOR CREATE YRDR_OrderTP_000\\YRDR_OrderTP_000\_Item.

    lt_items_new = CORRESPONDING #( DEEP entities ).

    LOOP AT lt_items_new ASSIGNING FIELD-SYMBOL(<ls_item>).

      LOOP AT <ls_item>-%target ASSIGNING FIELD-SYMBOL(<ls_item_data>).
        <ls_item_data> = VALUE #( %cid          =   entities[ 1 ]-%target[ 1 ]-%cid
                                  %is_draft     =   <ls_item>-%is_draft
                                  ReqQuantity   =   1
                                  uom           =   'EA'
                                  Status        =   '01'
                                  %control      = VALUE #( reqquantity = if_abap_behv=>mk-on
                                                           uom         = if_abap_behv=>mk-on
                                                           status      = if_abap_behv=>mk-on )
                                 ).
      ENDLOOP.

    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    CREATE BY \_Item
    FROM lt_items_new.



  ENDMETHOD.

  METHOD addMultipleItems.

    DATA: lt_items_new TYPE TABLE FOR CREATE YRDR_OrderTP_000\\YRDR_OrderTP_000\_Item.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND VALUE #( %tky      = <ls_keys>-%tky
                      %target   = VALUE #( FOR i = 1 UNTIL i > 5
                                            ( %cid          =   |ITEM| && i
                                              %is_draft     =   <ls_keys>-%is_draft
                                              reqquantity   =   1
                                              uom           =   'EA'
                                              status        =   '01'
                                              %control      =   VALUE #( reqquantity = if_abap_behv=>mk-on
                                                                         uom         = if_abap_behv=>mk-on
                                                                         status      = if_abap_behv=>mk-on )  )
                                          )
                         ) TO lt_items_new.

    ENDLOOP.

    MODIFY ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    CREATE BY \_Item
    FROM lt_items_new.


  ENDMETHOD.

  METHOD precheck_changeStatus.

    READ ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
       ALL FIELDS WITH
       CORRESPONDING #( keys )
     RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<ls_data>).
      IF <ls_data>-NetAmount > 100 AND keys[ 1 ]-%param-status_param = '03'.
        APPEND VALUE #( %tky = CORRESPONDING #( <ls_data>-%tky ) ) TO failed-yrdc_orderuuidtp_000.

        APPEND VALUE #( %tky                = CORRESPONDING #( <ls_data>-%tky )
                        %msg                = new_message_with_text(
                        severity  = if_abap_behv_message=>severity-warning
                        text      = |Order amount exceeded and can't be approved| )
                      ) TO reported-yrdc_orderuuidtp_000.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
