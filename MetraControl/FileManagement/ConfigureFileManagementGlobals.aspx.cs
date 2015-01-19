using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;
using Core.FileLandingService;
using MetraTech.UI.Tools;
using Resources;
using System.Globalization;

public partial class ConfigureFileManagementGlobals : MTPage
{
  public bool isConfirmVisible = false;
  public string confirmationMsg = FileManagementResources.SUCCESSFUL_SAVE;

  protected void Page_Load(object sender, EventArgs e)
  {
    object title = GetGlobalResourceObject("FileManagementResources", "SUCCESSFUL_SAVE");
    if (title != null)
      confirmationMsg = title.ToString();
    if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
    {
      Response.End();
      return;
    }

    if (!IsPostBack)
    {
      if (!LoadDialogWithConfigInDatabase())
      {
        LoadDialogWithDefaults();
      }
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!ValidateUserInput())
    {
      return;
    }

    var inClient = new RepositoryService_LoadInstances_Client();
    inClient.UserName = UI.User.UserName;
    inClient.Password = UI.User.SessionPassword;
    inClient.In_entityName = typeof(ConfigurationBE).FullName;

    // We only expect one configuration row to be in the database,
    // but we will update all that we find.
    MTList<DataObject> items = new MTList<DataObject>();

    items.CurrentPage = 1;
    items.PageSize = 1;
    inClient.InOut_dataObjects = items;

    isConfirmVisible = true;

    try
    {
      inClient.Invoke();

      items = inClient.InOut_dataObjects;

      if (items.Items.Count >= 1)
      {
        foreach (ConfigurationBE config in items.Items)
        {
          config._IncomingDirectory = tbIncomingDirectory.Text;
          config._ActiveDirectory = "undefined";
          config._FailedDirectory = "undefined";
          config._CompletedDirectory = "undefined";
          config._ConfRefreshIntervalInMS = 0;
          if (!WriteConfigToDatabase(config))
          {
            Session[Constants.ERROR] = FileManagementResources.TEXT_INTERNAL_ERROR;
          }
        }
      }
      else
      {
        CreateConfigInDatabase();
      }
    }
    catch(Exception)
    {
      isConfirmVisible = false;
      Session[Constants.ERROR] = FileManagementResources.TEXT_INTERNAL_ERROR;
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    if (!LoadDialogWithConfigInDatabase())
    {
      LoadDialogWithDefaults();
    }
  }

  // Load dialog variables with default values.
  // This is useful if there is currently no stored configuration.
  
  private void LoadDialogWithDefaults()
  {
    tbIncomingDirectory.Text = "";
  }


  // Returns true if able to read configuration from the database.
  // Stores the configuration in dialog variables.
  // Otherwise returns false.
  
  private bool LoadDialogWithConfigInDatabase()
  {
    // Default values
    LoadDialogWithDefaults();

    // Load configuration from the database
    RepositoryService_LoadInstances_Client client = 
                                  new RepositoryService_LoadInstances_Client();

    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;
    client.In_entityName = typeof(ConfigurationBE).FullName;

    MTList<DataObject> items = new MTList<DataObject>();

    items.CurrentPage = 1;
    items.PageSize = 1;

    client.InOut_dataObjects = items;

    try
    {
      // Call the service
      client.Invoke();

      items = client.InOut_dataObjects;

      // We only expect one configuration, but we'll use a loop anyway
      foreach (ConfigurationBE config in items.Items)
      {
        tbIncomingDirectory.Text = config._IncomingDirectory;
        return true;
      }
    }
    catch (FaultException<MASBasicFaultDetail> ex)
    {
      string errorMessage = "";
      foreach (string msg in ex.Detail.ErrorMessages)
      {
        errorMessage += string.Format("{0}{1}", msg, (errorMessage.Length > 0 ? "; " : "")); // "\r\n";
      }

      string errCodeString = Utils.ExtractString(errorMessage, "status '", "'");
      if (errCodeString != "")
      {
        string detailedError = Utils.MTErrorMessage(errCodeString);
        errorMessage += "  " + detailedError;
      }

      errorMessage = "{" + String.Format("'{0}'", errorMessage.Replace("'", "\'")) + "}";
      Session[Constants.ERROR] = errorMessage;
      return false;
    }
    catch (Exception)
    {
      Session[Constants.ERROR] = FileManagementResources.TEXT_INTERNAL_ERROR;
      return false;
    }

    return false;
  }


  // Create a brand new configuration and store it in the database.
  // We use dialog variables to set a portion of the configuration.
  // For the rest of configuration, we use defaults.
  
  private bool CreateConfigInDatabase()
  {
    // There we no configuration rows currently in the database.
    // We need to add a new configuration item.

    var config = new ConfigurationBE();
    config._IncomingDirectory = tbIncomingDirectory.Text;
    config._ActiveDirectory = "undefined";
    config._FailedDirectory = "undefined";
    config._CompletedDirectory = "undefined";
    config._ConfRefreshIntervalInMS = 0;
    config._UseDescriptorFile = false;
    config._UseSHA1 = false;
    config._UseToken = false;
    config._UseMD5 = false;
    config._MaximumActiveTargets = 5;

    return WriteConfigToDatabase(config);
  }


  // Write the given configuration to the database.

  private bool WriteConfigToDatabase(ConfigurationBE config)
  {
    var saveClient = new RepositoryService_SaveInstance_Client();
    saveClient.UserName = UI.User.UserName;
    saveClient.Password = UI.User.SessionPassword;

    saveClient.InOut_dataObject = config;

    try
    {
      saveClient.Invoke();
    }
    catch(Exception)
    {
      return false;
    }

    return true;
  }


  // Check the user's input to see if it reasonable.

  private bool ValidateUserInput()
  {
    return true;
  }
}
