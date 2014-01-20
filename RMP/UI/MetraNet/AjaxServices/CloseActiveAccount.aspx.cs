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

public partial class AjaxServices_CloseActiveAccount : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    UI.Subscriber.CloseAccount();
    Response.Write("OK");
    Response.End();
  }
}
