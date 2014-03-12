using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;

public partial class Adjustments_CreateCreditNote : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      lblAccount.Text = String.Format("{0} ({1})", UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount._AccountID);
    }

  protected void btnIssueCreditNote_Click(object sender, EventArgs e)
  {
    throw new NotImplementedException();
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    throw new NotImplementedException();
  }
}