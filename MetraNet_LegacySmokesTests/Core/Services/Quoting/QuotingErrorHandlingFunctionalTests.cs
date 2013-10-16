using System;
using System.Collections.Generic;
using MetraTech.Core.Services.Quoting;
using MetraTech.Core.Services.Test.Quoting.Domain;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.Test.Quoting
{
    [TestClass]
    public class QuotingErrorHandlingFunctionalTests
    {
        #region Setup/Teardown

        [ClassInitialize]
        public static void InitTests(TestContext testContext)
        {
            SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
            SharedTestCode.MakeSureServiceIsStarted("Pipeline");
        }

        #endregion

        [TestMethod, MTFunctionalTest(TestAreas.Quoting)]
        public void ProductOfferingWithMissingRCRatesReturnsClearErrorMessage()
        {
            //FEAT-2540
            #region Prepare

            string testName = "ProductOfferingWithMissingRCRatesReturnsClearErrorMessage";
            string testShortName = "Q_NoRCRates"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
            //string testDescription = @"Given an account and a Product Offering with missing Recurring Charge rates, When quote is run Then it fails and returns a clear error message";
            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

            QuoteImplementationData quoteImpl = new QuoteImplementationData();
            QuoteVerifyData expected = new QuoteVerifyData();

            // Create account
            CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
            corpAccountHolder.Instantiate();

            Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
            int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

            // Create/Verify Product Offering Exists
            IMTProductOffering productOffering = ProductOfferingFactory.CreateWithRCMissingRates(testShortName, testRunUniqueIdentifier);
            Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
            int idProductOfferingToQuoteFor = productOffering.ID;

            //Values to use for verification... needed only to pass in but not used since we never complete the quote
            expected.Total = 0.00M;

            expected.CountNRCs = 1;
            expected.CountFlatRCs = 2;


            string expectedErrorMessagePartialText = "RecurringCharge";
            #endregion

            #region Test and Verify
            //Prepare request
            quoteImpl.Request.Accounts.Add(idAccountToQuoteFor);
            quoteImpl.Request.ProductOfferings.Add(idProductOfferingToQuoteFor);
            quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
            quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
            quoteImpl.Request.ReportParameters = new ReportParams { PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault };
            quoteImpl.Request.EffectiveDate = MetraTime.Now;
            quoteImpl.Request.EffectiveEndDate = MetraTime.Now;
            quoteImpl.Request.Localization = "en-US";

            //Give request to testing scenario along with expected results for verification; get back response for further verification

            //Create and pass the implementation so we can further check the error result
            quoteImpl.QuoteImplementation = QuotingTestScenarios.GetDefaultQuotingImplementationForTestRun(new QuotingRepository());

            //We are expecting error/exception
            try
            {
                QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

                Assert.Fail("An exception should have been thrown due to failed adding RC charges");
            }
            catch(QuoteException ex)
            {
                //Assert.AreEqual("Parameter cannot be null or empty.", ex.Message);
                Assert.IsTrue(ex.Message.Contains(expectedErrorMessagePartialText), "Expected message about failed adding RC charges");
                Assert.IsTrue(!string.IsNullOrEmpty(ex.Response.FailedMessage), "Failed quote does not have FailedMessage set");
                SharedTestCodeQuoting.VerifyQuoteResponseIsErrorInRepository(ex.Response.IdQuote, expectedErrorMessagePartialText, quoteImpl.QuoteImplementation.QuotingRepository);
            }

            #endregion
        }

        [TestMethod, MTFunctionalTest(TestAreas.Quoting)]
        public void ProductOfferingWithMissingNRCRatesReturnsClearErrorMessage()
        {
            //TODO: FEAT-2541

            #region Prepare
            string testName = "ProductOfferingWithMissingNRCRatesReturnsClearErrorMessage";
            string testShortName = "Q_NoRCRates"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
            //string testDescription = @"Given an account and a Product Offering with missing Non-Recurring Charge rates, When quote is run Then it fails and returns a clear error message";
            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

            // Create account
            CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
            corpAccountHolder.Instantiate();

            Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
            int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

            // Create/Verify Product Offering Exists

            IMTProductOffering productOffering = ProductOfferingFactory.CreateWithNRCMissingRates(testShortName, testRunUniqueIdentifier);
            Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
            int idProductOfferingToQuoteFor = productOffering.ID;

            string expectedErrorMessagePartialText = "pipeline";
            #endregion


            #region Test and Verify
            //Prepare request
            QuoteRequest request = new QuoteRequest();
            request.Accounts.Add(idAccountToQuoteFor);
            request.ProductOfferings.Add(idProductOfferingToQuoteFor);
            request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
            request.QuoteDescription = "Quote generated by Automated Test: " + testName;
            request.ReportParameters = new ReportParams() { PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault };
            request.EffectiveDate = MetraTime.Now;
            request.EffectiveEndDate = MetraTime.Now;
            request.Localization = "en-US";

            QuoteResponse erroredResponse = null;

            try
            {
                erroredResponse = SharedTestCodeQuoting.InvokeCreateQuote(request);
            }
            catch (Exception ex)
            {
                Assert.Fail("QuotingService_CreateQuote_Client thrown an exception: " + ex.Message);
            }

            Assert.IsTrue(erroredResponse.Status == QuoteStatus.Failed, "Expected response quote status must be failed");
            Assert.IsTrue(!string.IsNullOrEmpty(erroredResponse.FailedMessage), "Failed quote does not have FailedMessage set");

            //Verify the message we expect is there
            Assert.IsTrue(erroredResponse.FailedMessage.Contains(expectedErrorMessagePartialText), "Expected failure message with text '{0}' but got failure message '{1}'", expectedErrorMessagePartialText, erroredResponse.FailedMessage);

            #endregion
        }

        [TestMethod, MTFunctionalTest(TestAreas.Quoting)]
        public void QuotingWithBadInputParameters()
        {
            #region Bad Account Id

            string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique
            const string TEST_NAME = "QuotingWithBadInputParameters";
            const string TEST_SHORT_NAME = "Q_Err_Basic";

            var pofConfiguration = new ProductOfferingFactoryConfiguration(TEST_NAME, testRunUniqueIdentifier);

            pofConfiguration.CountNRCs = 1;
            pofConfiguration.CountPairRCs = 1;

            IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
            Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");

            int idPoToQuoteFor = productOffering.ID;

            var accountIdsToQuoteFor = new List<int> { -666666 };
            var poIdsToQuoteFor = new List<int> { idPoToQuoteFor };

            string expectedErrorMessagePartial = String.Format("The account {0} has no billing cycle", accountIdsToQuoteFor[0]);

            QuotingTestScenarios.RunTestCheckingBadInputs(accountIdsToQuoteFor, poIdsToQuoteFor, expectedErrorMessagePartial);

            #endregion

            #region Bad PO Id

            testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

            CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(TEST_SHORT_NAME, testRunUniqueIdentifier);
            corpAccountHolder.Instantiate();

            Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
            int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

            accountIdsToQuoteFor = new List<int> { idAccountToQuoteFor };
            poIdsToQuoteFor = new List<int> { -666666 };

            expectedErrorMessagePartial = String.Format("Item of kind 100 with ID {0} not found in database", poIdsToQuoteFor[0]);

            QuotingTestScenarios.RunTestCheckingBadInputs(accountIdsToQuoteFor, poIdsToQuoteFor, expectedErrorMessagePartial);

            #endregion

            #region Accounts In Different Billing Cycle

            testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

            corpAccountHolder = new CorporateAccountFactory(TEST_SHORT_NAME, testRunUniqueIdentifier);
            corpAccountHolder.CycleType = UsageCycleType.Annually;
            corpAccountHolder.Instantiate();
            Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
            int idAccountDifferentCycleToQuoteFor = (int)corpAccountHolder.Item._AccountID;

            expectedErrorMessagePartial = "All accounts must be in the same billing cycle";

            accountIdsToQuoteFor = new List<int> { idAccountToQuoteFor, idAccountDifferentCycleToQuoteFor };
            poIdsToQuoteFor = new List<int> { idPoToQuoteFor };

            QuotingTestScenarios.RunTestCheckingBadInputs(accountIdsToQuoteFor, poIdsToQuoteFor, expectedErrorMessagePartial);

            #endregion
            
            #region Empty List Of POs

            expectedErrorMessagePartial = "At least one product offering must be specified for the quote";

            accountIdsToQuoteFor = new List<int>() { idAccountToQuoteFor };
            poIdsToQuoteFor = new List<int>();

            QuotingTestScenarios.RunTestCheckingBadInputs(accountIdsToQuoteFor, poIdsToQuoteFor, expectedErrorMessagePartial);

            #endregion
        }
    }
}
