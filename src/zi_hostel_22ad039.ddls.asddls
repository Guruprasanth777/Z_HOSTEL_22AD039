@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View for Hostel Parent'
define root view entity ZI_HOSTEL_22AD039 
  as select from zthostel_22ad039
  composition [0..*] of ZI_ROOM_22AD039 as _Rooms
{
  key alloc_id as AllocId,
  student_id as StudentId,
  student_name as StudentName,
  preference as Preference,
  status as Status,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  
  _Rooms
}
