using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Billing;
using System.Text;

public partial class Mobile_PDFLink : MTPage
{
 protected void Page_Load(object sender, EventArgs e)
  {
    var billManager = new BillManager(UI);
    Interval interval = billManager.GetCurrentInterval();

    var usageIntervalSlice = new UsageIntervalSlice();
    usageIntervalSlice.UsageInterval = interval.ID;
    billManager.ReportParams.DateRange = usageIntervalSlice;
    billManager.ReportParams.ReportView = ReportViewType.OnlineBill;
    billManager.ReportParams.UseSecondPassData = true;  // only show second pass data on bill
    billManager.GetInvoiceReport(true);
  }

  /// <summary>
  /// Returns the pdf link if the interval has an invoice available.
  /// The pdf must have invoice in the name.
  /// </summary>
  /// <returns></returns>
 public string GetPdfLink()
  {
    var sb = new StringBuilder();
    var billManager = new BillManager(UI);
    int intervalID = billManager.GetCurrentInterval().ID;

    // out of box way 
    // var reports = billManager.GetPDFReports(intervalID);
   
    // baas way
    var reports = new List<ReportFile>();
    ReportFile newReportFile = new ReportFile();
    newReportFile.DisplayName = "Your Invoice";
    newReportFile.FileName = "Invoice.html";
    reports.Add(newReportFile);


    if (reports != null && reports.Count > 0)
    {
      if (Session[SiteConstants.REPORT_DICTIONARY] == null)
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

        // Grab the pdf with invoice in the name (yup, that's how it is done for now)
        if (reportFile.FileName.ToLowerInvariant().Contains("invoice"))
        {
          sb.Append(
            String.Format(
              "/ShowPDF.aspx?pdf={0}",
              Server.UrlEncode(reportFile.DisplayName + "_" + intervalID.ToString())));
          break;
        }
      }
    }
    return sb.ToString();
  }

}
