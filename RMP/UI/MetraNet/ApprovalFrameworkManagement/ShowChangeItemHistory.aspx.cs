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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Globalization;
using System.Reflection;
using System.Resources;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;


public partial class ApprovalFrameworkManagement_ShowChangeItemHistory : MTPage
{
    public string strincomingChangeId { get; set; } //so we can read it any time in the session
    public string strincomingchangestate { get; set; }
    public int intincomingChangeId { get; set; }
    public string incomingshowchangestate { get; set; }

    protected void Page_Load(object sender, EventArgs e)
    {
      if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
        Response.End();

      strincomingChangeId = Request.QueryString["changeid"];
      strincomingchangestate = Request.QueryString["currentstate"];
      intincomingChangeId = System.Convert.ToInt32(strincomingChangeId);
      Session["intSessionChangeID"] = intincomingChangeId;
      incomingshowchangestate = Request.QueryString["showchangestate"];
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      //Go back to the previous page ALL, PENDING or FAILED Changes Summary Screen
      Response.Redirect("ShowChangesSummary.aspx?showchangestate=" + incomingshowchangestate, false);
    }


}