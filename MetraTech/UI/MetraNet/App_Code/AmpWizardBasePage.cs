using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTProductCatalogExec;

namespace MetraTech.UI.MetraNet.App_Code
{
  // AmpWizardBasePage is the base page for all the AMP Wizard pages.
  public class AmpWizardBasePage : MTClientSidePage
  {
    private string mAmpAccountQualificationGroupNameJs;
    protected readonly static Logger logger = new Logger("[AmpWizard]");

    #region Properties

    protected string AmpCurrentPage
    {
      get { return Session[Constants.AMP_CURRENT_PAGE] as string; }
      set { Session[Constants.AMP_CURRENT_PAGE] = value; }
    }

    protected string AmpNextPage
    {
      get { return Session[Constants.AMP_NEXT_PAGE] as string; }
      set { Session[Constants.AMP_NEXT_PAGE] = value; }
    }

    protected string AmpPreviousPage
    {
      get { return Session[Constants.AMP_PREVIOUS_PAGE] as string; }
      set { Session[Constants.AMP_PREVIOUS_PAGE] = value; }
    }

    protected Decision CurrentDecisionInstance
    {
      // CurrentDecisionInstance is kept in ViewState so that it persists across postbacks.
      // For example, it is accessible in btnContinue_Click(), i.e., after a button click has occurred.
      get { return ViewState["CurrentDecisionInstance"] as Decision; }
      set { ViewState["CurrentDecisionInstance"] = value; }
    }

    protected GeneratedCharge CurrentGeneratedChargeInstance
    {
        get { return ViewState["CurrentGeneratedChargeInstance"] as GeneratedCharge; }
        set { ViewState["CurrentGeneratedChargeInstance"] = value; }
    }

    protected string AmpDecisionName
    {
      get { return Session[Constants.AMP_DECISION_NAME] as string; }
      set { Session[Constants.AMP_DECISION_NAME] = value; }
    }

    //JCTBD Change this property to enum?
    // AmpAction values: "Create", "View", "Edit", "Created"
    protected string AmpAction
    {
      get { return Session[Constants.AMP_ACTION] as string; }
      set { Session[Constants.AMP_ACTION] = value; }
    }

    protected string AmpIsErrorChecked
    {
      get { return Session[Constants.AMP_ISERRORCHECKED] as string; }
      set { Session[Constants.AMP_ISERRORCHECKED] = value; }
    }

    protected string AmpChargeCreditAction
    {
        get { return Session[Constants.AMP_CHARGE_CREDIT_ACTION] as string; }
        set { Session[Constants.AMP_CHARGE_CREDIT_ACTION] = value; }
    }

    protected string AmpChargeCreditName
    {
        get { return Session[Constants.AMP_CHARGE_CREDIT_NAME] as string; }
        set { Session[Constants.AMP_CHARGE_CREDIT_NAME] = value; }
    }

    protected string AmpAccountQualificationGroupName
    {
      get { return Session[Constants.AMP_ACCOUNT_QUALIFICATION_GROUP_NAME] as string; }
      set
      {
          Session[Constants.AMP_ACCOUNT_QUALIFICATION_GROUP_NAME] = value;
          mAmpAccountQualificationGroupNameJs = null;
      }
    }

    //CORE-6182 Security: /MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx page is vulnerable to Cross-Site Scripting 
    //Added JavaScript encoding.
    protected string AmpAccountQualificationGroupNameForJs
    {
        get
        {
            if (string.IsNullOrEmpty(mAmpAccountQualificationGroupNameJs))
            {
                mAmpAccountQualificationGroupNameJs = MetraTech.UI.Tools.Utils.EncodeForJavaScript(AmpAccountQualificationGroupName);
            }

            return mAmpAccountQualificationGroupNameJs;
        }
    }

    protected string AmpAccountQualificationGroupAction
    {
      get { return Session[Constants.AMP_ACCOUNT_QUALIFICATION_GROUP_ACTION] as string; }
      set { Session[Constants.AMP_ACCOUNT_QUALIFICATION_GROUP_ACTION] = value; }
    }

    protected string AmpUsageQualificationAction
    {
      get { return Session[Constants.AMP_USAGE_QUALIFICATION_ACTION] as string; }
      set { Session[Constants.AMP_USAGE_QUALIFICATION_ACTION] = value; }
    }
    #endregion

  
    #region Methods

    //Retrieves from the database the Decision named by the AmpDecisionName property and returns it to the caller.  
    //Returns null if the Decision cannot be retrieved.
    protected Decision GetDecisionWithClient()
    {
      AmpServiceClient ampSvcClient = null;
      Decision decisionInstance = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.GetDecision(AmpDecisionName, out decisionInstance);

        // Clean up client.
        ampSvcClient.Close();
        ampSvcClient = null;

      }
      catch (Exception ex)
      {
        SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_RETRIEVE_DECISION, AmpDecisionName));
        Logger.LogException(String.Format("An error occurred while retrieving Decision '{0}'", AmpDecisionName), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return decisionInstance;
    }


    // Saves to the database the Decision defined by CurrentDecisionInstance.
    // Returns true if the Decision is successfully saved, else false.
    protected bool SaveDecisionWithClient()
    {
      bool retval = false;

      AmpServiceClient ampSvcClient = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.SaveDecision(CurrentDecisionInstance);
        Logger.LogDebug(String.Format("Successfully saved Decision '{0}'", AmpDecisionName));

        retval = true;

        ampSvcClient.Close();
        ampSvcClient = null;
      }
      catch (Exception ex)
      {
        SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_SAVE_DECISION, AmpDecisionName));
        Logger.LogException(String.Format("An error occurred while saving Decision '{0}'", AmpDecisionName), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return retval;
    }


    // Returns an MTList containing the names of the columns in the database table
    // named by tableName.  Returns an empty list if the information cannot be retrieved
    // from the database.
    protected MTList<string> GetTableColumnNamesWithClient(string tableName)
    {
      AmpServiceClient ampSvcClient = new AmpServiceClient();
      MTList<string> tableColumnNames = new MTList<string>();

      try
      {
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.GetTableColumnNames(tableName, ref tableColumnNames);

        ampSvcClient.Close();
        ampSvcClient = null;
      }
      catch (Exception ex)
      {
        SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_RETRIEVE_TABLE_COLUMN_NAMES, tableName));
        Logger.LogException(String.Format("An error occurred while retrieving column names for database table '{0}'", tableName), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return tableColumnNames;
    }

    // Populates an MTList containing the names of the columns in the database table
    // named by tableName.  Returns true if the information can be retrieved
    // from the database. Returns an false if the information cannot be retrieved
    // from the database.
    protected bool GetTableColumnNamesWithClient(string tableName, out MTList<string> tableColumnNames)
    {
      AmpServiceClient ampSvcClient = new AmpServiceClient();
      tableColumnNames = new MTList<string>();

      try
      {
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.GetTableColumnNames(tableName, ref tableColumnNames);

        ampSvcClient.Close();
        ampSvcClient = null;
      }
      catch (Exception)
      {
        return false;
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return true;
    }

    // Populates a List of KeyValuePairs containing the names of the columns in the database parameter table
    // named by tableName.  Returns true if the information can be retrieved
    // from the database. Returns an false if the information cannot be retrieved
    // from the database.
    public bool GetParameterTableColumnNamesWithClient(string tableName, out List<KeyValuePair<String, String>> tableColumnNames)
    {
      AmpServiceClient ampSvcClient = new AmpServiceClient();
      tableColumnNames = new List<KeyValuePair<String, String>>();

      try
      {
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        int id = 0;
        ampSvcClient.GetParameterTableId(tableName, ref id);

        IMTParamTableDefinitionReader reader = new MTParamTableDefinitionReaderClass();
        if (id != 0)
        {
          var paramTableDef =
            reader.FindByID((MetraTech.Interop.MTProductCatalogExec.IMTSessionContext) UI.SessionContext, id);
          MetraTech.Interop.MTProductCatalogExec.IMTCollection mtActionMetaDataCollection = paramTableDef.ActionMetaData;
          if (mtActionMetaDataCollection.Count > 0)
          {
            foreach (MTActionMetaData action in mtActionMetaDataCollection)
            {
              tableColumnNames.Add(new KeyValuePair<string, string>(action.ColumnName, action.DisplayName));
            }
          }
          MetraTech.Interop.MTProductCatalogExec.IMTCollection mtConditionMetaDataCollection =
            paramTableDef.ConditionMetaData;
          if (mtConditionMetaDataCollection.Count > 0)
          {
            foreach (MTConditionMetaData condition in mtConditionMetaDataCollection)
            {
              tableColumnNames.Add(new KeyValuePair<string, string>(condition.ColumnName, condition.DisplayName));
            }
          }
        }
        tableColumnNames.Sort((firstPair, nextPair) =>
                  String.Compare(firstPair.Value, nextPair.Value, false, CultureInfo.InvariantCulture));

        ampSvcClient.Close();
        ampSvcClient = null;
      }
      catch (Exception)
      {
        return false;
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return true;
    }

    // Retrieves from the database the AccountQualificationGroup named by the
    // AmpAccountQualificationGroupName property and returns it to the caller.  
    // Returns null if the AccountQualificationGroup cannot be retrieved.
    protected AccountQualificationGroup GetAccountQualificationGroupWithClient()
    {
      AmpServiceClient ampSvcClient = null;
      AccountQualificationGroup acctQualGroup = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.GetAccountQualificationGroup(AmpAccountQualificationGroupName, out acctQualGroup);

        // Clean up client.
        ampSvcClient.Close();
        ampSvcClient = null;

      }
      catch (Exception ex)
      {
        SetError(String.Format(GetGlobalResourceObject("AmpWizard", "TEXT_ERROR_RETRIEVE_ACCOUNT_QUALIFICATION_GROUP").ToString(), AmpAccountQualificationGroupName));
        Logger.LogException(String.Format("An error occurred while retrieving Account Qualification Group '{0}'", AmpAccountQualificationGroupName), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return acctQualGroup;
    }


    //Retrieves from the database the Charge named by the AmpChargeCreditName property and returns it to the caller.  
    //Returns null if the Charge cannot be retrieved.
    protected GeneratedCharge GetGeneratedChargeWithClient()
    {
      AmpServiceClient ampSvcClient = null;
      GeneratedCharge generatedCharge = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.GetGeneratedCharge(AmpChargeCreditName, out generatedCharge);

        // Clean up client.
        ampSvcClient.Close();
        ampSvcClient = null;

      }
      catch (Exception ex)
      {
        SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_RETRIEVE_GENERATED_CHARGE, AmpChargeCreditName));
        Logger.LogException(String.Format("An error occurred while retrieving Generated Charge'{0}'", AmpChargeCreditName), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return generatedCharge;
    }

    //TBD Should find a better place for this static method -- in a class of utility methods?
    // Enables the items in radioButtonList that are selected and disables the rest.
    // This method is expected to be called when the wizard user is Viewing a decision.
    public static void SetRadioButtonViewAction(RadioButtonList radioButtonList)
    {
      foreach (ListItem rblItem in radioButtonList.Items)
      {
        rblItem.Enabled = rblItem.Selected == true;
      }
    }

    public static void SetCheckBoxViewAction(WebControl cb_control)
    {
        cb_control.Enabled = false;
    }
    #endregion

    // Saves to the database the Decision defined by CurrentDecisionInstance.
    // Returns true if the Decision is successfully saved, else false.
    protected bool SaveGeneratedChargeWithClient()
    {
      bool isSuccessSave = false;

      AmpServiceClient ampSvcClient = null;
      try
      {
        ampSvcClient = new AmpServiceClient();
        if (ampSvcClient.ClientCredentials != null)
        {
          ampSvcClient.ClientCredentials.UserName.UserName = UI.User.UserName;
          ampSvcClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        ampSvcClient.SaveGeneratedCharge(CurrentGeneratedChargeInstance);
        Logger.LogDebug(String.Format("Successfully saved Generated Charge '{0}'", CurrentGeneratedChargeInstance.Name));

        isSuccessSave = true;

        ampSvcClient.Close();
        ampSvcClient = null;
      }
      catch (Exception ex)
      {
        SetError(String.Format(Resources.AmpWizard.TEXT_ERROR_SAVE_GENERATED_CHARGE, CurrentGeneratedChargeInstance.Name));
        Logger.LogException(String.Format("An error occurred while saving Generated Charge '{0}'", CurrentGeneratedChargeInstance.Name), ex);
      }
      finally
      {
        if (ampSvcClient != null)
        {
          ampSvcClient.Abort();
        }
      }
      return isSuccessSave;
    }

  } // AmpWizardBasePage
}
