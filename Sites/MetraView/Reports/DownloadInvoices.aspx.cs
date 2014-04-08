using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;
using MetraTech.Interop.RCD;
using MetraTech.DomainModel.Billing;
using System.Text;
using System.Xml.Linq;
using System.IO;
using MetraTech.Core.CreditNotes;
using MetraTech.CreditNotes;
using RCD = MetraTech.Interop.RCD;



public partial class Reports_DownloadInvoices : MTPage
{
  private XDocument reportFormats = new XDocument();
  private bool _creditNotesEnabled = false;
  private RCD.IMTRcd rcd = new RCD.MTRcd();
  protected void Page_Load(object sender, EventArgs e)
  {
    Intervals1.RedirectURL = Request.FilePath;

    StringBuilder sb = new StringBuilder();
    var billManager = new BillManager(UI);
    Interval interval = billManager.GetCurrentInterval();

    string reportingDir = Path.Combine(rcd.ExtensionDir, "Reporting");
    if (Directory.Exists(reportingDir)) // check if Reporting extension exists
    {
      _creditNotesEnabled =
        MetraTech.CreditNotes.CreditNotePDFConfigurationManager.creditNotePDFConfig.creditNotesEnabled;
    }
   
    if (interval == null)
    {
      this.Intervals1.Visible = false;
      InvoiceList.Text = (String)GetLocalResourceObject("NoInvoices.Text");
      return;
    }

    try
    {
        //fill reports list
      int intervalID = billManager.GetCurrentInterval().ID;
      var reports = billManager.GetReports(intervalID);
      reportFormats = GetReportFormatConfigFile();

      if (reports != null && reports.Count > 0 && reportFormats.Root != null)
      {
        if (Session[SiteConstants.REPORT_DICTIONARY] == null)
        {
          Session[SiteConstants.REPORT_DICTIONARY] = new Dictionary<string, ReportFile>();
        }

        var reportDictionary = Session[SiteConstants.REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

        foreach (var reportFile in reports)
        {
          // The reportFile objects are stored in a dictionary and the name is passed to ShowReports.aspx
          if (reportDictionary != null)
          {
            if (!reportDictionary.ContainsKey(String.Format("{0}_{1}", reportFile.FileName, intervalID)))
            {
              reportDictionary.Add((String.Format("{0}_{1}", reportFile.FileName, intervalID)), reportFile);
            }
          }
          string reportToList = AddReportToInvoiceList(reportFile.FileName, intervalID);

          if (!string.IsNullOrEmpty(reportToList))
          {
            sb.Append(reportToList);
            Logger.LogInfo((string) GetLocalResourceObject("AddReport.Text"), reportFile.FileName);
          }
        }
      }
      else
      {
        sb.Append(GetLocalResourceObject("NoInvoices.Text"));
      }
      InvoiceList.Text = sb.ToString();

      //fill quotes list
      
      var quoteReports = billManager.GetQuoteReports();
      reportFormats = GetReportFormatConfigFile();
        sb = new StringBuilder();

      if (quoteReports != null && quoteReports.Count > 0 && reportFormats.Root != null)
      {
          if (Session[SiteConstants.QUOTE_REPORT_DICTIONARY] == null)
          {
              Session[SiteConstants.QUOTE_REPORT_DICTIONARY] = new Dictionary<string, ReportFile>();
          }

          var quoteReportDictionary = Session[SiteConstants.QUOTE_REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

          foreach (var reportFile in quoteReports)
          {
              // The reportFile objects are stored in a dictionary and the name is passed to ShowReports.aspx
              if (quoteReportDictionary != null)
              {
                  if (!quoteReportDictionary.ContainsKey(String.Format("{0}_{1}", reportFile.FileName, intervalID)))
                  {
                      quoteReportDictionary.Add((String.Format("{0}_{1}", reportFile.FileName, intervalID)), reportFile);
                  }
              }
              string reportToList = AddReportToQuoteList(reportFile.FileName, intervalID);

              if (!string.IsNullOrEmpty(reportToList))
              {
                  sb.Append(reportToList);
                  Logger.LogInfo((string)GetLocalResourceObject("AddReport.Text"), reportFile.FileName);
              }
          }
      }
      else
      {
          sb.Append(GetLocalResourceObject("NoQuotes.Text"));
      }
      QuoteList.Text = sb.ToString();


      //fill CreditNotes list
      if (_creditNotesEnabled)
      {
        var creditNotesReports = billManager.GetCreditNotesReports();
        sb = new StringBuilder();

        if (creditNotesReports != null && creditNotesReports.Count > 0)
        {
          if (Session[SiteConstants.CREDIT_NOTES_REPORT_DICTIONARY] == null)
          {
            Session[SiteConstants.CREDIT_NOTES_REPORT_DICTIONARY] = new Dictionary<string, ReportFile>();
          }

          var creditNotesReportDictionary =
            Session[SiteConstants.CREDIT_NOTES_REPORT_DICTIONARY] as Dictionary<string, ReportFile>;

          foreach (var reportFile in creditNotesReports)
          {
            // The reportFile objects are stored in a dictionary and the name is passed to ShowReports.aspx
            if (creditNotesReportDictionary != null)
            {
              if (!creditNotesReportDictionary.ContainsKey(String.Format("{0}", reportFile.FileName)))
              {
                creditNotesReportDictionary.Add((String.Format("{0}", reportFile.FileName)), reportFile);
              }
            }
            string reportToList = AddReportToCreditNotesList(reportFile.FileName, intervalID);

            if (!string.IsNullOrEmpty(reportToList))
            {
              sb.Append(reportToList);
              Logger.LogInfo((string) GetLocalResourceObject("AddCreditNoteReport.Text"), reportFile.FileName);
            }
          }
        }
        else
        {
          sb.Append(GetLocalResourceObject("NoCreditNotes.Text"));
        }
        CreditNoteList.Text = sb.ToString();

      }
      else
      { 
        DownLoadCreditNotesDiv.Attributes.Add("style", "display: none;");
      }
    }
    catch (Exception exp)
    {
      Logger.LogException(Resources.ErrorMessages.ERROR_DOWNLOAD_REPORTS, exp);
      InvoiceList.Text = (string) GetLocalResourceObject("ErrorDownload.Text");
    }
  }

  //Add report to Invoice list, add reports only with  formats 
  //.xls, .xlsx, .csv, .doc, .docx, .htm, .html, .ps, .txt.,.pdf
  //
  private string AddReportToInvoiceList(string reportFileName, int intervalID)
  {
      string reportFormat = Path.GetExtension(reportFileName);
      string reportToList = String.Empty;

        foreach (XElement format in reportFormats.Root.Elements())
        {
          if (format.Attribute("type").Value.Equals(reportFormat))
          {
            reportToList =
              String.Format(
                "<li><a href=\"{0}/Reports/ShowReports.aspx?report={1}&reportType=invoice\"><img src='{2}'/>{3}</a></li>",
                Request.ApplicationPath,
                Server.UrlEncode(String.Format("{0}_{1}", reportFileName, intervalID)),
                format.Element("ReportImage").Value,
                reportFileName);
          }
        }
      return reportToList;
  }

  private string AddReportToCreditNotesList(string reportFileName, int intervalID)
  {

    string reportFormat = Path.GetExtension(reportFileName);
    string reportToList = String.Empty;

    foreach (XElement format in reportFormats.Root.Elements())
    {
      if (format.Attribute("type").Value.Equals(reportFormat))
      {
        reportToList =
          String.Format(
            "<li><a href=\"{0}/Reports/ShowReports.aspx?report={1}&reportType=creditnote\"><img src='{2}'/>{3}</a></li>",
            Request.ApplicationPath,
            Server.UrlEncode(String.Format("{0}", reportFileName)),
            format.Element("ReportImage").Value,
            reportFileName);
      }
    }
    return reportToList;
 
  }

  private string AddReportToQuoteList(string reportFileName, int intervalID)
  {
      string reportFormat = Path.GetExtension(reportFileName);
      string reportToList = String.Empty;

      foreach (XElement format in reportFormats.Root.Elements())
      {
          if (format.Attribute("type").Value.Equals(reportFormat))
          {
              reportToList =
                String.Format(
                  "<li><a href=\"{0}/Reports/ShowReports.aspx?report={1}&reportType=quote\"><img src='{2}'/>{3}</a></li>",
                  Request.ApplicationPath,
                  Server.UrlEncode(String.Format("{0}_{1}", reportFileName, intervalID)),
                  format.Element("ReportImage").Value,
                  reportFileName);
          }
      }
      return reportToList;
  }
  //
  //Get report format config file. Location r:\extensions\MetraView\Config\ReportFormats.xml
  //
  private XDocument GetReportFormatConfigFile()
  {
    IMTRcd rcd = new MTRcd();
    string reportFormatFile = String.Empty;

    try
    {
      reportFormatFile = Path.Combine(rcd.ExtensionDir, @"MetraView\Config\ReportFormats.xml");
      reportFormats = XDocument.Load(reportFormatFile);
      ReportFormatConfigValidation();
    }
    catch (Exception exp)
    {
      throw new UIException(String.Format("{0} {1} Details:{2}", Resources.ErrorMessages.ERROR_REPORT_CONFIG, reportFormatFile, exp));
    }
    finally
    {
      if (rcd != null)
      {
        Marshal.ReleaseComObject(rcd);
      }
    }
    return reportFormats;
  }
  //
  //Check report format config file for correct structure
  //
  private void ReportFormatConfigValidation()
  {
    if (reportFormats.Root != null)
    {
      foreach (XElement format in reportFormats.Root.Elements())
      {
        XAttribute formatType = format.Attribute("type");
        XElement reportImage = format.Element("ReportImage");

        if ((formatType == null) || (string.IsNullOrEmpty(formatType.Value)))
        {
          throw new UIException(Resources.ErrorMessages.ERROR_REPORT_FORMAT);
        }
        if (reportImage == null)
        {
          throw new UIException(Resources.ErrorMessages.ERROR_REPORT_IMAGE);
        }
      }
    }
  }
}


