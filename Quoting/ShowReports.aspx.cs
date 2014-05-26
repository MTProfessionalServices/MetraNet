using System;
using System.IO;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;

public partial class Reports_ShowReports : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    ShowReport();
  }
  //
  //Open selected report in appropriate application
  //
  private void ShowReport()
  {          
        var reportFile = Request.QueryString["report"];
        var accountId = Request.QueryString["account"];

        if (reportFile != null)
        {
          ReportStream(reportFile, accountId);
        }      
  }



  //
  //Get stream of selected report from StaticReportService
  //
  private void ReportStream(string reportFile, string accId)
  {
    var client = new StaticReportsServiceClient("NetTcpBinding_IMetraTech.Core.Services.StaticReportsService");

// ReSharper disable PossibleNullReferenceException
    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
// ReSharper restore PossibleNullReferenceException

    Stream stream = null;

    try
    {
      client.GetReportFile(new AccountIdentifier(int.Parse(accId)), -1, reportFile, out stream);

        string reportFileName = reportFile;

        Response.ClearContent();
        Response.ClearHeaders();
        Response.BufferOutput = true;
        Response.ContentType = "application/octet-stream";
        Response.AddHeader("Content-Disposition", "attachment;filename=" + reportFileName);

        // Each format need to have appropriate MIME type in IIS to open file correctly.
        WriteReportStream(stream);      
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
}