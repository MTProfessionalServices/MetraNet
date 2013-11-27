using System;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class NonStandardCharges_ManageNonStandardCharges : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {
    if (!String.IsNullOrEmpty(Request.QueryString["ParentSessionId"]))
    {
      string parentSessionId = Request.QueryString["ParentSessionId"];

      MTGridDataElement el = MTFilterGrid1.FindElementByID("ParentSessionId");
      if (el != null)
      {
        el.ElementValue = parentSessionId;
        MTFilterGrid1.SearchOnLoad = true;
      }
    }
    else if (!String.IsNullOrEmpty(Request.QueryString["SessionId"]))
    {
      string sessionId = Request.QueryString["SessionId"];

      MTGridDataElement el = MTFilterGrid1.FindElementByID("SessionId");
      if (el != null)
      {
        el.ElementValue = sessionId;
        MTFilterGrid1.SearchOnLoad = true;
      }
    }

    base.OnLoadComplete(e);
  }
}