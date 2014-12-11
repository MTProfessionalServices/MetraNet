using System;
using System.Collections.Generic;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

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
  public string FixedWord;
  public string UnguidedWord;
  public string pipelineWaitDurationText;
  public string pipelineProcessingDurationText;
  public string pipelineWaitDurationToolTipText;
  public string pipelineProcessingDurationToolTipText;
  public string DaysBackText;
  public string DateFormatJs;
  protected string TypeM5Text;
  protected string TypeM12Text;
  protected string TypeM19Text;
  protected string TypeM26Text;
  protected string TypeEOMText;
  #endregion

  protected void Page_Load(object sender, EventArgs e)
  {
    if (!IsPostBack)
    {
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
    var ddList = new List<MTDropDown>{ ddBillCloses };
    VisualizeService.ConfigureAndLoadIntervalDropDowns(ddList);

    var ddSoftClosedList = new List<MTDropDown> { ddActiveBillRun };
    VisualizeService.ConfigureAndLoadSoftClosedIntervalDropDowns(ddSoftClosedList);
  }

  private void SetLocalization()
  {
    lblOverXDays.Text = String.Format("{0} {1} {2}:", GetLocalResourceObject("TEXT_OVER"), failedUdrCleanupThreshold,
                                      GetLocalResourceObject("TEXT_DAYS"));
    lblLastBatch.Text = String.Format("{0}:", GetLocalResourceObject("TEXT_LAST_BATCH"));
    lblFailedAdapters.Text = Convert.ToString(GetLocalResourceObject("pnlFailedAdapters.Text"));
    lblSuccessful.Text = Convert.ToString(GetLocalResourceObject("TEXT_SUCCESSFUL"));
    lblReady.Text = Convert.ToString(GetLocalResourceObject("TEXT_READY"));
    lblWaiting.Text = Convert.ToString(GetLocalResourceObject("TEXT_WAITING"));

    DurationWord = Convert.ToString(GetLocalResourceObject("TEXT_DURATION"));
    AdapterWord = Convert.ToString(GetLocalResourceObject("TEXT_ADAPTER"));
    CurrentVs3MonthAverageText = Convert.ToString(GetLocalResourceObject("TEXT_CURRENT_VS_3_MONTH_AVERAGE"));
    ThreeMonthAverageText = Convert.ToString(GetLocalResourceObject("TEXT_3_MONTH_AVERAGE"));
    CurrentRunText = Convert.ToString(GetLocalResourceObject("TEXT_CURRENT_RUN"));    
    OpenWord = Convert.ToString(GetLocalResourceObject("TEXT_OPEN"));
    UnderInvestigationWord = Convert.ToString(GetLocalResourceObject("TEXT_UNDER_INVESTIGATION"));
    UDRsWord = Convert.ToString(GetLocalResourceObject("TEXT_UDRS"));
    BatchesWord = Convert.ToString(GetLocalResourceObject("TEXT_BATCHES"));
    pipelineQueueText = Convert.ToString(GetLocalResourceObject("TEXT_PIPELINE_QUEUE"));
    rampQueueText = Convert.ToString(GetLocalResourceObject("TEXT_RAMP_QUEUE"));
    schedulerQueueText = Convert.ToString(GetLocalResourceObject("TEXT_SCHEDULER_QUEUE"));
    pipelineQueueToolTipText = Convert.ToString(GetLocalResourceObject("TEXT_MESSAGES_WAITING_TO_BE_ASSIGNED"));
    rampQueueToolTipText = Convert.ToString(GetLocalResourceObject("TEXT_MESSAGES_WAITING_IN_RABBITMQ"));
    schedulerQueueToolTipText = Convert.ToString(GetLocalResourceObject("TEXT_TASKS_WAITING_TO_BE_PROCESSED"));
    FixedWord = Convert.ToString(GetLocalResourceObject("TEXT_FIXED"));
    UnguidedWord = Convert.ToString(GetLocalResourceObject("TEXT_UNGUIDED"));
    pipelineWaitDurationText = Convert.ToString(GetLocalResourceObject("TEXT_PIPELINE_WAIT_DURATION"));
    pipelineProcessingDurationText = Convert.ToString(GetLocalResourceObject("TEXT_PIPELINE_PROCESSING_DURATION"));
    pipelineWaitDurationToolTipText = Convert.ToString(GetLocalResourceObject("TEXT_SECONDS_WAITING_TO_BE_ASSIGNED"));
    pipelineProcessingDurationToolTipText = Convert.ToString(GetLocalResourceObject("TEXT_SECONDS_PROCESSING_IN_PIPELINE"));
    DaysBackText = Convert.ToString(GetLocalResourceObject("TEXT_DAYS_BACK"));
    DateFormatJs = Convert.ToString(GetLocalResourceObject("DATE_FORMAT_JS"));
    TypeM5Text = Convert.ToString(GetLocalResourceObject("TEXT_TYPE_M5"));
    TypeM12Text = Convert.ToString(GetLocalResourceObject("TEXT_TYPE_M12"));
    TypeM19Text = Convert.ToString(GetLocalResourceObject("TEXT_TYPE_M19"));
    TypeM26Text = Convert.ToString(GetLocalResourceObject("TEXT_TYPE_M26"));
    TypeEOMText = Convert.ToString(GetLocalResourceObject("TEXT_TYPE_EOM"));
  }
}
