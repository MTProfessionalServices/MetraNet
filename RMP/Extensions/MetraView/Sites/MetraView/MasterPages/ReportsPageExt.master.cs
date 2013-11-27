using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Xml.Linq;
using MetraTech.UI.Common;

public partial class MasterPages_ReportsPageExt : System.Web.UI.MasterPage
{

  /// <summary>
  /// Return the current HelpPage.
  /// </summary>
  public string HelpPage
  {
    get { return Session[Constants.HELP_PAGE] as string; }
  }

  /// <summary>
  /// Returns ClickJacking protection JS code if needed. Otherwise returns empty string.
  /// </summary>
  public string CJProtectionCode
  {
    get
    {
      return (Session[Constants.PAGE_RUNNING_FROM_METRANET] != null) && (bool)Session[Constants.PAGE_RUNNING_FROM_METRANET] ? "" : Constants.CJ_PROTECTION_CODE;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {

  }
}
