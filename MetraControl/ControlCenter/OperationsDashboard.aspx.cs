using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.UI.Controls;
using MetraTech.OnlineBill;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using System.Web.UI.WebControls;
using System.Net;
using System.Text;
using System.IO;

public partial class OperationsDashboard : MTPage
{

  public int failedUdrCleanupThreshold = 30;
  public int udrBatchFrequencyThreshold = 60;
  protected string primaryCurrency = "USD";
  protected int softCloseThreshold = 40;
  public string puppetMasterUrl = "https://puppet-corp1";
  public string puppetJsonUrl = "https://puppet-corp1.metratech.com:443/radiator.json";
  public string puppetJson = "";

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
      // TODO:  Get data to bind to and place in viewstate
     
      // TODO:  Set binding properties and template on MTGenericForm control
      // MTGenericForm1.RenderObjectType = Data.GetType();
      // MTGenericForm1.RenderObjectInstanceName = "Data";
      // MTGenericForm1.TemplatePath = TemplatePath;
      // MTGenericForm1.ReadOnly = false;
        lblOverXDays.Text = "Over " + failedUdrCleanupThreshold.ToString() + " Days:";
        lblLastBatch.Text = "Last Batch:";
        
       
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
      try
      {
          LoadGrids();
          LoadDropDowns();
         // loadPuppetData();   
      }
      catch (Exception ex)
      {
          Response.Write(ex.StackTrace);
      }
      base.OnLoadComplete(e);
  }

  private void LoadGrids()
  {
    const string querydir = "..\\Extensions\\SystemConfig\\config\\SqlCustom\\Queries\\UI\\Dashboard";

    VisualizeService.ConfigureAndLoadGrid(grdFailedAdapters, "__GET_FAILED_ADAPTERS__", querydir);
    VisualizeService.ConfigureAndLoadGrid(grdRunningAdapters, "__GET_RUNNING_ADAPTERS__", querydir);
    VisualizeService.ConfigureAndLoadGrid(grdPendingBillClose, "__GET_PENDINGBILLCLOSE_INFORMATION__", querydir);
  }

  private void LoadDropDowns()
  {
    VisualizeService.ConfigureAndLoadDropDowns(ddBillCloses, "dt_end", "id_usage_interval",
                                               "__GET_BILLCLOSESYNOPSIS_AVAILABLEINTERVALS__");
    VisualizeService.ConfigureAndLoadDropDowns(ddActiveBillRun, "dt_end", "id_usage_interval",
                                               "__GET_ACTIVEBILLRUN_AVAILABLEINTERVALS__");
  }

  private void loadPuppetData()
  {

    WebRequest myReq = WebRequest.Create(puppetJsonUrl);

    string username = "username";
    string password = "password";
    string usernamePassword = username + ":" + password;
    CredentialCache mycache = new CredentialCache();
    mycache.Add(new Uri(puppetJsonUrl), "Basic", new NetworkCredential(username, password));
    myReq.Credentials = mycache;
    myReq.Headers.Add("Authorization", "Basic " + Convert.ToBase64String(new ASCIIEncoding().GetBytes(usernamePassword)));

    WebResponse wr = myReq.GetResponse();
    Stream receiveStream = wr.GetResponseStream();
    StreamReader reader = new StreamReader(receiveStream, Encoding.UTF8);

    puppetJson = reader.ReadToEnd();
    Logger.LogInfo(puppetJson);
  }
  

}
