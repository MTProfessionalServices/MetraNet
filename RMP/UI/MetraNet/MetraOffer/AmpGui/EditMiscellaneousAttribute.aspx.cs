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

public partial class AmpEditMiscellaneousAttributePage : AmpWizardBasePage
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
      // Get the current setting for the Miscellaneous attribute being edited and show those values on the page
      SetNameText();
      PopulateDropDown();

      if (CurrentDecisionInstance.OtherAttributes.ContainsKey(Name.Text))
      {
        DecisionAttributeValue value;
        if (CurrentDecisionInstance.OtherAttributes.TryGetValue(Name.Text, out value) == true)
        {
          if (value.HardCodedValue != null)
          {
            ctrlValue.TextboxText = value.HardCodedValue;
            ctrlValue.UseTextbox = true;
          }
          else if (value.ColumnName != null)
          {
            ctrlValue.DropdownSelectedText = value.ColumnName;
            ctrlValue.UseDropdown = true;
          }
        }
      }
    }

    private void SetNameText()
    {
      Name.Text = key;
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
    #endregion

    #region OKbutton
    protected void btnOK_Click(object sender, EventArgs e)
    {
      SetDecisionMiscellaneousAttributeProperties();
      SaveDecision();
    }

    protected void SetDecisionMiscellaneousAttributeProperties()
    {
      if (ctrlValue.UseTextbox && !String.IsNullOrEmpty(ctrlValue.TextboxText))
      {
        CurrentDecisionInstance.OtherAttributes[Name.Text].HardCodedValue = ctrlValue.TextboxText;
        CurrentDecisionInstance.OtherAttributes[Name.Text].ColumnName = null;
      }
      else if (ctrlValue.UseDropdown && !String.IsNullOrEmpty(ctrlValue.DropdownSelectedText))
      {
        CurrentDecisionInstance.OtherAttributes[Name.Text].ColumnName = ctrlValue.DropdownSelectedText;
        CurrentDecisionInstance.OtherAttributes[Name.Text].HardCodedValue = null;
      }
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

    #region CancelButton
    protected void btnCancel_Click(object sender, EventArgs e)
    {      
      Page.ClientScript.RegisterStartupScript(Page.GetType(), "closeWindow", "closeWindow();", true);
    }
    #endregion
}