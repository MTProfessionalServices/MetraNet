                            var win = null;
  var winGridToRefresh = null;

  function onUpdateAllStatus(grid, gridname)
  {
    getAllIdsAndPerformAction(grid, "prompt");
  }

  function getAllIdsAndPerformAction(grid, action)
  {
    // Go get ALL the ids and put them in Session["SelectedIDs"] via ajax call
    // then go to the status page via popup
    var params = new Object(); 
    
    var totalRecords = grid.store.reader.jsonData.TotalRows;

    // copy base parameters
    for(var prop in grid.store.baseParams)
    {
      params[prop] = grid.store.baseParams[prop];
    }  

    // copy standard params, overwrite if necessary
    for(var prop in grid.store.lastOptions.params)
    {
      params[prop] = grid.store.lastOptions.params[prop];
    }
   
    // apply filters
    Ext.apply(params, grid.filters.buildQuery(grid.filters.getFilterData()));

    //configure data source URL
    var dataSourceURL = '/MetraNet/AjaxServices/QueryService.aspx';

    if(dataSourceURL.indexOf('?') < 0)
    {
      dataSourceURL += '?';
    }
    else{ dataSourceURL += '&'};
    dataSourceURL += 'mode=SelectAll&idNode=failurecompoundsessionid';
    //ESR-4577 No option to act on all failed transactions in MetraNet 6.4
    params.limit = parseInt(totalRecords, 10);
      
      Ext.Ajax.request({
        url: dataSourceURL,
        params: params,
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
          var responseJSON = Ext.decode(response.responseText);
          if(responseJSON)
          {
            popupStatusChange("all", responseJSON, action, grid);
          }
          else
          {
            Ext.UI.msg(TEXT_ERROR, responseJSON.Message);
          }
        }
      });   
  }


function caseNumberColRenderer(value, meta, record, rowIndex, colIndex, store) {
  var str = "";
  str += String.format("<span style='display:inline-block; vertical-align:middle'>&nbsp;<a style='cursor:hand;vertical-align:middle' id='editcase_{0}' title='{1}' href='JavaScript:onEditFailedTransaction(\"{0}\",\"{3}\",\"{2}\");'>{0}&nbsp;<img src='/Res/Images/icons/database_edit.png' alt='{1}' align='middle'/></a></span>", record.data.casenumber, TEXT_EDIT_FAILED_TRANSACTION, record.data.compound, record.data.failurecompoundsessionid);

  return str;
}

function actionsColRenderer(value, meta, record, rowIndex, colIndex, store) {
  var str = "";
  str += String.format("<span style='display:inline-block; vertical-align:middle'>&nbsp;<a style='cursor:hand;vertical-align:middle' id='viewaudit_{0}' title='{1}' href='JavaScript:onViewFailedTransactionAuditLog(\"{0}\",\"{2}\");'>View Log&nbsp;</a></span>", record.data.casenumber, TEXT_VIEW_AUDIT_FAILED_TRANSACTION, record.data.failurecompoundsessionid);

  return str;
}

function errorMessageColRenderer(value, meta, record, rowIndex, colIndex, store) {
  meta.attr = 'style="white-space:normal"';
  return value;
}

function statusColRenderer(value, meta, record, rowIndex, colIndex, store) {
  meta.attr = 'style="white-space:normal"';

  var str = "";
  var strStatus = record.data.status;
  switch (strStatus) {
    case 'N':
      str = TEXT_TRANSACTION_OPEN;
      break;
    case 'I':
      str = TEXT_UNDER_INVESTIGATION;
	  if (record.data.statereasoncode != null)
        str += " (" + record.data.statereasoncode + ")";
      break;
    case 'C':
      str = TEXT_CORRECTED;
      break;
    case 'P':
      str = TEXT_DISMISSED;
	  if (record.data.statereasoncode != null)
        str += " (" + record.data.statereasoncode + ")";
      break;
    case 'R':
      str = TEXT_RESUBMITTED;
      break;
    case 'D':
      str = TEXT_DELETED;
	  if (record.data.statereasoncode != null)
        str += " (" + record.data.statereasoncode + ")";
      break;
    default:
      str = TEXT_UNKNOWN_STATUS;
      break;
  }

  return str;
}

  function onEditFailedTransaction(idFailedTransaction, idFailureCompoundSession, isCompound)
  {
    if (isCompound == 'Y')
    {
      window.open("/MetraNet/TicketToMOMNoMenu.aspx?Title=Edit Failed Transaction&URL=/mom/default/dialog/FailedTransactionEditCompoundFrame.asp?IdFailure=" + idFailedTransaction + "**FailureCompoundSessionId=" + idFailureCompoundSession);
    }
    else
    {
      window.open("/MetraNet/TicketToMOMNoMenu.aspx?Title=Edit Failed Transaction&URL=/mom/default/dialog/FailedTransactionEditAtomic.asp?IdFailure=" + idFailedTransaction + "**MDMReload=TRUE**FailureCompoundSessionId=" + idFailureCompoundSession);
    }
  }

  function onViewFailedTransactionAuditLog(idFailedTransaction, idFailureCompoundSession) {
    //http://localhost/mom/default/dialog/AuditLog.List.asp?EntityType=5&EntityId=3004&Title=Audit%20History%20For%20Failed%20Transaction%20Case%20Number%203004
    window.open("/MetraNet/TicketToMOMNoMenu.aspx?Title=Audit Log&URL=/mom/default/dialog/AuditLog.List.asp?EntityType=5**EntityId=" + idFailedTransaction + "**Title=" + encodeURIComponent(TEXT_AUDIT_HISTORY_FAILED + idFailedTransaction));
  }

    // Popup a window to set the status so we don't lose the current search filters.
  function popupStatusChange(ids, responseJSON, action, grid)
  {
    var statusChangePage = "/MetraNet/MetraControl/FailedTransactions/ChangeStatus.aspx?Action=" + action;
    if(ids != "all")
    {
      statusChangePage += "&FailureIDs=" + ids;
  }
    var tpl = new Ext.XTemplate(
            '<tpl for=".">',
            '<p>{Message}</p>',
            '<iframe src="' + statusChangePage.replace("+", "%2B") + '" width="100%" height="100%" id="statusChange">',
            '</tpl>'
      );

    if (!win) {
      win = new Ext.Window({
        applyTo: 'results-win',
        layout: 'fit',
        width: 700,
        height: 500,
        closeAction: 'hide',
        plain: true,
        buttons: [{
          text: TEXT_CLOSE,
          handler: function() {
            win.hide();
          }
        }]
      });

      win.on("hide", function () {
        grid.getSelectionModel().deselectAll(true);
        grid.store.reload();
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
        ids += records[i].data.failurecompoundsessionid; 
      }
      var message = TEXT_SELECTED + records.length + TEXT_ITEMS
      var responseJSON = {Success:true,Message:message};
      popupStatusChange(ids, responseJSON, "prompt",grid);
  }

  function onResubmitAll(grid, gridname)
  {
    getAllIdsAndPerformAction(grid, "resubmit");
  }
  
  function onResubmit(grid, gridname)
  {
      var records = grid.getSelectionModel().getSelections();
      var ids = "";
      for(var i=0; i < records.length; i++)
      {
        if(i > 0)
        {
          ids += ",";
        }
        ids += records[i].data.failurecompoundsessionid;
    }
      var message = TEXT_SELECTED + records.length + TEXT_ITEMS
      var responseJSON = {Success:true,Message:message};
      popupStatusChange(ids, responseJSON, "resubmit", grid);
  }
