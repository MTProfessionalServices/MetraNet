using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;


public partial class AjaxServices_GetAllowedDescAccountTypes : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    int id = -1;
    if (!String.IsNullOrEmpty(Request["id"]))
    {
      id = int.Parse(Request["id"]);
      Logger.LogDebug("Recieves accountID={0}", id);
    }
    else
    {
      Logger.LogDebug("accountID is not set, so all types will be returned for account hierarchy");
    }

    // account type names
    List<string> accTypes = new List<string>
      {
        "CorporateAccount",
        "DepartmentAccount"
      };

      var jss = new JavaScriptSerializer();
      Response.Write(jss.Serialize(accTypes));
      Response.End();
    }
}