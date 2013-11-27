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

public partial class AjaxServices_ServerState : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string action = Request["Action"].ToString();
    string name = Request["Name"].ToString();
    string value = Request["Value"].ToString();

    switch(action.ToLower())
    {
      case "set":
        Session[name] = value;
        Response.Write("OK");
        break;

      case "get":
        if (Session[name] == null)
        {
          Response.Write("");
        }
        else
        {
          Response.Write(Session[name].ToString());
        }
        break;

      case "clear":
        Session.Remove(name);
        Response.Write("OK");
        break;
    }

    Response.End();
  }
}
