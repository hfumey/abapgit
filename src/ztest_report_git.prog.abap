*&---------------------------------------------------------------------*
*& Report ZTEST_REPORT_GIT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_REPORT_GIT.

DATA:
  "Reference to the instance of ALV Grid
  g_alv   TYPE REF TO cl_gui_alv_grid,
  "Reference to the custom container that
  "we placed in the screen
  g_cust  TYPE REF TO cl_gui_custom_container,
  "Internal table for data to be displayed
  gt_kna1 TYPE STANDARD TABLE OF kna1,
  "Internal table for field catalog
  gt_fcat TYPE lvc_t_fcat,
  "Work area for field catalog
  gs_fcat TYPE lvc_s_fcat.

START-OF-SELECTION.

  SET SCREEN 0100.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STAT1'.

  IF g_cust IS INITIAL and sy-subrc = 0.

    CREATE OBJECT g_cust
      EXPORTING
        container_name              = 'CUSTCONT'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CREATE OBJECT g_alv
      EXPORTING
        i_parent          = g_cust
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    PERFORM load_data.
    PERFORM prepare_fcat.


    CALL METHOD g_alv->set_table_for_first_display
      CHANGING
        it_outtab                     = gt_kna1
        it_fieldcatalog               = gt_fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.



  ENDIF.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  case sy-ucomm.
    when 'BACK'.
      leave to screen 0.
    when 'EXIT'.
      leave program.
  endcase.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

FORM load_data.

  SELECT * FROM kna1
    INTO CORRESPONDING FIELDS OF TABLE gt_kna1
    UP TO 10 ROWS.

ENDFORM.

FORM prepare_fcat.

  DEFINE add_fcat.
    CLEAR gs_fcat.
    gs_fcat-col_pos = &1.
    gs_fcat-fieldname = &2.
    gs_fcat-coltext = &3.
    gs_fcat-outputlen = &4.
    APPEND gs_fcat TO gt_fcat.
  END-OF-DEFINITION.

  add_fcat:
     1 'KUNNR' 'Customer No.' 15,
     2 'LAND1' 'Country'      5,
     3 'NAME1' 'Name'         30,
     4 'ORT01' 'City'         20.

ENDFORM.
