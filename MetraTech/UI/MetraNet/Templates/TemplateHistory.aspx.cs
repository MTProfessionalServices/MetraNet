using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;

public partial class Templates_TemplateHistory : MTPage
{

  public int? SessionId
  {
    get { return ViewState["SessionId"] as int?; }
    set { ViewState["SessionId"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {

  }

  protected override void OnLoadComplete(EventArgs e)
  {
    GridRenderer.AddAccountTypeFilter(MTFilterGrid1);

    try
    {
      SessionId = (int?)PageNav.Data.Out_StateInitData["SessionIdInstance"];
    }
    catch (Exception)
    {
      // continue rendering the grid anyway
    }

    if (SessionId.HasValue && SessionId != 0)
    {
      MTGridDataElement el = MTFilterGrid1.FindElementByID("SessionId");
      if (el != null)
      {
        el.ElementValue = SessionId.Value.ToString();
      }
    }

    base.OnLoadComplete(e);
  }
}