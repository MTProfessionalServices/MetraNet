using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.UI.WebControls;
using System.Xml.Serialization;
using Core.UI;
using MetraTech;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.COMDBObjects;
using MetraTech.UI.Common;
using MetraTech.UI.Controls.MTLayout;
using MetraTech.UI.Tools;
using ICOMLocaleTranslator = MetraTech.Interop.COMDBObjects.ICOMLocaleTranslator;
using RCD = MetraTech.Interop.RCD;
using MetraTech.Core.Services.ClientProxies;

/// <summary>
/// BillManager - used to load the online bill
/// </summary>
public class BillManager: System.Web.UI.TemplateControl
{
  #region Private member variables
  private static readonly Logger Logger = new Logger("[MetraView_BillManger]");
  private readonly UIManager UI;
  private UsageHistoryService_GetInvoiceReportLocalized_Client invoiceReportClient;
  #endregion

  #region Application Cache Properties

  public Dictionary<LanguageCode, ICOMLocaleTranslator> LocaleTranslators
  {
    get
    {
      if (HttpContext.Current.Application[SiteConstants.LocaleTransator] == null)
      {
        HttpContext.Current.Application[SiteConstants.LocaleTransator] =
          new Dictionary<LanguageCode, ICOMLocaleTranslator>();
      }
      return HttpContext.Current.Application[SiteConstants.LocaleTransator] as Dictionary<LanguageCode, ICOMLocaleTranslator>;
    }
    set { HttpContext.Current.Application[SiteConstants.LocaleTransator] = value; }
  }

  #endregion

  #region Session Cache Properties

  /// <summary>
  /// Cache of Report Parameters
  /// </summary>
  public ReportParameters ReportParams
  {
    get { return HttpContext.Current.Session[SiteConstants.ReportParameters] as ReportParameters; }
    set { HttpContext.Current.Session[SiteConstants.ReportParameters] = value; }
  }

  /// <summary>
  /// Cache of Report Parameters
  /// </summary>
  public ReportParametersLocalize ReportParamsLocalized
  {
    get { return HttpContext.Current.Session[SiteConstants.ReportParamsLocalized] as ReportParametersLocalize; }
    set { HttpContext.Current.Session[SiteConstants.ReportParamsLocalized] = value; }
  }

  /// <summary>
  /// Cache of InvoiceReport
  /// </summary>
  public InvoiceReport InvoiceReport
  {
    get { return HttpContext.Current.Session[SiteConstants.InvoiceReport] as InvoiceReport; }
    set { HttpContext.Current.Session[SiteConstants.InvoiceReport] = value; }
  }

  /// <summary>
  /// Cache of DefaultInvoiceReport
  /// Default will be the last open one. we can take total amount due from it.
  /// </summary>
  public InvoiceReport DefaultInvoiceReport
  {
    get { return HttpContext.Current.Session[SiteConstants.DefaultInvoiceReport] as InvoiceReport; }
    set { HttpContext.Current.Session[SiteConstants.DefaultInvoiceReport] = value; }
  }

  /// <summary>
  /// Cache of intervals
  /// </summary>
  public List<Interval> Intervals
  {
    get { return HttpContext.Current.Session[SiteConstants.Intervals] as List<Interval>; }
    set { HttpContext.Current.Session[SiteConstants.Intervals] = value; }
  }

  /// <summary>
  /// Cache of Payment Info
  /// </summary>
  public PaymentInfo PaymentInformation
  {
    get 
    {
      return GetPaymentInfo(UI.SessionContext.AccountID); 
    }
  }
  #endregion

  #region Constructor - Sets up UIManager reference and default Report Parameters
  /// <summary>
  /// The BillManager is used to interface to the MAS.  It holds onto the UIManager so that it can get subscriber info.
  /// </summary>
  /// <param name="ui"></param>
  public BillManager(UIManager ui)
  {
    UI = ui;

    if (UI.Subscriber.SelectedAccount == null)
      return;

    // Setup default report parameters
    if (ReportParams == null)
    {
      var interval = GetCurrentInterval();

      ReportParams = new ReportParameters
                       {
                         InlineAdjustments = SiteConfig.Settings.BillSetting.InlineAdjustments ?? false,
                         InlineVATTaxes = SiteConfig.Settings.BillSetting.InlineTax ?? false,
                         UseSecondPassData = SiteConfig.Settings.BillSetting.ShowSecondPassData ?? false,
                         Language = GetLanguageCode(),
                         ReportView = ReportViewType.OnlineBill
                       };

      if (interval != null)
      {
        var defaultIntervalSlice = new UsageIntervalSlice {UsageInterval = interval.ID};
        ReportParams.DateRange = defaultIntervalSlice;
      }
    }

    // Setup default report parameters
    if (ReportParamsLocalized == null)
    {
      var interval = GetCurrentInterval();

      ReportParamsLocalized = new ReportParametersLocalize
                       {
                         InlineAdjustments = SiteConfig.Settings.BillSetting.InlineAdjustments ?? false,
                         InlineVATTaxes = SiteConfig.Settings.BillSetting.InlineTax ?? false,
                         UseSecondPassData = SiteConfig.Settings.BillSetting.ShowSecondPassData ?? false,
                         LanguageLocale = Thread.CurrentThread.CurrentUICulture.ToString().ToLower(),
                         ReportView = ReportViewType.OnlineBill
                       };

      if (interval != null)
      {
        var defaultIntervalSlice = new UsageIntervalSlice {UsageInterval = interval.ID};
        ReportParamsLocalized.DateRange = defaultIntervalSlice;
      }
    }
  }
  #endregion

  #region Billing History
  /// <summary>
  /// Returns an accounts billing history
  /// </summary>
  /// <returns></returns>
  public List<Interval> GetBillingHistory()
  {
    var billingHistoryClient = new UsageHistoryService_GetBillingHistory_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
    };
    if (UI.Subscriber.SelectedAccount._AccountID != null)
      billingHistoryClient.In_accountID = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID);
      billingHistoryClient.In_languageID = GetLanguageCode();
    billingHistoryClient.Invoke();
    var returnIntervals = billingHistoryClient.Out_intervals;
    return returnIntervals;
  }
  #endregion

  #region Intervals
  /// <summary>
  /// Returns a list of Intervals for the current selected subscriber
  /// </summary>
  /// <returns></returns>
  public List<Interval> GetIntervals()
  {
    var accountIntervalsClient = new UsageHistoryService_GetAccountIntervals_Client
                                   {
                                     UserName = UI.User.UserName,
                                     Password = UI.User.SessionPassword
                                   };
    if (UI.Subscriber.SelectedAccount._AccountID != null)
      accountIntervalsClient.In_accountID = new AccountIdentifier((int) UI.Subscriber.SelectedAccount._AccountID);
    accountIntervalsClient.Invoke();
    var returnIntervals = accountIntervalsClient.Out_acctIntervals;
    return returnIntervals;
  }

  /// <summary>
  /// Gets the current selected interval
  /// </summary>
  /// <returns></returns>
  public Interval GetCurrentInterval()
  {
    if (HttpContext.Current.Session[SiteConstants.SelectedIntervalId] == null)
    {
      return GetDefaultInterval();
    }

    if (Intervals != null)
    {
      var currentIntervals =
        from currinter in Intervals
        where currinter.ID.ToString(CultureInfo.InvariantCulture) == HttpContext.Current.Session[SiteConstants.SelectedIntervalId].ToString() && currinter.InvoiceNumber == HttpContext.Current.Session[SiteConstants.SelectedIntervalinvoice].ToString()
        select currinter;

      foreach (var itm in currentIntervals)
      {
        HttpContext.Current.Session[SiteConstants.Interval] = itm;
        HttpContext.Current.Session[SiteConstants.SelectedIntervalId] = itm.ID.ToString(CultureInfo.InvariantCulture);
        HttpContext.Current.Session[SiteConstants.SelectedIntervalinvoice] = itm.InvoiceNumber;
        return itm;
      } 
    }
    return null;
  }

  /// <summary>
  /// Gets the first hard closed interval 
  /// </summary>
  /// <returns></returns>
  public Interval GetDefaultInterval()
  {
    if (UI.Subscriber.SelectedAccount == null)
      return null;

    var accountIntervalsClient = new UsageHistoryService_GetAccountIntervals_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword
    };

    if (UI.Subscriber.SelectedAccount._AccountID != null)
      accountIntervalsClient.In_accountID = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID);
    accountIntervalsClient.Invoke();
    var intervals = accountIntervalsClient.Out_acctIntervals;

    if (intervals != null && intervals.Count > 0)
    {
      Intervals = intervals;
      Interval interval;

      if (SiteConfig.Settings.BillSetting.ShowOnlyHardClosedIntervals.GetValueOrDefault(false))
      {
        interval = intervals.FirstOrDefault(v => v.Status == IntervalStatusCode.HardClosed); 
      }
      else
      {
        interval = intervals.FirstOrDefault();
      }

      if (interval != null)
      {
        HttpContext.Current.Session[SiteConstants.Interval] = interval;
        HttpContext.Current.Session[SiteConstants.SelectedIntervalId] = interval.ID.ToString(CultureInfo.InvariantCulture);
        HttpContext.Current.Session[SiteConstants.SelectedIntervalinvoice] = interval.InvoiceNumber;
      }
      return interval; 
    }
    return null;
  }

  /// <summary>
  /// Gets the first open interval for the current selected subscriber
  /// without setting it as current on the ui
  /// </summary>
  /// <returns></returns>
  public Interval GetOpenIntervalWithoutSettingItAsCurrentOnTheUI()
  {
    if (UI.Subscriber.SelectedAccount == null)
      return null;

    var accountIntervalsClient = new UsageHistoryService_GetAccountIntervals_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword
    };

    if (UI.Subscriber.SelectedAccount._AccountID != null)
      accountIntervalsClient.In_accountID = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID);
    accountIntervalsClient.Invoke();
    var intervals = accountIntervalsClient.Out_acctIntervals;

    if (intervals != null && intervals.Count > 0)
    {
      Intervals = intervals;
      var interval = intervals.FirstOrDefault(v => v.Status == IntervalStatusCode.Open);
      return interval;
    }
    return null;
  }
  #endregion

  #region Invoice Report

  /// <summary>
  /// Returns an InvoiceReport for the passed in interval and current selected subscriber
  /// </summary>
  /// <returns></returns>
  public InvoiceReport GetInvoiceReport(bool refreshData)
  {
    if (UI.Subscriber.SelectedAccount == null)
      return null;

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      return null;
    
    var interval = GetCurrentInterval();
    if(interval == null)
    {
      return null;  
    }

    if (refreshData)
    {
      invoiceReportClient = new UsageHistoryService_GetInvoiceReportLocalized_Client
                              {
                                UserName = UI.User.UserName,
                                Password = UI.User.SessionPassword,
                                In_intervalID = interval.ID,
                                In_languageID = Thread.CurrentThread.CurrentUICulture.ToString().ToLower(),
                                In_inlineVATTaxes = ReportParams.InlineVATTaxes,
                                In_owner = new AccountIdentifier((int) UI.Subscriber.SelectedAccount._AccountID)
                              };
      try
      {
        invoiceReportClient.Invoke();
        InvoiceReport = invoiceReportClient.Out_report;
        return InvoiceReport;
      }
      catch (Exception ex)
      {
        Logger.LogException("Exception", ex);
      }
      return null;
    }

    return InvoiceReport;
  }


  /// <summary>
  /// Begin InvoiceReport call for the current interval and current selected subscriber
  /// </summary>
  /// <returns></returns>
  public IAsyncResult GetInvoiceReportBeginAsync(AsyncCallback asyncCallback, object stateObject)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    Interval interval = GetCurrentInterval();
    invoiceReportClient = new UsageHistoryService_GetInvoiceReportLocalized_Client
                              {
                                UserName = UI.User.UserName,
                                Password = UI.User.SessionPassword,
                                In_intervalID = interval.ID,
                                In_languageID = Thread.CurrentThread.CurrentUICulture.ToString().ToLower(),
                                In_inlineVATTaxes = ReportParams.InlineVATTaxes,
                                In_owner = new AccountIdentifier((int) UI.Subscriber.SelectedAccount._AccountID)
                              };

    return invoiceReportClient.BeginInvoke(asyncCallback, stateObject);
  }

  /// <summary>
  /// Returns an InvoiceReport for the passed in interval and current selected subscriber
  /// </summary>
  /// <returns></returns>
  public InvoiceReport GetInvoiceReportEndAsync(IAsyncResult result)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);
    
    if (invoiceReportClient == null)
      throw new UIException("Call begin first.");

    invoiceReportClient.EndInvoke(result);
    InvoiceReport = invoiceReportClient.Out_report;
    return InvoiceReport;
  }

  #endregion

  #region Default Invoice Report
  /// <summary>
  /// Returns an InvoiceReport for the default interval and current selected subscriber
  /// </summary>
  /// <returns></returns>
  public InvoiceReport GetDefaultInvoiceReport(bool refreshData)
  {
    if (UI.Subscriber.SelectedAccount == null)
      return null;

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      return null;

    var interval = GetOpenIntervalWithoutSettingItAsCurrentOnTheUI();

    if (refreshData)
    {
      invoiceReportClient = new UsageHistoryService_GetInvoiceReportLocalized_Client
      {
        UserName = UI.User.UserName,
        Password = UI.User.SessionPassword,
        In_intervalID = interval.ID,
        In_languageID = Thread.CurrentThread.CurrentUICulture.ToString().ToLower(),
        In_inlineVATTaxes = ReportParams.InlineVATTaxes,
        In_owner = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID)
      };
      try
      {
        invoiceReportClient.Invoke();
        DefaultInvoiceReport = invoiceReportClient.Out_report;
        return DefaultInvoiceReport;
      }
      catch (Exception ex)
      {
        Logger.LogException("Exception", ex);
      }
      return null;
    }

    return DefaultInvoiceReport;
  }


  /// <summary>
  /// Begin InvoiceReport call for the current interval and current selected subscriber
  /// </summary>
  /// <returns></returns>
  public IAsyncResult GetDefaultInvoiceReportBeginAsync(AsyncCallback asyncCallback, object stateObject)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    Interval interval = GetOpenIntervalWithoutSettingItAsCurrentOnTheUI();

    invoiceReportClient = new UsageHistoryService_GetInvoiceReportLocalized_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_intervalID = interval.ID,
      In_languageID = Thread.CurrentThread.CurrentUICulture.ToString().ToLower(),
      In_inlineVATTaxes = ReportParams.InlineVATTaxes,
      In_owner = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID)
    };
    return invoiceReportClient.BeginInvoke(asyncCallback, stateObject);
  }

  /// <summary>
  /// Returns an InvoiceReport for the passed in interval and current selected subscriber
  /// </summary>
  /// <returns></returns>
  public InvoiceReport GetDefaultInvoiceReportEndAsync(IAsyncResult result)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (invoiceReportClient == null)
      throw new UIException("Call begin first.");

    invoiceReportClient.EndInvoke(result);
    DefaultInvoiceReport = invoiceReportClient.Out_report;
    return DefaultInvoiceReport;
  }
  #endregion

  #region Usage Details 
  /// <summary>
  /// Returns usage details for an account and product slice
  /// </summary>
  /// <returns></returns>
  public MTList<BaseProductView> GetUsageDetails(AccountSlice accountSlice, SingleProductSlice productSlice, MTList<BaseProductView> details)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if(ReportParams == null)
      throw new UIException("Invalid report parameters.");

    if (accountSlice == null)
      throw new UIException("Invalid account slice.");

    if (productSlice == null)
      throw new UIException("Invalid product slice.");
    
    var usageDetailsClient = new UsageHistoryService_GetUsageDetailsLocalized_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_accountSlice = accountSlice,
      In_productSlice = productSlice,
      In_repParams = ReportParamsLocalized,
      InOut_usageDetails = details,
    };
    
    usageDetailsClient.Invoke();

    //ESR-5461
    string accounttimezone = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).TimezoneIDValueDisplayName;
    String timeZoneId = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).TimezoneID.ToString();
    TimeZoneID? accounttimezoneID = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).TimezoneID;
    // Get list of TimeZones with Ids
    List<TimeZoneHelper> TimeZoneList = TimeZoneHelper.GetTimeZoneHelpers();
    //Iterate through usagedetails items
    foreach (BaseProductView bpv in usageDetailsClient.InOut_usageDetails.Items)
    {
      //string columnName
       foreach (System.Reflection.PropertyInfo prop in bpv.GetType().GetProperties())
       {
         object[] attribs = prop.GetCustomAttributes(typeof(MTProductViewMetadataAttribute), false);
         if (attribs.Length > 0 )
         {
           var pvattrib = (MTProductViewMetadataAttribute)attribs[0];
            if (pvattrib.UserVisible)
            {
              //check if pvattrib type is timestamp then convert to LocalTimeZone
              if (Convert.ToString(pvattrib.DataType) == "timestamp")
              {
                try 
                { 
                  //get current account UTC local timezone
                  var currenTimezone = TimeZoneList.FirstOrDefault(timezone => timezone.DisplayName == accounttimezoneID.ToString());
                  if (currenTimezone != null)
                  {
                    //TimeZoneInfo targetTimezoneinfo = TimeZoneInfo.FindSystemTimeZoneById(currenTimezone.Id);
                    //Convert to UTC (GMT) Time  
                    var currentDate = Convert.ToDateTime(bpv.GetValue(pvattrib.ColumnName));  //.ToUniversalTime();
                    prop.SetValue(bpv, this.GetLocalTime(currenTimezone.Id, currentDate),null);
                  // Converted UTC Time 
                   }
                  else
                  {
                    Logger.LogInfo("Specified Timezone " + accounttimezone + "not found");
                  }
                }
                catch (Exception ex)
                {
                  Logger.LogError("There is an issue with TimeZone Conversion ", ex.Message);
                }
              }
            }
         }
       }
    }
    return usageDetailsClient.InOut_usageDetails;
  }

  public DateTime GetLocalTime(String TimeZoneNameId, DateTime date)
  {
    DateTime utcTime = new DateTime(date.Year, date.Month, date.Day, date.Hour, date.Minute, date.Second, DateTimeKind.Utc);
    // Get the venue time zone info
    TimeZoneInfo tz = TimeZoneInfo.FindSystemTimeZoneById(TimeZoneNameId);
    TimeSpan timeDiffUtcClient = tz.BaseUtcOffset;
    DateTime localDate = TimeZoneInfo.ConvertTimeFromUtc(date, tz);

    /* if (tz.SupportsDaylightSavingTime && tz.IsDaylightSavingTime(localDate))
      {
        TimeZoneInfo.AdjustmentRule[] rules = tz.GetAdjustmentRules();
        foreach (var adjustmentRule in rules)
        {
          if (adjustmentRule.DateStart <= localDate && adjustmentRule.DateEnd >= localDate)
          {
            double dayLtDelta = adjustmentRule.DaylightDelta.Hours;
            localDate = localDate.AddHours(dayLtDelta);
          }
        }
      }
      else
      {
        DateTimeOffset utcDate = localDate.ToUniversalTime();
      }*/
    return localDate;
  }

  /// <summary>
  /// CORE-7967 -- Returns Time Zone ID based on the TimeZone ENUM list. 
  /// </summary>
  /// <param name="timeZoneList"></param>
  /// <param name="timeZoneId"></param>
  /// <returns>timezoneDisplayName</returns>
  public String ConvertTimeZoneId(List<TimeZoneList> timeZoneList, String timeZoneId)
  {
    String timezoneDisplayName = Convert.ToString(timeZoneId);
    String ThreeUndrScr = "___";
    String TwoUndrScr = "__";
    String OneUndrScr = "_";
    String[] separator = { " " };
    bool bFndIt = false;

    timezoneDisplayName = timezoneDisplayName.Replace(ThreeUndrScr, " ");
    timezoneDisplayName = timezoneDisplayName.Replace(TwoUndrScr, " ");
    timezoneDisplayName = timezoneDisplayName.Replace(OneUndrScr, " ").Trim();
    String[] timezoneVals = timezoneDisplayName.Split(separator, StringSplitOptions.RemoveEmptyEntries);
    for (int i = 0; i < timeZoneList.Count; i++)
    {
      int j1 = 0;
      int j2 = 0;
      foreach (String str in timezoneVals)
      {
        int loc = timeZoneList[i].DisplayName.IndexOf(str);
        if (loc == -1)
        {
          j1++;
          bFndIt = false;
          int result;
          if ((j1 == 3) || (Int32.TryParse(str, out result)))
          {
            break;
          }
        }
        else
        {
          j2++;
          if (j2 == 4)
          {
            bFndIt = true;
            break;
          }
        }
      }

      if (bFndIt)
      {
        timezoneDisplayName = Convert.ToString(timeZoneList[i].DisplayName);
        break;
      }
    }
    return timezoneDisplayName;
  }

  /// <summary>
  /// Returns fully qualified name 
  /// </summary>
  public string GetFQN(int id_view)
  {
      string nm_name = "";
      var usageDetailsClient = new UsageHistoryService_GetFullyQualifiedName_Client
      {
          UserName = UI.User.UserName,
          Password = UI.User.SessionPassword,
          In_id_view =  id_view,
          Out_nm_name = nm_name
      };
         usageDetailsClient.Invoke();

      return usageDetailsClient.Out_nm_name;
  }

  /// <summary>
  /// Returns usage summaries for compound children 
  /// </summary>
  /// <param name="accountSlice"></param>
  /// <param name="parentSessionId"></param>
  /// <returns></returns>
  public List<ChildUsageSummary> GetCompoundUsageSummaries(AccountSlice accountSlice, string parentSessionId)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (ReportParams == null)
      throw new UIException("Invalid report parameters.");

    if (accountSlice == null)
      throw new UIException("Invalid account slice.");

    if (parentSessionId == null)
      throw new UIException("Invalid parent session ID.");

    var compoundUsageSummariesClient = new UsageHistoryService_GetCompoundChildUsageSummaries_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_accountSlice = accountSlice,
      In_repParams = ReportParams
    };

    Int64 parentSessionIDValue = -1;
    if (!(Int64.TryParse(parentSessionId, out parentSessionIDValue)))
    {
      throw new UIException(String.Format("ParentSessionId value {0} is invalid", parentSessionId));
    }
    compoundUsageSummariesClient.In_parentSessionID = parentSessionIDValue;
    
    compoundUsageSummariesClient.Invoke();
    return compoundUsageSummariesClient.Out_childUsageSummaries;
  }

  /// <summary>
  /// Get Adjustment Details
  /// </summary>
  /// <param name="accountSlice"></param>
  /// <param name="isPostBill"></param>
  /// <param name="adjDetails"></param>
  /// <returns></returns>
  public MTList<BaseAdjustmentDetail> GetAdjustmentDetails(AccountSlice accountSlice, bool isPostBill, MTList<BaseAdjustmentDetail> adjDetails)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (ReportParams == null)
      throw new UIException("Invalid report parameters.");

    if (accountSlice == null)
      throw new UIException("Invalid account slice.");

    var adjustmentDetailsClient = new UsageHistoryService_GetBaseAdjustmentDetails_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_accountSlice = accountSlice,
      In_isPostbill = isPostBill,
      In_languageId  = GetLanguageCode(),
      In_timeSlice = ReportParams.DateRange,
      InOut_adjustmentDetails = adjDetails
    };

    adjustmentDetailsClient.Invoke();
    return adjustmentDetailsClient.InOut_adjustmentDetails;
  }

  /// <summary>
  /// Returns a Product View domain model object instance by PV name
  /// </summary>
  /// <param name="name"></param>
  /// <returns></returns>
  public object GetProductViewObjectByName(string name)
  {
    // This is the same naming algorithm the code generator uses
    string typename = String.Format("MetraTech.DomainModel.ProductView.{0}ProductView", StringUtils.MakeAlphaNumeric(name.Trim()));
    Type viewType = Type.GetType(String.Format("{0}, MetraTech.DomainModel.Billing.Generated", typename), true, true);
    var o = Activator.CreateInstance(viewType);
    return o;
  }

  /// <summary>
  /// Init Product View Layout Cache
  /// </summary>
  public static void InitPvLayouts()
  {
    if (HttpContext.Current.Application["ProductViewLayouts"] == null)
    {
      var productViewLayouts = new Dictionary<string, GridLayout>();
      RCD.IMTRcd rcd = new RCD.MTRcd();
      RCD.IMTRcdFileList fileList = rcd.RunQuery(@"config\ProductViewLayouts\*.xml", true);
      

      GridLayout gridLayout;
      foreach (string fileName in fileList)
      {
        try
        {
          gridLayout = LoadGridLayout(fileName);
          productViewLayouts.Add(fileName.ToLower(), gridLayout);
        }
        catch (Exception exp)
        {
          Logger.LogInfo(string.Format("Error loading Product View Layout {0}", fileName), exp);
        }
      }

      // Load default product view layout
      string appFolder = HttpRuntime.AppDomainAppVirtualPath;
      string appPath = HttpContext.Current.Server.MapPath(appFolder);
      var defaultFile = Path.Combine(appPath, "Config\\DefaultProductViewLayout.xml");
      gridLayout = LoadGridLayout(defaultFile);
      productViewLayouts.Add(defaultFile.ToLower(), gridLayout);

      HttpContext.Current.Application["ProductViewLayouts"] = productViewLayouts;
    }
  }

  /// <summary>
  /// Get ProductView template file based on viewName
  /// </summary>
  /// <param name="pvName"></param>
  /// <returns></returns> 
  public string GetProductViewLayout(string pvName)
  {
    if (HttpContext.Current.Application["ProductViewLayouts"] == null)
    {
      InitPvLayouts();
    }

    var productViewLayouts = HttpContext.Current.Application["ProductViewLayouts"] as Dictionary<string, GridLayout>;
    
    // Step 1:  Look in ProductViewMapping Entity for a match, if found use that.
    if(SiteConfig.Settings.ProductViewMappings != null  && SiteConfig.Settings.ProductViewMappings.Count > 0)
    {
      foreach (var map in
        SiteConfig.Settings.ProductViewMappings.Where(map => ((ProductViewMapping)map).ProductViewMappingBusinessKey.ProductViewName.ToLower() == pvName.ToLower()))
      {
        if (!String.IsNullOrEmpty(map.CustomPage))
        {
          HttpContext.Current.Response.Redirect(String.Format("{0}?accountSlice={1}&productSlice={2}&parentSessionID={3}",
                                                              map.CustomPage,
                                                              HttpContext.Current.Request["accountSlice"],
                                                              HttpContext.Current.Request["productSlice"],
                                                              HttpContext.Current.Request["parentSessionID"]), false);
        }

        if (!String.IsNullOrEmpty((map.CustomLayout)))
        {
          return map.CustomLayout;
        }
      }
    }

    // Step 2:  If no custom mapping is found, match view to one that is loaded.
    if (productViewLayouts != null)
    {
      string pvLayoutName = (from pair in productViewLayouts 
                             where pair.Value.Name.ToLower() == pvName.ToLower() 
                             select pair.Key).FirstOrDefault();
      if (pvLayoutName != null)
        return pvLayoutName;
    }

    // Step 3:  If no custom mapping is found use config/DefaultProductViewLayout.xml.
    return (from pair in productViewLayouts
            where pair.Value.Name.ToLower() == "[default]"
            select pair.Key).FirstOrDefault();

    // Generic rendering is done by reflecting over the PV object and adding elements to the 
    // grid on the fly in the details.aspx.cs page.
  }

  /// <summary>
  /// Load Grid Layout
  /// </summary>
  /// <param name="layoutFile"></param>
  /// <returns></returns>
  public static GridLayout LoadGridLayout(string layoutFile)
  {
    GridLayout gl = null;

    if (String.IsNullOrEmpty(layoutFile))
    {
      return gl;
    }

    if (!File.Exists(layoutFile))
    {
      return gl;
    }

    using (FileStream fileStream = File.Open(layoutFile, FileMode.Open, FileAccess.Read, FileShare.Read))
    {
      var s = new XmlSerializer(typeof(GridLayout));
      gl = (GridLayout)s.Deserialize(fileStream);
    }

    return gl;
  }
  #endregion

  #region Language Codes
  /// <summary>
  /// Get MetraNet language code for the current thread culture
  /// </summary>
  /// <returns></returns>
  public LanguageCode GetLanguageCode()
  {
    try
    {
      if (Thread.CurrentThread.CurrentUICulture.ToString().ToLower() == "ja-jp")
      {
        return LanguageCode.JP;
      }
      if (Thread.CurrentThread.CurrentUICulture.ToString().ToLower() == "it-it")
      {
        return LanguageCode.IT;
      }
      return (LanguageCode)CommonEnumHelper.GetEnumByValue(typeof(LanguageCode), Thread.CurrentThread.CurrentUICulture.ToString());
    }
    catch (Exception)
    {
      Logger.LogWarning("using default language code");
      return LanguageCode.US;
    }
  }

   /// <summary>
  /// Keep a cache of locale translators
  /// </summary>
  /// <param name="languageId"></param>
  /// <returns></returns>
  public ICOMLocaleTranslator GetLocaleTranslator(LanguageCode languageId)
  {
    HttpContext.Current.Application.Lock();

    ICOMLocaleTranslator translator;
    if (!LocaleTranslators.TryGetValue(languageId, out translator))
    {
      translator = new COMLocaleTranslator();
      translator.Init(Enum.GetName(typeof (LanguageCode), languageId));
      LocaleTranslators.Add(languageId, translator);
    }

    HttpContext.Current.Application.UnLock();
    return translator;
  }
  #endregion

  #region Get PDF Reports
  /// <summary>
  /// Get a list of ReprotFiles for the passed in interval id - for the current account
  /// </summary>
  /// <param name="intervalId"></param>
  /// <returns></returns>
  public List<ReportFile> GetReports(int intervalId)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    var getReportsListClient = new StaticReportsService_GetReportsList_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_accountId = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID),
      In_intervalId = intervalId
    };
    try
    {
      getReportsListClient.Invoke();
      return getReportsListClient.Out_reportFiles;
    }
    catch (System.ServiceModel.EndpointNotFoundException Ex)
    {
      Logger.LogWarning("Unable to get PDF reports. Not able to connect to reporting service. Was reporting extension installed?");
      Logger.LogWarning("error message was: {0}", Ex.Message);
      return null;
    }
    catch (Exception exp)
    {
      Logger.LogException("Error getting PDF reports", exp);
      return null;  // possibly no report server
    }
  }

  /// <summary>
  /// Get a list of ReprotFiles for the quotes for the current account
  /// </summary>  
  /// <returns></returns>
  public List<ReportFile> GetQuoteReports()
  {
      return GetReports(-1);
  }
  #endregion

  #region  GetCreditNotes
  public List<ReportFile> GetCreditNotesReports()
  {
    return GetReports(-2);
  }

  #endregion

  #region Payment Info - Last Payment and Next Payment Amount and Due Date
  public PaymentInfo GetPaymentInfo(int accID)
  {
    UsageHistoryServiceClient client = null;
    try
    {
      client = new UsageHistoryServiceClient();
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      PaymentInfo paymentInfo = new PaymentInfo();
      AccountIdentifier identifier = new AccountIdentifier(accID);
      var language = Thread.CurrentThread.CurrentUICulture.ToString().ToLower();
      client.GetPaymentInfoLocalized(identifier, language, ref paymentInfo);

      return paymentInfo;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to retrieve payment information", ex);
    }
  }
  #endregion

  ////////////////////////////////////////////////////////////////////////////
  // By-Product Report Rendering
  ////////////////////////////////////////////////////////////////////////////
  #region By-Product Report Rendering

  /// <summary>
  /// Get By Product Report
  /// </summary>
  /// <returns></returns>
  public ReportLevel GetByProductReport()
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    var reportLevelClient = new UsageHistoryService_GetByProductReportLocalized_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_owner = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID),
      In_repParams = ReportParamsLocalized
    };
    try
    {
      reportLevelClient.Invoke();
    }
    catch (Exception ex)
    {
      Logger.LogException("GetByProductReport", ex);
    }
    return reportLevelClient.Out_reportData;
  }

  /// <summary>
  /// Render a full ReportLevel
  /// </summary>
  /// <param name="level"></param>
  /// <param name="isByProduct"></param>
  /// <param name="indent"></param>
  /// <param name="sb"></param>
  public void RenderReportLevel(ReportLevel level, bool isByProduct, int indent, ref StringBuilder sb)
  {
    if ((string) HttpContext.Current.Session[SiteConstants.View] == "details")
    {
      string uniqueId = null;
      var payerAndPayee = level.FolderSlice as PayerAndPayeeSlice;
      if (payerAndPayee != null)
      {
        uniqueId = string.Format("{0}_{1}", payerAndPayee.PayeeAccountId.AccountID, Guid.NewGuid());
      }
      else
      {
        var payee = level.FolderSlice as PayeeAccountSlice;
        if (payee != null)
        {
          uniqueId = string.Format("{0}_{1}", payee.PayeeID.AccountID, Guid.NewGuid());
        }
      }

      // check if there are charges
      if (level.ProductOfferings == null && level.Charges == null && String.IsNullOrEmpty(level.Name))
      {
        sb.Append("<tr>");
        sb.Append(String.Format("<td colspan \"2\" style=\"padding-left:{0}px;\">{1}</td>",
                                indent*10,
                                Resources.Resource.TEXT_NO_TRANSACTIONS_FOUND));
        sb.Append("</tr>");
        return;
      }

      sb.Append("<tr>");
      sb.Append(
        String.Format(
          "<td style=\"padding-left:{0}px;\"><img id=\"img{1}\" border=\"0\" src=\"images/bullet-gray.gif\" /><a style=\"text-decoration:none;cursor:pointer;\" ext:accId=\"{1}\" ext:accEffDate=\"{4}\" ext:position=\"closed\" ext:indent=\"{2}\" ext:currency=\"{5}\">{3}</a></td>",
          indent*10,
          uniqueId,
          indent,
          // SECENG: CORE-4791 CLONE - MSOL BSS 31927 Online Bill - Stored XSS through the individual or tenant name associated with syndication orders (ESR for 31444)
          // Added HTML enecoding
          Utils.EncodeForHtml(level.Name),
          SliceConverter.ToString(level.AccountEffectiveDate),
          level.Currency));

      sb.Append(String.Format("<td class=\"{0}\">{1}</td>",
                              GetAmountStyle(indent, isByProduct),
                              level.DisplayAmountAsString));

      sb.Append("</tr>");
      // this is the placeholder for dynamic content to be loaded
      sb.Append(String.Format("<tr><td colspan=\"2\"><div id=\"{0}\"></div></td></tr>", uniqueId));
      indent++;
    }

    if (isByProduct)
      sb = RenderReportLevelCharges(level, true, indent, ref sb);
  }

  /// <summary>
  /// Render ReportLevel charges
  /// </summary>
  /// <param name="level"></param>
  /// <param name="isByProduct"></param>
  /// <param name="indent"></param>
  /// <param name="sb"></param>
  /// <returns></returns>
  public StringBuilder RenderReportLevelCharges(ReportLevel level, bool isByProduct, int indent, ref StringBuilder sb)
  {
    int resetIndent = indent;

    if (level.ProductOfferings == null && level.Charges == null)
    {
      if ((string)HttpContext.Current.Session[SiteConstants.View] == "summary")
      {
        sb.Append("<tr>");
        sb.Append(String.Format("<td colspan \"2\" style=\"padding-left:{0}px;\">{1}</td>", indent * 10,
                                Resources.Resource.TEXT_NO_TRANSACTIONS_FOUND)); 
        sb.Append("</tr>");
      }
    }

    if (level.ProductOfferings != null && level.ProductOfferings.Count > 0)
    {
      foreach (var reportProductOffering in level.ProductOfferings)
      {
        sb.Append("<tr>");
        // SECENG: CORE-4772 CLONE - MSOL BSS 27144 Online Bill - Stored XSS allowed in the priceable item name (post-pb)
        // Added HTML encoding
        sb.Append(String.Format("<td style=\"padding-left:{0}px;\">{1}</td>", indent*10,
                                Utils.EncodeForHtml(reportProductOffering.Name)));
        sb.Append(String.Format("<td class=\"{0}\">{1}</td>",
          GetAmountStyle(indent, isByProduct), 
          reportProductOffering.AmountAsString));
        sb.Append("</tr>");

        if (reportProductOffering.Charges != null && reportProductOffering.Charges.Count > 0)
        {
          RenderSubCharges(level, reportProductOffering.Charges, isByProduct, ++indent, ref sb);
        }
        indent = resetIndent;
      }
    }
    
    indent = resetIndent;
    if (level.FolderSlice != null)
    {
      string accountSlice = SliceConverter.ToString(level.FolderSlice);

      if (level.Charges != null && level.Charges.Count > 0)
      {
        foreach (var charge in level.Charges)
        {
          string productSlice = SliceConverter.ToString(charge.ProductSlice);
          sb.Append("<tr>");
          
          sb.Append(String.Format("<td style=\"padding-left:{0}px;\"><a href=\"Product/Details.aspx?productSlice={2}&accountSlice={3}\">{1}</a></td>",
                                   indent * 20,
                                   charge.DisplayName,
                                   productSlice,
                                   accountSlice));

          sb.Append(String.Format("<td class=\"{0}\">{1}</td>",
            GetAmountStyle(indent, isByProduct),
            charge.DisplayAmountAsString));

          sb.Append("</tr>");

          if (charge.SubCharges != null && charge.SubCharges.Count > 0)
          {
            RenderSubCharges(level, charge.SubCharges, isByProduct, ++indent, ref sb);
          }
        }
      }
    }
    return sb;
  }



  /// <summary>
  /// Returns style class for an amount
  /// </summary>
  /// <param name="indent"></param>
  /// <param name="isByProduct"></param>
  /// <returns></returns>
  public string GetAmountStyle(int indent, bool isByProduct)
  {
    string style;
    if(isByProduct)
    {
      style = "amount"; 
    }
    else
    {
      if(indent == 0)
      {
        style = "amountfolder"; 
      }
      else
      {
        style = "secondaryamount"; 
      }
    }
    return style;
  }

  /// <summary>
  /// Render sub charges
  /// </summary>
  /// <param name="level"></param>
  /// <param name="subCharges"></param>
  /// <param name="isByProduct"></param>
  /// <param name="indent"></param>
  /// <param name="sb"></param>
  public void RenderSubCharges(ReportLevel level, List<ReportCharge> subCharges, bool isByProduct, int indent, ref StringBuilder sb)
  {
    int resetIndent = indent;
    string accountSlice = SliceConverter.ToString(level.FolderSlice);

    foreach (var charge in subCharges)
    {
      string productSlice = SliceConverter.ToString(charge.ProductSlice);

      sb.Append("<tr>");
      sb.Append(String.Format("<td style=\"padding-left:{0}px;\"><a href=\"Product/Details.aspx?productSlice={2}&accountSlice={3}\">{1}</a></td>", 
        indent * 10,
        Utils.EncodeForHtml(charge.DisplayName),
        productSlice,
        accountSlice));
      sb.Append(String.Format("<td class=\"{0}\">{1}</td>",
        GetAmountStyle(indent, isByProduct),   
        charge.DisplayAmountAsString));
      sb.Append("</tr>");

      if (charge.SubCharges != null && charge.SubCharges.Count > 0)
      {
        RenderSubCharges(level, charge.SubCharges, isByProduct, ++indent, ref sb);
        indent = resetIndent + 1;
      }
    }
  }

  #endregion

  ////////////////////////////////////////////////////////////////////////////
  // By-Folder Report Rendering
  ////////////////////////////////////////////////////////////////////////////
  #region By-Folder Report Rendering

  /// <summary>
  /// Get By Folder Report
  /// </summary>
  /// <returns></returns>
  public ReportLevel GetByFolderReport(int? folderId, DateRangeSlice accountEffectiveDate, string currency = null)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    AccountIdentifier acc = null;
    if(folderId != null)
    {
      acc = new AccountIdentifier(folderId.Value);
    }

    var reportLevelClient = new UsageHistoryService_GetByFolderReportLevel2Localized_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_owner = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID),
      In_accountEffectiveDate = accountEffectiveDate,
      In_repParams = ReportParamsLocalized,
      In_folder = acc, 
      In_currency = currency
    };

    try
    {
      reportLevelClient.Invoke();
      return reportLevelClient.Out_reportData;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
    }
    return null;
  }

  /// <summary>
  /// Get By Folder Report
  /// </summary>
  /// <returns></returns>
  public MTList<ReportLevel> GetByFolderChildrenReport(int? folderId, DateRangeSlice accountEffectiveDate, int currentPage, int pageSize, MTList<ReportLevel> children)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    children.CurrentPage = currentPage;
    children.PageSize = pageSize;

    var reportLevelClient = new UsageHistoryService_GetByFolderReportLevelChildren2_Client
    {
      UserName = UI.User.UserName,
      Password = UI.User.SessionPassword,
      In_owner = new AccountIdentifier((int)UI.Subscriber.SelectedAccount._AccountID),
      In_accountEffectiveDate = accountEffectiveDate,
      In_repParams = ReportParams,
      In_folder = folderId == null ? null : new AccountIdentifier((int) folderId),
      InOut_children = children
    };
    try
    {
      reportLevelClient.Invoke();
      children = reportLevelClient.InOut_children;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);

    }

    return children;
  }
  #endregion

  #region SetChargeViewType for UI

  /// <summary>
  /// Sets up the charge type for the UI
  /// by-product = summary
  /// by-folder = details
  /// </summary>
  /// <param name="panelCurrentCharges"></param>
  /// <param name="panelCurrentChargesByFolder"></param>
  public void SetChargeViewType(Panel panelCurrentCharges, Panel panelCurrentChargesByFolder)
  {
    if (HttpContext.Current.Request.QueryString[SiteConstants.View] != null)
    {

      if (HttpContext.Current.Request.QueryString[SiteConstants.View] == "details")
      {
        panelCurrentCharges.Visible = false;
        panelCurrentChargesByFolder.Visible = true;
        HttpContext.Current.Session[SiteConstants.View] = "details";
      }
      else
      {
        panelCurrentCharges.Visible = true;
        panelCurrentChargesByFolder.Visible = false;
        HttpContext.Current.Session[SiteConstants.View] = "summary";
      }
    }
    else
    {
      if (HttpContext.Current.Session[SiteConstants.View] == null)
      {
        HttpContext.Current.Session[SiteConstants.View] = "summary";
      }
      else
      {
        if (HttpContext.Current.Session[SiteConstants.View].ToString() == "details")
        {
          panelCurrentCharges.Visible = false;
          panelCurrentChargesByFolder.Visible = true;
          HttpContext.Current.Session[SiteConstants.View] = "details";
        }
        else
        {
          panelCurrentCharges.Visible = true;
          panelCurrentChargesByFolder.Visible = false;
          HttpContext.Current.Session[SiteConstants.View] = "summary";
        }
      }
    }
  }
  #endregion

  #region subscriptions
  public MTList<Subscription> GetSubscriptions(MTList<Subscription> subList)
  {
    SubscriptionServiceClient client = null;

    try
    {

      client = new SubscriptionServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        client.GetSubscriptionsByLanguageCode(acct, Convert.ToInt32(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)), ref subList);
      }

      client.Close();
      client = null;
      return subList;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to get list of subscriptions", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }

  public MTList<ProductOffering> GetEligiblePOsForSubscriptions(MTList<ProductOffering> poList)
  {
    SubscriptionServiceClient client = null;
     
    try
    {

      client = new SubscriptionServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        client.GetEligiblePOsForSubscriptionMetraView(acct, MetraTime.Now, false, Convert.ToInt32(EnumHelper.GetValueByEnum(GetLanguageCode(), 1)), ref poList);
      }

      client.Close();
      client = null;
     
      return poList;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to get list of eligible product offerings", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }


  public Subscription AddSubscription(Subscription sub)
  {
    SubscriptionServiceClient client = null;

    try
    {

      client = new SubscriptionServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      if (UI.Subscriber.SelectedAccount._AccountID != null)
      {
        var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        client.AddSubscription(acct, ref sub);
      }

      client.Close();
      client = null;
      return sub;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to add subscription", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }

  public List<UDRCInstance> GetUDRCInstancesForPO(int productOfferingId)
  {
    SubscriptionServiceClient client = null;

    try
    {

      client = new SubscriptionServiceClient();

      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

      List<UDRCInstance> udrcInstances;
      client.GetUDRCInstancesForPO(productOfferingId, out udrcInstances);

      client.Close();
      client = null;
      return udrcInstances;
    }
    catch (Exception ex)
    {
      Logger.LogError(ex.Message);
      throw new Exception("Unable to add subscription", ex);
    }
    finally
    {
      if (client != null)
      {
        client.Abort();
      }
    }
  }
  #endregion

}

