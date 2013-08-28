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
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.UI.MetraNet.App_Code;


public partial class AmpNavigationPanelInitPage : AmpWizardBasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      // Extra check that user has permission to configure AMP decisions.
      if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
      {
        Response.End();
        return;
      }

      if (!IsPostBack)
      {
        // Copy DecisionName and Action from query string to Session.
        AmpDecisionName = null;
        AmpAction = null;
                     
        if (!(String.IsNullOrEmpty(Request.QueryString["DecisionName"])))
        {
          AmpDecisionName = Request.QueryString["DecisionName"].ToString().Replace("&#039;", "'");
        }
               
        if (!(String.IsNullOrEmpty(Request.QueryString["Action"])))
        {
          AmpAction = Request.QueryString["Action"].ToString();
        }
      }
    }

}