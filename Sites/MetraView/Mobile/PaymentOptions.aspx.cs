using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;

public partial class Mobile_PaymentOptions : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    var acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
    var client = new RecurringPaymentsServiceClient();
    client.ClientCredentials.UserName.UserName = UI.User.UserName;
    client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
    MTList<MetraPaymentMethod> items = new MTList<MetraPaymentMethod>();
    client.GetPaymentMethodSummaries(acct, ref items);

    var sb = new StringBuilder();
    sb.Append("[");
    const string row = "{\"paymentType\" : \"%%PAYMENT_TYPE%%\", \"type\" : \"%%TYPE%%\",\"endingDigits\" : \"%%ENDING_DIGITS%%\", \"piid\" : \"%%PIID%%\", \"priority\" : \"%%PRIORITY%%\"}";

    var i = 0;
    foreach(var method in items.Items)
    {
      i++;
      var str = row;

      str = str.Replace("%%PAYMENT_TYPE%%", method.PaymentMethodType.ToString());
      if(method.PaymentMethodType.ToString() == "ACH")
      {
        var ach = method as ACHPaymentMethod;
        str = str.Replace("%%TYPE%%", ach.AccountType.ToString());
      }
      else
      {
        var credit = method as CreditCardPaymentMethod;
        str = str.Replace("%%TYPE%%", credit.CreditCardTypeValueDisplayName);
      }
      str = str.Replace("%%ENDING_DIGITS%%", method.AccountNumber.Replace("*", ""));
      str = str.Replace("%%PIID%%", method.PaymentInstrumentIDString);
      str = str.Replace("%%PRIORITY%%", method.Priority.ToString());
      sb.Append(str);
      if(items.Items.Count != i)
      {
        sb.Append(", ");
      }
    }

    sb.Append("]");
    Response.Write(sb.ToString());
  }
}
