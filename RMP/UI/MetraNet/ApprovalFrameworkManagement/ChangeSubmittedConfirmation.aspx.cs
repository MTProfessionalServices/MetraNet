using System;
using MetraTech.UI.Common;
using MetraTech.DomainModel.BaseTypes;

public partial class ApprovalFrameworkManagement_ChangeSubmittedConfirmation : MTPage
{
  
  protected void Page_Load(object sender, EventArgs e)
  {
  
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    String redirectLoc = (String)Session["RedirectLoc"];
    if (String.IsNullOrEmpty(redirectLoc))
    {
      Response.Redirect("/MetraNet/ApprovalFrameworkManagement/ShowChangesSummary.aspx?showchangestate=PENDING", false);
    }
    else
    {
      Session["RedirectLoc"] = "";
      Response.Redirect(redirectLoc, false);
    }
  }


}
