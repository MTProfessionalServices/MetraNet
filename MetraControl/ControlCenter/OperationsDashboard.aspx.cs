using System;
using MetraTech.UI.Common;

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
}
