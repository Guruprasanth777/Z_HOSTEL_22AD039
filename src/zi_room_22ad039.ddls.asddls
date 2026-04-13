@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child Interface View for Rooms'
define view entity ZI_ROOM_22AD039 
  as select from ztroom_22ad039
  association to parent ZI_HOSTEL_22AD039 as _Hostel on $projection.AllocId = _Hostel.AllocId
{
  key alloc_id as AllocId,
  key room_uuid as RoomUuid,
  room_number as RoomNumber,
  bed_number as BedNumber,
  allocation_date as AllocationDate,
  remarks as Remarks,
  
  _Hostel
}
