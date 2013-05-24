// --------------------------------------------------------------------------------------------------------------------
// <copyright file="MetangaGatewayTest.cs" company="MetraTech">
//   
// </copyright>
// <summary>
//   This is a test class for MetangaGatewayTest and is intended
//   to contain all MetangaGatewayTest Unit Tests
// </summary>
// --------------------------------------------------------------------------------------------------------------------

namespace MetraTech.FunctionalTests
{
    using System;
    using System.Globalization;
    using System.Linq;
    using System.Net.Http;
    using System.Transactions;
    using DataAccess;
    using DomainModel.Enums;
    using DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
    using DomainModel.MetraPay;
    using Interop.QueryAdapter;
    using MetraPay.PaymentGateway;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using Newtonsoft.Json.Linq;


    /// <summary>
    /// This is a test class for MetangaGatewayTest and is intended
    /// to contain all MetangaGatewayTest Unit Tests
    /// </summary>
    [TestClass()]
    public class MetangaGatewayTest
    {


        private static Guid _accountId;
        private const string PaymentBrokerAddress = "https://andy.mypayaccesstest.com";
        
        private TestContext testContextInstance;

        /// <summary>
        /// LogPaymentHistory emulates what EPS does to insert a transaction into the database before it calls MetraPay, which would call the gateway.
        /// </summary>
       /// <param name="pm">
        /// The pm.
        /// </param>
        /// <param name="paymentInfo">
        /// The payment info.
        /// </param>
        private void LogPaymentHistory(MetraPaymentMethod pm, MetraPaymentInfo paymentInfo)
        {
            int idAcc = 123;
            TransactionType txType = TransactionType.DEBIT;

            string nextTxnID = paymentInfo.TransactionSessionId.ToString();

            //Don't roll back inserts in case of failure, so that we can clean them up later.
            using (TransactionScope scope = new TransactionScope(TransactionScopeOption.Suppress,
                                                                 new TransactionOptions(),
                                                                 EnterpriseServicesInteropOption.Full))
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ElectronicPaymentService"))
                {
                    IMTQueryAdapter qa = new MTQueryAdapter();
                    qa.Init("Queries\\ElectronicPaymentService");
                    qa.SetQueryTag("__INSERT_PAYMENT_HISTORY__");
                    string payHistStmt = qa.GetQuery();
                    using (IMTPreparedStatement stmtHistory = conn.CreatePreparedStatement(payHistStmt))
                    {
                        //Serialize PaymentInfo to a byte[]
                        System.IO.MemoryStream piStream = new System.IO.MemoryStream();
                        var _BinaryFormatter = new System.Runtime.Serialization.Formatters.Binary.BinaryFormatter();
                        _BinaryFormatter.Serialize(piStream, paymentInfo);


                        stmtHistory.AddParam("id_payment_transaction", MTParameterType.String, nextTxnID);
                        stmtHistory.AddParam("id_acct", MTParameterType.Integer, idAcc);
                        stmtHistory.AddParam("dt_transaction", MTParameterType.DateTime, MetraTime.Now);
                        // should this be consistent on both sides?
                        stmtHistory.AddParam("n_payment_method_type", MTParameterType.Integer,
                                             EnumHelper.GetDbValueByEnum(pm.PaymentMethodType));
                        stmtHistory.AddParam("nm_truncd_acct_num", MTParameterType.String, "1234");
                        if (pm.PaymentMethodType == PaymentType.Credit_Card)
                        {
                            stmtHistory.AddParam("id_creditcard_type", MTParameterType.Integer,
                                                 EnumHelper.GetDbValueByEnum(
                                                     ((CreditCardPaymentMethod) pm).CreditCardType));
                        }
                        else
                        {
                            stmtHistory.AddParam("id_creditcard_type", MTParameterType.Integer, null);
                        }

                        if (pm.PaymentMethodType == PaymentType.ACH)
                        {
                            stmtHistory.AddParam("n_account_type", MTParameterType.Integer,
                                                 EnumHelper.GetDbValueByEnum(((ACHPaymentMethod) pm).AccountType));
                            // for ach
                        }
                        else
                        {
                            stmtHistory.AddParam("n_account_type", MTParameterType.Integer, null); // for ach
                        }

                        stmtHistory.AddParam("nm_description", MTParameterType.String, " ");
                        stmtHistory.AddParam("n_currency", MTParameterType.String, "USD");
                        stmtHistory.AddParam("n_amount", MTParameterType.Decimal, 130.50);
                        stmtHistory.AddParam("n_transaction_type", MTParameterType.String, txType.ToString());
                        stmtHistory.AddParam("n_state", MTParameterType.String,
                                             TransactionState.RECEIVED_REQUEST.ToString());
                        stmtHistory.AddParam("id_payment_instrument", MTParameterType.String,
                                             pm.PaymentInstrumentIDString);
                        stmtHistory.AddParam("payment_info", MTParameterType.Blob, piStream.ToArray());
                        
                        stmtHistory.ExecuteNonQuery();
                        stmtHistory.ClearParams();
                    }

                    using (MTComSmartPtr<IMTQueryAdapter> queryAdapter = new MTComSmartPtr<IMTQueryAdapter>())
                    {
                        queryAdapter.Item = new MTQueryAdapter();
                        queryAdapter.Item.Init("Queries\\ElectronicPaymentService");
                        queryAdapter.Item.SetQueryTag("__INSERT_PAYMENT_HISTORY_DETAILS__");

                        using (
                            IMTPreparedStatement stmtHistory =
                                conn.CreatePreparedStatement(queryAdapter.Item.GetRawSQLQuery(true)))
                        {
                            if (paymentInfo.MetraPaymentInvoices == null ||
                                paymentInfo.MetraPaymentInvoices.Count == 0)
                            {
                                stmtHistory.AddParam(MTParameterType.String, nextTxnID);
                                stmtHistory.AddParam(MTParameterType.Integer, 1);
                                stmtHistory.AddParam(MTParameterType.String, paymentInfo.InvoiceNum);
                                stmtHistory.AddParam(MTParameterType.DateTime, paymentInfo.InvoiceDate);
                                stmtHistory.AddParam(MTParameterType.String, paymentInfo.PONum);
                                stmtHistory.AddParam(MTParameterType.Decimal, paymentInfo.Amount);

                                stmtHistory.ExecuteNonQuery();
                                stmtHistory.ClearParams();
                            }
                            else
                            {
                                int idPmtTxnDtls = 1;

                                foreach (MetraPaymentInvoice invoice in paymentInfo.MetraPaymentInvoices)
                                {
                                    stmtHistory.AddParam(MTParameterType.String, nextTxnID);
                                    stmtHistory.AddParam(MTParameterType.Integer, idPmtTxnDtls);
                                    stmtHistory.AddParam(MTParameterType.String, invoice.InvoiceNum);
                                    stmtHistory.AddParam(MTParameterType.DateTime, invoice.InvoiceDate);
                                    stmtHistory.AddParam(MTParameterType.String, invoice.PONum);
                                    stmtHistory.AddParam(MTParameterType.Decimal, invoice.AmountToPay);

                                    stmtHistory.ExecuteNonQuery();
                                    stmtHistory.ClearParams();

                                    idPmtTxnDtls++;
                                }
                            }
                        }
                    }
                }
            }
        }


        private static MetraPaymentInfo GetPaymentInfo()
        {
            return new MetraPaymentInfo
            {
                Amount = 50.0M,
                Currency = "USD",
                TransactionID = "420",
                Description = "Payment",
                InvoiceNum = "Dummy",
                InvoiceDate = DateTime.Now,
                TransactionSessionId = Guid.NewGuid()
            };
        }
        
        private CreditCardPaymentMethod InitializeCCMethod()
        {
            CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod
                {
                    SafeAccountNumber = _accountId.ToString(),
                    CVNumber = "123",
                    City = "Waltham",
                    Country = PaymentMethodCountry.USA,
                    FirstName = "Andy",
                    LastName = "Knowles",
                    State = "MA",
                    Street = "200 West St.",
                    Street2 = string.Empty,
                    ZipCode = "02451",
                    CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Visa,
                    ExpirationDate = "12/2020",
                    ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY
                };
            foreach (var val in Enum.GetValues(typeof (PaymentMethodCountry)).Cast<PaymentMethodCountry>())
            {
                
            }
            var temp = MetraTech.DomainModel.Enums.EnumHelper.GetValueByEnum(PaymentMethodCountry.Afghanistan);
                    
            return paymentMethod;
        }

        private static Guid CreateCreditCardInPaymentBroker()
        {
            const string creditCardNumber = "4111111111111111";
            const string creditCardType = "Visa";
            const string cardVerificationNumber = "123";
            const string cardExpiration = "12/2018";
            const string address1 = "200 West St.";
            const string city = "Waltham";
            const string country = "US";
            const string email = "aknowles@metratech.com";
            const string firstName = "Andy";
            const string lastName = "Knowles";
            const string middleInitial = "";
            const string phoneNumber = "781-839-8300";
            const string zip = "02451";
            const string state = "MA";

            // Send request to payment broker to obtain a credit card token
            return CreditCard.CreateCreditCard(PaymentBrokerAddress, address1, string.Empty, string.Empty,
                                               cardVerificationNumber, city, country,
                                               creditCardNumber, creditCardType,
                                               email, cardExpiration, firstName,
                                               lastName, middleInitial, phoneNumber,
                                               zip, state);
        }




        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get { return testContextInstance; }
            set { testContextInstance = value; }
        }

        #region Additional test attributes

        // 
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            _accountId = CreateCreditCardInPaymentBroker();
        }

        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //

        #endregion

        /// <summary>
        /// A test for ValidatePaymentMethod
        /// </summary>
        [TestMethod]
        public void ValidatePaymentMethodTest()
        {
            MetangaGateway target = new MetangaGateway();
            target.Init(string.Empty);
            MetraPaymentMethod paymentMethod = InitializeCCMethod();
            Assert.IsTrue(target.ValidatePaymentMethod(paymentMethod));
        }

        /// <summary>
        ///A test for ReverseAuthorizedCharge
        ///</summary>
        [TestMethod()]
        public void ReverseAuthorizedChargeTest()
        {
            var target = new MetangaGateway();
            target.Init(string.Empty);
            CreditCardPaymentMethod ccPaymentMethod = InitializeCCMethod();
            var paymentInfo = GetPaymentInfo();
            LogPaymentHistory(ccPaymentMethod, paymentInfo);
            string requestParams = string.Empty;
            string warnings = string.Empty;
            target.AuthorizeCharge(ccPaymentMethod, ref paymentInfo, out requestParams, out warnings, 0, string.Empty);
            Assert.AreEqual(warnings, string.Empty);
            target.ReverseAuthorizedCharge(ccPaymentMethod, ref paymentInfo, requestParams, out warnings, 0, string.Empty);
            Assert.AreEqual(warnings, string.Empty);
        }

        /// <summary>
        ///A test for AuthorizeCharge
        ///</summary>
        [TestMethod()]
        public void AuthorizeChargeTest()
        {
            var target = new MetangaGateway();
            target.Init(string.Empty);
            CreditCardPaymentMethod ccPaymentMethod = InitializeCCMethod(); 
            var paymentInfo = GetPaymentInfo();
            string requestParms = string.Empty; 
            string warnings = string.Empty; 
            target.AuthorizeCharge(ccPaymentMethod, ref paymentInfo, out requestParms, out warnings, 0, string.Empty);
            Assert.AreEqual(warnings, string.Empty);
        }

        

        /// <summary>
        ///A test for CaptureCharge
        ///</summary>
        [TestMethod()]
        public void CaptureChargeTest()
        {
            var target = new MetangaGateway();
            target.Init(string.Empty);
            CreditCardPaymentMethod ccPaymentMethod = InitializeCCMethod(); 
            var paymentInfo = GetPaymentInfo();
            string requestParms = string.Empty; 
            string warnings = string.Empty;
            LogPaymentHistory(ccPaymentMethod, paymentInfo);
            target.AuthorizeCharge(ccPaymentMethod, ref paymentInfo, out requestParms, out warnings, 0, string.Empty);
            Assert.AreEqual(warnings, string.Empty);
            target.CaptureCharge(ccPaymentMethod, ref paymentInfo, requestParms, out warnings, 0, string.Empty);
            Assert.AreEqual(string.Empty, warnings);
        }

        /// <summary>
        ///A test for Credit
        ///</summary>
        [TestMethod()]
        public void CreditTest()
        {
            var target = new MetangaGateway();
            target.Init(string.Empty);
            CreditCardPaymentMethod ccPaymentMethod = InitializeCCMethod();
            var paymentInfo = GetPaymentInfo();
            string requestParams = string.Empty;
            string warnings = string.Empty;
            LogPaymentHistory(ccPaymentMethod, paymentInfo);
            Assert.IsTrue(target.ValidatePaymentMethod(ccPaymentMethod));
            target.Debit(ccPaymentMethod, ref paymentInfo, out warnings, 0, string.Empty);
            Assert.AreEqual(warnings, string.Empty);
            paymentInfo.Amount /= 2;
            target.Credit(ccPaymentMethod, ref paymentInfo, out warnings, 0, string.Empty);
            Assert.AreEqual(string.Empty, warnings);
        }

        /// <summary>
        ///A test for Debit
        ///</summary>
        [TestMethod()]
        public void DebitTest()
        {
            var target = new MetangaGateway();
            target.Init(string.Empty);
            CreditCardPaymentMethod ccPaymentMethod = InitializeCCMethod();
            var paymentInfo = GetPaymentInfo();
            string requestParams = string.Empty;
            string warnings = string.Empty;
            Assert.IsTrue(target.ValidatePaymentMethod(ccPaymentMethod));
            target.Debit(ccPaymentMethod, ref paymentInfo, out warnings, 0, string.Empty);
            Assert.AreEqual(warnings, string.Empty);
        }


        /// <summary>
        ///A test for Void
        ///</summary>
        [TestMethod()]
        public void VoidTest()
        {
            var target = new MetangaGateway();
            target.Init(string.Empty);
            CreditCardPaymentMethod ccPaymentMethod = InitializeCCMethod();
            var paymentInfo = GetPaymentInfo();
            string requestParams = string.Empty;
            string warnings = string.Empty;
            LogPaymentHistory(ccPaymentMethod, paymentInfo);
            Assert.IsTrue(target.ValidatePaymentMethod(ccPaymentMethod));
            target.Debit(ccPaymentMethod, ref paymentInfo, out warnings, 0, string.Empty);
            target.Void(ccPaymentMethod, ref paymentInfo, out warnings, 0, string.Empty);
            Assert.AreEqual(string.Empty, warnings);
        }
    }

    /// <summary>
    /// A helper class to create a credit card in Payment Broker
    /// </summary>
    public static class CreditCard
    {
        /// <summary>
        /// A helper method to create a credit card in Payment Broker
        /// </summary>
        /// <param name="paymentBrokerAddress">The URL to payment broker</param>
        /// <param name="address1">CC Contact Address, Line 1</param>
        /// <param name="address2">CC Contact Address, Line 2</param>
        /// <param name="address3">CC Contact Address, Line 3</param>
        /// <param name="cardVerificationNumber">The CCV is used to verify that the credit card number is not stolen</param>
        /// <param name="city">CC Contact Address, City</param>
        /// <param name="country">Should be a 2-letter ISO 3166-1 country code</param>
        /// <param name="creditCardNumber">CC Number</param>
        /// <param name="creditCardType">CC Type: Visa, Master Card, Discover, etc.</param>
        /// <param name="email">Email address</param>
        /// <param name="expirationDate">CC expiration date</param>
        /// <param name="firstName">CC Contact First Name</param>
        /// <param name="lastName">CC Contact Last Name</param>
        /// <param name="middleName">CC Contact Middle Name</param>
        /// <param name="phoneNumber">CC Contact Phone Number</param>
        /// <param name="postal">Zip or Postal Code</param>
        /// <param name="state">State or Province</param>
        /// <returns></returns>
        public static Guid CreateCreditCard(
            string paymentBrokerAddress,
            string address1,
            string address2,
            string address3,
            string cardVerificationNumber,
            string city,
            string country,
            string creditCardNumber,
            string creditCardType,
            string email,
            string expirationDate,
            string firstName,
            string lastName,
            string middleName,
            string phoneNumber,
            string postal,
            string state)
        {
            var createCreditCardQuery =
                paymentBrokerAddress +
                String.Format(CultureInfo.InvariantCulture,
                              "/paymentmethod/creditcard?address1={0}&address2={1}&address3={2}&cardVerificationNumber={3}&city={4}&country={5}&creditCardNumber={6}&creditCardType={7}&email={8}&expirationDate={9}&firstName={10}&lastName={11}&middleName={12}&phoneNumber={13}&postal={14}&state={15}",
                              address1,
                              address2,
                              address3,
                              cardVerificationNumber,
                              city,
                              country,
                              creditCardNumber,
                              creditCardType,
                              email,
                              expirationDate,
                              firstName,
                              lastName,
                              middleName,
                              phoneNumber,
                              postal,
                              state
                    );

            var metangaUri = new Uri(createCreditCardQuery);
            using (var httpClient = new HttpClient())
            {
                {
                    httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
                    using (var response = httpClient.GetAsync(metangaUri))
                    using (var responseTask = response.Result.Content.ReadAsStringAsync())
                    {
                        var responseJson = JToken.Parse(responseTask.Result);
                        return responseJson["ResponseValue"].ToObject<Guid>();
                    }
                }
            }
        }
    }
}
