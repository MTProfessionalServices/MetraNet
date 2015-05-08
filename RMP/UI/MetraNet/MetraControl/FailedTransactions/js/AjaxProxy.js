FailedTransactions = {};

FailedTransactions.AjaxProxy = function () {
  this.UrlResubmit = "/MetraNet/MetraControl/FailedTransactions/AjaxServices/FailedTransactionsAjaxService.aspx";
  this.actionsParam = {
    Resubmit: "?action=resubmit",
    ResubmitAll: "?action=resubmitAll",
    ChangeStatusAll: "?action=changeStatusAll",
    ChangeStatus: "?action=changeStatus"
  };
  this.loaderElement = null;
};

FailedTransactions.AjaxProxy.prototype.resubmitAll = function (data, onSuccess, onComplete) {
  this._ajax(this.UrlResubmit + this.actionsParam.ResubmitAll, {
    onSuccess: onSuccess,
    data: data,
    onComplete: onComplete
  });
};

FailedTransactions.AjaxProxy.prototype.resubmitSelectedItems = function (data, onSuccess, onComplete) {
  this._ajax(this.UrlResubmit + this.actionsParam.Resubmit, {
    onSuccess: onSuccess,
    data: data,
    onComplete: onComplete
  });
};

FailedTransactions.AjaxProxy.prototype.updateStatusAll = function (data, onSuccess, onComplete) {
  this._ajax(this.UrlResubmit + this.actionsParam.ChangeStatusAll, {
    onSuccess: onSuccess,
    data: data,
    onComplete: onComplete
  });
};

FailedTransactions.AjaxProxy.prototype.updateStatus = function (data, onSuccess, onComplete) {
  this._ajax(this.UrlResubmit + this.actionsParam.ChangeStatus, {
    onSuccess: onSuccess,
    data: data,
    onComplete: onComplete
  });
};

FailedTransactions.AjaxProxy.prototype.clearRefreshTOAndStartRefresh = function () {
  this._runRefreshProcess();
};

FailedTransactions.AjaxProxy.prototype._ajax = function (url, settings) {
  var defaultSettings = {
    data: settings.data || {},
    type: settings.type || 'POST',
    onSuccess: settings.onSuccess || function () { },
    onComplete: settings.onComplete || function () { },
    onError: settings.onError || function () { },
    async: settings.async === false ? false : true,
    contentType: settings.contentType || 'application/json; charset=utf-8'
  };
  this._showProgress();
  window.refreshEnabled = false;
  if (window.refreshEnabledSummaryGrid) {
    window.refreshEnabledSummaryGrid = false;
  }
  $.ajax({
    context: this,
    type: defaultSettings.type,
    url: url,
    data: defaultSettings.data,
    async: defaultSettings.async,
    success: function (result) {
      if (result) {
        defaultSettings.onSuccess(result);
        return;
      }
      this._runRefreshProcess();
    },
    error: function (jqXhr, errorText, errorThrown) {
      this._runRefreshProcess();
      this._hideProgress();
      var responseText = jqXhr.responseText;
      if (responseText) {
        this._showError(responseText);
      }
    },
    complete: function () {
      this._hideProgress();
      defaultSettings.onComplete();
      this._runRefreshProcess();
    }
  });
};

FailedTransactions.AjaxProxy.prototype._showProgress = function () {
  if (!this.loaderElement) {
    var loaderDiv = document.getElementById('loader');
    if (loaderDiv) {
      this.loaderElement = new Ext.LoadMask(loaderDiv);
    }
  }
  if (this.loaderElement) {
    this.loaderElement.show();
  }
};

FailedTransactions.AjaxProxy.prototype._hideProgress = function () {
  if (this.loaderElement) {
    this.loaderElement.hide();
  }
};

FailedTransactions.AjaxProxy.prototype._errorHandler = function (defaultSettings, jqXhr, errorText, errorThrown) {
  var retVal = defaultSettings.onError(jqXhr, errorText, errorThrown);
  if (retVal !== false) {
    this._showError(errorThrown || errorText, jqXhr, errorThrown);
  }
};

FailedTransactions.AjaxProxy.prototype._showError = function (message) {
  Ext.MessageBox.show({
    title: window.TITLE_OPERATION_FAILED,
    msg: message,
    buttons: Ext.MessageBox.OK,
    fn: function () {
      if (window.grid) {
        grid.store.reload();
      }
    },
    icon: Ext.MessageBox.ERROR
  });
};

FailedTransactions.AjaxProxy.prototype._runRefreshProcess = function () {
  if (window.refreshGridTimeout) {
    clearTimeout(window.refreshGridTimeout);
  }
  window.refreshEnabled = true;
  if (window.events && window.events.refreshGrid instanceof Function) {
    window.refreshGridTimeout = setTimeout("this.events.refreshGrid()", 25000);
  }
  if (window.refreshEnabledSummaryGrid !== undefined && window.refreshEnabledSummaryGrid === false) {
    window.refreshEnabledSummaryGrid = true;
  }
};