using System;
using System.Text.RegularExpressions;
using MetraTech.UI.Common;

public partial class MasterPages_NoMenuPageExt : System.Web.UI.MasterPage
{
  public string currHelpPage;

  protected void Page_Load(object sender, EventArgs e)
  {
    string pageName = Request.Url.ToString();
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
    }
    else
    {
      currHelpPage = Session[Constants.HELP_PAGE] as string;
    }
  }
}
