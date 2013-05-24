using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using System.Net;
using System.IO;
using System.Web.Services;
using System.Text;

public partial class ux_rss_GetRss : System.Web.UI.Page
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string URL = Request["feed"].ToString();

    if (String.IsNullOrEmpty(URL))
    {
      Response.End();
      return;
    }

    if (URL.Substring(0, 7) == "http://")
    {
      Encoding enc = Encoding.GetEncoding("ISO-8859-1");
      HttpWebRequest request = WebRequest.Create(URL) as HttpWebRequest;
      HttpWebResponse response = request.GetResponse() as HttpWebResponse;
      StreamReader reader = new StreamReader(response.GetResponseStream(), enc);
      string str = "";
      string reply = "";
      while (!reader.EndOfStream)
      {
        str = reader.ReadLine();
        reply += str + System.Environment.NewLine;
      }
      Response.ContentType = "text/xml";
      Response.ContentEncoding = enc;
      Response.Cache.SetExpires(DateTime.Now.AddSeconds(60));
      Response.Cache.SetCacheability(HttpCacheability.Public);

      Response.Write(reply);
      Response.End();
    }
  }
}
