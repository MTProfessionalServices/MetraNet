using System.Web.Script.Serialization;

public class AjaxResponse
{
  public bool Success { get; set; }
  public string Message { get; set; }
  public object ResultObject { get; set; }

  public string ToJson()
  {
    var jss = new JavaScriptSerializer();
    return jss.Serialize(this);
  }
}