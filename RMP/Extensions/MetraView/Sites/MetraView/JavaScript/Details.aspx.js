OverrideRenderer_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function(cm) {

  if (cm.getIndexById('Timestamp') >= 0)
    cm.setRenderer(cm.getIndexById('Timestamp'), LongDateRenderer);
}
  
// Render child items for compounds
BeforeExpanderRender_ctl00_ContentPlaceHolder1_MTFilterGrid1 = function(tplString)
{
  var xTemplate = '<div id="ChildrenWrapper"><div id="ChildItem{SessionID}"></div></div>'; 
  tplString = tplString + xTemplate;
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
    text: 'Loading...',
    timeout: 60000
  });
};