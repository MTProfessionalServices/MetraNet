using System;
using MetraTech.UI.Common;

public partial class MasterPages_DetailsPageExt : System.Web.UI.MasterPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    MTPage p = Page as MTPage;
    if (p == null) return;
    if (p.UI == null || p.PageNav == null) return;

    if (Request.UrlReferrer != null && Request.UrlReferrer.AbsolutePath != null &&
      Request.UrlReferrer.AbsolutePath.Contains("Bill.aspx"))
    {
      BillMenu.Style.Add("display", "block");
      ReportMenu.Style.Add("display", "none");
    }
    else
    {
      BillMenu.Style.Add("display", "none");
      ReportMenu.Style.Add("display", "block");
    }
   
  }

  public string CJProtectionCode
  {
    get
    {
      return (Session[Constants.PAGE_RUNNING_FROM_METRANET] != null) && (bool)Session[Constants.PAGE_RUNNING_FROM_METRANET] ? "" : Constants.CJ_PROTECTION_CODE;
    }
  }
  /// <summary>
  /// Return the current HelpPage.
  /// </summary>
  public string HelpPage
  {
    get { return Session[Constants.HELP_PAGE] as string; }
  }

  /// <summary>
  /// Return the current workflow state.
  /// </summary>
  public string CurrentState
  {
    get
    {
      MTPage p = Page as MTPage;
      if (p == null) return String.Empty;

      if (p.UI != null && p.PageNav != null)
      {
        return p.PageNav.State;
      }

      return String.Empty;
    }
  }

  /// <summary>
  /// Return the current workflow processor Id.
  /// </summary>
  public string ProcessorId
  {
    get
    {
      MTPage p = Page as MTPage;
      if (p == null) return String.Empty;

      if (p.UI != null && p.PageNav != null)
      {
        return p.PageNav.ProcessorId.ToString();
      }

      return String.Empty;
    }
  }

  /// <summary>
  /// Return the name of the last interface called
  /// </summary>
  public string InterfaceName
  {
    get
    {
      MTPage p = Page as MTPage;
      if (p == null) return String.Empty;

      if (p.UI != null && p.PageNav != null)
      {
        return p.PageNav.InterfaceName;
      }

      return String.Empty;
    }
  }

}
