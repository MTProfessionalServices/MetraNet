using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;
using System.Text;
using MetraTech.PageNav.ClientProxies;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;

public partial class Account_ContactGrid : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {

    // Set argument for grid     
    MyGrid1.DataBinder.Arguments.Add("UpdateAccountId",UI.Subscriber.SelectedAccount._AccountID.ToString());

    Account acc = UI.Subscriber.SelectedAccount;
    List <ContactView> contactsOnSelectedAccount = (List<ContactView>)Utils.GetProperty(acc, "LDAP");
    List<MetraTech.DomainModel.BaseTypes.EnumData> contactsInEnum = BaseObject.GetEnumData(typeof(ContactType));
    if (contactsOnSelectedAccount.Count < contactsInEnum.Count - 1) // minus one for the crazy 'None' on the enum
    {
      MTGridButton btn = new MTGridButton();
      btn.ButtonID = "AddContact";
      btn.ButtonText = GetLocalResourceObject("AddButtonText").ToString();
      btn.IconClass = "add";
      btn.JSHandlerFunction = "onAddContact";
      btn.ToolTip = GetLocalResourceObject("AddButtonToolTip").ToString();
      MyGrid1.ToolbarButtons.Add(btn);
    }
    base.OnLoadComplete(e);
  }

  protected override void OnLoad(EventArgs e)
  {
    base.OnLoad(e);
  }
  protected void Page_Load(object sender, EventArgs e)
  {


  }
}
