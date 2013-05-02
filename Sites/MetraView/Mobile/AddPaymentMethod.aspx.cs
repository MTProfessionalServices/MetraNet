using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.MetraPay;
using MetraTech.UI.Common;
using CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType;

public partial class Mobile_AddPaymentMethod : MTAccountPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string resultSuccess = "{ \"success\": \"true\", \"errorMessage\" : \"\"}";
    string resultFailed = "{ \"success\": \"false\", \"errorMessage\" : \"%%ERROR_MESSAGE%%\" }";

    Account = UI.Subscriber.SelectedAccount;

    try
    {
      int paymentMethod = int.Parse(Request["paymentMethod"]);

      if (paymentMethod == 0)
      {
        // Add Credit /Debit
        CreditCardPaymentMethod CreditCard = new CreditCardPaymentMethod();

        int cardType = int.Parse(Request["creditCardNumber"][0].ToString());
        // * 3 - travel/entertainment cards (such as American Express and Diners Club)
        // * 4 - Visa
        // * 5 - MasterCard
        // * 6 - Discover Card 
        switch (cardType)
        {
          case 3: CreditCard.CreditCardType = CreditCardType.American_Express;
            break;
          case 4: CreditCard.CreditCardType = CreditCardType.Visa;
            break;
          case 5: CreditCard.CreditCardType = CreditCardType.MasterCard;
            break;
          case 6: CreditCard.CreditCardType = CreditCardType.Discover;
            break; 
        }

        CreditCard.AccountNumber = Request["creditCardNumber"].Replace("-", "");
        CreditCard.CVNumber = Request["CVV"];
        CreditCard.ExpirationDate = Request["expDate"];
        CreditCard.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;
        CreditCard.Priority = 1;

        // For mobile, we grab this info off the account
        CreditCard.FirstName = BillTo.FirstName;
        CreditCard.MiddleName = BillTo.MiddleInitial;
        CreditCard.LastName = BillTo.LastName;
        CreditCard.Street = BillTo.Address1;
        CreditCard.Street2 = BillTo.Address2;
        CreditCard.City = BillTo.City;
        CreditCard.State = BillTo.State;
        CreditCard.ZipCode = BillTo.Zip;
        CreditCard.Country = (PaymentMethodCountry)BillTo.Country;

        AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        Guid paymentInstrumentID;

        var metraPayManager = new MetraPayManager(UI);
        paymentInstrumentID = metraPayManager.AddPaymentMethod(acct, (MetraPaymentMethod)CreditCard);
      }
      else
      {
        // Add ACH
        ACHPaymentMethod ACH = new ACHPaymentMethod();
        ACH.AccountType = int.Parse(Request["accountType"]) == 0 ? BankAccountType.Checking : BankAccountType.Savings;
        ACH.AccountNumber = Request["accountNumber"];
        ACH.RoutingNumber = Request["routingNumber"];
        
        // For mobile, we grab this info off the account
        ACH.FirstName = BillTo.FirstName;
        ACH.MiddleName = BillTo.MiddleInitial;
        ACH.LastName = BillTo.LastName;
        ACH.Street = BillTo.Address1;
        ACH.Street2 = BillTo.Address2;
        ACH.City = BillTo.City;
        ACH.State = BillTo.State;
        ACH.ZipCode = BillTo.Zip;
        ACH.Country = (PaymentMethodCountry) BillTo.Country;

        AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
        ACH.Priority = 1;

        Guid paymentInstrumentID;
        var metraPayManager = new MetraPayManager(UI);
        paymentInstrumentID = metraPayManager.AddPaymentMethod(acct, (MetraPaymentMethod)ACH);
      }

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
