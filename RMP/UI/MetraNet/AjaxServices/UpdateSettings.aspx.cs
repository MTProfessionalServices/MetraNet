using System;
using System.Threading;
using System.Globalization;
using MetraTech.UI.Common;

public partial class AjaxServices_UpdateSettings : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // App Time
    if (Request.Form["tbAppTime"] != null)
    {
      ApplicationTime = DateTime.Parse(Request.Form["tbAppTime"]);
    }

    // App Language
    if (Request.Form["ddLanguage"] != null)
    {
      String selectedLanguage = Request.Form["ddLanguage"].ToString();
      if (selectedLanguage.ToLower() != "auto")
      {
        Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(selectedLanguage);
        Thread.CurrentThread.CurrentUICulture = new CultureInfo(selectedLanguage);
        Session[Constants.SELECTED_LANGUAGE] = selectedLanguage;
        Session[Constants.MAIN_MENU] = null;
      }
      else
      {
        Session[Constants.SELECTED_LANGUAGE] = null;
        Session[Constants.MAIN_MENU] = null;
      }
    }
    else if (Session[Constants.SELECTED_LANGUAGE] != null)
    {
      Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture(Session[Constants.SELECTED_LANGUAGE].ToString());
      Thread.CurrentThread.CurrentUICulture = new CultureInfo(Session[Constants.SELECTED_LANGUAGE].ToString());
    }

    base.InitializeCulture();

    Response.Write("OK");
    Response.End();
  }
}
