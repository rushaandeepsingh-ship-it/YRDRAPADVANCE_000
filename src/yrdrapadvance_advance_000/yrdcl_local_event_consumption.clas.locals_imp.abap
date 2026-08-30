*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
CLASS lcl_event_order DEFINITION INHERITING FROM cl_abap_behavior_event_handler.
  PRIVATE SECTION.
    METHODS get_uuid RETURNING VALUE(uuid) TYPE sysuuid_x16.

    METHODS on_orderstatus_updated FOR ENTITY EVENT
       keys FOR YRDR_OrderTP_000~orderStatusUpdatedLocal.

ENDCLASS.

CLASS lcl_event_order IMPLEMENTATION.

  METHOD get_uuid.
    TRY.
        uuid = cl_system_uuid=>create_uuid_x16_static( ) .
      CATCH cx_uuid_error.
    ENDTRY.
  ENDMETHOD.

  METHOD on_orderstatus_updated.
    "close the active modify phase
    cl_abap_tx=>save( ).

    "loop over transfered Order instances and do the needful :)
    LOOP AT keys REFERENCE INTO DATA(lr_key).
      DATA lr_status_updated TYPE yrd_event_data.
      MOVE-CORRESPONDING lr_key->* TO lr_status_updated.
      lr_status_updated-event_id    = get_uuid( ).
      lr_status_updated-event_name  = 'OrderStatusUpdated'.
      lr_status_updated-orderid     = lr_key->orderid.
      lr_status_updated-uuid        = lr_key->Uuid.
      lr_status_updated-status      = lr_key->order_status.
      GET TIME STAMP FIELD lr_status_updated-created_at.
      "insert to db
      INSERT yrd_event_data FROM @lr_status_updated.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
