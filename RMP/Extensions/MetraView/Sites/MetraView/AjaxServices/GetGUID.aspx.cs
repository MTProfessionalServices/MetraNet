using System;
using System.Web.Script.Serialization;

public class UIGuid
{
  public UIGuid()
  {
    GUID = Guid.NewGuid().ToString();
  }

  public string GUID { get; set; }

  public string ToJson()
  {
    var jss = new JavaScriptSerializer();
    return jss.Serialize(this);
  }
}

public partial class AjaxServices_GetGUID : System.Web.UI.Page
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var guid = new UIGuid();
    Response.Write(guid.ToJson());
    Response.End();
  }
}
