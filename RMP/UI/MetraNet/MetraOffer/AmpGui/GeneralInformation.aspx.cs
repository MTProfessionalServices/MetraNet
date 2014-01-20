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
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UsageServer;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.MetraNet.App_Code;
using System.Collections.Generic;

public partial class AmpGeneralInformationPage : AmpWizardBasePage
{
  private string currentParameterTableName;
  protected Boolean IsParameterTableInvalid;

    protected void Page_Load(object sender, EventArgs e)
    {
      // Extra check that user has permission to configure AMP decisions.
      if (!UI.CoarseCheckCapability("ManageAmpDecisions"))
      {
        Response.End();
        return;
      }

      // Set the current, next, and previous AMP pages right away.
      AmpCurrentPage = "GeneralInformation.aspx";
      AmpNextPage = "AccountGroup.aspx";
      AmpPreviousPage = "Start.aspx";

      // The Continue button should NOT prompt the user if the controls have changed.
      // However, we don't need to call IgnoreChangesInControl(btnContinue) here
      // because of how OnClientClick is defined for the button.
      //IgnoreChangesInControl(btnContinue);

      if (!IsPostBack)
      {
        // If we are only Viewing a decision, show the "Continue" button.
        if (AmpAction == "View")
        {
          btnContinue.Visible = true;
          btnSaveAndContinue.Visible = false;
          editDescriptionDiv.Attributes.Add("style", "display: none;");
          viewDescriptionDiv.Attributes.Add("style", "display: block;");
        }
        else // If we are creating or editing a decision, show the "Save & Continue" button
        {
          btnContinue.Visible = false;
          btnSaveAndContinue.Visible = true;
          editDescriptionDiv.Attributes.Add("style", "display: block;");
          viewDescriptionDiv.Attributes.Add("style", "display: none;");

          if (AmpAction == "Create")
          {
              lblTitle.Text = String.Format(lblTitle.Text, " New Decision");
          }

          // Monitor changes made to the controls on the page.
          MonitorChangesInControl(tbGenInfoName);
          MonitorChangesInControl(tbDescription);
          MonitorChangesInControl(ddParamTable);
        }

        // Populate parameter table dropdown list with parameter table names.
        AmpServiceClient ampSvcLoadParamTableClient = null;
        try
        {
          ampSvcLoadParamTableClient = new AmpServiceClient();
          if (ampSvcLoadParamTableClient.ClientCredentials != null)
          {
            ampSvcLoadParamTableClient.ClientCredentials.UserName.UserName = UI.User.UserName;
            ampSvcLoadParamTableClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }

          var paramTableNames = new List<KeyValuePair<String, String>>();
          ampSvcLoadParamTableClient.GetParameterTableNamesWithDisplayValues(ref paramTableNames);

          if (paramTableNames.Count > 0)
          {
            foreach (var paramTable in paramTableNames)
            {
              ListItem item = new ListItem();
              item.Value = paramTable.Key;
              item.Text = paramTable.Value;
              ddParamTable.Items.Add(item);
            }
          }

          // Clean up client.
          ampSvcLoadParamTableClient.Close();
          ampSvcLoadParamTableClient = null;

        }
        catch (Exception ex)
        {
          SetError(GetLocalResourceObject("TEXT_ERROR_RETRIEVE_PARAM_TABLE_NAMES").ToString());
          logger.LogException("An error occurred while retrieving parameter table names.", ex);
        }
        finally
        {
          if (ampSvcLoadParamTableClient != null)
          {
            ampSvcLoadParamTableClient.Abort();
          }
        }

        IsParameterTableInvalid = false;
        
        // Load up the decision.
        if (AmpAction != "Create")
        {

            AmpServiceClient ampSvcGetDecisionClient = null;
          try
          {

            ampSvcGetDecisionClient = new AmpServiceClient();
            if (ampSvcGetDecisionClient.ClientCredentials != null)
            {
              ampSvcGetDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
              ampSvcGetDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            }

            Decision decisionInstance;
            ampSvcGetDecisionClient.GetDecision(AmpDecisionName, out decisionInstance);

            CurrentDecisionInstance = decisionInstance;
            lblTitle.Text = String.Format(lblTitle.Text, CurrentDecisionInstance.Name);

            if (decisionInstance.Name != null)
            {
              tbGenInfoName.Text = decisionInstance.Name;
            }

            if (decisionInstance.Description != null)
            {
              tbDescription.Text = decisionInstance.Description;
              ViewDescriptionText.Text = decisionInstance.Description;
            }

            if (decisionInstance.ParameterTableName != null)
            {
              // First, check if decisionInstance.ParameterTableName actually exists in the list of parameter tables
              if (-1 == ddParamTable.Items.IndexOf(ddParamTable.Items.FindByValue(decisionInstance.ParameterTableName)))
              {
                currentParameterTableName = decisionInstance.ParameterTableName;
                // The parameter table does not exist in the DB
                IsParameterTableInvalid = true;
                if (AmpAction != "View" && AmpAction != "Create")
                {
                  ListItem item = new ListItem();
                  item.Text = item.Value = "";
                  ddParamTable.Items.Insert(0, item);
                  ddParamTable.SelectedIndex = ddParamTable.Items.IndexOf(ddParamTable.Items.FindByText(""));
                }
                else if (AmpAction == "View")
                {
                  // In "View" mode, show the Decision's configured parameter table name here 
                  // even if it does not exist in the db
                  ListItem item = new ListItem();
                  item.Text = item.Value = decisionInstance.ParameterTableName;
                  ddParamTable.Items.Insert(0, item);
                  ddParamTable.SelectedIndex = ddParamTable.Items.IndexOf(ddParamTable.Items.FindByValue(decisionInstance.ParameterTableName));
                }
              }
              else
              {
                ddParamTable.SelectedIndex = ddParamTable.Items.IndexOf(ddParamTable.Items.FindByValue(decisionInstance.ParameterTableName));
              }

            }

            tbGenInfoName.ReadOnly = true;


            if (AmpAction == "View")
            {
              tbDescription.ReadOnly = true;
              ddParamTable.ReadOnly = true;
            }
            else if ((AmpAction == "Edit") || (AmpAction == "Created"))
            {
              ddParamTable.ReadOnly = true;
            }

            // Clean up client.
            ampSvcGetDecisionClient.Close();
            ampSvcGetDecisionClient = null;

          }
          catch (Exception ex)
          {
            SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_RETRIEVE_DECISION").ToString(), AmpDecisionName));
            logger.LogException("An error occurred while retrieving Decision '" + AmpDecisionName + "'", ex);
          }
          finally
          {
            if (ampSvcGetDecisionClient != null)
            {
              ampSvcGetDecisionClient.Abort();
            }
          }

        } // if View or Edit
      } // if (!IsPostBack)

    }


    protected void btnContinue_Click(object sender, EventArgs e)
    {  
      AmpServiceClient ampSvcStoreDecisionClient = null;

      try
      {
        ampSvcStoreDecisionClient = new AmpServiceClient();
        if (ampSvcStoreDecisionClient.ClientCredentials != null)
        {
          ampSvcStoreDecisionClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcStoreDecisionClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
       
        if (AmpAction == "Create")
        {
          // For "Create", create the new decision.
          Decision decisionAddInstance;

          ampSvcStoreDecisionClient.CreateDecision(tbGenInfoName.Text, tbDescription.Text, ddParamTable.SelectedItem.Value, out decisionAddInstance);
          logger.LogDebug(GetLocalResourceObject("TEXT_SUCCESS_CREATE_DECISION").ToString() + " '" + tbGenInfoName.Text + "'");

          // Store name of new decision in Session.
          AmpDecisionName = tbGenInfoName.Text;

          // Change action to "Created" so that if we come back to the GeneralInformation page,
          // we know we should load the decision.
          AmpAction = "Created";
        }
        else if (AmpAction != "View")
        {
          // Else, if not viewing, save the decision.
          CurrentDecisionInstance.Description = tbDescription.Text;
          CurrentDecisionInstance.ParameterTableName = ddParamTable.SelectedItem.Text;  
          ampSvcStoreDecisionClient.SaveDecision(CurrentDecisionInstance);
          logger.LogDebug(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_SUCCESS_SAVE_DECISION").ToString(), AmpDecisionName));
        }

        // Clean up client.
        ampSvcStoreDecisionClient.Close();
        ampSvcStoreDecisionClient = null;

        // Advance to next page in wizard.  Set EndResponse parameter to false
        // to prevent Response.Redirect from throwing ThreadAbortException.
        Response.Redirect(AmpNextPage, false);
      }
      catch (FaultException<MASBasicFaultDetail> ex)
      {
        // We may add error codes to AMP service exceptions in the future, but for now
        // this handler is here to provide a useful message to the AMP GUI user
        // if creation of a decision failed because the name is already in use.
        string exMessage = ex.Detail.ErrorMessages[0];
        string decisionName = string.IsNullOrEmpty(AmpDecisionName) ? tbGenInfoName.Text : AmpDecisionName;

        if (exMessage.Contains("Violation of UNIQUE KEY constraint"))
        {
          SetError(GetLocalResourceObject("TEXT_ERROR_DUPLICATE_DECISION_NAME").ToString() + ": '" + decisionName + "'");
          logger.LogException("Error: Decision name already in use: '" + decisionName + "'", ex);
        }
        else
        {
          SetError(GetLocalResourceObject("TEXT_ERROR_ADD_EDIT_DECISION").ToString() + " '" + decisionName + "'");
          logger.LogException("An error occurred while creating/editing Decision '" + decisionName + "'", ex);
        }
      }
      catch (Exception ex)
      {
        string decisionName = string.IsNullOrEmpty(AmpDecisionName) ? tbGenInfoName.Text : AmpDecisionName;
        SetError(GetLocalResourceObject("TEXT_ERROR_ADD_EDIT_DECISION").ToString() + " '" + decisionName + "'");
        logger.LogException("An error occurred while creating/editing Decision '" + decisionName + "'", ex);

        // Stay on current page.
      }
      finally
      {
        if (ampSvcStoreDecisionClient != null)
        {
          ampSvcStoreDecisionClient.Abort();
        }
      }

    } // btnContinue_Click

    protected string getCurrentDecisionInstanceName()
    {
      string value = "";
      if (CurrentDecisionInstance != null)
      {
        value = CurrentDecisionInstance.Name;
      }
      return value;
    }

    protected string getCurrentDecisionInstanceParameterTableName()
    {
      string value = "";
      if (CurrentDecisionInstance != null)
      {
        value = CurrentDecisionInstance.ParameterTableName;
      }
      return value;
    }
}
