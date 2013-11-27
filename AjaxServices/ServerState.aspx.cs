using System;
using MetraTech.UI.Common;

public partial class AjaxServices_ServerState : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var action = string.IsNullOrEmpty(Request.Form["Action"]) ? string.Empty : Request.Form["Action"];
    var name = string.IsNullOrEmpty(Request.Form["Name"]) ? string.Empty : Request.Form["Name"];
    var value = string.IsNullOrEmpty(Request.Form["Value"]) ? string.Empty : Request.Form["Value"];

    Logger.LogDebug(String.Format("Server State - action: {0}, name: {1}, value: {2}", 
                      action, name, value));


    // Make sure we only allow this function to operate
    // on state names which are guids and not other things that might be in session
    try
    {
      new Guid(name);
    }
    catch (Exception)
    {
      Response.Write("Access Denied.");
      return;
    }

    switch(action.ToLower())
    {
      case "set":
        Session[name] = value;
        Response.Write("OK");
        break;

      case "get":
        Response.Write(Session[name] == null ? "" : Session[name].ToString());
        break;

      case "clear":
        Session.Remove(name);
        Response.Write("OK");
        break;
    }

    Response.End();
  }

}
