using System;
using System.Collections.Generic;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.UI.Common;
using System.IO;

public partial class ShowPDF : MTPage
{
  protected string ConvertDateToString(DateTime date)
  {
    string result = string.Format("{0}-{1}-{2}",
                                    date.Year.ToString(),
                                    date.Month.ToString(),
                                    date.Day.ToString());
    return result;
  }
  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.Subscriber.SelectedAccount == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (UI.Subscriber.SelectedAccount._AccountID == null)
      throw new UIException(Resources.ErrorMessages.ERROR_NOT_VALID_ACCOUNT);

    if (Session[SiteConstants.REPORT_DICTIONARY] == null)
    {
      return;
    }

    if(Request.QueryString["pdf"] == null)
    {
      return;
    }

    var pdfName = Request.QueryString["pdf"];
    var reportDictionary = Session[SiteConstants.REPORT_DICTIONARY] as Dictionary<string, ReportFile>;
    if (reportDictionary != null)
    {
      var reportFile = reportDictionary[pdfName];
      var billManager = new BillManager(UI);
      Interval currentInterval = billManager.GetCurrentInterval();

      // we wait to close the client until we are done streaming
      var client = new StaticReportsServiceClient("NetTcpBinding_IMetraTech.Core.Services.StaticReportsService");
      client.ClientCredentials.UserName.UserName = UI.User.UserName;
      client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      
      Stream s = null;
      try
      {
        client.GetReportFile(new AccountIdentifier((int) UI.Subscriber.SelectedAccount._AccountID),
                             currentInterval.ID, reportFile.FileName, out s);

        string fname = reportFile.FileName;

        if (!reportFile.FileName.EndsWith(".pdf"))
        {
          //append interval dates to the filename
          fname += "_" + ConvertDateToString(currentInterval.StartDate);
          fname += "_";
          fname += ConvertDateToString(currentInterval.EndDate);
          fname += ".pdf";
        }
        else
        {
          //append dates before the .pdf
          fname = fname.Replace(".pdf", string.Format("_{0}_{1}.pdf",
            ConvertDateToString(currentInterval.StartDate),
            ConvertDateToString(currentInterval.EndDate)));
        }

        Response.ClearContent();
        Response.ClearHeaders();
        Response.BufferOutput = true;
        Response.ContentType = "application/pdf";
        Response.AddHeader("Content-Disposition", "attachment;filename=" + fname ); 

        var buffer = new byte[4096];

        while (true)
        {
          var count = s.Read(buffer, 0, 4096);
          if (count == 0)
          {
            break;
          }

          Response.OutputStream.Write(buffer, 0, count);
          Response.Flush();
        }

        s.Close();
        client.Close();
      }
      catch(Exception)
      {
        if (s != null)
          s.Close();

        client.Abort();
      }

      Response.End();
    }
  }
}
