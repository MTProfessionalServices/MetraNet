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

public partial class AmpDeleteMiscellaneousAttributePage : AmpWizardBasePage
{
  private string key;

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
      setKey();
      CurrentDecisionInstance = GetDecisionWithClient();
      DefaultActionSettings();
    }
  }

  private void setKey()
  {
    if (!(String.IsNullOrEmpty(Request.QueryString["MiscellaneousAttributeName"])))
    {
      key = Request.QueryString["MiscellaneousAttributeName"].ToString();
    }
    else
    {
      key = "";
    }
  }

  #region DefaultActionSettings
  private void DefaultActionSettings()
  {
    // Get the current setting for the Miscellaneous attribute being deleted and show that value on the page
    SetNameText();

    Question.Text = String.Format(GetLocalResourceObject("TEXT_QUESTION").ToString(), Name.Value, AmpDecisionName);

    if (CurrentDecisionInstance.OtherAttributes.ContainsKey(Name.Value))
    {
      DecisionAttributeValue value;
      if (CurrentDecisionInstance.OtherAttributes.TryGetValue(Name.Value, out value) == true)
      {
        if (value.HardCodedValue != null)
        {

        }
        else if (value.ColumnName != null)
        {

        }
      }
    }
  }

  private void SetNameText()
  {
    Name.Value = key;
  }
  #endregion

  #region YesButton
  protected void btnYes_Click(object sender, EventArgs e)
  {
    DeleteMiscellaneousAttribute();
    SaveDecision();
  }

  protected void DeleteMiscellaneousAttribute()
  {
    CurrentDecisionInstance.OtherAttributes.Remove(Name.Value);
  }

  protected void SaveDecision()
  {
    AmpServiceClient ampSvcSaveDecisionRangeClient = null;
    try
    {
      ampSvcSaveDecisionRangeClient = new AmpServiceClient();
      if (ampSvcSaveDecisionRangeClient.ClientCredentials != null)
      {
        ampSvcSaveDecisionRangeClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcSaveDecisionRangeClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      ampSvcSaveDecisionRangeClient.SaveDecision(CurrentDecisionInstance);
      logger.LogInfo(String.Format(Resources.AmpWizard.TEXT_SUCCESS_SAVE_DECISION, AmpDecisionName));

      ampSvcSaveDecisionRangeClient.Close();
      ampSvcSaveDecisionRangeClient = null;

      // Close the page
      Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
    }
    catch (Exception ex)
    {
      SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_SAVE_DECISION, AmpDecisionName));
      logger.LogException(String.Format("An error occurred while saving Decision '{0}'", AmpDecisionName), ex);
    }
    finally
    {
      if (ampSvcSaveDecisionRangeClient != null)
      {
        ampSvcSaveDecisionRangeClient.Abort();
      }
    }
  }
  #endregion

  #region NoButton
  protected void btnNo_Click(object sender, EventArgs e)
  {
    Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
  }
  #endregion
}