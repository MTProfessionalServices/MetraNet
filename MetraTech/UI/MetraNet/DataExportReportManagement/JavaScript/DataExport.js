
// Event listeners Used by CreateScheduleReportInstanceMonthly.aspx and UpdateScheduleReportInstanceMonthly.aspx

// Calls on 'check' event of 'ExecuteFirstDayMonth' radio
function disableOthersIfExecuteDayChecked(radio, checked) {
  var exLastCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteLastDayMonth');
  var exFirstCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteFirstDayMonth');
  var exDayCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_tbExecuteDay');
  if (checked) {
    exLastCtrl.setValue(false);
    exFirstCtrl.setValue(false);
    exDayCtrl.enable();
  } 
  else {
    exDayCtrl.disable();
  }
}

// Calls on 'check' event of 'ExecuteFirstDayMonth' radio
function disableOthersIfFirstDayChecked(radio, checked){
  var exLastCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteLastDayMonth');
  var exDayRb = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteDay');
  var exDayCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_tbExecuteDay');
  if (checked) {
    exDayRb.setValue(false);
    exDayCtrl.setValue('1');
    exLastCtrl.setValue(false);
  }
}

// Calls on 'check' event of 'ExecuteLastDayMonth' radio
function disableOthersIfLastDayChecked(radio, checked) {
  var exDayRb = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteDay');
  var exFirstCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_cbbExecuteFirstDayMonth');
  var exDayCtrl = Ext.getCmp('ctl00_ContentPlaceHolder1_tbExecuteDay');
  if (checked) {
    exDayRb.setValue(false);
    exFirstCtrl.setValue(false);
    exDayCtrl.setValue('1');
  }
}
