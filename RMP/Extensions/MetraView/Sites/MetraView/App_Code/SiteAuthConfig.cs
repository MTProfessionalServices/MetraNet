using System.Web;
using System.Xml.Linq;

/// <summary>
/// A wrapper around Config/Site.xml
/// </summary>
public class SiteAuthConfig
{
  public string AuthenticationType { get; set; }
  public string AuthenticationNamespace { get; set; }
  public string AuthenticationCapabilityApplicationValue { get; set; }

  public SiteAuthConfig()
  {
    LoadSite();
  }

  private void LoadSite()
  {
    string filename = HttpContext.Current.Server.MapPath(HttpContext.Current.Request.ApplicationPath) +
                      "/Config/Site.xml";
    XDocument siteXml = XDocument.Load(filename);

    var site = siteXml.Root;
    if (site != null)
    {
      AuthenticationType = (string)site.Element("AuthenticationType");
      AuthenticationNamespace = (string)site.Element("AuthenticationNamespace");
      AuthenticationCapabilityApplicationValue = (string)site.Element("AuthenticationCapabilityApplicationValue");
    }
  }
}
