using System;
using System.Globalization;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech;
using MindTouch;

public partial class Help : System.Web.UI.Page
{
  /// <summary>
  /// Get the MetraTech logger object
  /// </summary>
  private Logger mLog = new Logger("[MTPage]");
  public Logger Logger
  {
    get { return mLog; }
    set { mLog = value; }
  }


  //public string URL = @"/MetraNetHelp/en-us/";
  public string URL = @"https://doc.metratech.com/MetraNet/MetraNet_8.0/Application_Help/MetraCare";
  protected void Page_Load(object sender, EventArgs e)
  {
    var pageName = Request["PageName"];
    if (string.IsNullOrEmpty(pageName)) pageName = "VersionInfo.asp";

    var lang = Thread.CurrentThread.CurrentCulture.ToString();
    string redirectUrl = MindTouchSso.GetRedirectUrl(MindTouchSso.DefaultUser, lang, pageName);
    Logger.LogDebug("redirect URL for page {0} is {1}", pageName, redirectUrl);
    URL = redirectUrl;
  }
}