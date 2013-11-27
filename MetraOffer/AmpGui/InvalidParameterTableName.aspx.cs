using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.ServiceModel;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.MetraNet.App_Code;
using MetraTech.UsageServer;

public partial class AmpInvalidParameterTableName : AmpWizardBasePage
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
      string decisionName = String.Empty;
      if (!(String.IsNullOrEmpty(Request.QueryString["DecisionName"])))
      {
        decisionName = Request.QueryString["DecisionName"].ToString();
      }
      string parameterTableName = String.Empty;
      if (!(String.IsNullOrEmpty(Request.QueryString["ParameterTableName"])))
      {
        parameterTableName = Request.QueryString["ParameterTableName"].ToString();
      }

      Message.Text = String.Format(GetLocalResourceObject("TEXT_MESSAGE").ToString(), decisionName, parameterTableName);
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    // Close the page
    Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
  }

}