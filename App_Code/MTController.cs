using System;
using System.Globalization;
using System.IO;
using System.ServiceModel;
using System.Threading;
using System.Web.Mvc;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;
using MetraTech;
using MetraTech.UI.Tools;

/// <summary>
/// Summary description for MTController
/// </summary>
public class MTController : Controller
{

  public UIManager UI
  {
    get { return Session[Constants.UI_MANAGER] as UIManager; }
  }

  /// <summary>
  /// Get the MetraTech logger object
  /// </summary>
  private Logger mLog = new Logger("[MTController]");
  public Logger Logger
  {
    get { return mLog; }
    set { mLog = value; }
  }

  /// <summary>
  /// Returns the current help page.  Setup on page load.
  /// </summary>
  public string HelpPage
  {
    get { return Session[Constants.HELP_PAGE] as string; }
    set
    {
      ViewBag.HelpPage = value;
      Session[Constants.HELP_PAGE] = value;
    }
  }
  /// <summary>
  /// Set title for page.
  /// </summary>
  public string Title
  {
    get { return ViewBag.Title; }
    set { ViewBag.Title = value; }
  }

  /// <summary>
  /// The current UI ApplicationTime.  This maybe metratime or a value set
  /// by the UI (like when accounts are being looked up in the future).  
  /// </summary>
  public DateTime ApplicationTime
  {
    get
    {
      if (Session[Constants.APP_TIME] == null)
      {
        Session[Constants.APP_TIME] = MetraTime.Now;
      }
      return (DateTime)Session[Constants.APP_TIME];
    }
    set
    {
      Session[Constants.APP_TIME] = value;
    }
  }

  protected override void OnActionExecuting(ActionExecutingContext filterContext)
  {
    // If session exists
    if (filterContext.HttpContext.Session != null)
    {
      // setup culture
      if (filterContext.HttpContext.Session[Constants.SELECTED_LANGUAGE] != null)
      {
        Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(filterContext.HttpContext.Session[Constants.SELECTED_LANGUAGE].ToString());
        Thread.CurrentThread.CurrentUICulture = new CultureInfo(filterContext.HttpContext.Session[Constants.SELECTED_LANGUAGE].ToString());
      }

      // setup help
      SetupHelpUrl();
    }
  }

  /// <summary>
  /// Generate help link for the page.
  /// </summary>
  public void SetupHelpUrl()
  {
    try
    {
      if (Request.ServerVariables["SCRIPT_NAME"].Contains("AjaxServices")) return;

      HelpPage = String.Format("/MetraNet/Help.aspx?PageName={0}", Path.GetFileName(Request.ServerVariables["SCRIPT_NAME"]));
      Logger.LogDebug(string.Format("HelpPage: {0}", HelpPage));
    }
    catch (Exception exp)
    {
      Logger.LogInfo("Locating help:" +  exp.Message);
    }
  }

  /// <summary>
  /// Sets an error in session that will be displayed by the error user control.
  /// Also logs, the error to MTLog.
  /// </summary>
  /// <param name="error"></param>
  protected void SetError(string error)
  {
      Session[Constants.ERROR] = error;
      Logger.LogError(error);
  }

  /// <summary>
  /// Catch MTController exceptions
  /// </summary>
  /// <param name="filterContext"></param>
  protected override void OnException(ExceptionContext filterContext)
  {
    Logger.LogException("MTController caught exception", filterContext.Exception);
    SetError(filterContext.Exception.Message);

    base.OnException(filterContext);
  }

  /// <summary>
  /// Sets an error from MAS in session that will be displayed by the error user control.
  /// Also logs, the error to MTLog.
  /// </summary>
  /// <param name="fe"></param>
  protected void SetMASError(FaultException<MASBasicFaultDetail> fe)
  {
    foreach (string msg in fe.Detail.ErrorMessages)
    {
        // CORE-6182 Security: /MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx page is vulnerable to Cross-Site Scripting 
        // Removed insecure formatting
        //Session[Constants.ERROR] = msg + "<br />";
        Session[Constants.ERROR] = msg + Environment.NewLine;
    }
    string errCodeString = Utils.ExtractString(Session[Constants.ERROR].ToString(), "status '", "'");
    if (errCodeString != "")
    {
      string detailedError = Utils.MTErrorMessage(errCodeString);
      Session[Constants.ERROR] += "  " + detailedError;
    }
  }

}