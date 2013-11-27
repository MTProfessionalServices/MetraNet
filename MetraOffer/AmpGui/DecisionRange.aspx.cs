using System;
using System.Collections.Generic;
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


public partial class AmpDecisionRangePage : AmpWizardBasePage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Extra check that user has permission to configure AMP decisions.
    if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
    {
      Response.End();
      return;
    }

    // Set the current, next, and previous AMP pages right away.
    AmpCurrentPage = "DecisionRange.aspx";
    AmpNextPage = "DecisionCycle.aspx";
    AmpPreviousPage = "ItemsToAggregate.aspx";

    if (!IsPostBack)
    {
      MonitorChangesInControl(RBL_DecisionRangeRestart);
      MonitorChangesInControl(RBL_ProrateRangeStart);
      MonitorChangesInControl(RBL_ProrateRangeEnd);
      MonitorChangesInControlByClientId(startRange.ddSourceTypeClientId);
      MonitorChangesInControlByClientId(startRange.tbNumericSourceClientId);
      MonitorChangesInControlByClientId(startRange.tbTextSourceClientId);
      MonitorChangesInControlByClientId(startRange.ddSourceClientId);
      MonitorChangesInControlByClientId(endRange.ddSourceTypeClientId);
      MonitorChangesInControlByClientId(endRange.tbNumericSourceClientId);
      MonitorChangesInControlByClientId(endRange.tbTextSourceClientId);
      MonitorChangesInControlByClientId(endRange.ddSourceClientId);

      CurrentDecisionInstance = GetDecision();

      // Fill drop down controls for star and end range parameter table field
      FillDropDownControl(CurrentDecisionInstance.ParameterTableName, startRange);
      FillDropDownControl(CurrentDecisionInstance.ParameterTableName, endRange);

      //Setup page settings for different ampActions
      DecisionRangePageSettings();
    }
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

  private Decision GetDecision()
  {
    AmpServiceClient ampSvcGetDecisionClient = null;
    Decision decisionInstance = null;
    try
    {
      ampSvcGetDecisionClient = new AmpServiceClient();
      if (ampSvcGetDecisionClient.ClientCredentials != null)
      {
        ampSvcGetDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
        ampSvcGetDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      }

      ampSvcGetDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);
    }
    catch (Exception ex)
    {
      SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_RETRIEVE_DECISION, AmpDecisionName));
      logger.LogException(String.Format("An error occurred while retrieving Decision '{0}'", AmpDecisionName), ex);
    }
    finally
    {
      if (ampSvcGetDecisionClient != null)
      {
        ampSvcGetDecisionClient.Abort();
      }
    }
    return decisionInstance;
  }

  private void EditActionSettings()
  {
    if (CurrentDecisionInstance.TierStartValue != null)
    {
      startRange.TextboxText = CurrentDecisionInstance.TierStartValue.ToString();
      startRange.UseTextbox = true;
    }
    else if (CurrentDecisionInstance.TierStartColumnName != null)
    {
      startRange.DropdownSelectedText = CurrentDecisionInstance.TierStartColumnName;
      startRange.UseDropdown = true;
    }
    if (CurrentDecisionInstance.TierEndValue != null)
    {
      endRange.TextboxText = CurrentDecisionInstance.TierEndValue.ToString();
      endRange.UseTextbox = true;
    }
    else if (CurrentDecisionInstance.TierEndColumnName != null)
    {
      endRange.DropdownSelectedText = CurrentDecisionInstance.TierEndColumnName;
      endRange.UseDropdown = true;
    }
    else
    {
      endRange.UseTextbox = true;
    }
    if (CurrentDecisionInstance.TierRepetitionValue.Equals("None"))
    {
      RBL_DecisionRangeRestart.Items[1].Selected = true;
    }
    else
    {
      RBL_DecisionRangeRestart.Items[0].Selected = true;
    }

    switch (CurrentDecisionInstance.TierProration)
    {
      case Decision.TierProrationEnum.PRORATE_BOTH:
        RBL_ProrateRangeStart.Items[0].Selected = true;
        RBL_ProrateRangeEnd.Items[0].Selected = true;
        break;
      case Decision.TierProrationEnum.PRORATE_TIER_START:
        RBL_ProrateRangeStart.Items[0].Selected = true;
        RBL_ProrateRangeEnd.Items[1].Selected = true;
        break;
      case Decision.TierProrationEnum.PRORATE_TIER_END:
        RBL_ProrateRangeStart.Items[1].Selected = true;
        RBL_ProrateRangeEnd.Items[0].Selected = true;
        break;
      case Decision.TierProrationEnum.PRORATE_NONE:
        RBL_ProrateRangeStart.Items[1].Selected = true;
        RBL_ProrateRangeEnd.Items[1].Selected = true;
        break;
    }
  }

  private void ViewActionSettings()
  {
    startRange.ReadOnly = true; 
    endRange.ReadOnly = true;

    SetRadioButtonViewAction(RBL_ProrateRangeEnd);
    SetRadioButtonViewAction(RBL_ProrateRangeStart);
    SetRadioButtonViewAction(RBL_DecisionRangeRestart);

    btnSaveAndContinue.CausesValidation = false;
    btnSaveAndContinue.OnClientClick = "MPC_setNeedToConfirm(false);";
  }

  private void DefaultActionSettings()
  {
    startRange.UseTextbox = true;
    startRange.TextboxText = "0";

    endRange.UseTextbox = true;
    endRange.TextboxText = "0";
  }


  private void DecisionRangePageSettings()
  {
    btnSaveAndContinue.Text = AmpAction != "View"
                                ? Resources.Resource.TEXT_SAVE_AND_CONTINUE
                                : Resources.Resource.TEXT_CONTINUE;

    switch (AmpAction)
    {
      case "Edit":
        EditActionSettings();
        break;
      case "View":
        EditActionSettings();
        ViewActionSettings();
        break;
      case "Created":
        DefaultActionSettings();
        EditActionSettings();
        break;
      default:
        DefaultActionSettings();
        break;
    }
  }

  protected void btnContinue_Click(object sender, EventArgs e)
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

      if (AmpAction != "View")
      {
        SetDecisionProperties();
        ampSvcSaveDecisionRangeClient.SaveDecision(CurrentDecisionInstance);
        logger.LogDebug(String.Format(Resources.AmpWizard.TEXT_SUCCESS_SAVE_DECISION, AmpDecisionName)); 
      }

      ampSvcSaveDecisionRangeClient.Close();
      ampSvcSaveDecisionRangeClient = null;

      Response.Redirect(AmpNextPage, false);
    }
    catch (Exception ex)
    {
      SetError(String.Format( Resources.AmpWizard.TEXT_ERROR_SAVE_DECISION, AmpDecisionName));
      logger.LogException(String.Format("An error occurred while saving Decision '{0}'", AmpDecisionName),ex);
    }
    finally
    {
      if (ampSvcSaveDecisionRangeClient != null)
      {
        ampSvcSaveDecisionRangeClient.Abort();
      }
    }
  }

  private void SetDecisionProperties()
  {
    //setup start of range property
    if (startRange.UseTextbox == true && !String.IsNullOrEmpty(startRange.TextboxText))
    {
      CurrentDecisionInstance.TierStartValue = Decimal.Parse(startRange.TextboxText);
      CurrentDecisionInstance.TierStartColumnName = null;
    }
    else
    {
      CurrentDecisionInstance.TierStartColumnName = startRange.DropdownSelectedText;
      CurrentDecisionInstance.TierStartValue = null;
    }

    //setup end of range proprty
    if (endRange.UseTextbox == true && !String.IsNullOrEmpty(endRange.TextboxText))
    {
      CurrentDecisionInstance.TierEndValue = Decimal.Parse(endRange.TextboxText);
      CurrentDecisionInstance.TierEndColumnName = null;
    }
    else
    {
      CurrentDecisionInstance.TierEndColumnName = endRange.DropdownSelectedText;
      CurrentDecisionInstance.TierEndValue = null;
    }

    //setup restast decision property 
    CurrentDecisionInstance.TierRepetitionValue = RBL_DecisionRangeRestart.SelectedValue.Equals("Yes") ? "Individual" : "None";


    //setup proration properties
    if (RBL_ProrateRangeStart.SelectedValue.Equals("Yes") && RBL_ProrateRangeEnd.SelectedValue.Equals("Yes"))
    {
       CurrentDecisionInstance.TierProration = Decision.TierProrationEnum.PRORATE_BOTH;
    }

    if (RBL_ProrateRangeStart.SelectedValue.Equals("Yes") && RBL_ProrateRangeEnd.SelectedValue.Equals("No"))
    {
      CurrentDecisionInstance.TierProration = Decision.TierProrationEnum.PRORATE_TIER_START;
    }

    if (RBL_ProrateRangeStart.SelectedValue.Equals("No") && RBL_ProrateRangeEnd.SelectedValue.Equals("Yes"))
    {
      CurrentDecisionInstance.TierProration = Decision.TierProrationEnum.PRORATE_TIER_END;
    }

    if (RBL_ProrateRangeStart.SelectedValue.Equals("No") && RBL_ProrateRangeEnd.SelectedValue.Equals("No"))
    {
      CurrentDecisionInstance.TierProration = Decision.TierProrationEnum.PRORATE_NONE;
    }
  }

}