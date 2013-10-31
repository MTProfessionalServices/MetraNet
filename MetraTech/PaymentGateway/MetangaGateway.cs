using System;
using System.Collections.Generic;
using System.Globalization;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel;
using System.Transactions;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.MetraPay;
using System.IO;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Xml;
using metratech.com.PaymentBroker;
using CreditCard = metratech.com.PaymentBroker.CreditCard;

namespace MetraTech.MetraPay.PaymentGateway
{
  /// <summary>
  /// The metanga payment broker gateway.
  /// </summary>
  public class MetangaGateway : IPaymentGateway
  {
    private static PaymentBrokerClient _client;
    private static string _tenantName;
    private const string CertificateName = "*.metratech.com";
    private static PaymentProviderTenantConfiguration _tenantConfiguration;
    private readonly Logger _logger = new Logger("[MetangaGateway]");

    #region IPaymentGateway Members
    /// <summary>
    /// Initialize the payment broker
    /// </summary>
    /// <param name="configFile">
    /// The config file.  Ignored
    /// </param>
    /// <exception cref="InvalidOperationException">
    /// </exception>
    public void Init(string configFile)
    {
      //We only want to set up the client once.
      if (_client != null) return;

      // get payment gateway configuration and credentials
      IMTServerAccessDataSet serverAccess = new MTServerAccessDataSetClass();
      serverAccess.Initialize();
      IMTServerAccessData server = serverAccess.FindAndReturnObject("MetangaPaymentBroker");

      //We're cheating, using DatabaseType to stand for the payment server type
      _tenantConfiguration = CreateTenantConfiguration(server);
      string PaymentBrokerAddress = server.ServerName;
      _tenantName = server.UserName;

      // connect to payment broker using wcf
      var binding = CreateBinding();
      var uri = new Uri("https://" + PaymentBrokerAddress);
      var endpoint = new EndpointAddress(uri);
      _client = new PaymentBrokerClient(binding, endpoint);

      // set the client certificate to use for authentication
      if (_client.ClientCredentials == null)
      {
        throw new InvalidOperationException("Client credentials for payment broker client is null");
      }

      _client.ClientCredentials.ClientCertificate.SetCertificate(StoreLocation.LocalMachine,
                                                                 StoreName.My,
                                                                 X509FindType.FindBySubjectName,
                                                                 CertificateName);
    }

   /// <summary>
    /// Authorize a charge against a credit card.
    /// </summary>
    /// <param name="ccPaymentMethod">
    /// The credit card payment method.
    /// </param>
    /// <param name="paymentInfo">
    /// The payment info.
    /// </param>
    /// <param name="requestParms">
    ///  request parameters.  Not used
    /// </param>
    /// <param name="warnings">
    /// Warnings to return if this failed.
    /// </param>
    /// <param name="timeout">
    /// The timeout.  Not used
    /// </param>
    /// <param name="cos">
    /// The class of service.  Not used.
    /// </param>
    public void AuthorizeCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo,
                                out string requestParms, out string warnings, double timeout = 0, string cos = "")
    {
      // log into payment broker and set the tenant context
      var sessionId = _client.CreateSession(_tenantName);

      // Verify the payment method
      var response = _client.AuthorizeCreditCard(sessionId,
                                                 _tenantConfiguration,
                                                 Guid.Parse(ccPaymentMethod.AccountToken),
                                                 ccPaymentMethod.CVNumber,
                                                 paymentInfo.Amount,
                                                 paymentInfo.Currency,
                                                 paymentInfo.TransactionSessionId.ToString(),
                                                 PointOfSaleMode.Recurring,
                                                 string.Empty,
                                                 string.Empty);

      // close the paymentbroker session
      _client.CloseSession(sessionId);
      requestParms = "";
      warnings = "";
      if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      {
        UpdateProviderInfo(paymentInfo.TransactionSessionId, response.ProviderReference);
        return;
      }
      warnings = GetError(response);
      _logger.LogError(GetError(response));
      throw new PaymentProcessorException("Authorize With Payment Details failed : " + GetError(response));
    }


    /// <summary>
    /// Capture a charge.
    /// </summary>
    /// <param name="ccPaymentMethod">
    /// The credit card payment method.
    /// </param>
    /// <param name="paymentInfo">
    /// The payment info.
    /// </param>
    /// <param name="requestParms">
    /// The request parms.  Not used
    /// </param>
    /// <param name="warnings">
    /// Warnings to return if this failed.
    /// </param>
    /// <param name="timeout">
    /// The timeout.  Not used
    /// </param>
    /// <param name="cos">
    /// The class of service.  Not used.
    /// </param>
    public void CaptureCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo,
                              string requestParms, out string warnings, double timeout = 0, string cos = "")
    {
      // log into payment broker and set the tenant context
      var sessionId = _client.CreateSession(_tenantName);
      string providerRef = GetProviderInfo(paymentInfo.TransactionSessionId);
      // capture the payment method
      var response = _client.CaptureCreditCard(sessionId,
                                               _tenantConfiguration,
                                               Guid.Parse(ccPaymentMethod.AccountToken),
                                               providerRef,
                                               paymentInfo.Amount,
                                               paymentInfo.Currency,
                                               paymentInfo.TransactionSessionId.ToString(),
                                               PointOfSaleMode.Recurring,
                                               string.Empty,
                                               string.Empty);

      // close the paymentbroker session
      _client.CloseSession(sessionId);

      warnings = "";
      if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      {
        UpdateProviderInfo(paymentInfo.TransactionSessionId, response.ProviderReference);
        return;
      }
      warnings = GetError(response);
      _logger.LogError(GetError(response));
      throw new PaymentProcessorException("Capture failed : " + GetError(response));
    }

    /// <summary>
    /// Debit a payment method
    /// </summary>
    /// <param name="paymentMethod">
    /// The payment method.
    /// </param>
    /// <param name="paymentInfo">
    /// The payment info.
    /// </param>
    /// <param name="warnings">
    /// Warnings to return if this failed.
    /// </param>
    /// <param name="timeout">
    /// The timeout.  Not used
    /// </param>
    /// <param name="cos">
    /// The class of service.  Not used.
    /// </param>
    public void Debit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings,
                      double timeout = 0, string cos = "")
    {
      // log into payment broker and set the tenant context
      var sessionId = _client.CreateSession(_tenantName);

      // debit the payment method
      PaymentResponse response;
      if (paymentMethod.PaymentMethodType == PaymentType.Credit_Card)
      {
        var ccPaymentMethod = (CreditCardPaymentMethod) paymentMethod;
        response = _client.SaleCreditCard(sessionId,
                                          _tenantConfiguration,
                                          Guid.Parse(ccPaymentMethod.AccountToken),
                                          ccPaymentMethod.CVNumber,
                                          paymentInfo.Amount,
                                          paymentInfo.Currency,
                                          paymentInfo.TransactionSessionId.ToString(),
                                          PointOfSaleMode.Recurring,
                                          string.Empty,
                                          string.Empty);
      }
      else
      {
        response = _client.AchDebit(sessionId,
                                    _tenantConfiguration,
                                    Guid.Parse(paymentMethod.AccountToken),
                                    paymentInfo.Amount,
                                    paymentInfo.Currency,
                                    paymentInfo.TransactionSessionId.ToString(),
                                    paymentInfo.InvoiceDate,
                                    string.Empty);
      }

      // close the paymentbroker session
      _client.CloseSession(sessionId);
      warnings = string.Empty;
      if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      {
        UpdateProviderInfo(paymentInfo.TransactionSessionId, response.ProviderReference);
        return;
      }

      warnings = GetError(response);
      _logger.LogError(GetError(response));
      throw new PaymentProcessorException("Debit failed : " + GetError(response));
    }

    /// <summary>
    /// Credit an payment method
    /// </summary>
    /// <param name="paymentMethod">
    /// The payment method.
    /// </param>
    /// <param name="paymentInfo">
    /// The payment info.
    /// </param>
    /// <param name="warnings">
    /// The warnings.  Return any warnings to the sender.
    /// </param>
    /// <param name="timeout">
    /// The timeout.  Not used
    /// </param>
    /// <param name="cos">
    /// The class of service.  Not used.
    /// </param>
    public void Credit(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings,
                       double timeout = 0, string cos = "")
    {
      // log into payment broker and set the tenant context
      var sessionId = _client.CreateSession(_tenantName);

      string providerRef = GetProviderInfo(paymentInfo.TransactionSessionId);
      if (string.IsNullOrEmpty(providerRef))
      {
        warnings = "This transaction was never debited";
        return;
      }
      // credit the payment method.  This is a little different, depending on if this is ACH or CC
      PaymentResponse response;
      if (paymentMethod.PaymentMethodType == PaymentType.Credit_Card)
      {
        response = _client.CreditCreditCard(sessionId,
                                            _tenantConfiguration,
                                            Guid.Parse(paymentMethod.AccountToken),
                                            paymentInfo.Amount,
                                            providerRef,
                                            string.Empty);
      }
      else
      {
        response = _client.AchCredit(sessionId,
                                     _tenantConfiguration,
                                     Guid.Parse(paymentMethod.AccountToken),
                                     paymentInfo.Amount,
                                     paymentInfo.Currency,
                                     providerRef,
                                     string.Empty,
                                     paymentInfo.InvoiceDate,
                                     string.Empty);
      }

      // close the paymentbroker session
      _client.CloseSession(sessionId);

      warnings = "";
      if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      {
        return;
      }
      warnings = GetError(response);
      _logger.LogError(GetError(response));
      throw new PaymentProcessorException("Credit failed : " + GetError(response));
    }

    /// <summary>
    /// Void a transaction
    /// </summary>
    /// <param name="paymentMethod">
    /// The payment method.
    /// </param>
    /// <param name="paymentInfo">
    /// The payment info.
    /// </param>
    /// <param name="warnings">
    /// The warnings.  Return any warnings to the sender.
    /// </param>
    /// <param name="timeout">
    /// The timeout.  Not used
    /// </param>
    /// <param name="cos">
    /// The class of service.  Not used.
    /// </param>
    public void Void(MetraPaymentMethod paymentMethod, ref MetraPaymentInfo paymentInfo, out string warnings,
                     double timeout = 0, string cos = "")
    {
      // log into payment broker and set the tenant context
      var sessionId = _client.CreateSession(_tenantName);
      string providerRef = GetProviderInfo(paymentInfo.TransactionSessionId);
      if (string.IsNullOrEmpty(providerRef))
      {
        warnings = "This transaction was never debited";
        return;
      }
      // Void the payment method.  This is a little different, depending on if this is ACH or CC
      PaymentResponse response;
      if (paymentMethod.PaymentMethodType == PaymentType.Credit_Card)
      {
        response = _client.ReverseCreditCard(sessionId,
                                             _tenantConfiguration,
                                             Guid.Parse(paymentMethod.AccountToken),
                                             paymentInfo.Amount,
                                             providerRef,
                                             string.Empty);
      }
      else
      {
        response = _client.AchVoid(sessionId,
                                   _tenantConfiguration,
                                   Guid.Parse(paymentMethod.AccountToken),
                                   providerRef,
                                   string.Empty);
      }

      // close the paymentbroker session
      _client.CloseSession(sessionId);

      warnings = "";
      if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      {
        return;
      }
      warnings = GetError(response);
      _logger.LogError(GetError(response));
      throw new PaymentProcessorException("Void failed : " + GetError(response));
    }

    public bool GetACHTransactionStatus(string transactionId, out string warnings)
    {
      throw new NotImplementedException();
    }

    public void DownloadACHTransactionsReport(string url, out string warnings)
    {
      throw new NotImplementedException();
    }

    public void GetCreditCardUpdates(string transactionId, List<CreditCardPaymentMethod> cardsToUpdate,
                                     ref List<CreditCardPaymentMethod> updatedCards)
    {
      throw new NotImplementedException();
    }

    /// <summary>
    ///  reverse authorized charge.
    /// </summary>
    /// <param name="ccPaymentMethod">
    /// The credit card payment method.
    /// </param>
    /// <param name="paymentInfo">
    /// The payment info.
    /// </param>
    /// <param name="requestParams">
    /// The request params.  Not used
    /// </param>
    /// <param name="warnings">
    /// The warnings.  Used to return error messages
    /// </param>
    /// <param name="timeout">
    /// The timeout.  Not used
    /// </param>
    /// <param name="cos">
    /// The class of service.  Not used.
    /// </param>
    public void ReverseAuthorizedCharge(CreditCardPaymentMethod ccPaymentMethod, ref MetraPaymentInfo paymentInfo,
                                        string requestParams, out string warnings, double timeout = 0,
                                        string cos = "")
    {
      throw new NotImplementedException();
      // Metanga payment broker doesn't let you reverse an authorized change.  I will leave the code below in place,
      // in case they do end up implementing it.

      // log into payment broker and set the tenant context
      //var sessionId = client.CreateSession(TenantName);
      //string providerRef = GetProviderInfo(paymentInfo.TransactionSessionId);
      //if (string.IsNullOrEmpty(providerRef))
      //{
      //    warnings = "This transaction was never debited";
      //    return;
      //}
      //// Reverse the authorized charge.
      //PaymentResponse response = client.ReverseCreditCard(sessionId: sessionId,
      //                                                    tenantConfiguration: tenantConfiguration,
      //                                                    creditCardId: Guid.Parse(ccPaymentMethod.AccountNumber),
      //                                                    amount: paymentInfo.Amount,
      //                                                    providerReference: providerRef,
      //                                                    merchantReference: string.Empty);

      //// close the paymentbroker session
      //client.CloseSession(sessionId);

      //warnings = "";
      //if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      //{
      //    return;
      //}

      //warnings = GetError(response);
      //m_logger.LogError(GetError(response));
      //return;
    }

    public void UpdatePaymentMethod(MetraPaymentMethod paymentMethod, string currency)
    {
      //Currently it does not support ACH
      if (paymentMethod == null) throw new ArgumentNullException("paymentMethod");
      if (paymentMethod.PaymentMethodType != PaymentType.Credit_Card)
        return;

      if (string.IsNullOrEmpty(currency)) throw new ArgumentNullException("currency");

      var sessionId = _client.CreateSession(_tenantName);
      try
      {
        UpdatePaymentMethod(paymentMethod, currency, sessionId);
      }
      finally
      {
        _client.CloseSession(sessionId);
      }
    }

    /// <summary>
    /// Validate payment method.
    /// </summary>
    /// <param name="paymentMethod">
    /// The payment method.
    /// </param>
    /// <param name="currency"></param>
    /// <returns>
    /// true if valid, else false.
    /// </returns>
    public bool ValidatePaymentMethod(MetraPaymentMethod paymentMethod, string currency)
    {
      //Currently it does not support ACH
      if (paymentMethod == null) throw new ArgumentNullException("paymentMethod");
      if (paymentMethod.PaymentMethodType != PaymentType.Credit_Card)
        return true;

      if (string.IsNullOrEmpty(currency)) throw new ArgumentNullException("currency");

      var sessionId = _client.CreateSession(_tenantName);
      try
      {
        return ValidatePaymentMethod(paymentMethod, currency, sessionId);
      }
      finally
      {
        _client.CloseSession(sessionId);
      }
    }

    /// <summary>
    /// The broker type.
    /// </summary>
    private enum BrokerType
    {
      //Test,
      //BraintreePayments,
      //ChaseOrbital,
      Cybersource,
      //WorldPay,
      //AuthorizeNet,
      //PayPal,
      //TransFirst
    }

    #endregion

    /// <summary>
    /// Construct an error message.  This is one line of code, but this way, it's easier to change the error format
    /// </summary>
    /// <param name="response">the payment response</param>
    /// <returns>an error string</returns>
    private static string GetError(PaymentResponse response)
    {
      return response.ProviderResponseCode + ": " + response.ProviderResponseDescription;
    }

    private static string GetProviderInfo(Guid txId)
    {
      var retVal = string.Empty;
      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init("Queries\\ElectronicPaymentService");
      qa.SetQueryTag("__GET_PROVIDER_INFO__");
      var txInfo = qa.GetQuery();
      using (new TransactionScope(TransactionScopeOption.Suppress,
                                  new TransactionOptions(),
                                  EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(txInfo))
          {
            stmt.AddParam("id_payment_transaction", MTParameterType.String, txId.ToString());
            using (IMTDataReader dataReader = stmt.ExecuteReader())
            {
              if (dataReader.Read())
              {
                retVal = dataReader.GetString("nm_provider_info");
              }
            }
          }
        }
      }

      return retVal;
    }

    private static void UpdateProviderInfo(Guid txId, string providerInfo)
    {
      IMTQueryAdapter qa = new MTQueryAdapter();
      qa.Init("Queries\\ElectronicPaymentService");
      qa.SetQueryTag("__UPDATE_PROVIDER_INFO__");
      var updateTx = qa.GetQuery();
      //Transaction state updates shouldn't be rolled back in case of failure.
      using (new TransactionScope(TransactionScopeOption.Suppress,
                                  new TransactionOptions(),
                                  EnterpriseServicesInteropOption.Full))
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
        {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(updateTx))
          {

            stmt.AddParam("id_payment_transaction", MTParameterType.String, txId.ToString());
            stmt.AddParam("provider_info", MTParameterType.String, providerInfo);
            stmt.ExecuteNonQuery();
            stmt.ClearParams();
          }
        }
      }
    }

    /// <summary>
    /// The PaymentProviderTenantConfiguration is the base class for the configuration of any
    /// payment gateway. The one used below is a test gateway that won't generate an actual
    /// request to a real payment gateway.
    /// Derived classes of the PaymentProviderTenantConfiguration include:
    /// - TestTenantConfiguration
    /// - BraintreePaymentsTenantConfiguration
    /// - ChaseOrbitalTenantConfiguration
    /// - CybersourceTenantConfiguration
    /// - WorldPayTenantConfiguration
    /// - AuthorizeNetTenantConfiguration
    /// - PayPalTenantConfiguration
    /// - TransFirstTenantConfiguration
    /// </summary>
    /// <returns></returns>
    private static PaymentProviderTenantConfiguration CreateTenantConfiguration(IMTServerAccessData brokerType)
    {
      var doc = new MTXmlDocument();
      Interop.RCD.IMTRcd rcd = new Interop.RCD.MTRcd();
      var configFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\PaymentBrokerConfig.xml");
      doc.Load(configFile);

      switch ((BrokerType) doc.GetNodeValueAsEnum(typeof (BrokerType), "/config/gatewayType"))
      {
        case BrokerType.Cybersource:
          return new CybersourceTenantConfiguration
            {
              MerchantId = doc.GetNodeValueAsString("/config/CyberSource/merchantId", "MetraTech"),
              Password = brokerType.Password,
              TestMode = doc.GetNodeValueAsBool("/config/CyberSource/testMode", true),
              UserName = doc.GetNodeValueAsString("/config/CyberSource/userName", "GavinSteyn"),
              TransactionKey = doc.GetNodeValueAsString("/config/CyberSource/transactionKey", "dummy")
            };
        default:
          return new TestTenantConfiguration
            {
              TestMode = true,
              VisaZeroAuthBackup = false
            };
      }
    }

    private static WSHttpBinding CreateBinding()
    {
      return new WSHttpBinding
        {
          Security =
            {
              Mode = SecurityMode.TransportWithMessageCredential,
              Message =
                {
                  ClientCredentialType = MessageCredentialType.Certificate,
                  NegotiateServiceCredential = false,
                  EstablishSecurityContext = false
                }
            },
          OpenTimeout = new TimeSpan(0, 3, 0),
          CloseTimeout = new TimeSpan(0, 3, 0),
          SendTimeout = new TimeSpan(0, 3, 0),
          ReceiveTimeout = new TimeSpan(0, 10, 0)
        };
    }

    #region Helper methods

    private void UpdatePaymentMethod(MetraPaymentMethod metraMethod, string currency, Guid sessionId)
    {
      var instrumentId = Guid.Parse(metraMethod.AccountToken);
      var brokerMethod = _client.GetPaymentInstrument(sessionId, instrumentId);

      if (brokerMethod == null)
      {
        var error =
          string.Format(CultureInfo.CurrentCulture,
                        "Payment method with ID {0} is not found in Payment Broker database",
                        instrumentId);
        _logger.LogError(error);
        throw new PaymentProcessorException(error);
      }

      var creditCard = ConvertToCreditCard(metraMethod, brokerMethod);
      if (creditCard != null)
      {
        _client.EditPaymentInstrument(sessionId, instrumentId, creditCard);
        try
        {
          ValidatePaymentMethod(metraMethod, currency, sessionId);
          return;
        }
        catch (PaymentProcessorException)
        {
          _client.EditPaymentInstrument(sessionId, instrumentId, brokerMethod);
          throw;
        }
      }

      //var bankAccount = ConvertToBankAccount(metraMethod, brokerMethod);
      //if (bankAccount != null)
      //{
      //  _client.EditPaymentInstrument(sessionId, instrumentId, bankAccount);
      //  return;
      //}

      var error2 =
        string.Format(CultureInfo.CurrentCulture,
                      "Payment method with ID {0} from Payment Broker database cannot beconverted to MetraNet entity",
                      instrumentId);
      _logger.LogError(error2);
      throw new PaymentProcessorException(error2);
    }

    private bool ValidatePaymentMethod(MetraPaymentMethod paymentMethod, string currency, Guid sessionId)
    {
      var ccMethod = (CreditCardPaymentMethod)paymentMethod;
      var instrumentId = Guid.Parse(paymentMethod.AccountToken);
      var response = _client.VerifyCreditCard(sessionId, _tenantConfiguration, instrumentId, ccMethod.CVNumber,
                                              "Merchant ref", currency);

      if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
      {
        return true;
      }

      _logger.LogError(GetError(response));
      throw new PaymentProcessorException("Verify With Payment Details failed : " + GetError(response));
    }
    
    private static CreditCard ConvertToCreditCard(MetraPaymentMethod metraMethod, PaymentMethod brokerMethod)
    {
      var metraCard = metraMethod as CreditCardPaymentMethod;
      if (metraCard == null) return null;

      var oldCard = (CreditCard) brokerMethod;
      var newCard = new CreditCard
        {
          Address1 = oldCard.Address1,
          Address2 = oldCard.Address2,
          Address3 = oldCard.Address3,
          CardVerificationNumber = oldCard.CardVerificationNumber,
          City = oldCard.City,
          Country = oldCard.Country,
          CreditCardNumber = oldCard.CreditCardNumber,
          CreditCardType = oldCard.CreditCardType,
          Email = oldCard.Email,
          ExpirationDate = oldCard.ExpirationDate,
          FirstName = metraCard.FirstName,
          MiddleName = metraCard.MiddleName,
          LastName = metraCard.LastName
        };

      newCard.Address1 = metraCard.Street;
      newCard.Address2 = metraCard.Street2;
      //brokerCard.Country = metraCard.Country.ToString(); PaymentBroker Country has 2 chars but MetraNet Country 3 chars
      newCard.City = metraCard.City;
      newCard.State = metraCard.Country == PaymentMethodCountry.USA && metraCard.State != null
                           ? metraCard.State.ToUpperInvariant()
                           : metraCard.State;
      newCard.Postal = metraCard.ZipCode;
      newCard.ExpirationDate = metraCard.ExpirationDate;
      return newCard;
    }

    //private static BankAccount ConvertToBankAccount(MetraPaymentMethod metraMethod, PaymentMethod brokerMethod)
    //{
    //  var metraAch = metraMethod as ACHPaymentMethod;
    //  if (metraAch == null) return null;

    //  var brokerAch = (BankAccount) brokerMethod;
    //  brokerAch.BankName = metraAch.BankName;
    //  brokerAch.RoutingNumber = metraAch.RoutingNumber;
    //  return brokerAch;
    //}

    #endregion
  }
}