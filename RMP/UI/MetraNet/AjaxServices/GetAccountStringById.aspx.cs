using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class AjaxServices_GetAccountStringById : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (string.IsNullOrEmpty(Request["AccountID"]))
    {
      Response.Write(" ");
      return;
    }

    string accID = Request["AccountID"];
    int numAccID;

    if (int.TryParse(accID, out numAccID))
    {
      string accString = AccountLib.GetFieldID(numAccID, UI.User, ApplicationTime);
      Response.Write(accString);
      return;
    }

    Response.Write(" ");
  }
}
