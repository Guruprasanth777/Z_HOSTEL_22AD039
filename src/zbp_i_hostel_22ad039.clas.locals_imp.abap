" --- 1. Global Buffer Class to hold data between Interaction and Save phases ---
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_hostel_create TYPE TABLE OF zthostel_22ad039,
                mt_hostel_update TYPE TABLE OF zthostel_22ad039,
                mt_hostel_delete TYPE TABLE OF zthostel_22ad039,
                mt_room_create   TYPE TABLE OF ztroom_22ad039,
                mt_room_update   TYPE TABLE OF ztroom_22ad039,
                mt_room_delete   TYPE TABLE OF ztroom_22ad039.
ENDCLASS.

" --- 2. Interaction Phase for Hostel (Parent) ---
CLASS lhc_Hostel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Hostel RESULT result.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE Hostel.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE Hostel.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE Hostel.
    METHODS read FOR READ
      IMPORTING keys FOR READ Hostel RESULT result.
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Hostel.
    METHODS rba_Rooms FOR READ
      IMPORTING keys_rba FOR READ Hostel\_Rooms FULL result_requested RESULT result LINK association_links.
    METHODS cba_Rooms FOR MODIFY
      IMPORTING entities_cba FOR CREATE Hostel\_Rooms.
    METHODS OptimizeAllocation FOR MODIFY
      IMPORTING keys FOR ACTION Hostel~OptimizeAllocation RESULT result.
ENDCLASS.

CLASS lhc_Hostel IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA: ls_hostel TYPE zthostel_22ad039.
    LOOP AT entities INTO DATA(ls_entity).
      ls_hostel-client = sy-mandt.
      TRY.
          ls_hostel-alloc_id = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_hostel-student_id = ls_entity-StudentId.
      ls_hostel-student_name = ls_entity-StudentName.
      ls_hostel-preference = ls_entity-Preference.
      ls_hostel-status = 'Pending'.
      GET TIME STAMP FIELD ls_hostel-created_at.
      ls_hostel-created_by = sy-uname.
      ls_hostel-last_changed_at = ls_hostel-created_at.
      ls_hostel-last_changed_by = sy-uname.

      APPEND ls_hostel TO lcl_buffer=>mt_hostel_create. " Add to buffer

      INSERT VALUE #( %cid = ls_entity-%cid
                      AllocId = ls_hostel-alloc_id ) INTO TABLE mapped-hostel.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zthostel_22ad039 WHERE alloc_id = @ls_entity-AllocId INTO @DATA(ls_hostel).
      IF sy-subrc = 0.
        IF ls_entity-%control-StudentId = if_abap_behv=>mk-on. ls_hostel-student_id = ls_entity-StudentId. ENDIF.
        IF ls_entity-%control-StudentName = if_abap_behv=>mk-on. ls_hostel-student_name = ls_entity-StudentName. ENDIF.
        IF ls_entity-%control-Preference = if_abap_behv=>mk-on. ls_hostel-preference = ls_entity-Preference. ENDIF.
        IF ls_entity-%control-Status = if_abap_behv=>mk-on. ls_hostel-status = ls_entity-Status. ENDIF.

        GET TIME STAMP FIELD ls_hostel-last_changed_at.
        ls_hostel-last_changed_by = sy-uname.

        APPEND ls_hostel TO lcl_buffer=>mt_hostel_update. " Add to buffer
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_del) = VALUE zthostel_22ad039( alloc_id = ls_key-AllocId ).
      APPEND ls_del TO lcl_buffer=>mt_hostel_delete. " Add to buffer
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zthostel_22ad039 FOR ALL ENTRIES IN @keys WHERE alloc_id = @keys-AllocId INTO TABLE @DATA(lt_hostel).
    LOOP AT lt_hostel INTO DATA(ls_hostel).
      INSERT VALUE #( AllocId = ls_hostel-alloc_id
                      StudentId = ls_hostel-student_id
                      StudentName = ls_hostel-student_name
                      Preference = ls_hostel-preference
                      Status = ls_hostel-status
                      CreatedBy = ls_hostel-created_by
                      CreatedAt = ls_hostel-created_at
                      LastChangedBy = ls_hostel-last_changed_by
                      LastChangedAt = ls_hostel-last_changed_at ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Rooms.
  ENDMETHOD.

  METHOD cba_Rooms.
    DATA: ls_room TYPE ztroom_22ad039.
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        ls_room-client = sy-mandt.
        ls_room-alloc_id = ls_cba-AllocId.
        TRY.
            ls_room-room_uuid = cl_system_uuid=>create_uuid_x16_static( ).
          CATCH cx_uuid_error.
        ENDTRY.
        ls_room-room_number = ls_target-RoomNumber.
        ls_room-bed_number = ls_target-BedNumber.
        ls_room-allocation_date = ls_target-AllocationDate.
        ls_room-remarks = ls_target-Remarks.

        APPEND ls_room TO lcl_buffer=>mt_room_create. " Add to buffer

        INSERT VALUE #( %cid = ls_target-%cid
                        RoomUuid = ls_room-room_uuid
                        AllocId = ls_room-alloc_id ) INTO TABLE mapped-room.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD OptimizeAllocation.
    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_update) = VALUE zthostel_22ad039( alloc_id = ls_key-AllocId status = 'Optimized' ).
      APPEND ls_update TO lcl_buffer=>mt_hostel_update. " Add to buffer

      READ ENTITIES OF zi_hostel_22ad039 IN LOCAL MODE
        ENTITY Hostel ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_hostel).
      result = VALUE #( FOR hostel IN lt_hostel ( %tky = hostel-%tky %param = hostel ) ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

" --- 3. Interaction Phase for Room (Child) ---
CLASS lhc_Room DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Room.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Room.
    METHODS read FOR READ IMPORTING keys FOR READ Room RESULT result.
    METHODS rba_Hostel FOR READ IMPORTING keys_rba FOR READ Room\_Hostel FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_Room IMPLEMENTATION.
  METHOD update.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM ztroom_22ad039 WHERE room_uuid = @ls_entity-RoomUuid INTO @DATA(ls_room).
      IF sy-subrc = 0.
        IF ls_entity-%control-RoomNumber = if_abap_behv=>mk-on. ls_room-room_number = ls_entity-RoomNumber. ENDIF.
        IF ls_entity-%control-BedNumber = if_abap_behv=>mk-on. ls_room-bed_number = ls_entity-BedNumber. ENDIF.
        IF ls_entity-%control-AllocationDate = if_abap_behv=>mk-on. ls_room-allocation_date = ls_entity-AllocationDate. ENDIF.
        IF ls_entity-%control-Remarks = if_abap_behv=>mk-on. ls_room-remarks = ls_entity-Remarks. ENDIF.
        APPEND ls_room TO lcl_buffer=>mt_room_update. " Add to buffer
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      DATA(ls_del) = VALUE ztroom_22ad039( room_uuid = ls_key-RoomUuid ).
      APPEND ls_del TO lcl_buffer=>mt_room_delete. " Add to buffer
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM ztroom_22ad039 FOR ALL ENTRIES IN @keys WHERE room_uuid = @keys-RoomUuid INTO TABLE @DATA(lt_room).
    LOOP AT lt_room INTO DATA(ls_room).
      INSERT VALUE #( AllocId = ls_room-alloc_id RoomUuid = ls_room-room_uuid RoomNumber = ls_room-room_number
                      BedNumber = ls_room-bed_number AllocationDate = ls_room-allocation_date Remarks = ls_room-remarks ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Hostel.
  ENDMETHOD.
ENDCLASS.

" --- 4. Save Sequence Phase (Database Commits Happen Here) ---
CLASS lsc_ZI_HOSTEL_22AD039 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_HOSTEL_22AD039 IMPLEMENTATION.
  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " Write Hostel DB Updates
    IF lcl_buffer=>mt_hostel_create IS NOT INITIAL.
      INSERT zthostel_22ad039 FROM TABLE @lcl_buffer=>mt_hostel_create.
    ENDIF.
    IF lcl_buffer=>mt_hostel_update IS NOT INITIAL.
      UPDATE zthostel_22ad039 FROM TABLE @lcl_buffer=>mt_hostel_update.
    ENDIF.
    IF lcl_buffer=>mt_hostel_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_hostel_delete INTO DATA(ls_del_h).
        DELETE FROM zthostel_22ad039 WHERE alloc_id = @ls_del_h-alloc_id.
        DELETE FROM ztroom_22ad039 WHERE alloc_id = @ls_del_h-alloc_id.
      ENDLOOP.
    ENDIF.

    " Write Room DB Updates
    IF lcl_buffer=>mt_room_create IS NOT INITIAL.
      INSERT ztroom_22ad039 FROM TABLE @lcl_buffer=>mt_room_create.
    ENDIF.
    IF lcl_buffer=>mt_room_update IS NOT INITIAL.
      UPDATE ztroom_22ad039 FROM TABLE @lcl_buffer=>mt_room_update.
    ENDIF.
    IF lcl_buffer=>mt_room_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_room_delete INTO DATA(ls_del_r).
        DELETE FROM ztroom_22ad039 WHERE room_uuid = @ls_del_r-room_uuid.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    " Clear the buffers after save
    CLEAR: lcl_buffer=>mt_hostel_create, lcl_buffer=>mt_hostel_update, lcl_buffer=>mt_hostel_delete,
           lcl_buffer=>mt_room_create, lcl_buffer=>mt_room_update, lcl_buffer=>mt_room_delete.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
