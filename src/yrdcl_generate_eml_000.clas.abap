CLASS yrdcl_generate_eml_000 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yrdcl_generate_eml_000 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: lt_read TYPE TABLE FOR READ RESULT YRDR_OrderTP_000.

*  lt_read = VALUE #( ( %tky-Uuid = ) )
*************************************************************************************
    " READ existing Order and associated Items
    " Provide the Order-UUID for an existing Order in %tky-uuid below
    "
*************************************************************************************

    READ ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    ALL FIELDS
    WITH VALUE #( ( %tky-Uuid = 'FED9F9699AA11FD1A695B54A09B2CA0F'  ) ) " This can be changed during testing
    RESULT DATA(lt_read_result)
    BY \_Item
    ALL FIELDS
    WITH VALUE #( ( %tky-Uuid = 'FED9F9699AA11FD1A695B54A09B2CA0F'  ) ) " This can be changed during testing
    RESULT DATA(lt_read_item)
    FAILED DATA(lt_read_failed)
    REPORTED DATA(lt_read_reported).

    IF lt_read_failed IS INITIAL.
      out->write(
        EXPORTING
            data   = lt_read_result
            name   = 'READ Result : Order' ).

      out->write(
        EXPORTING
            data   = lt_read_item
            name   = 'READ Result : Item' ).

    ELSE.

      out->write(
        EXPORTING
        data   = lt_read_failed
        name   = 'FAILED' ).

      out->write(
        EXPORTING
        data   = lt_read_reported
        name   = 'REPORTED' ).

    ENDIF.

*************************************************************************************
    " UPDATE Existing Order
    " Provide the Order-UUID for an existing Order in %tky-uuid below
*************************************************************************************

    MODIFY ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    UPDATE FIELDS ( Status )
    WITH VALUE #( ( %tky-Uuid = 'FED9F9699AA11FD1A695B54A09B2CA0F' " This can be changed during testing
                    Status    = '02'
                   )
                 )
    FAILED DATA(lt_update_failed)
    REPORTED DATA(lt_update_reported).

    COMMIT ENTITIES.

    IF lt_update_failed IS INITIAL.
*************************************************************************************
      " READ the updated data
*************************************************************************************
      READ ENTITIES OF YRDR_OrderTP_000
  ENTITY YRDR_OrderTP_000
  ALL FIELDS WITH VALUE #( ( %tky-Uuid = 'FED9F9699AA11FD1A695B54A09B2CA0F'  ) )
  RESULT DATA(lt_read_updated)
  FAILED DATA(lt_read_failed1)
  REPORTED DATA(lt_read_reported1).

      IF lt_read_failed1 IS INITIAL.
        out->write(
          EXPORTING
              data   = lt_read_updated
              name   = 'READ Updated : Order' ).


      ELSE.

        out->write(
          EXPORTING
          data   = lt_read_failed1
          name   = 'FAILED' ).

        out->write(
          EXPORTING
          data   = lt_read_reported1
          name   = 'REPORTED' ).

      ENDIF.

    ENDIF.

*************************************************************************************
    " CREATE new Order
*************************************************************************************

    MODIFY ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    CREATE FIELDS ( OrderId Status NetAmount CurrencyCode CustomerId )
    AUTO FILL CID
    WITH VALUE #( ( OrderId         =   '2'
                    Status          =   '01'
                    NetAmount       =   '150'
                    CurrencyCode    =   'EUR'
                    CustomerId      =   '2' ) )
    MAPPED DATA(lt_mapped)
    FAILED DATA(lt_create_failed)
    REPORTED DATA(lt_create_reported).

    COMMIT ENTITIES
    RESPONSE OF YRDR_OrderTP_000
    FAILED DATA(lt_failed_commit)
    REPORTED DATA(lt_failed_reported).

    IF lt_failed_commit IS INITIAL.
      " Check from DB if New order is created
      SELECT SINGLE * FROM zyrdorder000 WHERE order_id = '2'
      INTO @DATA(ls_new_order).
      IF sy-subrc = 0.
        out->write(
          EXPORTING
       data   = ls_new_order
       name   = 'READ Result : New Order' ).
      ENDIF.

    ELSE.

      out->write(
        EXPORTING
        data   = lt_failed_commit
        name   = 'FAILED' ).

      out->write(
        EXPORTING
        data   = lt_failed_reported
        name   = 'REPORTED' ).
    ENDIF.

*************************************************************************************
    " CREATE new Order and 2 items
    " Deep creation of root and child entities
*************************************************************************************
    MODIFY ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    CREATE FIELDS ( OrderId Status NetAmount CurrencyCode CustomerId )
    WITH VALUE #( ( %cid            =   'ORDER3'
                    OrderId         =   '3'
                    Status          =   '01'
                    NetAmount       =   '150'
                    CurrencyCode    =   'EUR'
                    CustomerId      =   '2' ) )
    CREATE BY \_Item
    FIELDS ( ProductId ItemId Status ReqQuantity Uom Amount CurrencyCode )
    WITH VALUE #( ( %cid_ref    =   'ORDER3'
                    %target     =   VALUE #( ( %cid         =   'ITEM1'
                                               Amount       =   '1000'
                                               CurrencyCode =   'EUR'
                                               ItemId       =   '1'
                                               ProductId    =   'P01'
                                               Status       =   '01'
                                               ReqQuantity  =   '10'
                                               Uom          =   'EA' )

                                             ( %cid         =   'ITEM2'
                                               Amount       =   '2000'
                                               CurrencyCode =   'EUR'
                                               ItemId       =   '2'
                                               ProductId    =   'P02'
                                               Status       =   '02'
                                               ReqQuantity  =   '10'
                                               Uom          =   'EA' )
                                            )
                    )
                    )

    MAPPED DATA(lt_mapped_deep)
    FAILED DATA(lt_create_failed_deep)
    REPORTED DATA(lt_create_reported_deep).

    COMMIT ENTITIES
    RESPONSE OF YRDR_OrderTP_000
    FAILED DATA(lt_failed_commit_deep)
    REPORTED DATA(lt_failed_reported_deep).

    IF lt_failed_commit_deep IS INITIAL.
      " Check from DB if New order is created
      SELECT SINGLE * FROM zyrdorder000 WHERE order_id = '3'
      INTO @DATA(ls_new_order1).
      IF sy-subrc = 0.
        out->write(
          EXPORTING
       data   = ls_new_order1
       name   = 'READ Result : New Order' ).
      ENDIF.

      " Check from DB if New Items are created
      SELECT * FROM zyrditem000 WHERE parent_uuid = @ls_new_order1-uuid
      INTO TABLE @DATA(lt_new_items).
      IF sy-subrc = 0.
        out->write(
          EXPORTING
       data   = lt_new_items
       name   = 'READ Result : New Items' ).
      ENDIF.


    ELSE.

      out->write(
        EXPORTING
        data   = lt_failed_commit_deep
        name   = 'FAILED_DEEP' ).

      out->write(
        EXPORTING
        data   = lt_failed_reported_deep
        name   = 'REPORTED_DEEP' ).
    ENDIF.

*************************************************************************************
    " DELETE existing Order
*************************************************************************************
    MODIFY ENTITIES OF YRDR_OrderTP_000
    ENTITY YRDR_OrderTP_000
    DELETE FROM VALUE #( ( %tky-Uuid = ls_new_order1-uuid ) )
    FAILED DATA(lt_delete_failed)
    REPORTED DATA(lt_delete_reported).

    COMMIT ENTITIES
    RESPONSE OF YRDR_OrderTP_000
    FAILED DATA(lt_failed_commit_del)
    REPORTED DATA(lt_reported_commit_del).

    IF lt_failed_commit_deep IS INITIAL.
      " Check from DB if New order is created
      SELECT SINGLE * FROM zyrdorder000 WHERE order_id = '3'
      INTO @DATA(ls_new_order2).
      IF sy-subrc <> 0.
        out->write(
          EXPORTING
            data = ls_new_order2
            name = 'DELETED successfully' ).
      ENDIF.

    ELSE.

      out->write(
        EXPORTING
        data   = lt_failed_commit_del
        name   = 'FAILED_DELETE' ).

      out->write(
        EXPORTING
        data   = lt_reported_commit_del
        name   = 'REPORTED_DELETE' ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
