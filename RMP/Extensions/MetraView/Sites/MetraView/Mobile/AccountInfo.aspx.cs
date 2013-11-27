using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;

public partial class Mobile_AccountInfo : MTAccountPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    Account = UI.Subscriber.SelectedAccount;

    if (BillTo == null)
    {
      var billToContact = new ContactView { ContactType = ContactType.Bill_To };
      Account.AddView(billToContact, "LDAP");
    }
  }
}
