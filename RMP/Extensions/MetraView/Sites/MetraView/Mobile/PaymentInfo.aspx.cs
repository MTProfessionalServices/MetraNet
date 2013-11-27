using System;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web.UI;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.MetraPay;
using MetraTech.UI.Common;

public partial class Mobile_PaymentInfo : MTPage
{
  new public UIManager UI
  {
    get { return ((MTPage)Page).UI; }
  }
  public InvoiceReport InvoiceReport { get; set; }
  public Payment Payment { get; set; }
  private BillManager billManager;
  private PaymentInfo paymentInfo;

  public string EndingDigits { get; set; }
  public string PaymentType { get; set; }
  public string PIID { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
    billManager = new BillManager(UI);
    paymentInfo = billManager.PaymentInformation;

    PaymentType = "none";
    var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
    var client = new RecurringPaymentsServiceClient();
    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    MTList<MetraPaymentMethod> items = new MTList<MetraPaymentMethod>();
    client.GetPaymentMethodSummaries(acct, ref items);

    foreach (var method in items.Items)
    {

       if(method.Priority == 1)
       {
         if (method.PaymentMethodType.ToString() == "ACH")
         {
           var ach = method as ACHPaymentMethod;
           PaymentType = ach.AccountType.ToString();
           EndingDigits = ach.AccountNumber.Replace("*", "");
         }
         else
         {
           var credit = method as CreditCardPaymentMethod;
           PaymentType = credit.CreditCardTypeValueDisplayName;
           EndingDigits = credit.AccountNumber.Replace("*", "");
         }
         PIID = method.PaymentInstrumentIDString;
         break;
       }
    }
  }

  protected string GetPreviousBalance()
  {
    if (paymentInfo == null)
    {
      return "";
    }

    return paymentInfo.AmountDue.ToString("F2");
  }

  protected string GetPreviousBalanceAsString()
  {
    if (paymentInfo == null)
    {
      return 0M.ToDisplayAmount(UI);
    }

    return paymentInfo.AmountDueAsString;
  }
}
