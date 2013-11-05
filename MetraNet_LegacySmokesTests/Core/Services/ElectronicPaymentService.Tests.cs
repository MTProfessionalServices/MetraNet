using System;
using System.IO;
using System.Collections.Generic;
using MetraTech.DomainModel.Enums.Core.Metratech_com;
using MetraTech.Interop.RCD;
using NUnit.Framework;
using MetraTech.DomainModel.AccountTypes;
using MetraTech;
using MetraTech.Test.Common;
using MetraTech.Core.Services;
using System.ServiceModel;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.DomainModel.Enums;
using System.Collections;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;
using System.ServiceProcess;
using TimeoutException = System.TimeoutException;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.ElectronicPaymentServiceTests /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
    public class ElectronicPaymentServiceTests
    {
        //private string m_username;
        //private string m_namespace;
        private Guid m_paymentInstrumentID;
        private Guid m_paymentInstrumentID1;
        private Guid m_authToken;
        //private Guid m_paymentInstrumentID2;
        private Guid m_achPaymentInstrumentID;
        private Guid m_achPaymentInstrumentID2;

        private CreditCardPaymentMethod InitializeCCMethod()
        {
            CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod();
            paymentMethod.AccountNumber = "4111111111111111";
            paymentMethod.CVNumber = "111";
            paymentMethod.City = "Waltham";
            paymentMethod.Country = PaymentMethodCountry.USA;
            paymentMethod.FirstName = "Test";
            paymentMethod.LastName = "User";
            paymentMethod.State = "MA";
            paymentMethod.Street = "330 Bear Hill Road";
            paymentMethod.Street2 = "";
            paymentMethod.ZipCode = "02451";
            paymentMethod.CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.Visa;
            paymentMethod.ExpirationDate = "12/2020";
            paymentMethod.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;

            return paymentMethod;
        }

        private CreditCardPaymentMethod InitializeAmexCCMethod()
        {
            CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod();
            paymentMethod.AccountNumber = "378282246310005";
            paymentMethod.CVNumber = "0005";
            paymentMethod.City = "Waltham";
            paymentMethod.Country = PaymentMethodCountry.USA;
            paymentMethod.FirstName = "Test";
            paymentMethod.LastName = "User";
            paymentMethod.State = "MA";
            paymentMethod.Street = "330 Bear Hill Road";
            paymentMethod.Street2 = "";
            paymentMethod.ZipCode = "02451";
            paymentMethod.CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.American_Express;
            paymentMethod.ExpirationDate = "12/2020";
            paymentMethod.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;

            return paymentMethod;
        }

        // Master Card
        private CreditCardPaymentMethod InitializeMCCCMethod()
        {
            CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod();
            paymentMethod.AccountNumber = "5555555555554444";
            paymentMethod.CVNumber = "444";
            paymentMethod.City = "Waltham";
            paymentMethod.Country = PaymentMethodCountry.USA;
            paymentMethod.FirstName = "Test";
            paymentMethod.LastName = "User";
            paymentMethod.State = "MA";
            paymentMethod.Street = "330 Bear Hill Road";
            paymentMethod.Street2 = "";
            paymentMethod.ZipCode = "02451";
            paymentMethod.CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.MasterCard;
            paymentMethod.ExpirationDate = "12/2020";
            paymentMethod.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;

            return paymentMethod;
        }

        // Master Card
        private CreditCardPaymentMethod InitializeBadCCMethod()
        {
            CreditCardPaymentMethod paymentMethod = new CreditCardPaymentMethod();
            paymentMethod.AccountNumber = "5555555555551111";
            paymentMethod.CVNumber = "111";
            paymentMethod.City = "Walthams";
            paymentMethod.Country = PaymentMethodCountry.USA;
            paymentMethod.FirstName = "Test";
            paymentMethod.LastName = "User";
            paymentMethod.State = "MA";
            paymentMethod.Street = "330 Bear Hill Road";
            paymentMethod.Street2 = "";
            paymentMethod.ZipCode = "02451";
            paymentMethod.CreditCardType = MetraTech.DomainModel.Enums.Core.Metratech_com.CreditCardType.MasterCard;
            paymentMethod.ExpirationDate = "12/2020";
            paymentMethod.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;

            return paymentMethod;
        }

        // ACH Payment Method
        private ACHPaymentMethod InitializeACHPaymentMethod()
        {
            ACHPaymentMethod paymentMethod = new ACHPaymentMethod();
            paymentMethod.AccountNumber = "1234567890";
            paymentMethod.City = "Waltham";
            paymentMethod.Country = PaymentMethodCountry.USA;
            paymentMethod.FirstName = "ACH";
            paymentMethod.LastName = "User";
            paymentMethod.State = "MA";
            paymentMethod.Street = "330 Bear Hill Road";
            paymentMethod.Street2 = "";
            paymentMethod.ZipCode = "02451";
            paymentMethod.BankName = "Loco Inc";
            paymentMethod.BankAddress = "187 Loco Lane";
            paymentMethod.BankCity = "Loco City";
            paymentMethod.BankState = "MA";
            paymentMethod.BankZipCode = "02451";
            paymentMethod.BankCountry = PaymentMethodCountry.USA;
            paymentMethod.RoutingNumber = "123455678";

            return paymentMethod;
        }

        private ACHPaymentMethod InitializeACHPaymentMethod2()
        {
            ACHPaymentMethod paymentMethod = new ACHPaymentMethod();
            paymentMethod.AccountNumber = "9999999999";
            paymentMethod.City = "Boston";
            paymentMethod.Country = PaymentMethodCountry.USA;
            paymentMethod.FirstName = "New ACH";
            paymentMethod.LastName = "User";
            paymentMethod.State = "MA";
            paymentMethod.Street = "187 Loco Lane Hill Road";
            paymentMethod.Street2 = "";
            paymentMethod.ZipCode = "02451";
            paymentMethod.BankName = "Loco Inc";
            paymentMethod.BankAddress = "187 Loco Lane";
            paymentMethod.BankCity = "Loco City";
            paymentMethod.BankState = "MA";
            paymentMethod.BankZipCode = "02451";
            paymentMethod.BankCountry = PaymentMethodCountry.USA;
            paymentMethod.RoutingNumber = "123455678";

            return paymentMethod;
        }

        #region Test init and cleanup
        [TestFixtureSetUp]
        public void InitTests()
        {
            //m_namespace = "mt";
            //m_username = "abcdef1234567890";
        }

        [TestFixtureTearDown]
        public void UninitTests()
        {

        }
        #endregion

        #region Test Methods

        private MTList<MetraPaymentMethod> GetCreditCardSummary()
        {
            RecurringPaymentsServiceClient client = null;
            MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();

            try
            {
              client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

              client.ClientCredentials.UserName.UserName = "su";
              client.ClientCredentials.UserName.Password = "su123";

              AccountIdentifier acct = new AccountIdentifier(123);

              client.GetPaymentMethodSummaries(acct, ref paymentMethods);
              client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }

            return paymentMethods;
        }

        [Test]
        [Category("AddCCAndAuthorizeCharge")]
        public void T01AddCCAndAuthorizeCharge()
        {
            RecurringPaymentsServiceClient client = null;
            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                // 0 for non existentent accoutn . . .
                AccountIdentifier acct = new AccountIdentifier(123);


                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();
                client.GetPaymentMethodSummaries(acct, ref paymentMethods);

                if (paymentMethods.Items != null && paymentMethods.Items.Count > 0)
                {
                    foreach (MetraPaymentMethod pm in paymentMethods.Items)
                    {
                        client.DeletePaymentMethod(acct, pm.PaymentInstrumentID);
                    }
                }

                CreditCardPaymentMethod paymentMethod = InitializeCCMethod();

                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.99M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";
                pi.TransactionID = "T:1234333";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.99M;
                pi.MetraPaymentInvoices.Add(payinv);



                client.AddCCAndAuthorizeCharge(acct, paymentMethod, ref pi , out m_paymentInstrumentID, out m_authToken);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("AddCCAndAuthorizeCharge1")]
        public void T02AddCCAndAuthorizeCharge1()
        {
            RecurringPaymentsServiceClient client = null;
            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                // 0 for non existentent accoutn . . .
                AccountIdentifier acct = new AccountIdentifier(123);


                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();
                client.GetPaymentMethodSummaries(acct, ref paymentMethods);

                if (paymentMethods.Items != null && paymentMethods.Items.Count > 0)
                {
                    client.DeletePaymentMethod(acct, paymentMethods.Items[0].PaymentInstrumentID);
                }

                CreditCardPaymentMethod paymentMethod = InitializeCCMethod();

                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.99M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";
                pi.TransactionID = "T:1234333";

                pi.InvoiceDate = DateTime.Now;
                pi.InvoiceNum = "187";
                pi.PONum = "PO187";

                client.AddCCAndAuthorizeCharge(acct, paymentMethod, ref pi, out m_paymentInstrumentID, out m_authToken);
                client.Close();
            }
            catch (Exception e)
            {
                client.Abort();
                throw e;
            }
        }

        [Test]
        [Category("ReverseChargeAuthorization")]
        public void T03ReverseChargeAuthorization()
        {
            //Guid authToken, Guid paymentToken, MetraPaymentInfo paymentInfo
            //AddCCAndAuthorizeCharge();
            RecurringPaymentsServiceClient client = null;
            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                // 0 for non existentent accoutn . . .
                AccountIdentifier acct = new AccountIdentifier(123);

                

                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();
                client.GetPaymentMethodSummaries(acct, ref paymentMethods);

                if (paymentMethods.Items != null && paymentMethods.Items.Count > 0)
                {
                    foreach (MetraPaymentMethod pm in paymentMethods.Items)
                    {
                        client.DeletePaymentMethod(acct, pm.PaymentInstrumentID);
                    }
                }

                CreditCardPaymentMethod paymentMethod = InitializeCCMethod();
            
                MetraPaymentInfo pinfo = new MetraPaymentInfo();
                pinfo.Amount = 1.99M;
                pinfo.Currency = "USD";
                pinfo.TransactionID = "420";
                pinfo.Description = "Payment";
                pinfo.TransactionID = "T:1234";

                pinfo.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.99M;
                pinfo.MetraPaymentInvoices.Add(payinv);


                client.AddCCAndAuthorizeCharge(acct, paymentMethod, ref pinfo, out m_paymentInstrumentID, out m_authToken);

                client.ReverseChargeAuthorization(m_authToken, m_paymentInstrumentID, ref pinfo);
                client.Close();
                
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
            
        }

        [Test]
        [Category("UpdatePaymentMethodNoCheck")]
        public void T04UpdatePaymentMethodNoCheck()
        {
            RecurringPaymentsServiceClient client = null;
            
            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();

                client.GetPaymentMethodSummaries(acct, ref paymentMethods);

                if (paymentMethods.Items == null || (paymentMethods.Items != null && paymentMethods.Items.Count == 0))
                {
                    CreditCardPaymentMethod paymentMethod = InitializeCCMethod();
                    client.AddPaymentMethod(acct, paymentMethod, out m_paymentInstrumentID);
                }


                client.GetPaymentMethodSummaries(acct, ref paymentMethods);

                if (paymentMethods.Items.Count > 0)
                {
                    CreditCardPaymentMethod paymentMethod = paymentMethods.Items[0] as CreditCardPaymentMethod;
                    paymentMethod.FirstName = paymentMethod.FirstName + "upd";
                    paymentMethod.LastName = paymentMethod.LastName + "upd";
                    paymentMethod.Street = paymentMethod.Street + "upd" ;
                    paymentMethod.Street2 = "street2";
                    paymentMethod.ZipCode = "02451";
                    Guid piid = new Guid(paymentMethod.PaymentInstrumentIDString);
                    client.UpdatePaymentMethodNoCheck(acct, paymentMethod.PaymentInstrumentID, paymentMethod);
                    client.Close();
                }
                else
                {
                    Assert.Fail("No records to update");
                }
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("AddCCWithoutAccount")]
        public void T05AddCCWithoutAccount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                // 0 for non existentent accoutn . . .
                AccountIdentifier acct = new AccountIdentifier("nonexistentuser", "MT");
                CreditCardPaymentMethod paymentMethod = InitializeCCMethod();
                client.AddPaymentMethod(acct, paymentMethod, out m_paymentInstrumentID);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
                client.Abort();

                throw e;
            }
        }

        [Test]
        [Category("AssignCCtoAcount")]
        public void T06AssignCCtoAcount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                client.AssignPaymentMethodToAccount(m_paymentInstrumentID, acct);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }  
        }

        [Test]
        [Category("AddCreditCard")]
        public void T07AddCreditCard()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                CreditCardPaymentMethod paymentMethod = InitializeMCCCMethod();

                // want to add a different cc 
                client.AddPaymentMethod(acct, paymentMethod, out m_paymentInstrumentID1);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("HitCreditCard")]
        public void T08HitCreditCard()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
              client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

              //OneTimePaymentServiceClient client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");
              client.ClientCredentials.UserName.UserName = "su";
              client.ClientCredentials.UserName.Password = "su123";
              MetraPaymentInfo pi = new MetraPaymentInfo();
              pi.Amount = 1.99M;
              pi.Currency = "USD";
              pi.TransactionID = "420";
              pi.Description = "Payment";
              pi.TransactionID = "T:1234";

              pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
              MetraPaymentInvoice payinv = new MetraPaymentInvoice();
              payinv.InvoiceDate = DateTime.Now;
              payinv.InvoiceNum = "187";
              payinv.PONum = "PO187";
              payinv.AmountToPay = 1.00M;
              pi.MetraPaymentInvoices.Add(payinv);


              //client.DebitPaymentMethod(new Guid("67eff015-351e-47cf-88eb-1ae4cca8a9e8"), ref pi, m_Timeout);
        client.DebitPaymentMethod(m_paymentInstrumentID, ref pi);

              client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
              foreach (string e in fe.Detail.ErrorMessages)
              {
                Console.WriteLine("Error: {0}", e);
              }

              client.Abort();
              throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }


        [Test]
        [Category("SchedulePayment")]
        public void T09SchedulePayment()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                //OneTimePaymentServiceClient client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.99M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";
                pi.TransactionID = "T:1234";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


                client.SchedulePayment(m_paymentInstrumentID, MetraTime.Now.AddDays(5), false, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
                client.Abort();
                throw e;
            }
        }

        [Test]
        [Category("PreAuth")]
        public void T10PreAuth()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


        client.PreAuthorizeCharge(m_paymentInstrumentID, ref pi, out m_authToken);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }
        [Test]
        [Category("CCAuth")]
        public void T11CCAuth()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


        client.CapturePreauthorizedCharge(m_authToken, m_paymentInstrumentID, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("CCCredit")]
        public void T12CCCredit()
        {

            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);



        client.CreditPaymentMethod(m_paymentInstrumentID, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("OneTimeCCHit")]
        public void T13OneTimeCCHit()
        {
            OneTimePaymentServiceClient client = null;

            try
            {
                client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


                pi.TransactionID = "420";
                pi.Description = "Payment";

                CreditCardPaymentMethod paymentMethod = InitializeCCMethod();
        client.OneTimeDebit(acct, (MetraPaymentMethod)paymentMethod, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("OneTimeCCCredit")]
        public void T14OneTimeCCCredit()
        {
            MTList<MetraPaymentMethod> paymentMethods = GetCreditCardSummary();
            OneTimePaymentServiceClient client = null;

            try
            {
                client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                CreditCardPaymentMethod paymentMethod = InitializeAmexCCMethod();
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "420";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


        client.OneTimeCredit(acct, (MetraPaymentMethod)paymentMethod, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }


    [Test]
        [Category("UpdateCreditCardSummary")]
        public void T15UpdateCreditCardSummary()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();

                paymentMethods = GetCreditCardSummary();
                if (paymentMethods.Items.Count > 0)
                {
                    CreditCardPaymentMethod paymentMethod = paymentMethods.Items[0] as CreditCardPaymentMethod;
                    paymentMethod.FirstName = "Rick";
                    paymentMethod.LastName = "Ross";
                    paymentMethod.Street = "840 Winter St";
                    paymentMethod.Street2 = "";
                    paymentMethod.ZipCode = "02451";
                    Guid piid = paymentMethod.PaymentInstrumentID;
                    client.UpdatePaymentMethod(acct, piid, paymentMethod);
                    client.Close();
                }
                else
                {
                    Assert.Fail("No records to update");
                }
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }


        [Test]
        [Category("DeleteCreditCard")]
        public void T16DeleteCreditCard()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();

                paymentMethods = GetCreditCardSummary();
                if (paymentMethods.Items.Count > 0)
                {
                    CreditCardPaymentMethod paymentMethod = paymentMethods.Items[0] as CreditCardPaymentMethod;

                    Guid piid = paymentMethod.PaymentInstrumentID;
                    client.DeletePaymentMethod(acct, piid);
                    client.Close();

                }
                else
                {
                    Assert.Fail("No records to delete");
                }
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }


        [Test]
        [Category("AddACHMethod")]
        public void T17AddACHMethod()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                ACHPaymentMethod paymentMethod = InitializeACHPaymentMethod();

                // want to add a different cc 
                client.AddPaymentMethod(acct, paymentMethod, out m_achPaymentInstrumentID);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("HitACHAccount")]
        public void T18HitACHAccount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                //OneTimePaymentServiceClient client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.99M;
                pi.Currency = "USD";
                pi.TransactionID = "ACHHit";
                pi.Description = "Payment";
                pi.TransactionID = "T:1234";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


        client.DebitPaymentMethod(m_achPaymentInstrumentID, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("CreditAchAccount")]
        public void T19CreditAchAccount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "ACHCredit";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);



        client.CreditPaymentMethod(m_achPaymentInstrumentID, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("OneTimeACHHit")]
        public void T20OneTimeACHHit()
        {
            OneTimePaymentServiceClient client = null;

            try
            {
                client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "OneTimeACHHit";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


                ACHPaymentMethod paymentMethod = InitializeACHPaymentMethod();
        client.OneTimeDebit(acct, (MetraPaymentMethod)paymentMethod, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("OneTimeACHCredit")]
        public void T21OneTimeACHCredit()
        {
            MTList<MetraPaymentMethod> paymentMethods = GetCreditCardSummary();
            OneTimePaymentServiceClient client = null;

            try
            {
                client = new OneTimePaymentServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                ACHPaymentMethod paymentMethod = InitializeACHPaymentMethod();
                MetraPaymentInfo pi = new MetraPaymentInfo();
                pi.Amount = 1.00M;
                pi.Currency = "USD";
                pi.TransactionID = "OneTimeCCHit";
                pi.Description = "Payment";

                pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
                MetraPaymentInvoice payinv = new MetraPaymentInvoice();
                payinv.InvoiceDate = DateTime.Now;
                payinv.InvoiceNum = "187";
                payinv.PONum = "PO187";
                payinv.AmountToPay = 1.00M;
                pi.MetraPaymentInvoices.Add(payinv);


        client.OneTimeCredit(acct, (MetraPaymentMethod)paymentMethod, ref pi);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

		[Test]
        [Category("UpdateACHAccount")]
        public void T22UpdateACHAccount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);


                MTList<MetraPaymentMethod> paymentMethods = new MTList<MetraPaymentMethod>();
                paymentMethods = GetCreditCardSummary();

                for (int i = 0; i < paymentMethods.Items.Count; i++)
                {
                    MetraPaymentMethod pm = paymentMethods.Items[0];
                    if (pm.GetType() == typeof(ACHPaymentMethod))
                    {
                        ACHPaymentMethod ach = (ACHPaymentMethod)pm;
                        ach.BankAddress = "187 Loco Lane";
                        ach.BankCity = "WooStah";
                        client.UpdatePaymentMethod(acct, m_achPaymentInstrumentID, ach);
                        break;
                    }
                }
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("DeleteACHPaymentMethod")]
        public void T23DeleteACHPaymentMethod()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                client.DeletePaymentMethod(acct, m_achPaymentInstrumentID);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("AddACHWithoutAccount")]
        public void T24AddACHWithoutAccount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier("nonexistentuser", "MT");
                ACHPaymentMethod paymentMethod = InitializeACHPaymentMethod2();
                client.AddPaymentMethod(acct, paymentMethod, out m_achPaymentInstrumentID2);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }

        [Test]
        [Category("AssignACHtoAcount")]
        public void T25AssignACHtoAcount()
        {
            RecurringPaymentsServiceClient client = null;

            try
            {
                client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";

                AccountIdentifier acct = new AccountIdentifier(123);
                client.AssignPaymentMethodToAccount(m_achPaymentInstrumentID2, acct);
                client.Close();
            }
            catch (FaultException<MASBasicFaultDetail> fe)
            {
                foreach (string e in fe.Detail.ErrorMessages)
                {
                    Console.WriteLine("Error: {0}", e);
                }

                client.Abort();
                throw;
            }
            catch (Exception e)
            {
              client.Abort();
              throw e;
            }
        }
/*The next two tests are dependent on restarting MetraPay and ActivityServices.
  This turns out to be problematic on the smoke test machine, so I'm commenting them out.
  But individuals may still want to run this test.
      [Test]
      [Category("RepeatTxId")]
      public void RepeatTxId()
      {
        bool testSucceeded = false;
        ReplacePaymentStubConfig("TestGatewayStubSleepFailure.xml");
        ReplaceEpsConfig("EPSHostOpenTransactionTest.xml");

        RecurringPaymentsServiceClient client = null;
        client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        MetraPaymentInfo pi = new MetraPaymentInfo();
        pi.Amount = 1.99M;
        pi.Currency = "USD";
        pi.TransactionID = "420";
        pi.Description = "Payment";
        pi.TransactionID = "T:1234";
        pi.TransactionSessionId = Guid.NewGuid();

        pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
        MetraPaymentInvoice payinv = new MetraPaymentInvoice();
        payinv.InvoiceDate = DateTime.Now;
        payinv.InvoiceNum = "187";
        payinv.PONum = "PO187";
        payinv.AmountToPay = 1.00M;
        pi.MetraPaymentInvoices.Add(payinv);
 
        for (int i = 0; i < 2; i++)
        {
          try
          {
          client.DebitPaymentMethod(m_paymentInstrumentID, ref pi, m_Timeout, m_cos);
          }
          catch (FaultException<MASBasicFaultDetail> e)
          {
            //We expect the first transaction to time out; the next should tell us that the transaction already failed.
            if (e.Detail.ErrorCode == ErrorCodes.TRANSACTION_TIMED_OUT)
            {
              continue;
            }
            if ((e.Detail.ErrorCode == ErrorCodes.TRANSACTION_ALREADY_FAILED) && (i == 1))
            {
              testSucceeded = true;
            }
          }

        }
        Assert.IsTrue(testSucceeded);
      }

      [Test]
      [Category("TooManyOpenTransactions")]
      public void TooManyOpenTransactions()
      {
        bool testSucceeded = false;
 
        RecurringPaymentsServiceClient client = null;
        client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

        client.ClientCredentials.UserName.UserName = "su";
        client.ClientCredentials.UserName.Password = "su123";
        MetraPaymentInfo pi = new MetraPaymentInfo();
        pi.Amount = 1.99M;
        pi.Currency = "USD";
        pi.TransactionID = "420";
        pi.Description = "Payment";
        pi.TransactionID = "T:1234";

        pi.MetraPaymentInvoices = new List<MetraPaymentInvoice>();
        MetraPaymentInvoice payinv = new MetraPaymentInvoice();
        payinv.InvoiceDate = DateTime.Now;
        payinv.InvoiceNum = "187";
        payinv.PONum = "PO187";
        payinv.AmountToPay = 1.00M;
        pi.MetraPaymentInvoices.Add(payinv);

          try
          {
            pi.TransactionSessionId = Guid.NewGuid();
          client.DebitPaymentMethod(m_paymentInstrumentID, ref pi, m_Timeout, m_cos);
          } 
            //We expect an error here; we want to push over the high water mark.
          catch (Exception e)
          {
            //
          }
        

        try
        {
          pi.TransactionSessionId = Guid.NewGuid();
        client.DebitPaymentMethod(m_paymentInstrumentID, ref pi, m_Timeout, m_cos);
        }
        catch (FaultException<MASBasicFaultDetail> e)
        {
          if (e.Detail.ErrorCode == ErrorCodes.EXCEEDED_MAX_TRANSACTIONS)
          {
            testSucceeded = true;
          }
        }
        finally
        {
          ReplacePaymentStubConfig("TestGatewayStubOriginal.xml");
          ReplaceEpsConfig("EpsHostOriginal.xml");
          Assert.IsTrue(testSucceeded);
        }
      }
    */
    
        /*
        [Test]
        [Category("AddBadCreditCard")]
        public void AddBadCreditCard()
        {
          RecurringPaymentsServiceClient client = new RecurringPaymentsServiceClient("WSHttpBinding_IElectronicPaymentServices");

          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";

          AccountIdentifier acct = new AccountIdentifier(123);
          CreditCardPaymentMethod paymentMethod = InitializeBadCCMethod();

          // want to add a bad cc 
          client.AddPaymentMethod(acct, paymentMethod, out m_paymentInstrumentID1);
        }
        */

        #endregion

        #region private methods
        protected string CreateAccount()
        {
            // Create corporate account.
            string corporate = String.Format("SubSvcTests_CorpAccount_{0}", Utils.GetTestId());
            Utils.CreateCorporation(corporate, MetraTime.Now);
            int corporateAccountId = Utils.GetSubscriberAccountID(corporate);

            ArrayList accountSpecs = new ArrayList();

            string coreSubName = String.Format("SubSvcTests_CoreSub_{0}", Utils.GetTestId());
            Utils.BillingCycle cycle = new Utils.BillingCycle(Utils.CycleType.MONTHLY, 1);
            Utils.AccountParameters param = new Utils.AccountParameters(coreSubName, cycle);
            accountSpecs.Add(param);

            Utils.CreateSubscriberAccounts(corporate, accountSpecs, MetraTime.Now);

            return coreSubName;
        }

        private void ReplacePaymentStubConfig(string fileName)
        {
          using (ServiceController service = new ServiceController("MetraPay"))
          {
            IMTRcd rcd = new MTRcd();
            string newConfigFile = rcd.ExtensionDir + @"\\PaymentSvr\\config\\MetraPay\\" + fileName;
            string configFile = rcd.ExtensionDir + @"\\PaymentSvr\\config\\MetraPay\\TestGatewayStub.xml";
            // Create the file and clean up handles.

            service.Stop();
            service.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromMinutes(1.0));
            File.Copy(newConfigFile, configFile, true);
        for (int i = 0; i < 20; i++)
            {
              service.Start();
              try
              {
                service.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromMinutes(1.0));
                break;
              }
              catch (Exception)
              {
              }
            }
            Assert.IsTrue(service.Status == ServiceControllerStatus.Running, "Couldn't start MetraPay Server!");

          }
        }

      private void ReplaceEpsConfig(string fileName)
        {
          using (ServiceController service = new ServiceController("ActivityServices"))
          {
            IMTRcd rcd = new MTRcd();
            string newConfigFile = rcd.ConfigDir + @"\\ElectronicPaymentServices\\" + fileName;
            string configFile = rcd.ConfigDir + @"\\ElectronicPaymentServices\\EPSHost.xml";
            // Create the file and clean up handles.

            service.Stop();
            service.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromMinutes(1.0));
            File.Copy(newConfigFile, configFile, true);
        for (int i = 0; i < 20; i++)
            {
              service.Start();
              try
              {
                service.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromMinutes(1.0));
                break;
              }
              catch (Exception)
              {
              }
            }
            Assert.IsTrue(service.Status == ServiceControllerStatus.Running, "Couldn't start ActivityServices!");

          }


        }

      #endregion
    }
}
