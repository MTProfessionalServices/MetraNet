using System;
using System.Web.UI;
using System.Threading;
using System.IO;

public partial class UserControls_LocalizedIncludes : UserControl
{
  protected void Page_Load(object sender, EventArgs e)
  {
    // Include localized style sheet
    string localizedStyleSheet = "<link href=\"" + GetGlobalResourceObject("LocalizedIncludes", "LocalizedStyleSheet") +
                                 "\" rel=\"stylesheet\" type=\"text/css\" />";
    PlaceHolder1.Controls.Add(new LiteralControl(localizedStyleSheet)); 

    // Include localized javascript
    string localizedJS = "<script type=\"text/javascript\" src=\"" +
                         ResolveUrl(GetGlobalResourceObject("LocalizedIncludes", "LocalizedJavaScript").ToString()) +
                         "\"></script>";
    PlaceHolder1.Controls.Add(new LiteralControl(localizedJS));

    // Include localized validators
    string localizedJS2 = "<script type=\"text/javascript\" src=\"" +
                          ResolveUrl(GetGlobalResourceObject("LocalizedIncludes", "LocalizedJavaScriptValidators").ToString()) 
                           + "\"></script>";
    PlaceHolder1.Controls.Add(new LiteralControl(localizedJS2));

    // Include localized templates
    string localizedJS3 = "<script type=\"text/javascript\" src=\"" + GetGlobalResourceObject("LocalizedIncludes", "LocalizedJavaScriptTemplates") + "\"></script>";
    PlaceHolder1.Controls.Add(new LiteralControl(localizedJS3));

    // determine which localized EXT js file to load
    string cultureName = Thread.CurrentThread.CurrentUICulture.Name;
    string localizationFName;

    // however, if no file found, try the two-char version
    if(!IsFilePresent(cultureName,out localizationFName))
    {
      cultureName = Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName;

      //if still not found, use en (English)
      if (!IsFilePresent(cultureName, out localizationFName))
      {
        cultureName = "en";
        localizationFName = "/Res/Ext/src/locale/ext-lang-" + cultureName + ".js";
      }
    }

    localizedJS = "<script type=\"text/javascript\" src=\"" + localizationFName + "\"></script>";
    PlaceHolder1.Controls.Add(new LiteralControl(localizedJS));

  }

  //determine if there is a file associated with such a locale
  protected bool IsFilePresent(string cultureName, out string localizationFileName)
  {
    localizationFileName = "/Res/Ext/src/locale/ext-lang-" 
                + cultureName.Replace('-','_') 
                + ".js";

    //attempt to get the physical file path
    string localizationFullPath = Page.MapPath(localizationFileName);

    return File.Exists(localizationFullPath);
  }
}
