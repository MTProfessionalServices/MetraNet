using System;
using MetraTech.UI.Common;

public partial class UserControls_HeaderInfo : System.Web.UI.UserControl
{
  public string UserName { get; set; }
  public string AccountId { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    if (((MTPage)Page).UI == null)
      return;

    if (((MTPage)Page).UI.Subscriber == null)
      return;

    if (((MTPage)Page).UI.Subscriber.SelectedAccount == null)
      return;

    UserName = ((MTPage) Page).UI.Subscriber.SelectedAccount.UserName;
    AccountId = ((MTPage) Page).UI.Subscriber.SelectedAccount._AccountID.ToString();
  }
}
