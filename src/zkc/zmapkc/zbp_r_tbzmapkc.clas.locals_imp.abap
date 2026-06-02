CLASS lhc_zrtbzmapkc000 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zrtbzmapkc000 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zrtbzmapkc000 RESULT result.

*    METHODS validatecompanycode FOR VALIDATE ON SAVE
*      IMPORTING keys FOR zrtbzmapkc000~validatecompanycode.

    METHODS validateprofitct FOR VALIDATE ON SAVE
      IMPORTING keys FOR zrtbzmapkc000~validateprofitct.

    METHODS validaterultype FOR VALIDATE ON SAVE
      IMPORTING keys FOR zrtbzmapkc000~validaterultype.

ENDCLASS.

CLASS lhc_zrtbzmapkc000 IMPLEMENTATION.

  METHOD get_instance_features.
  " 1. Đọc dữ liệu hiện tại của các bản ghi đang xử lý
  READ ENTITIES OF zr_tbzmapkc000 IN LOCAL MODE
    ENTITY zrtbzmapkc000
    FIELDS ( Rulty ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_instances).

  " 2. Loop qua từng bản ghi để quyết định trạng thái của field TargetAccount
  result = VALUE #( FOR ls_instance IN lt_instances
                    ( %tky = ls_instance-%tky
                      " Nếu Rultype = '3A' thì set sang ReadOnly (xám lại), ngược lại thì cho phép sửa (All)
                      %field-Dacct = COND #( WHEN ls_instance-Rulty = '3A'
                                                     THEN if_abap_behv=>fc-f-read_only
                                                     ELSE if_abap_behv=>fc-f-unrestricted )
                    ) ).
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

*METHOD validateCompanyCode.
*  DATA:  lv_authority TYPE abap_bool.
*    READ ENTITIES OF zr_tbzmapkc000 IN LOCAL MODE
*       ENTITY zrtbzmapkc000
*       FIELDS ( Bukrs ) WITH CORRESPONDING #( keys )
*       RESULT DATA(lt_companycode).
*       READ TABLE lt_companycode INTO DATA(ls_row) INDEX 1.
*
*       select single COMPANYcODE from I_CompanyCode where COMPANYCODE = @ls_row-Bukrs into @DATA(lv_bukrs).
*       if lv_bukrs is not inITIAL.
*         AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*            ID 'BUKRS' FIELD  ls_row-Bukrs
*            ID 'ACTVT'      FIELD '03'.
*
*    IF sy-subrc = 0.
*    ELSE.
*      lv_authority = abap_true.
*    ENDIF.
*  IF  lv_authority IS NOT InITIAL.
*
*        " 1. PHẢI CÓ: Đưa vào failed để chặn nút Continue
*        APPEND VALUE #( %tky = ls_row-%tky ) TO failed-zrtbzmapkc000.
*
*        " 2. Đưa vào reported để hiển thị nội dung lỗi
*        APPEND VALUE #( %tky = ls_row-%tky
*                        %msg = new_message_with_text(
*                                 severity = if_abap_behv_message=>severity-error
*                                 text     = 'Không được cấp quyền cho công ty này. Vui lòng kiểm tra lại!' )
*                        %element-bukrs = if_abap_behv=>mk-on
*                      ) TO reported-zrtbzmapkc000.
*      ENDIF.
*      elSE.
*       " 1. PHẢI CÓ: Đưa vào failed để chặn nút Continue
*        APPEND VALUE #( %tky = ls_row-%tky ) TO failed-zrtbzmapkc000.
*
*        " 2. Đưa vào reported để hiển thị nội dung lỗi
*        APPEND VALUE #( %tky = ls_row-%tky
*                        %msg = new_message_with_text(
*                                 severity = if_abap_behv_message=>severity-error
*                                 text     = 'Sai mã Company Code. Vui lòng kiểm tra lại!' )
*                        %element-bukrs = if_abap_behv=>mk-on
*                      ) TO reported-zrtbzmapkc000.
*      enDIF.
*      CLear: lv_authority.
*  ENDMETHOD.

  METHOD validateprofitct.
  ENDMETHOD.

  METHOD validaterultype.
  ENDMETHOD.

ENDCLASS.
