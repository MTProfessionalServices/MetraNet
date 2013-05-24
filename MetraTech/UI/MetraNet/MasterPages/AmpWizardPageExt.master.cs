using System;
using System.Text.RegularExpressions;
using MetraTech.UI.Common;

///////////////////////////////////////////////////////////////////////////////////
// The AmpWizardPageExt master page is copied from the NoMenuPageExt master page
// and has a few additional items related to the AmpWizard.  We opted not to use
// nested master pages (i.e., have NoMenuPageExt be the master page of the
// AmpWizardPageExt master page) because that led to complications involving the
// AMP wizard's sitemap and iframe.
// NOTE:  All future updates that are made to NoMenuPageExt should probably
// be made to AmpWizardPageExt too!
///////////////////////////////////////////////////////////////////////////////////

public partial class MasterPages_AmpWizardPageExt : System.Web.UI.MasterPage
{
  #region Properties

  public string AmpCurrentPage 
  {
    get { return Session[Constants.AMP_CURRENT_PAGE] as string; }
  }

  public string AmpNextPage
  {
    get { return Session[Constants.AMP_NEXT_PAGE] as string; }
  }

  public string AmpPreviousPage
  {
    get { return Session[Constants.AMP_PREVIOUS_PAGE] as string; }
  }

  public string AmpDecisionName
  {
    get { return Session[Constants.AMP_DECISION_NAME] as string; }
  }

  // AmpAction values: "Create", "View", "Edit", "Created"
  public string AmpAction
  {
    get { return Session[Constants.AMP_ACTION] as string; }
  }

  public string currHelpPage;

  #endregion


  #region Methods

  protected void Page_Load(object sender, EventArgs e)
  {
    currHelpPage = Session[Constants.HELP_PAGE] as string;
  }

  #endregion
}
