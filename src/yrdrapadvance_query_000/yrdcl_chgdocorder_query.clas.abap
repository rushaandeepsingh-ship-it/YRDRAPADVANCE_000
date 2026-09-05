CLASS yrdcl_chgdocorder_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS yrdcl_chgdocorder_query IMPLEMENTATION.


  METHOD if_rap_query_provider~select.
    DATA: lv_start_date TYPE d,
          lv_end_date   TYPE d.
    TRY.
        " 1. Returning requested entity
        CASE io_request->get_entity_id( ).
          WHEN 'YRDC_CHANGEDOCORDERTP_000'.

            " 2. Filters
            TRY.
                DATA(lt_ranges) = io_request->get_filter(  )->get_as_ranges(  ).

                LOOP AT lt_ranges INTO DATA(ls_range).
                  CASE ls_range-name.
                    WHEN 'STARTDATE'.
                      LOOP AT ls_range-range ASSIGNING FIELD-SYMBOL(<ls_range>).
                        lv_start_date = <ls_range>-low.
                      ENDLOOP.

                    WHEN 'ENDDATE'.
                      LOOP AT ls_range-range ASSIGNING FIELD-SYMBOL(<ls_range_enddate>).
                        lv_end_date = <ls_range_enddate>-low.
                      ENDLOOP.
                  ENDCASE.
                ENDLOOP.

              CATCH cx_rap_query_filter_no_range.
                "handle exception
            ENDTRY.


            " 3. Request data
            IF io_request->is_data_requested(  ).

              " 4. Paging
              "Drop first N records from the result
              DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
              "Limit result to N records
              DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).
              DATA(lv_max_rows) = COND #( WHEN lv_page_size = if_rap_query_paging=>page_size_unlimited
                                          THEN 0 ELSE lv_page_size ).

*              " 5. Sorting
*              DATA(sort_elements) = io_request->get_sort_elements( ).
*              DATA(lt_sort_criteria) = VALUE string_table( FOR sort_element IN sort_elements
*                                                         ( sort_element-element_name && COND #( WHEN sort_element-descending = abap_true THEN ` descending`
*                                                                                                                                         ELSE ` ascending` ) ) ).
*              DATA(lv_sort_string)  = COND #( WHEN lt_sort_criteria IS INITIAL THEN `primary key`
*                                                                               ELSE concat_lines_of( table = lt_sort_criteria sep = `, ` ) ).


              " 6. Select Data
              " Read Change document object YRD_ORDER_CD
              TRY.

                  cl_chdo_read_tools=>changedocument_read(
                    EXPORTING
                      i_objectclass    = 'YRD_ORDER_CDH'
*      it_objectid      =
                      i_date_of_change = CONV #( lv_start_date )
*      i_time_of_change =
                      i_date_until     = CONV #( lv_end_date )
*      i_time_until     =
*      it_username      =
*      iv_read_archive  =
*      is_read_options  =
                IMPORTING
                  et_cdredadd_tab  = DATA(lt_result)
*    CHANGING
*      ct_cdhdr         =
                  ).
                CATCH cx_chdo_read_error.
              ENDTRY.

              " Convert the result as needed in Custom Entity
              DATA : lt_response TYPE TABLE OF YRDC_ChangeDocOrderTP_000.

              lt_response = CORRESPONDING #( lt_result ).

*              CATCH cx_rap_query_response_set_twic.

              " 8. Request count

              IF io_request->is_total_numb_of_rec_requested( ).
                io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_response ) ).
*                CATCH cx_rap_query_response_set_twic.
              ENDIF.

              IF lines( lt_response ) >  lv_max_rows.
                IF lv_offset >= 1.
                  DELETE lt_response FROM 1 TO lv_offset.
                ENDIF.

                IF lv_max_rows >= 1.
                  DELETE lt_response FROM ( lv_max_rows + 1 ).
                ENDIF.
              ENDIF.
              " 7. Fill response
              io_response->set_data( it_data = lt_response ).
            ENDIF.

        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lo_cx).

    ENDTRY.


  ENDMETHOD.
ENDCLASS.
