using System;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.MetraPay;
using MetraTech.UI.Common;

public partial class Mobile_PaymentHistory : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    UsageHistoryServiceClient client = new UsageHistoryServiceClient();
    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    MTList<Payment> items = new MTList<Payment>();

    var billManager = new BillManager(UI);
    AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
    client.GetPaymentHistory(acct, billManager.GetLanguageCode(), ref items);
    
    var sb = new StringBuilder();
    sb.Append("[");
    const string row = "{\"date\" : \"%%DATE%%\",  \"paymentType\" : \"%%PAYMENT_TYPE%%\", \"cardNumber\" : \"%%CARD_NUMBER%%\",\"amount\" : \"%%AMOUNT%%\"}";

    var i = 0;
    foreach (var payment in items.Items)
    {
      i++;
      var str = row;

      str = str.Replace("%%PAYMENT_TYPE%%", payment.CreditCardType.ToString());
      str = str.Replace("%%DATE%%", payment.PaymentDate.ToShortDateString());
      str = str.Replace("%%CARD_NUMBER%%",payment.CheckOrCardNumber);
      str = str.Replace("%%AMOUNT%%", payment.AmountAsString.Replace("-", ""));
      sb.Append(str);
      if (items.Items.Count != i)
      {
        sb.Append(", ");
      }
    }

    sb.Append("]");
    Response.Write(sb.ToString());
  }
}
