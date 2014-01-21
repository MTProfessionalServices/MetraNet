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
using MetraTech.DomainModel.ProductCatalog;


public partial class AmpEditAccountGroupPage : AmpWizardBasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      // Extra check that user has permission to configure AMP decisions.
      if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
      {
        Response.End();
        return;
      }

      if (!String.IsNullOrEmpty(Request["AccountGroupName"]))
      {
        AmpAccountQualificationGroupName = Request["AccountGroupName"];
      }
      if (!String.IsNullOrEmpty(Request["AccountGroupAction"]))
      {
        AmpAccountQualificationGroupAction = Request["AccountGroupAction"];
      }

      // Set the current, next, and previous AMP pages right away.
      AmpCurrentPage = "EditAccountGroup.aspx";
      AmpNextPage = "AccountGroup.aspx";
      AmpPreviousPage = "AccountGroup.aspx";

      //JCTBD Will this work with an MTFilterGrid?!
      // Monitor changes made to the controls on the page.
      //MonitorChangesInControl(tbAcctGroupDescription);

      // The Continue button should NOT prompt the user if the controls have changed.
      // However, we don't need to call IgnoreChangesInControl(btnContinue) here
      // because of how OnClientClick is defined for the button.
      //IgnoreChangesInControl(btnContinue);

      if (!IsPostBack)
      {
        // Load controls from DB.
        AccountQualificationGroup acctGroup = GetAccountQualificationGroupWithClient();
        tbAcctGroupName.Text = MetraTech.UI.Tools.Utils.EncodeForHtmlAttribute(AmpAccountQualificationGroupName);
        if (acctGroup != null)
        {
          tbAcctGroupDescription.Text = MetraTech.UI.Tools.Utils.EncodeForHtml(acctGroup.Description);
          ViewDescriptionText.Text = MetraTech.UI.Tools.Utils.EncodeForHtml(acctGroup.Description);
        }

      }
    }


    protected override void OnLoadComplete(EventArgs e)
    {
      // Pass the values to the service
      AccountQualificationsGrid.DataSourceURL =
          String.Format(
              "/MetraNet/MetraOffer/AmpGui/AjaxServices/AccountQualificationsSvc.aspx?command=LoadAcctQualificationsGrid&accountGroupName={0}",
              AmpAccountQualificationGroupNameForJs);

      SetMode();
    }


    // Set control properties based on current mode(View/Edit).
    private void SetMode()
    {
      if (AmpAccountQualificationGroupAction == "View")
      {
        tbAcctGroupDescription.ReadOnly = true;
        btnContinue.Text = Resources.Resource.TEXT_CONTINUE;
        btnContinue.CausesValidation = false;
        btnContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
        editDescriptionDiv.Attributes.Add("style", "display: none;");
        viewDescriptionDiv.Attributes.Add("style", "display: block;");

      }
      else
      {
        btnContinue.Text = Resources.Resource.TEXT_SAVE_AND_CONTINUE;

        MTGridButton button = new MTGridButton();
        button.ButtonID = "Add";
        button.ButtonText = GetLocalResourceObject("TEXT_ADD").ToString();
        button.ToolTip = GetLocalResourceObject("TEXT_ADD_TOOLTIP").ToString();
        button.JSHandlerFunction = "onAdd";
        button.IconClass = "Add";
        AccountQualificationsGrid.ToolbarButtons.Add(button);
        AccountQualificationsGrid.Height = 210;
        editDescriptionDiv.Attributes.Add("style", "display: block;");
        viewDescriptionDiv.Attributes.Add("style", "display: none;");

      }
    }


    protected void btnContinue_Click(object sender, EventArgs e)
    {
      //TBD Require that the Account Group contain at least one Account Qualification.

      // Save the description of the Account Group to the database.
      if (!SaveAccountQualificationGroup(AmpAccountQualificationGroupName))
      {
        return;
      }

      // Advance to next page in wizard.  Set EndResponse parameter to false
      // to prevent Response.Redirect from throwing ThreadAbortException.
      Response.Redirect(AmpNextPage, false);
    }


    // Saves the specified AccountQualificationGroup to the database.  
    // Returns a boolean indicating if the AccountQualificationGroup was saved successfully.
    private bool SaveAccountQualificationGroup(String aqgName)
    {
      bool success;

      AmpServiceClient ampSvcClient = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        AccountQualificationGroup acctGroup;
        ampSvcClient.GetAccountQualificationGroup(aqgName, out acctGroup);
        if (acctGroup != null)
        {
          acctGroup.Description = tbAcctGroupDescription.Text;
          ampSvcClient.SaveAccountQualificationGroup(acctGroup);
        }
        else
        {
        }

        // Clean up client.
        ampSvcClient.Close();
        ampSvcClient = null;
        success = true;
      }
      catch (Exception ex)
      {
        SetError(GetLocalResourceObject("TEXT_ERROR_UPDATING_ACCT_GROUP_DESCRIPTION").ToString() + aqgName);
        logger.LogException(String.Format("An error occurred while saving Account Group '{0}'.", aqgName), ex);
        success = false;
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }

      return success;
    }

}