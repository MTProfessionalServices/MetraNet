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
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Common;


public partial class AmpStartPage : AmpWizardBasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      // Extra check that user has permission to configure AMP decisions.
      if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
      {
        Response.End();
        return;
      }

      // Clear out some session variables in the case that a user visits this page after adding/viewing/editing a Decision Type
      // This way, the navigation panel will not have a previously visited step highlighted when you add/view/edit a different 
      // Decision Type from this page.
      if (Session[Constants.AMP_CURRENT_PAGE] != null)
      {
        Session.Remove(Constants.AMP_CURRENT_PAGE);
      }

      AppendParameterTableNames();
    }

    private void AppendParameterTableNames()
    {
        var parameterTableNames = GetParameterTableNamesWithClient();

        var sb = new StringBuilder();
        sb.Append("<script>");
        sb.Append("var parameterTableNames = new Array;");
        foreach (string str in parameterTableNames)
        {
            sb.Append("parameterTableNames.push('" + str + "');");
        }
        sb.Append("</script>");

        ClientScript.RegisterStartupScript(GetType(), "AppendParameterTableNamesScript", sb.ToString());
    }
    
    private List<string> GetParameterTableNamesWithClient()
    {
        var parameterTableNames = new MTList<string>();

        AmpServiceClient ampSvcGenChClient = null;
        try
        {
            ampSvcGenChClient = new AmpServiceClient();
            if (ampSvcGenChClient.ClientCredentials != null)
            {
                ampSvcGenChClient.ClientCredentials.UserName.UserName = UI.User.UserName;
                ampSvcGenChClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            ampSvcGenChClient.GetParameterTableNames(ref parameterTableNames);

            ampSvcGenChClient.Close();
            ampSvcGenChClient = null;
        }
        catch (Exception ex)
        {
            var errorMessage = GetLocalResourceObject("TEXT_ERROR_GET_PARAMETER_TABLE_NAMES").ToString();
            SetError(errorMessage);
            logger.LogException(errorMessage, ex);
        }
        finally
        {
            if (ampSvcGenChClient != null)
            {
                ampSvcGenChClient.Abort();
            }
        }

        return parameterTableNames.Items;
    }
}