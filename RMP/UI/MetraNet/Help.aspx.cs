using System;
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
    var lang = Thread.CurrentThread.CurrentCulture.ToString();
    var redirectUrl = MindTouchSso.GetRedirectUrl(MindTouchSso.DefaultUser, lang, pageName);
    Logger.LogDebug("redirect URL for page {0} is {1}", pageName, redirectUrl);
    URL = redirectUrl;
  }
}