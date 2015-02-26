var win = null,
    winGridToRefresh = null,
    Ext = window.Ext,
    loaderElement = null,
    FailedTransactions = FailedTransactions || {},
    ajaxProxy = new FailedTransactions.AjaxProxy() || {};
//--------------------------------------------------------------------------------PUBLIC---------------------------------------------------------------------- 
function onResubmitAll(grid) {
  if (grid) {
    if (grid.store.reader.jsonData && grid.store.reader.jsonData.TotalRows > 0) {
      if (typeof (window.getFailedTransactionParams) == "function") {
        var data = window.getFailedTransactionParams();
        ajaxProxy.resubmitAll(data, function () {
          if (window.subGridRefresh) {
            window.subGridRefresh.reload();
          }
          grid.store.reload();
        });
      }
    } else {
      _showInfoDialog(window.TITLE_POPUP_VALIDATION_FT, window.TEXT_VALIDATION_FT_NO_SELECTED_ITEMS);
    }
  }
}

function onResubmit(grid) {
  if (grid) {
    var records = grid.getSelectionModel().getSelections();
    if (!_validationSelectItems(records)) {
      return;
    }
    var ids = [];
    for (var i = 0, maxLength = records.length; i < maxLength; i += 1) {
      ids.push(records[i].data.casenumber);
    }
    var data = { ids: ids };
    ajaxProxy.resubmitSelectedItems(data, function () {
      if (window.subGridRefresh) {
        window.subGridRefresh.reload();
      }
      grid.store.reload();
    });
    grid.getSelectionModel().deselectAll();
    grid.getSelectionModel().selections.clear();
  }
}

function onUpdateAllStatus(grid) {
  if (grid) {
    if (grid.store.reader.jsonData && grid.store.reader.jsonData.TotalRows > 0) {
      _openChangeStatusWindow(grid, false);
      window.refreshEnabled = false;
      if (window.refreshEnabledSummaryGrid !== undefined) {
        window.refreshEnabledSummaryGrid = false;
      }
    } else {
      _showInfoDialog(window.TITLE_POPUP_VALIDATION_FT, window.TEXT_VALIDATION_FT_NO_SELECTED_ITEMS);
    }
  }
}

function onUpdateStatus(grid) {
  if (grid) {
    var selectedRecords = grid.getSelectionModel().getSelections();
    if (!_validationSelectItems(selectedRecords)) {
      return;
    }
    _openChangeStatusWindow(grid, true);
    window.refreshEnabled = false;
    if (window.refreshEnabledSummaryGrid !== undefined) {
      window.refreshEnabledSummaryGrid = false;
    }
  }
}

function doChangeStatus(statusData) {
  if (statusData) {
    var data = {};
    if (!window.ChangeStatusIsSelectIds) {
      if (typeof (window.getFailedTransactionParams) == "function") {
        data = window.getFailedTransactionParams();
        data.status = statusData.status;
        data.reason = statusData.reasonCode;
        data.comment = statusData.comment;
        data.doresubmit = statusData.isResubmit;
        ajaxProxy.updateStatusAll(data, function () {
          if (window.subGridRefresh) {
            window.subGridRefresh.reload();
          }
          win.hide();
        });
      }
    } else {
      var grid = Ext.getCmp(statusData.gridId);
      if (!grid) {
        return;
      }
      var records = grid.getSelectionModel().getSelections();
      if (!_validationSelectItems(records)) {
        return;
      }
      var ids = [];
      for (var i = 0, maxLength = records.length; i < maxLength; i += 1) {
        ids.push(records[i].data.casenumber);
      }
      data.ids = ids;
      data.status = statusData.status;
      data.reason = statusData.reasonCode;
      data.comment = statusData.comment;
      data.doresubmit = statusData.isResubmit;
      ajaxProxy.updateStatus(data, function () {
        if (window.subGridRefresh) {
          window.subGridRefresh.reload();
        }
        win.hide();
      });
      grid.getSelectionModel().deselectAll();
      grid.getSelectionModel().selections.clear();
    }
  }
}

function caseNumberColRenderer(value, meta, record, rowIndex, colIndex, store) {
  var str = "";
  if (record.data.status == 'R') {
    meta.attr = 'style="white-space:normal"';
    str += record.data.casenumber;
  }
  else {
    str += String.format("<span style='display:inline-block; vertical-align:middle'>&nbsp;<a style='cursor:hand;vertical-align:middle' id='editcase_{0}' title='{1}' href='JavaScript:onEditFailedTransaction(\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\");'>{0}&nbsp;<img src='/Res/Images/icons/database_edit.png' alt='{1}' align='middle'/></a></span>", record.data.casenumber, window.TEXT_EDIT_FAILED_TRANSACTION, record.data.failurecompoundsessionid, record.data.compound, store.sm.grid.id);
  }
  return str;
}

function actionsColRenderer(value, meta, record) {
  var str = "";
  str += String.format("<span style='display:inline-block; vertical-align:middle'>&nbsp;<a style='cursor:hand;vertical-align:middle' id='viewaudit_{0}' title='{1}' href='JavaScript:onViewFailedTransactionAuditLog(\"{0}\",\"{2}\");'>View Log&nbsp;</a></span>", record.data.casenumber, window.TEXT_VIEW_AUDIT_FAILED_TRANSACTION, record.data.failurecompoundsessionid);
  return str;
}

function errorMessageColRenderer(value, meta) {
  meta.attr = 'style="white-space:normal"';
  return value;
}

function statusColRenderer(value, meta, record) {
  var message,
      strStatus = record.data.status;
  meta.attr = 'style="white-space:normal"';
  switch (strStatus) {
    case 'N':
      message = window.TEXT_TRANSACTION_OPEN;
      break;
    case 'I':
      message = window.TEXT_UNDER_INVESTIGATION;
      if (record.data.statereasoncode != null && record.data.statereasoncode != "")
        message += " (" + record.data.statereasoncode + ")";
      break;
    case 'C':
      message = window.TEXT_CORRECTED;
      break;
    case 'P':
      message = window.TEXT_DISMISSED;
      if (record.data.statereasoncode != null && record.data.statereasoncode != "")
        message += " (" + record.data.statereasoncode + ")";
      break;
    case 'R':
      message = window.TEXT_RESUBMITTED;
      break;
    case 'D':
      message = window.TEXT_DELETED;
      if (record.data.statereasoncode != null && record.data.statereasoncode != "")
        message += " (" + record.data.statereasoncode + ")";
      break;
    default:
      message = window.TEXT_UNKNOWN_STATUS;
      break;
  }
  return message;
}

function onEditFailedTransaction(idFailedTransaction, title, idFailureCompoundSession, isCompound, gridId) {
  var page = isCompound === 'Y'
    ? "/MetraNet/TicketToMOM.aspx?Title=Edit Failed Transaction&URL=/mom/default/dialog/FailedTransactionEditCompoundFrame.asp?IdFailure=" + idFailedTransaction + "**FailureCompoundSessionId=" + idFailureCompoundSession
    : "/MetraNet/TicketToMOM.aspx?Title=Edit Failed Transaction&URL=/mom/default/dialog/FailedTransactionEditAtomic.asp?IdFailure=" + idFailedTransaction + "**MDMReload=TRUE**FailureCompoundSessionId=" + idFailureCompoundSession;
  var grid = window.Ext.getCmp(gridId);
  CreateWindow(grid, title, page);
}

function onViewFailedTransactionAuditLog(idFailedTransaction) {
  //http://localhost/mom/default/dialog/AuditLog.List.asp?EntityType=5&EntityId=3004&Title=Audit%20History%20For%20Failed%20Transaction%20Case%20Number%203004
  window.open("/MetraNet/TicketToMOM.aspx?Title=Audit Log&URL=/mom/default/dialog/AuditLog.List.asp?EntityType=5**EntityId=" + idFailedTransaction + "**Title=" + encodeURIComponent(window.TEXT_AUDIT_HISTORY_FAILED + idFailedTransaction));
}

function CreateWindow(grid, title, page) {
  var params = "resizable=yes";
  var myWin = ShowWindow(page, "updateTransaction", params, 900, 600);
  myWin.focus();
  setTimeout(function () {
    if (myWin.closed) {
      grid.getSelectionModel().deselectAll(true);
      grid.store.reload();
    }
    else {
      setTimeout(arguments.callee, 10);
    }
  }, 10);
  winGridToRefresh = grid;
}

function ShowWindow(url, title, params, w, h) {
  params += ', width=' + w + ', height=' + h;
  return window.open(url, title, params);
}
//---------------------------------------------------------------------------------PRIVATE---------------------------------------------------------------------

//--- Change Status functionality
function _openChangeStatusWindow(grid, isChangeSelectedIds) {
  if (grid) {

    if (!isChangeSelectedIds) {
      if (grid.store.reader.jsonData.TotalRows == 0) {
        _showInfoDialog(window.TITLE_POPUP_VALIDATION_FT, window.TEXT_VALIDATION_FT_NO_SELECTED_ITEMS);
        return false;
      }
    }
    var actionPage = "/MetraNet/MetraControl/FailedTransactions/ChangeFailedTransactionStatus.aspx?Action=prompt&gridId=" + encodeURIComponent(grid.id),
        message = String.format(window.TEXT_SELECTED_ITEMS_FT, isChangeSelectedIds ? grid.getSelectionModel().getSelections().length : grid.store.reader.jsonData.TotalRows);
    window.ChangeStatusIsSelectIds = isChangeSelectedIds;
    _showPopup(grid, message, actionPage, 600, 450);
  }
  return null;
}

function _validationSelectItems(collections) {
  if (collections && collections instanceof Array) {
    if (collections.length === 0) {
      _showInfoDialog(window.TITLE_POPUP_VALIDATION_FT, window.TEXT_VALIDATION_FT_NO_SELECTED_ITEMS);
      return false;
    }
    else {
      return true;
    }
  }
  else {
    return false;
  }
}

function _showPopup(grid, title, page, width, height) {
  if (!win) {
    win = new window.Ext.Window({
      applyTo: 'results-win',
      layout: 'fit',
      closeAction: 'hide',
      plain: true,
      buttons: [{
        text: window.TEXT_CLOSE,
        handler: function () {
          win.hide();
        }
      }]
    });

    win.on("hide", function () {
      grid.getSelectionModel().deselectAll(true);
      grid.store.reload();
      ajaxProxy.clearRefreshTOAndStartRefresh

    });
  }
  var template = new window.Ext.XTemplate(
    '<tpl for=".">',
    '<p>{Title}</p>',
    '<iframe src="' + page.replace("+", "%2B") + '" width="100%" height="100%" id="statusUpdate">',
    '</tpl>'
  );
  winGridToRefresh = grid;
  template.overwrite(win.body, { Title: title });
  win.setSize(width, height);
  win['center']();
  win.show(this);
}

function _showInfoDialog(captionStr, message, onClickfn) {
  Ext.MessageBox.show({
    title: captionStr,
    msg: message,
    buttons: Ext.MessageBox.OK,
    fn: function () {
      if (typeof onClickfn === 'function') {
        return onClickfn;
      }
      else {
        return null;
      }
    },
    icon: Ext.MessageBox.INFO
  });
}
