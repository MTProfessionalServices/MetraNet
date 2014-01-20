using System;
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
    lblError.Text = KeyTerms.ProcessKeyTerms(lblError.Text);
  }

  
}
