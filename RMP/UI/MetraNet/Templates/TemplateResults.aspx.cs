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

public partial class Templates_TemplateResults : MTPage
{

  public int? NumRetries
  {
    get { return ViewState["NumRetries"] as int?; }
    set { ViewState["NumRetries"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {

  }

  protected override void OnLoadComplete(EventArgs e)
  {
    try
    {
        NumRetries = (int?)PageNav.Data.Out_StateInitData["NumRetries"];
    }
    catch (Exception)
    {
        // continue rendering the grid anyway
    }

    if (NumRetries.HasValue && NumRetries != 0)
    {
      MTGridDataElement el = MTFilterGrid1.FindElementByID("NumRetries");
      if (el != null)
      {
        el.ElementValue = NumRetries.Value.ToString();
      }
    }

    base.OnLoadComplete(e);
  }
}