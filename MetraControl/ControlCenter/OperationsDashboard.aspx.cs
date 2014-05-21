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

  #region Localization Fields

  public string OpenWord;
  public string UnderInvestigationWord;
  public string UDRsWord;
  public string BatchesWord;
  public string pipelineQueueText;
  public string rampQueueText;
  public string schedulerQueueText;
  public string pipelineQueueToolTipText;
  public string rampQueueToolTipText;
  public string schedulerQueueToolTipText;
  public string FailedAdaptersText;
  public string DurationWord;
  public string AdapterWord;
  public string CurrentVs3MonthAverageText;
  public string ThreeMonthAverageText;
  public string CurrentRunText;
  
  #endregion

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
      SetLocalization();
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
    VisualizeService.ConfigureAndLoadGrid(grdFailedAdapters, "__GET_FAILED_ADAPTERS__");
    VisualizeService.ConfigureAndLoadGrid(grdRunningAdapters, "__GET_RUNNING_ADAPTERS__");
    VisualizeService.ConfigureAndLoadGrid(grdPendingBillClose, "__GET_PENDINGBILLCLOSE_INFORMATION__");
  }

  private void LoadDropDowns()
  {
    VisualizeService.ConfigureAndLoadDropDowns(ddBillCloses, "dt_end", "id_usage_interval",
                                               "__GET_BILLCLOSESYNOPSIS_AVAILABLEINTERVALS__");
    VisualizeService.ConfigureAndLoadDropDowns(ddActiveBillRun, "dt_end", "id_usage_interval",
                                               "__GET_ACTIVEBILLRUN_AVAILABLEINTERVALS__");
  }

  private void SetLocalization()
  {
    lblOverXDays.Text = String.Format("{0} {1} {2}:", GetLocalResourceObject("TEXT_OVER"), failedUdrCleanupThreshold,
                                      GetLocalResourceObject("TEXT_DAYS"));
    lblLastBatch.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_LAST_BATCH"));
    lblFailedAdapters.Text = GetLocalResourceObject("pnlFailedAdapters.Text").ToString();
    lblSuccessful.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_SUCCESSFUL"));
    lblReady.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_READY"));
    lblWaiting.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_WAITING"));
    lblVariance.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_VARIANCE"));
    lblEarliestETA.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_EARLIEST_ETA"));
    
    DurationWord = GetLocalResourceObject("TEXT_DURATION").ToString();
    AdapterWord = GetLocalResourceObject("TEXT_ADAPTER").ToString();
    CurrentVs3MonthAverageText = GetLocalResourceObject("TEXT_CURRENT_VS_3_MONTH_AVERAGE").ToString();
    ThreeMonthAverageText = GetLocalResourceObject("TEXT_3_MONTH_AVERAGE").ToString();
    CurrentRunText = GetLocalResourceObject("TEXT_CURRENT_RUN").ToString();    
    OpenWord = GetLocalResourceObject("TEXT_OPEN").ToString();
    UnderInvestigationWord = GetLocalResourceObject("TEXT_UNDER_INVESTIGATION").ToString();
    UDRsWord = GetLocalResourceObject("TEXT_UDRS").ToString();
    BatchesWord = GetLocalResourceObject("TEXT_BATCHES").ToString();
    pipelineQueueText = GetLocalResourceObject("TEXT_PIPELINE_QUEUE").ToString();
    rampQueueText = GetLocalResourceObject("TEXT_RAMP_QUEUE").ToString();
    schedulerQueueText = GetLocalResourceObject("TEXT_SCHEDULER_QUEUE").ToString();
    pipelineQueueToolTipText = GetLocalResourceObject("TEXT_MESSAGES_WAITING_TO_BE_ASSIGNED").ToString();
    rampQueueToolTipText = GetLocalResourceObject("TEXT_MESSAGES_WAITING_IN_RABBITMQ").ToString();
    schedulerQueueToolTipText = GetLocalResourceObject("TEXT_TASKS_WAITING_TO_BE_PROCESSED").ToString();
  }
}
