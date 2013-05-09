using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Interfaces;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Enums;
using System.ServiceModel;


namespace EPSServiceTest
{
  class Program
  {
    static void Main(string[] args)
    {
      RecurringPaymentsServiceClient client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      AccountIdentifier acct = new AccountIdentifier("ABCDEFGHABCDEFGH", "microsoft.com/ols");
      CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod();
      paymentMethod.AccountNumber = "4111111111111111";
      paymentMethod.City = "Boston";
      paymentMethod.Country = "US";
      paymentMethod.CustomerName = "Test User1";
      paymentMethod.State = "MA";
      paymentMethod.Street = "123 Main Street";
      paymentMethod.ZipCode = "02111";
      paymentMethod.CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Visa;
      paymentMethod.ExpirationDate = "122008";
      paymentMethod.ExpirationDateFormat = 3;

      Guid token;
      try
      {
        //MetraPaymentMethod paymentMethod1;// = new MetraPaymentMethod();
        //client.GetPaymentMethodDetail(new Guid("D26C27F0-52EE-41B7-B7D6-B682304F6C44"), out paymentMethod1);

        int accID = -2147483593;
        MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();
        //client.GetPaymentMethodSummaries(new AccountIdentifier(accID), ref paymentMethods);

        //client.AddPaymentMethod(acct, paymentMethod, out token);



        //client.DeletePaymentMethod(new Guid("00000000-0000-0000-0000-000000000000"));
        //client.UpdatePaymentMethod(new Guid("00000000-0000-0000-0000-000000000000"), paymentMethod);

        token = new Guid("B0DB5984-E057-4123-8BF3-C99D570E9674");
        AccountIdentifier accIdentifier = new AccountIdentifier(174);
        client.AssignPaymentMethodToAccount(token, accIdentifier);
      }
      catch (FaultException<MASBasicFaultDetail> exp)
      {

      }
      catch (Exception e)
      {

      }

    }
  }
}
