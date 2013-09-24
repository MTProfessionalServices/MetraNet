using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MeterRowset;
using MetraTech.Quoting.Test.Domain;
using MetraTech.Shared.Test;
using MetraTech.TestCommon;
using MetraTech.UsageServer;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Quoting.Test
{
//    /// <summary>
//    /// The tests are not for automation purpose. Before using some pre-steps should be performed
//    /// </summary>
//    [TestClass, Ignore]
//    public class QuotingEOPFunctionalTests
//    {
//        #region Setup/Teardown

//        [ClassInitialize]
//        public static void InitTests(TestContext testContext)
//        {
//            SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
//            SharedTestCode.MakeSureServiceIsStarted("Pipeline");
//        }

//        #endregion

//        #region : Quoting for 1 account. Tests for PO with 1 RC (flat RC), different type of accounts and billing cycles

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#1
//        public void QuotingCorpAnnualAccount()
//        {
//            /*
//             Account: Corporate. Billing Cycle: Annual
//             Effective date: Today
//             Action: Invoke CreateQuote with 1 such user
//             */

//            QuotingCorpAccount_diffBillingCycle("");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#2
//        public void QuotingCorpSemiAnnualAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Semi_Annually");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#3
//        public void QuotingCorpQuarterlyAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Quarterly");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#4
//        public void QuotingCorpMonthlyAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Monthly");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#5
//        public void QuotingCorpSemiMonthlyAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Semi_monthly");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#6
//        public void QuotingCorpBiweeklyAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Bi_weekly");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#7
//        public void QuotingCorpWeeklyAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Weekly");
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#8
//        public void QuotingCorpDailyAccount()
//        {
//            QuotingCorpAccount_diffBillingCycle("Daily");
//        }

//        public void QuotingCorpAccount_diffBillingCycle(string billcycle)
//        {
//            #region Prepare

//            string testName = "QuotingCorpAccount" + billcycle;
//            string testShortName = "Q_MAMPO";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();


//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;
//            // Create/Verify Product Offering Exists
//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts *
//                                         pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts *
//                                            pofConfiguration.CountPairRCs * 2; //???
//            expected.CountUDRCs = expected.CountAccounts * expected.CountProducts *
//                                          pofConfiguration.CountPairUDRCs * 2; //???
//            expected.Total = expected.CountAccounts * expected.CountProducts *
//                                         (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
//                                          pofConfiguration.CountNRCs * pofConfiguration.NRCAmount +
//                                          pofConfiguration.CountPairUDRCs * 30 * 2);

//            #region Creates account

//            var corpAccountHolder = new CorporateAccountFactory(testShortName + "0", testRunUniqueIdentifier);
//            corpAccountHolder.CycleType = StringToUsageCycle(billcycle);

//            switch (corpAccountHolder.CycleType)
//            {
//                case UsageCycleType.Semi_Annually:
//                case UsageCycleType.Quarterly:
//                case UsageCycleType.Monthly:
//                    // nothing to do
//                    break;

//                case UsageCycleType.Semi_monthly:
//                case UsageCycleType.Bi_weekly:
//                case UsageCycleType.Weekly:
//                case UsageCycleType.Daily:
//                    corpAccountHolder.CycleType = UsageCycleType.Semi_monthly;
//                    SetRcUdrcNadTotal(expected, pofConfiguration, 0);
//                    break;

//                default:
//                    SetRcUdrcNadTotal(expected, pofConfiguration, 12 - DateTime.Now.Month + 1);
//                    break;
//            }


//            corpAccountHolder.Instantiate();
//            Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//            Console.WriteLine("Account: {0}, Billing Cycle: {1}"
//                       , corpAccountHolder.Item._AccountID
//                       , corpAccountHolder.CycleType);

//            WriteToConsoleExpextedCharges(expected, pofConfiguration);

//            #endregion

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();
//            var productOfferingS = new List<IMTProductOffering>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                productOfferingS.Add(productOffering);
//                posToAdd.Add(productOffering.ID);
//                Console.WriteLine("PO ID for Quoting: {0}, PO name: {1}", productOffering.ID, productOffering.Name);
//            }


//            //Values to use for verification
//            #endregion

//            #region Test Quote and Verify

//            //Prepare request
//            var corpAccountHolders = new List<int> { corpAccountHolder.Item._AccountID.Value };
//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            foreach (IMTProductOffering productOffering in productOfferingS)
//            {
//                List<UDRCInstanceValueBase> list =
//                  SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
//                quoteImpl.Request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
//            }

//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion
//        }

//        private static void WriteToConsoleExpextedCharges(QuoteVerifyData expected,
//                                                          ProductOfferingFactoryConfiguration pofConfiguration)
//        {
//            Console.WriteLine("expectedQuoteFlatRCsCount: {0}, amount expectedQuoteFlatRCsCount: {1} "
//                              , expected.CountFlatRCs
//                              , pofConfiguration.RCAmount);

//            Console.WriteLine("expectedQuoteFlatUDRCsCount {0}, amount expectedQuoteUDRCsCount: {1}", expected.CountUDRCs, 30);
//            Console.WriteLine("expectedQuoteNRCCount: {0}, amount expectedQuoteNRCsCount: {1} "
//                              , expected.CountNRCs
//                              , pofConfiguration.NRCAmount);
//        }

//        private static void SetRcUdrcNadTotal(QuoteVerifyData expected, ProductOfferingFactoryConfiguration pofConfiguration,
//                                              int mult)
//        {
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts *
//                                    pofConfiguration.CountPairRCs * 2 * mult; //???
//            expected.CountUDRCs = expected.CountAccounts * expected.CountProducts *
//                                  pofConfiguration.CountPairUDRCs * 2 * mult; //???
//            expected.Total = expected.CountFlatRCs * pofConfiguration.RCAmount + expected.CountUDRCs.Value * 30 +
//                             expected.CountNRCs * pofConfiguration.NRCAmount;
//        }

//        private UsageCycleType StringToUsageCycle(string billcycle)
//        {
//            UsageCycleType reuslt = UsageCycleType.Annually;

//            try
//            {
//                reuslt = (UsageCycleType)Enum.Parse(typeof(UsageCycleType), billcycle);
//            }
//            // ReSharper disable EmptyGeneralCatchClause
//            catch
//            {
//                // if can't parse string to UsageCycleType then "UsageCycleType.Annually" will be used as default
//            }
//            // ReSharper restore EmptyGeneralCatchClause

//            return reuslt;
//        }

//        #endregion

//        #region EOP

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#6
//        public void QuotingSubscribedAccountforUDRC_NRC_RC_EOP()
//        {
//            #region Prepare

//            string testName = "QuotingAccUDRC_NRC_RC_Subscribe_EOP";
//            string testShortName = "Q_NRCRCUD";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for one account and multiple Product Offerings, When quote is run User subscriprion runs";
//            string testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            // Create accounts

//            #region Create account

//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//                Console.WriteLine("Account ID: {0}", corpAccountHolder.Item._AccountID);
//            }

//            #endregion

//            // Subscribe account to PO

//            #region Subscribe account to POs

//            // Subscribe account to PO
//            var POs_name = new List<string>();

//            var pofSubs = new ProductOfferingFactoryConfiguration(testShortName + "_For_Subscription_",
//                                                                  testRunUniqueIdentifier + "S");
//            pofSubs.CountNRCs = 2;
//            pofSubs.CountPairRCs = 1; //????
//            //pofSubs.CountPairUDRCs = 0; //????

//            var pos = new List<IMTProductOffering>();
//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofSubs.Name = testShortName + "_for_Subscription" + i;
//                pofSubs.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofSubs);
//                pos.Add(productOffering);
//                POs_name.Add(productOffering.Name);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                Console.WriteLine("PO ID for Subscription : {0}, PO name for Subscription: {1}", productOffering.ID, productOffering.Name);
//            }


//            var effDate = new MTPCTimeSpanClass
//              {
//                  StartDate = MetraTime.Now,
//                  StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
//              };
//            object modifiedDate = MetraTime.Now;

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);

//            #region Check and turn off InstantRCs if needed

//            bool instantRCsEnabled = QuotingHelper.GetInstanceRCStateAndSwitchItOff();

//            #endregion

//            foreach (int accID in corpAccountHolders)
//            {
//                MTPCAccount acc = productCatalog.GetAccount(accID);
//                foreach (string name in POs_name)
//                {
//                    MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
//                    acc.Subscribe(PO.ID, effDate, out modifiedDate);
//                }
//            }

//            #region Turn InstantRCs back on

//            QuotingHelper.BackOnInstanceRC(instantRCsEnabled);

//            #endregion

//            foreach (string name in POs_name)
//            {
//                MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
//                Console.WriteLine("PO ID: {0}, PO name: {1}", PO.ID, PO.Name);
//            }

//            #endregion

//            testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique
//            // Create/Verify Product Offering Exists

//            #region Create/Verify Product Offering Exists

//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 2; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();
//            var productOfferingS = new List<IMTProductOffering>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                productOfferingS.Add(productOffering);
//                posToAdd.Add(productOffering.ID);
//                Console.WriteLine("PO ID for Quoting: {0}, PO name: {1}", productOffering.ID, productOffering.Name);
//            }

//            #endregion

//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs * 2;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                            * pofConfiguration.CountPairRCs * 2 * 2; //???
//            expected.CountUDRCs = expected.CountAccounts * expected.CountProducts
//                                          * pofConfiguration.CountPairUDRCs * 2; //???
//            expected.Total = expected.CountFlatRCs * pofConfiguration.RCAmount +
//                                         expected.CountNRCs * pofConfiguration.NRCAmount + expected.CountUDRCs.Value * 30;

//            WriteToConsoleExpextedCharges(expected, pofConfiguration);
//#warning The test does not contaion any Assert()
//            #endregion

//            #region Test Quote and Verify

//            //Prepare request

//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            foreach (IMTProductOffering productOffering in productOfferingS)
//            {
//                List<UDRCInstanceValueBase> list =
//                  SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
//                quoteImpl.Request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
//            }

//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification

//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#8
//        public void QuotingAccountforUDRC_NRC_RC_EOP()
//        {
//            #region Prepare

//            string testName = "QuotingAccUDRC_NRC_RC_Subscribe_EOP";
//            string testShortName = "Q_NRCRCUDRC";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for one account and multiple Product Offerings, When quote is run User subscriprion runs";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            // Create accounts

//            #region Create account

//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//                Console.WriteLine("Account ID: {0}", corpAccountHolder.Item._AccountID);
//            }

//            #endregion

//            // Create/Verify Product Offering Exists

//            #region Create/Verify Product Offering Exists

//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 2; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();
//            var productOfferingS = new List<IMTProductOffering>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                productOfferingS.Add(productOffering);
//                posToAdd.Add(productOffering.ID);
//                Console.WriteLine("PO ID for Quoting: {0}, PO name: {1}", productOffering.ID, productOffering.Name);
//            }

//            #endregion

//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2; //???
//            expected.Total = expected.CountAccounts * expected.CountProducts
//                                         * (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
//                                          pofConfiguration.CountNRCs * pofConfiguration.NRCAmount +
//                                          pofConfiguration.CountPairUDRCs * 2 * 30);
//#warning The test does not contaion any Assert()

//            #endregion

//            #region Test Quote and Verify

//            //Prepare request
//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            foreach (IMTProductOffering productOffering in productOfferingS)
//            {
//                List<UDRCInstanceValueBase> list =
//                  SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
//                quoteImpl.Request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
//            }
//#warning The test does not contaion any Assert()
//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion
//        }


//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#1
//        public void QuotingAccount_EOP()
//        {
//            #region Prepare

//            string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
//            string testShortName = "Q_MAMPO";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            // Create accounts
//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//            }

//            // Create/Verify Product Offering Exists
//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                posToAdd.Add(productOffering.ID);
//            }


//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2; //???

//            expected.Total = expected.CountAccounts * expected.CountProducts
//                                         * (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
//                                          pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);


//            #endregion

//            #region Test Quote and Verify

//            //Prepare request
//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);
//            Console.WriteLine("Account: {0}", corpAccountHolders[0]);
//            for (int i = 0; i < expected.CountAccounts; i++)
//            {
//                Console.WriteLine("PO ID for Quoting: {0}, PO name: {1}", posToAdd[i], productCatalog.GetProductOffering(posToAdd[i]));
//            }
//            //move time
//#warning The current test does not conation any Assert()
//#warning the code bellow is not used
//            DateTime date = DateTime.Now;
//            DateTime movedDate = CycleUtils.MoveToDay(date, 30);

//            MeterRowset waiter = new MeterRowsetClass();
//            //waiter.WaitForCommit(5, 120);
//            //metters["RC"].WaitForCommit(countMeteredRecords, 120);
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#2
//        public void QuotedAccount_and_SubscribedEOP()
//        {
//            #region Prepare

//            string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
//            string testShortName = "Q_MAMPO";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            // Create accounts
//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//            }


//            // Create/Verify Product Offering Exists
//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                posToAdd.Add(productOffering.ID);
//            }


//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2; //???

//            expected.Total = expected.CountAccounts * expected.CountProducts
//                                         * (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
//                                          pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);


//            #endregion

//            #region Test Quote and Verify

//            //Prepare request

//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);

//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";

//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion

//            // Subscribe account to PO
//            var effDate = new MTPCTimeSpanClass
//              {
//                  StartDate = MetraTime.Now,
//                  StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
//              };
//            object modifiedDate = MetraTime.Now;

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);

//            MTPCAccount acc = productCatalog.GetAccount(corpAccountHolders[0]);

//            MTProductOffering po = productCatalog.GetProductOffering(posToAdd[0]);

//            Assert.IsNotNull(po, "Does not resolve PO by name");
//            Assert.IsFalse(po.ID <= 0, "ID was not found by name");


//            //var subscription = acc.Subscribe(1023, effDate, out modifiedDate);
//            MTSubscription subscription = acc.Subscribe(po.ID, effDate, out modifiedDate);

//            //put data to console
//            Console.WriteLine("Account: {0}", corpAccountHolders[0]);
//            Console.WriteLine("PO ID: {0}, PO name: {1} ", po.ID, po.Name);
//            for (int i = 0; i < expected.CountProducts; i++)
//            {
//                Console.WriteLine("PO ID for Quoting: {0}, , PO name: {1}",
//                              posToAdd[i],
//                              productCatalog.GetProductOffering(posToAdd[i]));
//            }

//#warning the test does not contaion any Assert()
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#4
//        public void QuotedAccount_and_Subscribefo_quotedPOsEOP()
//        {
//            #region Prepare

//            string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
//            string testShortName = "Q_MAMPO";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            #region Create account

//            // Create accounts
//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//            }

//            #endregion

//            #region create POs for quoting

//            // Create/Verify Product Offering Exists
//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                posToAdd.Add(productOffering.ID);
//            }

//            #endregion

//            #region Values to use for verification

//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2; //???

//            expected.Total = expected.CountAccounts * expected.CountProducts
//                                         * (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
//                                          pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);


//            #endregion

//            #endregion

//            #region Test Quote and Verify

//            //Prepare request
//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion

//            #region Subscribe account to quoted POs

//            // Subscribe account to PO
//            var effDate = new MTPCTimeSpanClass
//              {
//                  StartDate = MetraTime.Now,
//                  StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
//              };
//            object modifiedDate = MetraTime.Now;

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);

//            MTPCAccount acc = productCatalog.GetAccount(corpAccountHolders[0]);


//            foreach (int PO in posToAdd)
//            {
//                MTSubscription subscription = acc.Subscribe(PO, effDate, out modifiedDate);
//            }

//            #endregion

//            //var subscription = acc.Subscribe(1023, effDate, out modifiedDate);


//            //put data to console
//            Console.WriteLine("Account: {0}", corpAccountHolders[0]);
//            foreach (int PO in posToAdd)
//            {
//                Console.WriteLine("PO ID for Quoting: {0}, PO name: {1}", PO, productCatalog.GetProductOffering(PO));
//            }
//#warning The current test does not conation any Assert()
//#warning the code bellow is not used
//            //move time
//            DateTime date = DateTime.Now;
//            DateTime movedDate = CycleUtils.MoveToDay(date, 30);

//            MeterRowset waiter = new MeterRowsetClass();
//            //waiter.WaitForCommit(5, 120);
//            //metters["RC"].WaitForCommit(countMeteredRecords, 120);
//        }

//        #endregion

//        #region commented tests

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore] //#7
//        public void QuotingAccountsforUDRC_NRC_RC_Subscribe_EOP()
//        {
//            #region Prepare

//            string testName = "QuotingAccUDRC_NRC_RC_Subscribe_EOP";
//            string testShortName = "Q_NRCRCUDRC";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for one account and multiple Product Offerings, When quote is run User subscriprion runs";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique


//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            // Create accounts

//            #region Create account

//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//                Console.WriteLine("Account ID: {0}", corpAccountHolder.Item._AccountID);
//            }

//            #endregion

//            // Create/Verify Product Offering Exists

//            #region Create/Verify Product Offering Exists

//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();
//            var productOfferingS = new List<IMTProductOffering>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                productOfferingS.Add(productOffering);
//                posToAdd.Add(productOffering.ID);
//                Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name:" + productOffering.Name);
//            }

//            #endregion

//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2; //???
//            expected.CountUDRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairUDRCs * 2; //???
//            expected.Total = expected.CountFlatRCs * pofConfiguration.RCAmount +
//                                          expected.CountNRCs * pofConfiguration.NRCAmount + expected.CountUDRCs.Value * 30;


//            #endregion

//            #region Test Quote and Verify

//            //Prepare request
//            var request = new QuoteRequest();
//            var AccID = new List<int> { corpAccountHolders[0] };
//            request.Accounts.AddRange(AccID);
//            request.ProductOfferings.AddRange(posToAdd);

//            request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            request.EffectiveDate = MetraTime.Now;
//            request.EffectiveEndDate = MetraTime.Now;
//            foreach (IMTProductOffering productOffering in productOfferingS)
//            {
//                List<UDRCInstanceValueBase> list =
//                  SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
//                request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
//            }

//            request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion

//            // Subscribe account to PO

//            #region Subscribe account to POs

//            // Subscribe account to PO
//            var poS = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????


//            //Now generate the Product Offerings we need

//            var posToSbs = new List<IMTProductOffering>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                posToSbs.Add(productOffering);
//                Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name:" + productOffering.Name);
//            }


//            var effDate = new MTPCTimeSpanClass
//              {
//                  StartDate = MetraTime.Now,
//                  StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
//              };
//            object modifiedDate = MetraTime.Now;

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);

//            foreach (int accID in corpAccountHolders)
//            {
//                MTPCAccount acc = productCatalog.GetAccount(accID);
//                foreach (IMTProductOffering id in posToSbs)
//                {
//                    MTSubscription subscription = acc.Subscribe(id.ID, effDate, out modifiedDate);
//                }
//            }

//            foreach (IMTProductOffering id in posToSbs)
//            {
//                Console.WriteLine("PO ID: {0}, PO name: {1}", id.ID, id.Name);
//            }

//            #endregion
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore] //#3 Needs loaded "Localized Audio Conference Product Offering USD" PO
//        public void QuotingWithSubscribedAccount_EOP()
//        {
//            #region Prepare

//            string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
//            string testShortName = "Q_MAMPO";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 4;

//            #region create account

//            // Create accounts
//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//            }

//            #endregion

//            #region subscribe account to PO

//            // Subscribe account to PO
//            var effDate = new MTPCTimeSpanClass
//              {
//                  StartDate = MetraTime.Now,
//                  StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
//              };
//            object modifiedDate = MetraTime.Now;

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);

//            MTPCAccount acc = productCatalog.GetAccount(corpAccountHolders[0]);

//            MTProductOffering po = productCatalog.GetProductOfferingByName("Localized Audio Conference Product Offering USD");

//            Assert.IsNotNull(po, "Does not resolve PO by name");
//            Assert.IsFalse(po.ID <= 0, "ID was not found by name");

//            Console.WriteLine("Account:" + corpAccountHolders[0]);


//            MTSubscription subscription = acc.Subscribe(po.ID, effDate, out modifiedDate);
//            Console.WriteLine("PO ID:" + po.ID + ", PO name Localized Audio Conference Product Offering USD");

//            #endregion

//            // Create/Verify Product Offering Exists
//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();
//            var productOfferingS = new List<IMTProductOffering>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                productOfferingS.Add(productOffering);
//                posToAdd.Add(productOffering.ID);
//            }

//            for (int i = 0; i < expected.CountProducts; i++)
//            {
//                Console.WriteLine("PO ID for Quoting: {0}, PO name: {1}", posToAdd[i],
//                                productCatalog.GetProductOffering(posToAdd[i]));
//            }
//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2; //???

//            expected.Total = expected.CountAccounts * expected.CountProducts
//                                         * (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
//                                          pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);


//            #endregion

//            #region Test Quote and Verify

//            //Prepare request
//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            foreach (IMTProductOffering productOffering in productOfferingS)
//            {
//                List<UDRCInstanceValueBase> list =
//                  SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
//                quoteImpl.Request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
//            }

//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion

//            //move time
//            DateTime date = DateTime.Now;
//            DateTime movedDate = CycleUtils.MoveToDay(date, 30);

//            MeterRowset waiter = new MeterRowsetClass();
//        }

//        [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore] //#5
//        public void QuotingSubscribedMultipleAccounts_EOP()
//        {
//            #region Prepare

//            string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
//            string testShortName = "Q_MAMPO";
//            //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
//            //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
//            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

//            QuoteImplementationData quoteImpl = new QuoteImplementationData();
//            QuoteVerifyData expected = new QuoteVerifyData();

//            expected.CountAccounts = 1;
//            expected.CountProducts = 15;

//            #region Create account

//            // Create accounts
//            var corpAccountHolders = new List<int>();

//            for (int i = 1; i < expected.CountAccounts + 1; i++)
//            {
//                var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

//                corpAccountHolder.Instantiate();

//                Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
//                corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
//                Console.WriteLine("Account: {0}, Account name: {1}", corpAccountHolder.Item._AccountID, corpAccountHolder.Item.UserName);
//            }

//            #endregion

//            #region Subscribe account to POs

//            // Subscribe account to PO
//            var POs_name = new List<string>();

//            var pofSubs = new ProductOfferingFactoryConfiguration(testShortName + "_For_Subscription_",
//                                                                  testRunUniqueIdentifier + "S");
//            pofSubs.CountNRCs = 2;
//            pofSubs.CountPairRCs = 1; //????
//            pofSubs.CountPairUDRCs = 2; //????
//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofSubs.Name = testShortName + "_for_Subscription" + i;
//                pofSubs.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofSubs);
//                POs_name.Add(productOffering.Name);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                Console.WriteLine("PO ID for Subscription: {0}, PO name for Subscription: {1}", productOffering.ID,
//                                  productOffering.Name);
//            }
//            //var subscription = acc.Subscribe(1023, effDate, out modifiedDate);

//            var effDate = new MTPCTimeSpanClass
//              {
//                  StartDate = MetraTime.Now,
//                  StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
//              };
//            object modifiedDate = MetraTime.Now;

//            IMTProductCatalog productCatalog = new MTProductCatalogClass();
//            var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

//            productCatalog.SetSessionContext(sessionContext);

//            foreach (int accID in corpAccountHolders)
//            {
//                MTPCAccount acc = productCatalog.GetAccount(accID);
//                foreach (string name in POs_name)
//                {
//                    MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
//                    MTSubscription subscription = acc.Subscribe(PO.ID, effDate, out modifiedDate);
//                }
//            }

//            foreach (string name in POs_name)
//            {
//                MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
//                Console.WriteLine("PO ID: {0}, PO name: {1}", PO.ID, PO.Name);
//            }

//            #endregion

//            #region create POs for quoting

//            // Create/Verify Product Offering Exists
//            testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique
//            var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

//            pofConfiguration.CountNRCs = 2;
//            pofConfiguration.CountPairRCs = 1; //????
//            pofConfiguration.CountPairUDRCs = 1; //????

//            //Now generate the Product Offerings we need
//            var posToAdd = new List<int>();

//            for (int i = 1; i < expected.CountProducts + 1; i++)
//            {
//                pofConfiguration.Name = testShortName + "_" + i;
//                pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
//                IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
//                Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
//                posToAdd.Add(productOffering.ID);
//                Console.WriteLine("PO ID for Quoting: {0}, PO name {1}", productOffering.ID, productOffering.Name);
//            }

//            #endregion

//            #region Values to use for verification

//            //Values to use for verification
//            expected.CountNRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountNRCs * 2;
//            expected.CountFlatRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairRCs * 2 * 2; //???
//            expected.CountUDRCs = expected.CountAccounts * expected.CountProducts
//                                         * pofConfiguration.CountPairUDRCs * 2; //???

//            expected.Total = expected.CountFlatRCs * pofConfiguration.RCAmount +
//                                         expected.CountNRCs * pofConfiguration.NRCAmount + expected.CountUDRCs.Value * 30;


//            #endregion

//            #endregion

//            #region Test Quote and Verify

//            //Prepare request

//            quoteImpl.Request.Accounts.AddRange(corpAccountHolders);
//            quoteImpl.Request.ProductOfferings.AddRange(posToAdd);

//            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
//            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
//            quoteImpl.Request.ReportParameters = new ReportParams
//              {
//                  PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
//              };
//            quoteImpl.Request.EffectiveDate = MetraTime.Now;
//            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
//            quoteImpl.Request.Localization = "en-US";

//            //Give request to testing scenario along with expected results for verification; get back response for further verification
//            quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

//            #endregion

//            //move time
//            DateTime date = DateTime.Now;
//            DateTime movedDate = CycleUtils.MoveToDay(date, 30);

//            MeterRowset waiter = new MeterRowsetClass();
//            //waiter.WaitForCommit(5, 120);
//            //metters["RC"].WaitForCommit(countMeteredRecords, 120);
//        }

//        #endregion
//    }
}
