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
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.UI.MetraNet.App_Code;


public partial class AmpAccountQualificationPage : AmpWizardBasePage
{
  private String _acctQualAction = String.Empty;  // Create, View, Edit
  private String _acctQualId = String.Empty;      // Empty for Create action


  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    // Get parameters from query string.
    if (!String.IsNullOrEmpty(Request["AcctQualAction"]))
    {
      _acctQualAction = Request["AcctQualAction"];
    }
    if (!String.IsNullOrEmpty(Request["AcctQualId"]))
    {
      _acctQualId = Request["AcctQualId"];
    }

    if (!IsPostBack)
    {
      // Set the current, next, and previous AMP pages right away.
      AmpCurrentPage  = "AccountQualification.aspx";
      AmpNextPage     = "EditAccountGroup.aspx";
      AmpPreviousPage = "EditAccountGroup.aspx";

      ReadFromDbIntoControls();

      MonitorChanges();
    }
  }


    // Finds and returns the account qualification with the specified ID in the specified account group.
    // Returns null if the account qualification cannot be found.
    private AccountQualification GetAccountQualificationInGroup(AccountQualificationGroup acctGroup, String acctQualId)
    {
      AccountQualification result = null;
      if (acctGroup != null)
      {
        int aqIndex = acctGroup.AccountQualifications.FindIndex(acctqual => Convert.ToString(acctqual.UniqueId) == acctQualId);

        if (aqIndex != -1)
        {
          result = acctGroup.AccountQualifications[aqIndex];
        }
      }
      return result;
    }


    // Sets the page's controls based on the contents of the object retrieved from the database.
    private void ReadFromDbIntoControls()
    {
      AccountQualificationGroup acctGroup = GetAccountQualificationGroupWithClient();
      AccountQualification acctQual = GetAccountQualificationInGroup(acctGroup, _acctQualId);

      if (acctQual != null)
      {
        tbSourceField.Text = acctQual.SourceField;
        tbTableToInclude.Text = acctQual.TableToInclude;
        tbMatchField.Text = acctQual.MatchField;
        tbOutputField.Text = acctQual.OutputField;
        tbIncludeFilter.Text = acctQual.DbFilter;
        ViewIncludeFilterText.Text = acctQual.DbFilter;
        tbFilter.Text = acctQual.MvmFilter;
        ViewFilterText.Text = acctQual.MvmFilter;
      }

      InitializeModeDropdown(acctQual);

      if (_acctQualAction == "View")
      {
        SetViewMode();
      }
      else
      {
        SetEditMode();
      }
      btnContinue.Text = ((_acctQualAction != "View")
                            ? Resources.Resource.TEXT_SAVE_AND_CONTINUE
                            : Resources.Resource.TEXT_CONTINUE);
    }


  private void InitializeModeDropdown(AccountQualification acctQual)
    {
      ListItem item;

      item = new ListItem();
      item.Text = item.Value = GetLocalResourceObject("TEXT_MODE_ENGINE_FILTER").ToString();
      ddMode.Items.Add(item);

      item = new ListItem();
      item.Text = item.Value = GetLocalResourceObject("TEXT_MODE_APPEND_FIELDS").ToString();
      ddMode.Items.Add(item);

      item = new ListItem();
      item.Text = item.Value = GetLocalResourceObject("TEXT_MODE_APPEND_ROWS").ToString();
      ddMode.Items.Add(item);

      item = new ListItem();
      item.Text = item.Value = GetLocalResourceObject("TEXT_MODE_REPLACE_ROWS").ToString();
      ddMode.Items.Add(item);

      if (acctQual != null)
      {
        ddMode.SelectedIndex = acctQual.Mode - 1;
      }
    }


    private void SetViewMode()
    {
      btnContinue.CausesValidation = false;
      btnContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
      tbSourceField.ReadOnly = true;
      tbTableToInclude.ReadOnly = true;
      tbMatchField.ReadOnly = true;
      tbOutputField.ReadOnly = true;
      tbIncludeFilter.ReadOnly = true;
      tbFilter.ReadOnly = true;
      ddMode.ReadOnly = true;
      editIncludeFilterDiv.Attributes.Add("style", "display: none;");
      viewIncludeFilterDiv.Attributes.Add("style", "display: block;");
      editFilterDiv.Attributes.Add("style", "display: none;");
      viewFilterDiv.Attributes.Add("style", "display: block;");
    }

    private void SetEditMode()
    {
      editIncludeFilterDiv.Attributes.Add("style", "display: block;");
      viewIncludeFilterDiv.Attributes.Add("style", "display: none;");
      editFilterDiv.Attributes.Add("style", "display: block;");
      viewFilterDiv.Attributes.Add("style", "display: none;");
    }

    private void MonitorChanges()
    {
      MonitorChangesInControl(tbSourceField);
      MonitorChangesInControl(tbTableToInclude);
      MonitorChangesInControl(tbMatchField);
      MonitorChangesInControl(tbOutputField);
      MonitorChangesInControl(tbIncludeFilter);
      MonitorChangesInControl(tbFilter);
      MonitorChangesInControl(ddMode);
    }


    protected void btnContinue_Click(object sender, EventArgs e)
    {
      if (_acctQualAction != "View")
      {
        if (!WriteFromControlsIntoDb())
        {
          return;
        }
      }

      // Advance to next page in wizard.  Set EndResponse parameter to false
      // to prevent Response.Redirect from throwing ThreadAbortException.
      Response.Redirect(AmpNextPage, false);
    }


    // Writes the current content of the page's controls into an AccountQualification object
    // and stores it in the DB as part of the Account Qualification Group named by AmpAccountQualificationGroupName.
    private bool WriteFromControlsIntoDb()
    {
      bool bSuccess = false;

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
        ampSvcClient.GetAccountQualificationGroup(AmpAccountQualificationGroupName, out acctGroup);
        if (acctGroup != null)
        {
          AccountQualification acctQual = GetAccountQualificationInGroup(acctGroup, _acctQualId);
          if (acctQual != null)
          {
            // Not necessary to remove the existing account qualification in the group!
            //logger.LogDebug(String.Format("Removing AQ with id='{0}' from AQG '{1}'", _acctQualId, AmpAccountQualificationGroupName));
            //acctGroup.AccountQualifications.Remove(acctQual);
          }
          else
          {
            acctQual = new AccountQualification();
            acctQual.Priority = 0;  // Insert-trigger will bump this up to 1 in the DB.
          }

          // Stuff the object with content of controls.
          acctQual.SourceField = (!String.IsNullOrWhiteSpace(tbSourceField.Text) ? tbSourceField.Text : null);
          acctQual.TableToInclude = (!String.IsNullOrWhiteSpace(tbTableToInclude.Text) ? tbTableToInclude.Text : null);
          acctQual.MatchField = (!String.IsNullOrWhiteSpace(tbMatchField.Text) ? tbMatchField.Text : null);
          acctQual.OutputField = (!String.IsNullOrWhiteSpace(tbOutputField.Text) ? tbOutputField.Text : null);
          acctQual.DbFilter = (!String.IsNullOrWhiteSpace(tbIncludeFilter.Text) ? tbIncludeFilter.Text : null);
          acctQual.MvmFilter = (!String.IsNullOrWhiteSpace(tbFilter.Text) ? tbFilter.Text : null);
          acctQual.Mode = ddMode.SelectedIndex + 1;

          // Now add/replace the account qualification and write to the DB.
          acctGroup.AccountQualifications.Add(acctQual);
          ampSvcClient.SaveAccountQualificationGroup(acctGroup);

          bSuccess = true;
        }
        else
        {
          SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_RETRIEVE_ACCOUNT_QUALIFICATION_GROUP").ToString(), AmpAccountQualificationGroupName));
          logger.LogError(String.Format("An error occurred while retrieving Account Qualification Group '{0}'", AmpAccountQualificationGroupName));
        }

        // Clean up client.
        ampSvcClient.Close();
        ampSvcClient = null;
      }
      catch (Exception ex)
      {
        SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_STORE_ACCOUNT_QUALIFICATION_GROUP").ToString(), AmpAccountQualificationGroupName));
        logger.LogException(String.Format("An error occurred while storing Account Qualification Group '{0}'", AmpAccountQualificationGroupName), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }

      return bSuccess;
    }

}