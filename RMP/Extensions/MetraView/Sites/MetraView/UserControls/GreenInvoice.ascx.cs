using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;

public partial class UserControls_GreenInvoice : System.Web.UI.UserControl
{
  public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    InternalView acctIntView = (InternalView)UI.Subscriber.SelectedAccount.GetInternalView();
    if (acctIntView.InvoiceMethod != null)
    {
      if (acctIntView.InvoiceMethod.Value !=
          MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.InvoiceMethod.None)
      {
        PanelGoGreen.Visible = true;
      }
      else
      {
        PanelGoGreen.Visible = false;
      }
    }
    else
    {
      PanelGoGreen.Visible = true;
    }
  }
}
