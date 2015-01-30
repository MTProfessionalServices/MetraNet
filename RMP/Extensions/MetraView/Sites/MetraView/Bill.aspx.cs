using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class Bill : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Session[SiteConstants.ActiveMenu] = "Bill";

    Intervals1.RedirectURL = UI.DictionaryManager["BillPage"].ToString();

    var billManager = new BillManager(UI);
    billManager.SetChargeViewType(PanelCurrentCharges, PanelCurrentChargesByFolder);

    SelectInterval(billManager);

    Interval interval = billManager.GetCurrentInterval();

    if (interval == null)
    {
      panelBill.Visible = false;
      panelNoBillMessage.Visible = true;
      return;
    }

    if(interval.Status != IntervalStatusCode.HardClosed)
    {
      panelEstimate.Visible = true;
    }

    var usageIntervalSlice = new UsageIntervalSlice();
    usageIntervalSlice.UsageInterval = interval.ID;

    billManager.ReportParams.DateRange = usageIntervalSlice;    
    billManager.ReportParams.ReportView = ReportViewType.OnlineBill;    
    billManager.ReportParams.UseSecondPassData = false;

    billManager.ReportParamsLocalized.DateRange = usageIntervalSlice;
    billManager.ReportParamsLocalized.ReportView = ReportViewType.OnlineBill;
    billManager.ReportParamsLocalized.UseSecondPassData = false;
    billManager.GetInvoiceReport(true);
  }

  private void SelectInterval(BillManager billManager)
  {
    if (Request.QueryString[SiteConstants.IntervalQueryString] != null)
    {
      int i;
      if (!int.TryParse(Request.QueryString[SiteConstants.IntervalQueryString], out i))
      {
        Response.Redirect(SiteConfig.Settings.RootUrl + "/Logout.aspx"); // give us bad data an we log you out
      }
      Session[SiteConstants.SelectedIntervalId] = Request.QueryString[SiteConstants.IntervalQueryString];
      Session[SiteConstants.SelectedIntervalinvoice] = Request.QueryString[SiteConstants.InvoiceQueryString];
    }
    else
    {
      if (Session[SiteConstants.SelectedIntervalId] == null)
      {
        var interval = billManager.GetCurrentInterval();
        if (interval != null)
        {
          Session[SiteConstants.SelectedIntervalId] = interval.ID.ToString();
          Session[SiteConstants.SelectedIntervalinvoice] = interval.InvoiceNumber.ToString();
        }
      }
    }
  }

  /// <summary>
  /// Returns the print icon if the interval has an invoice available.
  /// The pdf must have invoice in the name.
  /// </summary>
  /// <returns></returns>
  public string GetPrintIcon()
  {
    var sb = new StringBuilder();
    var billManager = new BillManager(UI);
    int intervalID = billManager.GetCurrentInterval().ID;

    var reports = billManager.GetReports(intervalID);

    if (reports != null && reports.Count > 0)
    {
      if(Session[SiteConstants.REPORT_DICTIONARY] == null)
      {
        Session[SiteConstants.REPORT_DICTIONARY] = new Dictionary<string, ReportFile>();
      }

      var reportDictionary = Session[SiteConstants.REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

      foreach (var reportFile in reports)
      {
        // The reportFile objects are stored in a dictionary and the name is passed to ShowPDF.aspx 
        if (reportDictionary != null)
        {
          if (!reportDictionary.ContainsKey(reportFile.DisplayName + "_" + intervalID.ToString()))
          {
            reportDictionary.Add(reportFile.DisplayName + "_" + intervalID.ToString(), reportFile);
          }
        }
        var reportFormat = Path.GetExtension(reportFile.FileName); 
        // Get report with invoice in the name (yup, that's how it is done for now)
        if (reportFile.FileName.ToLowerInvariant().Contains("invoice") && !String.IsNullOrEmpty(reportFormat) && reportFormat.Equals(".pdf"))
        {
          const string startLoad = "setTimeout(function () { checkFrameLoading(); }, 1000);";
          sb.Append(
            String.Format(
              "<a href=\"{0}/Reports/ShowReports.aspx?report={1}\" onclick=\"{2}\"><img border=\"0\" src=\"/Res/Images/icons/printer.png\" /></a>",
              Request.ApplicationPath,
              Server.UrlEncode(String.Format("{0}_{1}", reportFile.DisplayName, intervalID)),
              startLoad));
          break;
        }
      }
    }
    return sb.ToString();
  }

  /// <summary>
  /// Returns the message that is displayed if no intervals have been hard closed yet.
  /// </summary>
  /// <returns></returns>
  protected string GetNoBillMessage()
  {
    return Resources.Resource.TEXT_NO_BILL;
  }

  protected string GetEstimateMessage()
  {
    return Resources.Resource.TEXT_ESTIMATE;
  }
}
