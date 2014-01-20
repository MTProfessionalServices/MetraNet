
function customDetailsRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return value;
}

function customCommentRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return value;
}

function customModifiedItemDisplayNameRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return value;
}

function entityDisplayNameRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return store.data.items[rowIndex].json.Name['en-us'];
}

function entityDescriptionRenderer(value, metadata, record, rowIndex, colIndex, store) {
  metadata.attr = 'ext:qtip="' + value + '"';
  return store.data.items[rowIndex].json.Description['en-us'];
}

function onAddNotificationEndpoint_ctl00_ContentPlaceHolder1_ItemList()
{
	alert("Add Notification Endpoint");
}

function onEditNotificationEndpoint()
{
	alert("Edit Notification Endpoint");
}
function onDeleteNotificationEndpoint()
{
	alert("Delete Notification Endpoint");
}

   defaultActionsColumnRenderer = function(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";
      var internalId = record.data.Id;
      var id = record.data[record.fields.items[0].mapping] + "";  // this is the primary key... it has to go first in the grid?  how else do I know?
     
      
        // Edit Template
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"edit\" href=\"javascript:onEditNotificationEndpoint('{0}','{1}')\"><img src=\"/Res/Images/icons/table_edit.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_EDIT));

        // Delete button     
        str += String.format("&nbsp;<a style=\"cursor:hand;\" id=\"delete\" href=\"javascript:onDeleteNotificationEndpoint('{0}','{1}')\"><img src=\"/Res/Images/icons/cross.png\" title=\"{2}\" alt=\"{2}\"/></a>", internalId, String.escape(id).replace(/"/g,""), String.escape(TEXT_DELETE));

        
    
      return str;
    };    
