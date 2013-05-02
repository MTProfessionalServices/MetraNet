using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using MetraTech.BusinessEntity.Service.ClientProxies;
using Core.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;

public partial class UserControls_ReportMenu : UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    myReportsBox.Visible = SiteConfig.Settings.BillSetting.AllowSavedReports.Value;
    sharedReportsBox.Visible = SiteConfig.Settings.BillSetting.AllowSharedReports.Value;
  }

  private void PopulateSharedReports()
  {
    sharedReportsBox.Visible = false;
  }
  private string RepackURL(string formattedURL, string pattern)
  {
    string repackedURL;

    if (!formattedURL.Contains(pattern))
    {
      return formattedURL;
    }

    int start = formattedURL.IndexOf(pattern);
    int end = formattedURL.IndexOf("&",start);
    if (end < 0)
    {
      repackedURL = formattedURL.Substring(0, start);
      if(repackedURL.EndsWith("?") || repackedURL.EndsWith("&"))
      {
        repackedURL= repackedURL.Substring(0, repackedURL.Length  -1);
      }
      return repackedURL;
    }
    //else, pattern is followed with another parameter
    repackedURL = formattedURL.Substring(0, start);
    repackedURL += formattedURL.Substring(end + 1, formattedURL.Length - end - 1);

    return repackedURL;

  }

  /// <summary>
  /// Returns a list of available PDFs, and stores the ReportFile object in a dictionary.
  /// </summary>
  /// <returns></returns>
  protected string GetInvoicePDFs()
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
        sb.Append("<li>");
        sb.Append(String.Format("<a href=\"{0}/ShowPDF.aspx?pdf={1}\">{2}</a>", Request.ApplicationPath,
          Server.UrlEncode(reportFile.DisplayName + "_" + intervalID.ToString()), reportFile.DisplayName));
        sb.Append("</li>");
      }
    }
    else
    {
      sb.Append(GetLocalResourceObject("NoInvoices.Text"));
    }
    return sb.ToString();
  }

}
