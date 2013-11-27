using System;
using MetraTech.UI.Common;

public partial class AjaxServices_ApplySiteChanges : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (UI.CoarseCheckCapability("MetraView Admin"))
    {
      // Load business entities for the site
      Application.Lock();
      Application["SiteConfig"] = BusinessEntityHelper.LoadSiteConfiguration();
      Application.UnLock();

      Response.Write("OK");
    }
  }
}
