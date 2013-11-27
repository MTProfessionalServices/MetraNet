using System;
using MetraTech.UI.Common;

public partial class MasterPages_NoMenuPageExt : System.Web.UI.MasterPage
{
  public string currHelpPage;
  /// <summary>
  /// Return the current HelpPage.
  /// </summary>
  public string HelpPage
  {
    get { return Session[Constants.HELP_PAGE] as string; }
  }

  public string CJProtectionCode
  {
    get
    {
      return (Session[Constants.PAGE_RUNNING_FROM_METRANET] != null) && (bool)Session[Constants.PAGE_RUNNING_FROM_METRANET] ? "" : Constants.CJ_PROTECTION_CODE;
    }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    /*string pageName = Request.Url.ToString();
    string BEName = "";
    if (pageName.Contains("BEList.aspx") || pageName.Contains("BEEdit.aspx"))
    {
      if (Request.QueryString["Name"] != null)
      {
        BEName = Request.QueryString["Name"].ToString();
        BEName = "BEList" + BEName.Substring(BEName.LastIndexOf('.'));

        currHelpPage = Session[Constants.HELP_PAGE].ToString();
        currHelpPage = currHelpPage.Replace("BEList", BEName);
        Session[Constants.HELP_PAGE] = currHelpPage;

      }
    }*/
  }
}
