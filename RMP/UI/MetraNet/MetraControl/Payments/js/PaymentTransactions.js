  var win = null;
  var winGridToRefresh = null;

function amountColRenderer(value, meta, record, rowIndex, colIndex, store) {
  meta.attr = 'style="white-space:normal"';
  return value;
}

function statusColRenderer(value, meta, record, rowIndex, colIndex, store) {
  meta.attr = 'style="white-space:normal"';

  var str = "";
  var strStatus = record.data.Status;

  switch (strStatus) {
    case "FAILURE":
      str = "<span style=\"color:red\">" + String.escape(FAILURE) + "</span>";
      break;
    case "SUCCESS":
      str = "<span style=\"color:green\">" + String.escape(SUCCESS) + "</span>"; ;
      break;
    case "RECEIVED_REQUEST":
      str = "<span style=\"color:black\">" + String.escape(RECEIVED_REQUEST) + "</span>"; ;
      break;       
    case "SUBMITTED_REQUEST":
      str = "<span style=\"color:black\">" + String.escape(SUBMITTED_REQUEST) + "</span>"; ;
      break;
    case "RECEIVED_RESPONSE":
      str = "<span style=\"color:black\">" + String.escape(RECEIVED_RESPONSE) + "</span>"; ;
      break;
    case "REVERSED":
      str = "<span style=\"color:black\">" + String.escape(REVERSED) + "</span>"; ;
      break;
    case "REJECTED":
      str = "<span style=\"color:red\">" + String.escape(REJECTED) + "</span>"; ;
      break;
    case "MANUAL_PENDING":
      str = "<span style=\"color:black\">" + String.escape(MANUAL_PENDING) + "</span>"; ;
      break;      
    case "MANUALLY_REVERSED":
      str = "<span style=\"color:black\">" + String.escape(MANUALLY_REVERSED) + "</span>"; ;
      break;
    case "POST_PROCESSING_SUCCESSFUL":
      str = "<span style=\"color:gren\">" + String.escape(POST_PROCESSING_SUCCESSFUL) + "</span>"; ;
      break;
    case "DUPLICATE":
      str = "<span style=\"color:red\">" + String.escape(DUPLICATE) + "</span>"; ;
      break;       
    default:
      str = "<span style=\"color:black\">" + String.escape(strStatus) + "</span>";
      break;
  }

  return str;
}

  // Popup a window to set the status so we don't lose the current search filters.
  function popupStatusChange(ids, responseJSON, action, grid)
  {
    var statusChangePage = "/MetraNet/MetraControl/Payments/ChangeStatus.aspx?Action=" + action;
    if(ids != "all")
    {
      statusChangePage += "&FailureIDs=" + ids;
    }
    var tpl = new Ext.XTemplate(
            '<tpl for=".">',
            '<p>{Message}</p>',
            '<iframe src="' + statusChangePage + '" width="100%" height="100%" id="statusChange">',
            '</tpl>'
      );

  if(!win){
    win = new Ext.Window({
          applyTo:'results-win',
          layout:'fit',
          width:700,
          height: 500,
          closeAction:'hide',
          plain: true,
          buttons: [{
              text: TEXT_CLOSE,
              handler: function(){
                  grid.store.reload();
                  win.hide();
              }
          }]
      });
  }

  winGridToRefresh = grid; //Some of the closing code relys on knowing which grid to refresh

  tpl.overwrite(win.body, responseJSON);
  win.show(this);
  }

  function onUpdateStatus(grid, gridname)
  {
      var records = grid.getSelectionModel().getSelections();
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
        if(i > 0)
        {
          ids += ",";
        }
        ids += records[i].data.TransactionId; 
      }
      var message = TEXT_SELECTED + records.length + TEXT_ITEMS
      var responseJSON = {Success:true,Message:message};
      popupStatusChange(ids, responseJSON, "prompt",grid);
  }

