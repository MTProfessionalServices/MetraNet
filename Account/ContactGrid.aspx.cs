using System;
using System.Collections.Generic;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.UI.Tools;

public partial class Account_ContactGrid : MTPage
{
  protected override void OnLoadComplete(EventArgs e)
  {

    // Set argument for grid     
    MyGrid1.DataBinder.Arguments.Add("UpdateAccountId",UI.Subscriber.SelectedAccount._AccountID.ToString());

    Account acc = UI.Subscriber.SelectedAccount;
    var contactsOnSelectedAccount = (List<ContactView>)Utils.GetProperty(acc, "LDAP");
    List<MetraTech.DomainModel.BaseTypes.EnumData> contactsInEnum = BaseObject.GetEnumData(typeof(ContactType));
    if (contactsOnSelectedAccount.Count < contactsInEnum.Count - 1) // minus one for the crazy 'None' on the enum
    {
      var btn = new MTGridButton
        {
          ButtonID = "AddContact",
          IconClass = "add",
          JSHandlerFunction = "onAddContact"
        };

      var resourceObject = GetLocalResourceObject("AddButtonText");
      if (resourceObject != null)
        btn.ButtonText = resourceObject.ToString();
      var localResourceObject = GetLocalResourceObject("AddButtonToolTip");
      if (localResourceObject != null)
        btn.ToolTip = localResourceObject.ToString();
      MyGrid1.ToolbarButtons.Add(btn);
    }
    base.OnLoadComplete(e);
  }

  protected void Page_Load(object sender, EventArgs e)
  {


  }
}
