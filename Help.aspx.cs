using System;
using System.Diagnostics;
using System.Threading;
using MetraTech;
using MindTouch;

public partial class Help : System.Web.UI.Page
{
  /// <summary>
  /// Get the MetraTech logger object
  /// </summary>
  private Logger _mLog = new Logger("[MTPage]");
  public Logger Logger
  {
    get { return _mLog; }
    set { _mLog = value; }
  }

  //public string URL = @"/MetraNetHelp/en-us/";
  public string URL = @"https://doc.metratech.com/MetraNet/MetraNet_8.0/Application_Help/MetraCare";
  protected void Page_Load(object sender, EventArgs e)
  {
    var pageName = Request["PageName"];
    if (string.IsNullOrEmpty(pageName)) pageName = "VersionInfo.asp";
    
    var lang = Thread.CurrentThread.CurrentCulture.ToString();
    var redirectUrl = MindTouchSso.GetRedirectUrl(MindTouchSso.DefaultUser, lang, pageName, GetMetraNetVersion());
    Logger.LogDebug("redirect URL for page {0} is {1}", pageName, redirectUrl);
    URL = redirectUrl;
  }

  private static string GetMetraNetVersion()
  {
    var rmpBin = Environment.GetEnvironmentVariable("MTRMPBIN");
    var metraNetVersionInfo = FileVersionInfo.GetVersionInfo(rmpBin + "\\pipeline.exe");
    return String.Format("{0}.{1}", metraNetVersionInfo.FileMajorPart, metraNetVersionInfo.FileMinorPart);
  }
}