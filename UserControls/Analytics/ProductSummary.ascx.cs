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
using MetraTech.UI.Controls;

using MetraTech.Statistics;

public partial class UserControls_Analytics_ProductSummary : System.Web.UI.UserControl
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Get server description
    VersionInfo vi = new VersionInfo();
    string serverDescription = vi.GetServerDescription("");
    if (serverDescription.ToUpper().IndexOf("PRODUCTION") != -1)
    {
      lblServerDescription.Text = serverDescription + "&nbsp;<img src=\"/Res/Images/header/productiona.gif\" width=\"10\" height=\"10\">";
    }
    else
    {
      lblServerDescription.Text = serverDescription;
    }
  }
}
