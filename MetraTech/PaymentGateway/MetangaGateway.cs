// --------------------------------------------------------------------------------------------------------------------
// <copyright file="MetangaGateway.cs" company=MetraTech corp"">
//   
// </copyright>
// <summary>
//   Defines the MetangaGateway type.
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.Security.Cryptography.X509Certificates;
using System.ServiceModel;
using System.Transactions;
using MetraTech;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using MetraTech.DomainModel.MetraPay;
using System.IO;
using MetraTech.Interop.MTServerAccess;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Xml;
using PaymentBroker.Infrastructure;
using PaymentBroker.Presentation;

namespace MetraTech.MetraPay.PaymentGateway
{
    /// <summary>
    /// The metanga payment broker gateway.
    /// </summary>
    public class MetangaGateway : IPaymentGateway
    {
        private static PaymentBrokerClient client = null;
        private static string TenantName = null;
        private const string CertificateName = "*.metratech.com";
        private static PaymentProviderTenantConfiguration tenantConfiguration = null;
        private Logger m_logger = new Logger("[MetangaGateway]");

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
            if (client != null) return;

            // get payment gateway configuration and credentials
            IMTServerAccessDataSet serverAccess = new MTServerAccessDataSetClass();
            serverAccess.Initialize();
            IMTServerAccessData server = serverAccess.FindAndReturnObject("MetangaPaymentBroker");

            //We're cheating, using DatabaseType to stand for the payment server type
            tenantConfiguration = CreateTenantConfiguration(server);
            string PaymentBrokerAddress = server.ServerName;
            TenantName = server.UserName;

            // connect to payment broker using wcf
            var binding = CreateBinding();
            var uri = new Uri("https://" + PaymentBrokerAddress);
            var endpoint = new EndpointAddress(uri);
            client = new PaymentBrokerClient(binding, endpoint);

            // set the client certificate to use for authentication
            if (client.ClientCredentials == null)
            {
                throw new InvalidOperationException("Client credentials for payment broker client is null");
            }

            client.ClientCredentials.ClientCertificate.SetCertificate(StoreLocation.LocalMachine,
                                                                      StoreName.My,
                                                                      X509FindType.FindBySubjectName,
                                                                      CertificateName);
        }

        /// <summary>
        /// Validate payment method.
        /// </summary>
        /// <param name="paymentMethod">
        /// The payment method.
        /// </param>
        /// <returns>
        /// true if valid, else false.
        /// </returns>
        public bool ValidatePaymentMethod(MetraPaymentMethod paymentMethod)
        {
            // log into payment broker and set the tenant context
            var sessionId = client.CreateSession(TenantName);

            // Verify the payment method
            PaymentResponse response;
            if (paymentMethod.PaymentMethodType == PaymentType.Credit_Card)
            {
                var ccMethod = paymentMethod as CreditCardPaymentMethod;
                response = client.VerifyCreditCard(sessionId, tenantConfiguration,
                                                   Guid.Parse(ccMethod.UniqueAccountNumber),
                                                   ccMethod.CVNumber, "Merchant ref");
            }
            else
            {
                response = client.VerifyCreditCard(sessionId, tenantConfiguration, paymentMethod.PaymentInstrumentID,
                                                   null,
                                                   "Merchant ref");
            }

            // close the paymentbroker session
            client.CloseSession(sessionId);
            if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
            {
                return true;
            }

            m_logger.LogError(GetError(response));
            return false;
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
            var sessionId = client.CreateSession(TenantName);

            // Verify the payment method
            var response = client.AuthorizeCreditCard(sessionId: sessionId,
                                                      tenantConfiguration: tenantConfiguration,
                                                      creditCardId: Guid.Parse(ccPaymentMethod.UniqueAccountNumber),
                                                      cardVerificationNumber: null,
                                                      amount: paymentInfo.Amount,
                                                      currency: paymentInfo.Currency,
                                                      merchantReference: paymentInfo.InvoiceNum,
                                                      pointOfSaleMode: PointOfSaleMode.Recurring,
                                                      softDescriptor: string.Empty,
                                                      comment: string.Empty);

            // close the paymentbroker session
            client.CloseSession(sessionId);
            requestParms = "";
            warnings = "";
            if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
            {
                UpdateProviderInfo(paymentInfo.TransactionSessionId, response.ProviderReference);
                return;
            }
            warnings = GetError(response);
            m_logger.LogError(GetError(response));
            return;
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
            var sessionId = client.CreateSession(TenantName);
            string providerRef = GetProviderInfo(paymentInfo.TransactionSessionId);
            // capture the payment method
            var response = client.CaptureCreditCard(sessionId: sessionId,
                                                    tenantConfiguration: tenantConfiguration,
                                                    creditCardId: Guid.Parse(ccPaymentMethod.UniqueAccountNumber),
                                                    authorizationCode: providerRef,
                                                    amount: paymentInfo.Amount,
                                                    currency: paymentInfo.Currency,
                                                    merchantReference: paymentInfo.InvoiceNum,
                                                    pointOfSaleMode: PointOfSaleMode.Recurring,
                                                    softDescriptor: string.Empty,
                                                    comment: string.Empty);

            // close the paymentbroker session
            client.CloseSession(sessionId);

            warnings = "";
            if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
            {
                UpdateProviderInfo(paymentInfo.TransactionSessionId, response.ProviderReference);
                return;
            }
            warnings = GetError(response);
            m_logger.LogError(GetError(response));
            return;

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
            var sessionId = client.CreateSession(TenantName);

            // debit the payment method
            PaymentResponse response;
            if (paymentMethod.PaymentMethodType == PaymentType.Credit_Card)
            {
                var ccPaymentMethod = paymentMethod as CreditCardPaymentMethod;
                response = client.SaleCreditCard(sessionId: sessionId,
                                                 tenantConfiguration: tenantConfiguration,
                                                 creditCardId: Guid.Parse(ccPaymentMethod.UniqueAccountNumber),
                                                 cardVerificationNumber: ccPaymentMethod.CVNumber,
                                                 amount: paymentInfo.Amount,
                                                 currency: paymentInfo.Currency,
                                                 merchantReference: paymentInfo.InvoiceNum,
                                                 pointOfSaleMode: PointOfSaleMode.Recurring,
                                                 softDescriptor: string.Empty,
                                                 comment: string.Empty);
            }
            else
            {
                response = client.AchDebit(sessionId: sessionId,
                                           tenantConfiguration: tenantConfiguration,
                                           bankAccountId: Guid.Parse(paymentMethod.UniqueAccountNumber),
                                           amount: paymentInfo.Amount,
                                           currency: paymentInfo.Currency,
                                           merchantReference: paymentInfo.InvoiceNum,
                                           description: string.Empty,
                                           debitDate: paymentInfo.InvoiceDate);
            }

            // close the paymentbroker session
            client.CloseSession(sessionId);
            warnings = string.Empty;
            if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
            {
                UpdateProviderInfo(paymentInfo.TransactionSessionId, response.ProviderReference);
                return;
            }

            warnings = GetError(response);
            m_logger.LogError(GetError(response));
            return;
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
            var sessionId = client.CreateSession(TenantName);

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
                response = client.CreditCreditCard(sessionId: sessionId,
                                                   tenantConfiguration: tenantConfiguration,
                                                   creditCardId: Guid.Parse(paymentMethod.UniqueAccountNumber),
                                                   amount: paymentInfo.Amount,
                                                   providerReference: providerRef,
                                                   merchantReference: string.Empty);
            }
            else
            {
                response = client.AchCredit(sessionId: sessionId,
                                            tenantConfiguration: tenantConfiguration,
                                            bankAccountId: Guid.Parse(paymentMethod.UniqueAccountNumber),
                                            amount: paymentInfo.Amount,
                                            currency: paymentInfo.Currency,
                                            providerReference: providerRef,
                                            merchantReference: string.Empty,
                                            creditDate: paymentInfo.InvoiceDate,
                                            description: string.Empty);
            }

            // close the paymentbroker session
            client.CloseSession(sessionId);

            warnings = "";
            if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
            {
                return;
            }
            warnings = GetError(response);
            m_logger.LogError(GetError(response));
            return;
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
            var sessionId = client.CreateSession(TenantName);
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
                response = client.ReverseCreditCard(sessionId: sessionId,
                                                    tenantConfiguration: tenantConfiguration,
                                                    creditCardId: Guid.Parse(paymentMethod.UniqueAccountNumber),
                                                    amount: paymentInfo.Amount,
                                                    providerReference: providerRef,
                                                    merchantReference: string.Empty);
            }
            else
            {
                response = client.AchVoid(sessionId: sessionId,
                                          tenantConfiguration: tenantConfiguration,
                                          bankAccountId: Guid.Parse(paymentMethod.UniqueAccountNumber),
                                          providerReference: providerRef,
                                          merchantReference: string.Empty);
            }

            // close the paymentbroker session
            client.CloseSession(sessionId);

            warnings = "";
            if (response.MetraTechResponseCode == PaymentBrokerResponseCode.Success)
            {
                return;
            }
            warnings = GetError(response);
            m_logger.LogError(GetError(response));
            return;
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

        /// <summary>
        /// The broker type.
        /// </summary>
        private enum BrokerType
        {
            Test,
            BraintreePayments,
            ChaseOrbital,
            Cybersource,
            WorldPay,
            AuthorizeNet,
            PayPal,
            TransFirst
        }

        #endregion

        /// <summary>
        /// Construct an error message.  This is one line of code, but this way, it's easier to change the error format
        /// </summary>
        /// <param name="response">the payment response</param>
        /// <returns>an error string</returns>
        private string GetError(PaymentResponse response)
        {
            return response.ProviderResponseCode + ": " + response.ProviderResponseDescription;
        }

        private string GetProviderInfo(Guid txId)
        {
            string retVal = string.Empty;
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\ElectronicPaymentService");
            qa.SetQueryTag("__GET_PROVIDER_INFO__");
            string txInfo = qa.GetQuery();
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
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

        private void UpdateProviderInfo(Guid txId, string providerInfo)
        {
            IMTQueryAdapter qa = new MTQueryAdapter();
            qa.Init("Queries\\ElectronicPaymentService");
            qa.SetQueryTag("__UPDATE_PROVIDER_INFO__");
            string updateTx = qa.GetQuery();
            //Transaction state updates shouldn't be rolled back in case of failure.
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
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
        private PaymentProviderTenantConfiguration CreateTenantConfiguration(IMTServerAccessData brokerType)
        {
            MTXmlDocument doc = new MTXmlDocument();
            MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
            var configFile = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\PaymentBrokerConfig.xml");
            doc.Load(configFile);

            switch ((BrokerType) doc.GetNodeValueAsEnum(typeof (BrokerType), "/config/gatewayType"))
            {
                case BrokerType.Cybersource:
                    var dummy = doc.GetNodeValueAsString("/config/CyberSource/merchantId", "MetraTech");
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
    }
}