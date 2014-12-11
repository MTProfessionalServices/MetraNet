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
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;

using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.Security;
using MetraTech.Interop.MTAuth;

using Core.FileLandingService;
using Resources;

public partial class FileManagementDetailReport : MTPage
{
  private string controlNumber = "";        // request variable
  public string stateHistoryDetails = "";   // html displaying history

  public string routeTo
  {
    get { return ViewState["RouteTo"] as string; }
    set { ViewState["RouteTo"] = value; }
  }

  public string filter
  {
    get { return ViewState["Filter"] as string; }
    set { ViewState["Filter"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
    {
      Response.End();
      return;
    }
    string selectedControlNo = Request.QueryString["controlNumber"];
    if (!String.IsNullOrEmpty(selectedControlNo))
    {
      controlNumber = selectedControlNo;
    }

    if (!IsPostBack)
    {
      string filterInUrl = "0";
      if (!String.IsNullOrEmpty(Request.QueryString["filter"]))
      {
        filterInUrl = Request.QueryString["filter"];
      }
      filter = filterInUrl;
      routeTo = "/MetraNet/MetraControl/FileManagement/FileManagement.aspx?filter=" + filter;
      LoadDialog();
    }
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    Response.Redirect(routeTo);
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect(routeTo);
  }


  // Returns true if able to the control number invocation from 
  // the database and set the appropriate dialog fields.
  
  private bool LoadDialog()
  {
      if (!LoadInvocationRecord())
      {
          return false;
      }

      return true;
  }

  private bool LoadInvocationRecord()
  {
      // Load configuration from the database
      RepositoryService_LoadInstances_Client client =
                                    new RepositoryService_LoadInstances_Client();

      client.UserName = UI.User.UserName;
      client.Password = UI.User.SessionPassword;
      client.In_entityName = typeof(InvocationRecordBE).FullName;

      MTList<DataObject> items = new MTList<DataObject>();

      items.CurrentPage = 1;
      items.PageSize = 1;
      items.Filters.Add(
          new MTFilterElement("_ControlNumber",
                              MTFilterElement.OperationType.Equal,
                              controlNumber));

      client.InOut_dataObjects = items;

      try
      {
          bool foundIt = false;

          // Call the service
          client.Invoke();

          items = client.InOut_dataObjects;

          // Find the control record
          foreach (InvocationRecordBE invocation in items.Items)
          {
              tbControlNumber.Text = controlNumber;
              tbTrackingID.Text = invocation._TrackingId;
              tbBatchID.Text = invocation._BatchId;
              tbState.Text = invocation._State.ToString();
              tbErrorCode.Text = invocation._ErrorCode.ToString();
              tbCommand.Text = "";
              tbCommand2.Text = invocation._Command.ToString();
              long errorCode = invocation._ErrorCode;

              LoadTarget(invocation);
              LoadFiles(invocation);
              LoadStateHistory(invocation);
              if (tbState.Text == "FAILED")
              {
                  LoadFileErrorMessages(invocation);
              }
              else
              {
                  tbErrorMessage.Visible = false;
                  TextBoxErrorMessage.Visible = false;
              }
              foundIt = true;
          }

          if (!foundIt)
          {
              return false;
          }

          // Find the associated files

      }
      catch (Exception)
      {
          Session[Constants.ERROR] = FileManagementResources.TEXT_RETRIEVE_RUN_DETAILS_ERROR;
          return false;
      }

      return false;
  }

  private bool LoadTarget(InvocationRecordBE invocation)
  {
      // Load configuration from the database

      var client = new RepositoryService_LoadInstancesFor_Client();
      client.UserName = UI.User.UserName;
      client.Password = UI.User.SessionPassword;
      client.In_entityName = typeof(TargetBE).FullName;
      client.In_forEntityName = typeof(InvocationRecordBE).FullName;
      client.In_forEntityId = invocation.Id;
      MTList<DataObject> items = new MTList<DataObject>();
      client.InOut_mtList = items;
      
      try
      {
          // Call the service
          client.Invoke();

          // Find the control record
          foreach (TargetBE target in client.InOut_mtList.Items)
          {
              tbTarget.Text = target._Name;
          }
      }
      catch (Exception)
      {
        Session[Constants.ERROR] = FileManagementResources.TEXT_RETRIEVE_TARGET_DETAILS_ERROR;
          return false;
      }

      return true;
  }

  private bool LoadFileErrorMessages(InvocationRecordBE invocation)
  {
      // Load error messages related to files in the batch
      var client = new RepositoryService_LoadInstancesFor_Client();
      client.UserName = UI.User.UserName;
      client.Password = UI.User.SessionPassword;
      client.In_entityName = typeof(FileBE).FullName;
      client.In_forEntityName = typeof(InvocationRecordBE).FullName;
      client.In_forEntityId = invocation.Id;
      MTList<DataObject> items = new MTList<DataObject>();
      client.InOut_mtList = items;

      TextBoxErrorMessage.Text = "";
      try
      {
          // Call the service
          client.Invoke();

          // Find the control record
          foreach (FileBE fileMatch in client.InOut_mtList.Items)
          {
              TextBoxErrorMessage.Text = TextBoxErrorMessage.Text + fileMatch._ErrorMessage + " ";
          }

      }
      catch (Exception)
      {
          Session[Constants.ERROR] = FileManagementResources.TEXT_RETRIEVE_FILE_DETAILS_ERROR;
          return false;
      }

      return false;
  }

    private bool LoadFiles(InvocationRecordBE invocation)
  {
      // Load configuration from the database

      var client = new RepositoryService_LoadInstancesFor_Client();
      client.UserName = UI.User.UserName;
      client.Password = UI.User.SessionPassword;
      client.In_entityName = typeof(FileBE).FullName;
      client.In_forEntityName = typeof(InvocationRecordBE).FullName;
      client.In_forEntityId = invocation.Id;
      MTList<DataObject> items = new MTList<DataObject>();
      client.InOut_mtList = items;

      tbFile.Text = "";
      try
      {
          // Call the service
          client.Invoke();

          // Find the control record
          foreach (FileBE fileMatch in client.InOut_mtList.Items)
          {
              tbFile.Text = tbFile.Text + fileMatch._Name + " ";
          }

      }
      catch (Exception)
      {
        Session[Constants.ERROR] = FileManagementResources.TEXT_RETRIEVE_FILE_DETAILS_ERROR;
          return false;
      }

      return false;
  }


  private bool LoadStateHistory(InvocationRecordBE invocation)
  {
    RepositoryService_LoadHistoryInstances_Client client =
                                  new RepositoryService_LoadHistoryInstances_Client();
  
    client.UserName = UI.User.UserName;
    client.Password = UI.User.SessionPassword;
    client.In_entityName = typeof(InvocationRecordBE).FullName;

    MTList<DataObject> items = new MTList<DataObject>();

    items.CurrentPage = 1;
    items.PageSize = 1000;
    items.Filters.Add(
       new MTFilterElement(InvocationRecordBEHistory.Property_InvocationRecordBEId,
                           MTFilterElement.OperationType.Equal,
                           invocation.Id));

    client.InOut_dataObjects = items;

    try
    {
      bool foundIt = false;

      // Call the service
      client.Invoke();

      items = client.InOut_dataObjects;
      stateHistoryDetails = "";

      if (items.Items.Count > 0)
      {
        stateHistoryDetails = "<h2>" + FileManagementResources.DETAIL_STATE_HISTORY + "</h2>";
        string lastState = "";
        string curState = "";

        stateHistoryDetails += "<table>";
        // Find the control record
        foreach (InvocationRecordBEHistory history in items.Items)
        {
          curState = history._State.ToString();
          if (lastState.Equals(curState))
          {
            continue;
          }
          stateHistoryDetails += "<tr>";
          stateHistoryDetails += "<td>" + FileManagementResources.DETAIL_STATE_HISTORY_STATE + ":</td>" + 
                                 "<td>" + curState + "&nbsp&nbsp&nbsp"+ "</td>" + 
                                 "<td>" + FileManagementResources.DETAIL_STATE_HISTORY_DATE + ":</td>" + 
                                 "<td>" + history._StartDate.ToString() + "</td>";
          lastState = curState;
          stateHistoryDetails += "</tr>";

          foundIt = true;
        }

        stateHistoryDetails += "</table><br>";
      }

      if (!foundIt)
      {
        return false;
      }

      // Find the associated files

    }
    catch (Exception)
    {
      Session[Constants.ERROR] = FileManagementResources.TEXT_RETRIEVE_HISTORY_DETAILS_RUN_ERROR;
      return false;
    }

    return false;
  }
}
