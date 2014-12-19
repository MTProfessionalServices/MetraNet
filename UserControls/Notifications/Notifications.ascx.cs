using System;
using System.Collections.Generic;
using MetraTech.UI.Common;

public partial class UserControl_Notifications :  System.Web.UI.UserControl
{
  protected Dictionary<string, string> NotificationEventsTemplates;
  public UIManager UI
  {
    get { return Session[Constants.UI_MANAGER] as UIManager; }
    set { Session[Constants.UI_MANAGER] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    NotificationEventsTemplates =
      NotificationService.GetExisitingNotificationEventsTemplates(UI.SessionContext.LanguageID);

  }
  protected string defineJavaScriptDictionary()
  {
    string outstr = "var hashtable = {};\n";
    foreach (string notname in NotificationEventsTemplates.Keys)
    {
      outstr += "hashtable[\"";
      string tmp = "";
      outstr += notname;
      outstr += "\"] = \"";
      NotificationEventsTemplates.TryGetValue(notname, out tmp);
      outstr += tmp + "\";\n";
    }
    return outstr;
  }

}