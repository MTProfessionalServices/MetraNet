using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.MetraPay.Client;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;


namespace MPTest
{
  class Program
  {
    static void Main(string[] args)
    {
      string serverName = "localhost";
      int serverPort = 51515;
      string identityName = "ActivityServicesCert";
      MetraPayClient client = new MetraPayClient(serverName,serverPort,identityName, "CyberSource_US");

      client.ClientCredentials.ClientCertificate.SetCertificate(StoreLocation.LocalMachine,
            StoreName.Root, X509FindType.FindBySubjectName, "ActivityServicesCert");

      CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod();
      paymentMethod.AccountNumber = "4111111111111111";
      paymentMethod.CVNumber = "111";
      paymentMethod.City = "Boston";
      paymentMethod.Country = PaymentMethodCountry.USA;
      paymentMethod.FirstName = "Test";
      paymentMethod.LastName = "User1";
      paymentMethod.State = "MA";
      paymentMethod.Street = "123 Main Street";
      paymentMethod.ZipCode = "02111";
      paymentMethod.CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Visa;
      paymentMethod.ExpirationDate = "122008";
      paymentMethod.ExpirationDateFormat = 3;

      Guid paymentInstrumentID = new Guid("4C2C721E-EE1F-461F-BA28-D2AC61303AD0");
      AccountIdentifier accIdentifier = new AccountIdentifier("ABCDEFGHABCDEFG1", "microsoft.com/ols");
      Guid tmp;
      try
      {
          client.AddPaymentMethod(paymentMethod, out tmp);
        //client.UpdatePaymentInstrument(paymentInstrumentID, paymentMethod);
      }
      catch (FaultException<MASBasicFaultDetail>)
      {

      }


      
    }
  }
}
