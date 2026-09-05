CLASS lhc_Customer DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_cba_Order FOR MODIFY
       entities FOR CREATE Customer\_Order.

ENDCLASS.

CLASS lhc_Customer IMPLEMENTATION.

  METHOD augment_cba_Order.

    DATA: lt_order_new TYPE TABLE FOR CREATE YRDR_CustomerTP_000\\Customer\_Order.

    lt_order_new = CORRESPONDING #( DEEP entities ).

    READ ENTITIES OF YRDR_CustomerTP_000
    ENTITY Customer
    FIELDS ( CustomerId )
    WITH VALUE #( FOR ls_data IN entities
                  ( %tky = ls_data-%tky ) )
    RESULT DATA(lt_customer).

    LOOP AT lt_order_new ASSIGNING FIELD-SYMBOL(<ls_order_new>).

      LOOP AT <ls_order_new>-%target ASSIGNING FIELD-SYMBOL(<ls_order_data>).
        <ls_order_data> = VALUE #( %cid       =   entities[ 1 ]-%target[ 1 ]-%cid
                                   %is_draft  =   <ls_order_new>-%is_draft
                                   OrderDate  =   cl_abap_context_info=>get_system_date( )
                                   Status     =   '01'
                                   CustomerId =   lt_customer[ 1 ]-CustomerId
                                   %control   =   VALUE #( status     = if_abap_behv=>mk-on
                                                           OrderDate  = if_abap_behv=>mk-on
                                                           CustomerId = if_abap_behv=>mk-on ) ).
      ENDLOOP.

    ENDLOOP.

    MODIFY AUGMENTING ENTITIES OF YRDR_CustomerTP_000
    ENTITY Customer
    CREATE BY \_Order
    FROM lt_order_new.

  ENDMETHOD.

ENDCLASS.
