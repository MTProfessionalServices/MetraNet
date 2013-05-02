using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Interop.RCD;
using MetraTech.DomainModel.Billing;
using System.Text;
using System.Xml.Linq;
using System.IO;

public partial class Reports_DownloadInvoices : MTPage
{
  private XDocument reportFormats = new XDocument();

  protected void Page_Load(object sender, EventArgs e)
  {
    Intervals1.RedirectURL = Request.FilePath;

    StringBuilder sb = new StringBuilder();
    var billManager = new BillManager(UI);
    Interval interval = billManager.GetCurrentInterval();

    if (interval == null)
    {
      this.Intervals1.Visible = false;
      InvoiceList.Text = (String)GetLocalResourceObject("NoInvoices.Text");
      return;
    }

    try
    {
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
                "<li><a href=\"{0}/Reports/ShowReports.aspx?report={1}\"><img src='{2}'/>{3}</a></li>",
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


