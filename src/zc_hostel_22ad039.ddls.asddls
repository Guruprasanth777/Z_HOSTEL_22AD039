@EndUserText.label: 'Root Projection View for Hostel'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_HOSTEL_22AD039 
  provider contract transactional_query
  as projection on ZI_HOSTEL_22AD039
{
  key AllocId,
  StudentId,
  StudentName,
  Preference,
  Status,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  
  _Rooms : redirected to composition child ZC_ROOM_22AD039
}
