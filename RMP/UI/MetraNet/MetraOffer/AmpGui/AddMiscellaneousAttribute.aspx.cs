using System;
using System.Collections;
using System.Collections.Generic;
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

public partial class AmpAddMiscellaneousAttributePage : AmpWizardBasePage
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
      CurrentDecisionInstance = GetDecisionWithClient();
      DefaultActionSettings();
    }
  }

  private void DefaultActionSettings()
  {
    PopulateDropDown();

    ctrlValue.UseTextbox = true;
  }

  private void PopulateDropDown()
  {
    FillDropDownControl(CurrentDecisionInstance.ParameterTableName, ctrlValue);
  }

  private void FillDropDownControl(string tableName, UserControls_AmpTextboxOrDropdown ampControl)
  {
    // Populate the drop down list with values from the decision's configured parameter table.
    List<KeyValuePair<String, String>> columns;
    if (GetParameterTableColumnNamesWithClient(tableName, out columns))
    {
      ampControl.DropdownItems = columns;
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    string key = MiscAttributeName.Text;

    // TODO: First verify that the miscellaneous attribute name they are adding is not one that is already in use! For now, the Amp service will throw exception if the name is in use already.

    DecisionAttributeValue miscAttribute = new DecisionAttributeValue();
    if (ctrlValue.UseTextbox)
    {
      // get the number entered by the user and set that as the hardcoded value for the new Miscellaneous Attribute for the Decision
      if (ctrlValue.TextboxText != null && ctrlValue.TextboxText != "")
        miscAttribute.HardCodedValue = ctrlValue.TextboxText;
      else
      {
        logger.LogError(String.Format("Error: Null or empty text value is invalid for Miscellaneous Attribute '{0}' (Decision '{1}')", key, AmpDecisionName));
        SetError(Resources.AmpWizard.TEXT_ERROR_MISSING_MISC_ATTRIBUTE_TEXT_VALUE);
        return;  // Stay on current page.
      }
    }
    else
    {
      // Get the parameter table column name selected by the user and set that value for the new Miscellaneous Attribute for the Decision
      miscAttribute.ColumnName = ctrlValue.DropdownSelectedText;
    }

    // Save the new Miscellaneous Attribute
    AmpServiceClient ampSvcStoreDecisionClient = null;
    // if any of the radio buttons are selected, update the decision to reflect the selected values.
    try
    {
      ampSvcStoreDecisionClient = new AmpServiceClient();
      if (ampSvcStoreDecisionClient.ClientCredentials != null)
      {
        ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      CurrentDecisionInstance.OtherAttributes.Add(key, miscAttribute);
      ampSvcStoreDecisionClient.SaveDecision(CurrentDecisionInstance);
      logger.LogDebug(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(), AmpDecisionName));

      // Clean up client.
      ampSvcStoreDecisionClient.Close();
      ampSvcStoreDecisionClient = null;

      // Close the page
      Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
    }
    catch (Exception ex)
    {
      string exMessage = ex.Message;
      if (exMessage.Contains("An item with the same key has already been added."))
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_DUPLICATE_MISC_ATTRIBUTE_NAME").ToString());
        logger.LogException("Error: Decision miscellaneous attribute name already in use for Decision: '" + AmpDecisionName + "'", ex);
      }
      else
      {
        SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_SAVE_DECISION").ToString(), AmpDecisionName));
        logger.LogException("An error occurred while saving Decision '" + AmpDecisionName + "'", ex);
      }

      // Stay on current page.
    }
    finally
    {
      if (ampSvcStoreDecisionClient != null)
      {
        ampSvcStoreDecisionClient.Abort();
      }
    }

  }


  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
  }
}