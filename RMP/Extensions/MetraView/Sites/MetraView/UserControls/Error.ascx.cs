using System;
using System.Text.RegularExpressions;
using MetraTech.UI.Common;
using MetraTech.SecurityFramework;

public partial class UserControls_Error : System.Web.UI.UserControl
{
  protected void Page_PreRender(object sender, EventArgs e)
  {
    lblError.Text = "";
    ErrorPanel.Visible = false;

    // Check for error messages in Session
    if (Session[Constants.ERROR] != null)
    {
      lblError.Text = Session[Constants.ERROR].ToString();
      ErrorPanel.Visible = true;

      // Clear Errors
      Session[Constants.ERROR] = null;
    }

    // Check for error messages in PageNav
    MTPage page = (MTPage)Page;
    if (page.UI != null && page.PageNav != null)  // we check for nulls, because some pages don't need all this stuff like the login
    {
      if (page.PageNav.HasError)
      {
        lblError.Text += "  " + page.PageNav.ErrorMessage;
        ErrorPanel.Visible = true;
      }

      // Clear Errors
      Session[Constants.ERROR] = null;
      page.PageNav.HasError = false;
      page.PageNav.ErrorMessage = null;
    }

    // Encode output
    if (!string.IsNullOrWhiteSpace(lblError.Text))
    {
        // CORE-6182 Security: /MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx page is vulnerable to Cross-Site Scripting 
        lblError.Text = lblError.Text.EncodeForHtml().Replace(Environment.NewLine, "<br/>");
    }

    // Replace KeyTerms
    lblError.Text = ProcessKeyTerms(lblError.Text);
  }

  /// <summary>
  /// Replace KeyTerm tags with the localized resource string
  /// </summary>
  /// <param name="str"></param>
  /// <returns></returns>
  public string ProcessKeyTerms(string str)
  {
    Regex regexKey = new Regex(@"\[[^\]]*\]", RegexOptions.IgnoreCase | RegexOptions.Compiled);

    // Step 1:  Use a compiled Regex to pull out possible [key] values in a collection
    MatchCollection mc = regexKey.Matches(str);

    // Step 2:  Replace KeyTerm entries in the string
    if (mc.Count > 0)
    {
      string replaceKey;
      foreach (Match m in mc)
      {
        replaceKey = m.ToString();
        string newKey = replaceKey.Substring(1, replaceKey.Length - 2);
        try
        {
          newKey = GetGlobalResourceObject("KeyTerms", newKey).ToString();
        }
        catch (Exception)
        {
          newKey = replaceKey;
        }
        
        if(!String.IsNullOrEmpty(newKey))
        {
          str = str.Replace(replaceKey, newKey); 
        }
      }
    }
    return str;
  }
  
}
