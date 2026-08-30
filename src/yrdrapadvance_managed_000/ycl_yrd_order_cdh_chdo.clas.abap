CLASS ycl_yrd_order_cdh_chdo DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_chdo_enhancements .

    CLASS-DATA objectclass TYPE if_chdo_object_tools_rel=>ty_cdobjectcl READ-ONLY VALUE 'YRD_ORDER_CDH' ##NO_TEXT.

    CLASS-METHODS write
      IMPORTING
        !objectid                TYPE if_chdo_object_tools_rel=>ty_cdobjectv
        !utime                   TYPE if_chdo_object_tools_rel=>ty_cduzeit
        !udate                   TYPE if_chdo_object_tools_rel=>ty_cddatum
        !username                TYPE if_chdo_object_tools_rel=>ty_cdusername
        !planned_change_number   TYPE if_chdo_object_tools_rel=>ty_planchngnr DEFAULT space
        !object_change_indicator TYPE if_chdo_object_tools_rel=>ty_cdchngindh DEFAULT 'U'
        !planned_or_real_changes TYPE if_chdo_object_tools_rel=>ty_cdflag DEFAULT space
        !no_change_pointers      TYPE if_chdo_object_tools_rel=>ty_cdflag DEFAULT space
        !o_zyrditem000           TYPE zyrditem000 OPTIONAL
        !n_zyrditem000           TYPE zyrditem000 OPTIONAL
        !upd_zyrditem000         TYPE if_chdo_object_tools_rel=>ty_cdchngindh DEFAULT space
        !o_zyrdorder000          TYPE zyrdorder000 OPTIONAL
        !n_zyrdorder000          TYPE zyrdorder000 OPTIONAL
        !upd_zyrdorder000        TYPE if_chdo_object_tools_rel=>ty_cdchngindh DEFAULT space
      EXPORTING
        VALUE(changenumber)      TYPE if_chdo_object_tools_rel=>ty_cdchangenr
      RAISING
        cx_chdo_write_error .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_yrd_order_cdh_chdo IMPLEMENTATION.


  METHOD write.
*"----------------------------------------------------------------------
*"         this WRITE method is generated for object YRD_ORDER_CDH
*"         never change it manually, please!        :08/29/2026
*"         All changes will be overwritten without a warning!
*"
*"         CX_CHDO_WRITE_ERROR is used for error handling
*"----------------------------------------------------------------------

    DATA: l_upd        TYPE if_chdo_object_tools_rel=>ty_cdchngind.

    cl_chdo_write_tools=>changedocument_open(
      EXPORTING
        objectclass             = objectclass
        objectid                = objectid
        planned_change_number   = planned_change_number
        planned_or_real_changes = planned_or_real_changes ).

    IF ( n_zyrditem000 IS INITIAL ) AND
       ( o_zyrditem000 IS INITIAL ).
      l_upd  = space.
    ELSE.
      l_upd = upd_zyrditem000.
    ENDIF.

    IF  l_upd  NE space.
      cl_chdo_write_tools=>changedocument_single_case(
        EXPORTING
          tablename              = 'ZYRDITEM000'
          workarea_old           = o_zyrditem000
          workarea_new           = n_zyrditem000
          change_indicator       = upd_zyrditem000
          docu_delete            = 'X'
          docu_insert            = 'X'
          docu_delete_if         = ''
          docu_insert_if         = 'X'
                 ).
    ENDIF.

    IF ( n_zyrdorder000 IS INITIAL ) AND
       ( o_zyrdorder000 IS INITIAL ).
      l_upd  = space.
    ELSE.
      l_upd = upd_zyrdorder000.
    ENDIF.

    IF  l_upd  NE space.
      cl_chdo_write_tools=>changedocument_single_case(
        EXPORTING
          tablename              = 'ZYRDORDER000'
          workarea_old           = o_zyrdorder000
          workarea_new           = n_zyrdorder000
          change_indicator       = upd_zyrdorder000
          docu_delete            = 'X'
          docu_insert            = 'X'
          docu_delete_if         = ''
          docu_insert_if         = 'X'
                 ).
    ENDIF.

    cl_chdo_write_tools=>changedocument_close(
      EXPORTING
        objectclass             = objectclass
        objectid                = objectid
        date_of_change          = udate
        time_of_change          = utime
        username                = username
        object_change_indicator = object_change_indicator
        no_change_pointers      = no_change_pointers
      IMPORTING
        changenumber            = changenumber ).

  ENDMETHOD.

  METHOD if_chdo_enhancements~authority_check.
    rv_is_authorized = abap_true.
  ENDMETHOD.
ENDCLASS.
