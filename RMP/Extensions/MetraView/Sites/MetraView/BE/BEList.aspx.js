function onApplyChanges_ctl00_ContentPlaceHolder1_MyGrid1() {
  var myMask = new Ext.LoadMask(grid_ctl00_ContentPlaceHolder1_MyGrid1.getEl());
  myMask.show();
  Ext.Ajax.request({
    url: '<%=Request.ApplicationPath%>/AjaxServices/ApplySiteChanges.aspx',
    success: function(result, request) {
      myMask.hide();

      if (result.responseText == "OK") {

        Ext.MessageBox.show({
          msg: TEXT_CONFIGURATION_COMPLETED,
          buttons: Ext.MessageBox.OK,
          icon: Ext.MessageBox.INFO
        });
      }
      else {
        Ext.MessageBox.show({
          msg: TEXT_CONFIGURATION_FAILED,
          buttons: Ext.MessageBox.OK,
          icon: Ext.MessageBox.ERROR
        });
      }
    },
    failure: function(result, request) {
      myMask.hide();

      Ext.MessageBox.show({
        msg: TEXT_CONFIGURATION_FAILED,
        buttons: Ext.MessageBox.OK,
        icon: Ext.MessageBox.ERROR
      });
    }

  });

} 