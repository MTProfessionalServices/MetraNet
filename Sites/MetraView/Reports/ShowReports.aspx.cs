using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;

public partial class Reports_ShowReports : MTPage
{
  enum ReportTypes { Invoice, Quote, CreditNote };

  private ReportTypes reportType;
  protected void Page_Load(object sender, EventArgs e)
  {
    ShowReport();
  }
  //
  //Open selected report in appropriate application
  //
  private void ShowReport()
  {
    if (UI.Subscriber.SelectedAccount == null)
    {
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);
    }

    if (UI.Subscriber.SelectedAccount._AccountID == null)
    {
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);
    }

    if(!string.IsNullOrEmpty(Request.QueryString["reportType"]))
    {
      string rt = Request.QueryString["reportType"].ToLower();
      switch (rt)
      {
        case "quote" :
          reportType = ReportTypes.Quote;
          break;
        case "creditnote":
          reportType = ReportTypes.CreditNote;
          break;
        case "invoice":
          reportType = ReportTypes.Invoice;
          break;
        default:
          reportType = ReportTypes.Invoice;
          break;
      }
    }
    switch (reportType)
    {
      case ReportTypes.Quote :
             {
          if (Session[SiteConstants.QUOTE_REPORT_DICTIONARY] != null
               && !string.IsNullOrEmpty(Request.QueryString["report"]))
          {

              var reportName = Request.QueryString["report"];
              var reportDictionary = Session[SiteConstants.QUOTE_REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

              if (reportDictionary != null)
              {
                  var reportFile = reportDictionary[reportName];

                  if (reportFile != null)
                  {
                      var billManager = new BillManager(UI);
                      Interval currentInterval = billManager.GetCurrentInterval();

                      ReportStream(reportFile, currentInterval, ReportTypes.Quote);
                  }
              }
          }
      }
        break;
      case ReportTypes.Invoice:
        if (Session[SiteConstants.REPORT_DICTIONARY] != null
               && !string.IsNullOrEmpty(Request.QueryString["report"]))
        {

          var reportName = Request.QueryString["report"];
          var reportDictionary = Session[SiteConstants.REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

          if (reportDictionary != null)
          {
              var reportFile = reportDictionary[reportName];

              if (reportFile != null)
              {
                  var billManager = new BillManager(UI);
                  Interval currentInterval = billManager.GetCurrentInterval();

                  ReportStream(reportFile, currentInterval, ReportTypes.Invoice);
              }
          }
        }
        break;
        case ReportTypes.CreditNote:
        if (Session[SiteConstants.CREDIT_NOTES_REPORT_DICTIONARY] != null
               && !string.IsNullOrEmpty(Request.QueryString["report"]))
        {
          var reportName = Request.QueryString["report"];
          var reportDictionary = Session[SiteConstants.CREDIT_NOTES_REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

          if (reportDictionary != null)
          {
              var reportFile = reportDictionary[reportName];

              if (reportFile != null)
              {
                  var billManager = new BillManager(UI);
                  Interval currentInterval = billManager.GetCurrentInterval();

                  ReportStream(reportFile, currentInterval, ReportTypes.CreditNote);
              }
          }
      }
        break;
    }

  }



  //
  //Get stream of selected report from StaticReportService
  //
  private void ReportStream(ReportFile reportFile, Interval currentInterval, ReportTypes rt)
  {
    var client = new StaticReportsServiceClient("NetTcpBinding_IMetraTech.Core.Services.StaticReportsService");

    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    
    Stream stream = null;

    try
    {
      if (UI.Subscriber.SelectedAccount._AccountID.HasValue)
      {
        //For Crystal report service
        switch (rt)
        {
          case ReportTypes.Quote:
            client.GetReportFile(new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value), -1, reportFile.FileName, out stream);
            break;
          case ReportTypes.Invoice:
            client.GetReportFile(new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value), currentInterval.ID, reportFile.FileName, out stream);
            break;
          case ReportTypes.CreditNote:
            client.GetReportFile(new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value), -2, reportFile.FileName, out stream);
            break;
        }


        string reportFileName = GetReportByFormat(reportFile.FileName, currentInterval);

        Response.ClearContent();
        Response.ClearHeaders();
        Response.BufferOutput = true;
        Response.ContentType = "application/octet-stream";
        Response.AddHeader("Content-Disposition", "attachment;filename=" + reportFileName);

        // Each format need to have appropriate MIME type in IIS to open file correctly.
        WriteReportStream(stream);
      }
    }
    catch (Exception exp)
    {
      Logger.LogException(Resources.ErrorMessages.ERROR_REPORT_OPEN, exp);

      if (stream != null)
      {
        stream.Close();
      }
      client.Abort();
    }
    finally
    {
      if (stream != null)
      {
        stream.Close();
      }
      client.Close();
      Response.End();
    }
  }

  //
  //Write stream to Response.OutputStream
  //
  private void WriteReportStream(Stream stream)
  {
    var buffer = new byte[4096];

      while (true)
      {
        var count = stream.Read(buffer, 0, 4096);
        if (count == 0)
        {
          break;
        }
        Response.OutputStream.Write(buffer, 0, count);
        Response.Flush();
      }
  }

  //
  //Set up report name for saving <ReportName>_<IntervalStartDate>_<IntervalEndDate>.<ReportExtention>
  //
  private string GetReportByFormat(string reportName, Interval interval)
  {
    string reportFormat = Path.GetExtension(reportName);

    if (!string.IsNullOrEmpty(reportFormat))
    {
      reportName = reportName.Replace(reportFormat, string.Format("_{0}_{1}{2}", interval.StartDate.ToString("yyyy-MM-dd"),
                                                    interval.EndDate.ToString("yyyy-MM-dd"), reportFormat));
    }
    return reportName;
  }
}