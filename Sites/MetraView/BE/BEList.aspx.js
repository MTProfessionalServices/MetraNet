function onApplyChanges_ctl00_ContentPlaceHolder1_MyGrid1() {
  var myMask = new window.Ext.LoadMask(grid_ctl00_ContentPlaceHolder1_MyGrid1.getEl());
  myMask.show();
  window.Ext.Ajax.request({
    url: '../AjaxServices/ApplySiteChanges.aspx',
    success: function(result, request) {
      myMask.hide();

      if (result.responseText == "OK") {

        window.Ext.MessageBox.show({
          msg: TEXT_CONFIGURATION_COMPLETED,
          buttons: Ext.MessageBox.OK,
          icon: Ext.MessageBox.INFO
        });
      }
      else {
        window.Ext.MessageBox.show({
          msg: TEXT_CONFIGURATION_FAILED,
          buttons: Ext.MessageBox.OK,
          icon: Ext.MessageBox.ERROR
        });
      }
    },
    failure: function(result, request) {
      myMask.hide();

      window.Ext.MessageBox.show({
        msg: TEXT_CONFIGURATION_FAILED,
        buttons: Ext.MessageBox.OK,
        icon: Ext.MessageBox.ERROR
      });
    }
  });
} 