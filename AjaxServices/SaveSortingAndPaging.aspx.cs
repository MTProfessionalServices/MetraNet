using System;
using MetraTech.UI.Common;

public partial class AjaxServices_SaveSortingAndPaging : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      string pageURL = Request["PageUrl"];
      string gridID = Request["GridID"];
      string SessionID = Request["SessionID"];
      if(Session.SessionID.Equals(SessionID))
      {
        string key = pageURL + ";" + gridID;
        if (!String.IsNullOrEmpty(Request["PageNo"]))
          Session[key + "_PageNo"] = Request["PageNo"];
        if (!String.IsNullOrEmpty(Request["SortField"]))
          Session[key + "_SortField"] = Request["SortField"];
        if (!String.IsNullOrEmpty(Request["SortOrder"]))
          Session[key + "_SortOrder"] = Request["SortOrder"];
        if (!String.IsNullOrEmpty(Request["Filters"]))
          Session[key + "_Filters"] = Request["Filters"];
      }
    }
}