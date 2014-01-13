using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.UI.Common;

public partial class Mobile_UpdateAccount : MTAccountPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string resultSuccess = "{ \"success\": \"true\", \"errorMessage\" : \"\"}";
    string resultFailed = "{ \"success\": \"false\", \"errorMessage\" : \"%%ERROR_MESSAGE%%\" }";

    Account = UI.Subscriber.SelectedAccount;

    if (BillTo == null)
    {
      var billToContact = new ContactView { ContactType = ContactType.Bill_To };
      Account.AddView(billToContact, "LDAP");
    }

    try
    {
      BillTo.FirstName = Request["firstName"];
      BillTo.MiddleInitial = Request["middleInitial"];
      BillTo.LastName = Request["lastName"];
      BillTo.Address1 = Request["address1"];
      BillTo.Address2 = Request["address2"];
      BillTo.Address3 = Request["address3"];
      BillTo.City = Request["city"];
      BillTo.State = Request["state"];
      BillTo.Zip = Request["zip"];
      BillTo.PhoneNumber = Request["phoneNumber"];
      BillTo.Email = Request["email"];

      var update = new AccountCreation_UpdateAccount_Client
                     {
                       In_Account = Account,
                       UserName = UI.User.UserName,
                       Password = UI.User.SessionPassword
                     };
      update.Invoke();

      UI.Subscriber.SelectedAccount = Account;
      Response.Write(resultSuccess);
    }
    catch (FaultException<MASBasicFaultDetail> fe)
    {
      string message = "";
      foreach (string msg in fe.Detail.ErrorMessages)
      {
        message += msg + " ";
      }
      Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", message));
    }
    catch (Exception ex)
    {
      Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", ex.Message));
      Logger.LogError(ex.Message);
    }

  }
}
