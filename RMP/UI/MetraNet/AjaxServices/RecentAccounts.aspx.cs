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
using System.Web.Script.Serialization;

public partial class AjaxServices_RecentAccounts : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (Session[Constants.RECENT_ACCOUNT_LIST] == null)
    {
      Response.Write("{\"ListRecentAccounts\":[{\"AccountId\":0}]}");
      Response.End();
      return;
    }

    RecentAccounts accs = Session[Constants.RECENT_ACCOUNT_LIST]  as RecentAccounts;
    JavaScriptSerializer jss = new JavaScriptSerializer();
    Response.Write(jss.Serialize(accs));
    Response.End();
  }
}
