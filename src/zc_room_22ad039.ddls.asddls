@EndUserText.label: 'Child Projection View for Rooms'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_ROOM_22AD039 
  as projection on ZI_ROOM_22AD039
{
  key AllocId,
  key RoomUuid,
  RoomNumber,
  BedNumber,
  AllocationDate,
  Remarks,
  
  _Hostel : redirected to parent ZC_HOSTEL_22AD039
}
