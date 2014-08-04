using System;
using System.Web;
using Core.UI;
using MetraTech.UI.Common;

/// <summary>
/// SiteConfig - Holds the cached site configuration and user profiles
/// </summary>
static public class SiteConfig
{

    /// <summary>
    /// Site configuration
    /// </summary>
    static public Site Settings
    {
        get { return HttpContext.Current.Application["SiteConfig"] as Site; }
        set { HttpContext.Current.Application["SiteConfig"] = value; }
    }

    /// <summary>
    /// Logged in user profile
    /// </summary>
    static public UserProfile Profile
    {
        get { return HttpContext.Current.Session["UserProfile"] as UserProfile; }
        set { HttpContext.Current.Session["UserProfile"] = value; }
    }

    /// <summary>
    /// Site auth configuration
    /// </summary>
    static public SiteAuthConfig AuthSettings
    {
        get { return HttpContext.Current.Application["SiteAuthConfig"] as SiteAuthConfig; }
        set { HttpContext.Current.Application["SiteAuthConfig"] = value; }
    }

    /// <summary>
    /// Returns the configured image path to the application logo
    /// </summary>
    /// <returns></returns>
    static public string GetApplicationLogo()
    {
        var logo = "";
        var appFolder = GetVirtualFolder();

        if (String.IsNullOrEmpty(SiteConfig.Settings.LogoImage))
        {
            logo = appFolder + "/Images/metratech-logo.gif";
        }
        else
        {
            // If it is an absolute path (starts with "/") or is an external path (http(s)), don't prefix with appFolder
            if (SiteConfig.Settings.LogoImage.StartsWith("/") ||
                SiteConfig.Settings.LogoImage.StartsWith("http://", StringComparison.InvariantCultureIgnoreCase) ||
                SiteConfig.Settings.LogoImage.StartsWith("https://", StringComparison.InvariantCultureIgnoreCase))
            {
                logo = SiteConfig.Settings.LogoImage;
            }
            else // Relative path => prefix with appFolder
            {
                logo = appFolder + "/" + SiteConfig.Settings.LogoImage;
            }
        }
        return logo;
    }

    /// <summary>
    /// Return the virtual folder
    /// </summary>
    /// <returns></returns>
    static public string GetVirtualFolder()
    {
        return HttpRuntime.AppDomainAppVirtualPath;
    }

    /// <summary>
    /// Returns true if the site is down for maintenance and this user is not admin
    /// </summary>
    /// <param name="ui"></param>
    /// <returns></returns>
    static public bool IsSiteDownForMaintenance(UIManager ui)
    {
        var result = false;


        if (Settings.IsSiteDownForMaintenance == true)
        {
            result = !ui.CoarseCheckCapability("MetraView Admin");
        }

        return result;
    }
}
