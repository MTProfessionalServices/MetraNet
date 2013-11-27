OverrideRenderer_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function(cm) {
 // if(cm.getIndexById('DisplayAmountAsString') >= 0)
 //   cm.setRenderer(cm.getIndexById('DisplayAmountAsString'), CurrencyRenderer);

 // if (cm.getIndexById('Timestamp') >= 0)
 //    cm.setRenderer(cm.getIndexById('Timestamp'), LongDateRenderer);
}
  

BeforeExpanderRender_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function(tplString) {
  var xTemplate = "";
  
  // Conference details
  xTemplate += '<h6>Call Details</h6><table width="80%" cellspacing="0" cellpadding="0">';
  xTemplate += '<tr><th></th><th><strong>Start Time</strong></th><th class="amount"><strong>Duration</strong></th><th class="amount"><strong>Connections</strong></th></tr>';
  xTemplate += '<tr><td><strong>Scheduled:</strong></td><td>{ScheduledStartTime}</td><td class="amount">{ScheduledDuration}</td><td class="amount">{ScheduledConnections}</td></tr>';
  xTemplate += '<tr><td><strong>Actual:</strong></td<td>{ActualStartTime}</td><td class="amount">{ActualDuration}</td><td class="amount">{ActualNumConnections}</td></tr>';
  xTemplate += '<tr><td><strong>Conference End:</strong></td<td>{ConferenceEndTime}</td><td class="amount"></td><td class="amount"></td></tr>';
  xTemplate += '</table>';

  xTemplate += '<h6>Tax / Adjustment Amount</h6><table width="40%" cellspacing="0" cellpadding="0">';
  xTemplate += '<tr><td><strong>Prebill Adjustments:</strong></td><td class="amount">{CompoundAdjustmentInfo#PreBillAdjustmentAmountAsString}</td></tr>';
  xTemplate += '<tr><td><strong>Tax:</strong></td><td class="amount">{TaxAmount}</td></tr>';
  xTemplate += '<tr><td><strong>Tax Adjustments:</strong></td><td class="amount">{CompoundTotalTaxAdjustments#PreBillTaxAdjustmentAmountAsString}</td></tr>';
  xTemplate += '</table>';
  
  // Render child items for compounds
  xTemplate += '<div id="ChildrenWrapper"><div id="ChildItem{SessionID}"></div></div>';
  tplString = xTemplate;
  return tplString;
};

// On expand get compound usage summaries
onExpand = function(record) {
  var el = Ext.get("ChildItem" + record.data.SessionID);
  var reportLevelSvc = '../AjaxServices/CompoundUsageSummariesSvc.aspx';
  var mgr = el.getUpdater();
  mgr.update({
    url: reportLevelSvc,
    params: { "productSlice": productSlice, "accountSlice": accountSlice, "parentSessionID": record.data.SessionID },
    text: TEXT_LOADING,
    timeout: 60000
  });
};