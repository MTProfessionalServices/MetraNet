using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
using Core.FileLandingService;
using Resources;

public partial class MetraControl_FileManagement_File : MTPage
{
    public string stateFilter = "";
    public string retryMessage = "";
    public string retryHint = "";
    public string retryTitle = "";
    public string cancelUrl = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
      if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
      {
        Response.End();
        return;
      }
      stateFilter = EnumHelper.GetDbValueByEnum(EFileState.REJECTED).ToString();
        retryMessage = FileManagementResources.FILE_RETRY_MESSAGE;
        retryHint = FileManagementResources.FILE_RETRY_HINT;
        retryTitle = FileManagementResources.FILE_RETRY_TITLE;

        string fileName = Request.QueryString["name"];
        if (!String.IsNullOrEmpty(fileName))
        {
          MarkForRetry(fileName);
        }

        cancelUrl = UI.DictionaryManager["DashboardPage"].ToString();
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        MTGridDataElement stateElement = MTFilterGrid1.FindElementByID("_State");

        if (stateElement != null)
        {
            stateElement.ElementValue =
                    EnumHelper.GetDbValueByEnum(EFileState.REJECTED).ToString();
            stateElement.ElementValue2 = "REJECTED";
        }
      
        base.OnLoadComplete(e);
    }

    private bool MarkForRetry(string name)
    { 
      // Load configuration from the database
      RepositoryService_LoadInstances_Client client =
                                    new RepositoryService_LoadInstances_Client();

      client.UserName = UI.User.UserName;
      client.Password = UI.User.SessionPassword;
      client.In_entityName = typeof(FileBE).FullName;

      MTList<DataObject> items = new MTList<DataObject>();

      items.CurrentPage = 1;
      items.PageSize = 1;
      items.Filters.Add(
          new MTFilterElement("_Name",
                              MTFilterElement.OperationType.Equal,
                              name));

      client.InOut_dataObjects = items;

      try
      {
          bool markedIt = false;

          // Call the service
          client.Invoke();

          items = client.InOut_dataObjects;

          // We expect to only find one item.
          foreach (FileBE file in items.Items)
          {
            markedIt = MarkFileForRetry(file);
          }

          if (!markedIt)
          {
            return false;
          }
      }
      catch (Exception)
      {
        Session[MetraTech.UI.Common.Constants.ERROR] = FileManagementResources.TEXT_UNABLE_RETRIEVE_FILE_DETAILS_ERROR;
          return false;
      }

      return false;
    }

    private bool MarkFileForRetry(FileBE file)
    {
      file._Retry = 1;
      var saveClient = new RepositoryService_SaveInstance_Client();
      saveClient.UserName = UI.User.UserName;
      saveClient.Password = UI.User.SessionPassword;
      saveClient.InOut_dataObject = file;
      try
      {
        saveClient.Invoke();
      }
      catch (Exception)
      {
        return false;
      }

      return true;
    }

}
