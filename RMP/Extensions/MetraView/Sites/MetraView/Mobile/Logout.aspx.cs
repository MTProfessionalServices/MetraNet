using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using MetraTech.UI.Common;

public partial class Mobile_Logout : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string resultSuccess = "{ \"success\": \"true\" }";
        Session.Abandon();
        FormsAuthentication.SignOut();
        Response.Write(resultSuccess);
    }
}
