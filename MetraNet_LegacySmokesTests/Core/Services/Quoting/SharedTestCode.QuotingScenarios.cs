using System;
using System.Collections.Generic;
using MetraTech.Core.Services.Quoting;
using MetraTech.Core.Services.Test.Quoting.Domain;
using MetraTech.Domain.Quoting;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.Test.Quoting
{
    public class QuotingTestScenarios
    {
        public const bool RunPDFGenerationForAllTestsByDefault = false; //Might eventually be a test setting

        /// <summary>
        /// Generic method for Quoting test.
        /// </summary>
        /// <remarks>The method whould not use in try-catch-finnally block, due to Assert() are used.</remarks>
        /// <param name="quoteImp"></param>
        /// <param name="expected"></param>
        /// <returns></returns>
        public static QuoteResponse CreateQuoteAndVerifyResults(QuoteImplementationData quoteImp, QuoteVerifyData expected)
        {
            QuoteResponse result = null;
            QuoteVerifyData beforeCreateQuote = new QuoteVerifyData();
            QuoteVerifyData beforeCleanQuote = new QuoteVerifyData();
            QuoteVerifyData afterCleanQuote = new QuoteVerifyData();

            // Record expected values
            expected.CountHeaders = 1;
            expected.CountContents = 1;
            expected.CountAccounts = quoteImp.Request.Accounts.Count;
            expected.CountProducts = quoteImp.Request.ProductOfferings.Count;

            // sets that request should contain Quote Artefacts (Chrages, Batch ID, Usage Intervals, Subscriptrions IDs and etc.)
            quoteImp.Request.ShowQuoteArtefacts = true;
            //Instantiate our implementation
            var quotingRepositoryForTestRun = new QuotingRepository();

            //Record pv counts before test
            beforeCreateQuote.CountNRCs = SharedTestCodeQuoting.GetNRCsCount();
            beforeCreateQuote.CountFlatRCs = SharedTestCodeQuoting.GetFlatRCsCount();
            beforeCreateQuote.CountUDRCs = SharedTestCodeQuoting.GetUDRCsCount();
            beforeCreateQuote.CountSubs = SharedTestCodeQuoting.GetSubsCount();
            beforeCreateQuote.CountRecurWindows = SharedTestCodeQuoting.GetRecurWindowsCount();

            beforeCreateQuote.CountHeaders = quotingRepositoryForTestRun.GetQuoteHeaderCount();
            beforeCreateQuote.CountContents = quotingRepositoryForTestRun.GetQuoteContentCount();
            beforeCreateQuote.CountAccounts = quotingRepositoryForTestRun.GetAccountForQuoteCount();
            beforeCreateQuote.CountProducts = quotingRepositoryForTestRun.GetPOForQuoteCount();

            UsageAndFailedTransactionCount usageAndFailedTransactionCount = UsageAndFailedTransactionCount.CreateSnapshot();



            //Instantiate our implementation
            if (quoteImp.QuoteImplementation == null)
            {
                quoteImp.QuoteImplementation = GetDefaultQuotingImplementationForTestRun(quotingRepositoryForTestRun);
            }

            #region CreateQuote

           

            try
            {
                result = quoteImp.QuoteImplementation.CreateQuote(quoteImp.Request);

                beforeCleanQuote.CountHeaders = quotingRepositoryForTestRun.GetQuoteHeaderCount();
                beforeCleanQuote.CountContents = quotingRepositoryForTestRun.GetQuoteContentCount();
                beforeCleanQuote.CountAccounts = quotingRepositoryForTestRun.GetAccountForQuoteCount();
                beforeCleanQuote.CountProducts = quotingRepositoryForTestRun.GetPOForQuoteCount();
                
                SharedTestCodeQuoting.VerifyQuoteRequestCorrectInRepository(result.IdQuote, quoteImp.Request,
                                                                            quoteImp.QuoteImplementation
                                                                                    .QuotingRepository);

                beforeCleanQuote.CountFlatRCs = SharedTestCodeQuoting.GetFlatRCsCount();
                beforeCleanQuote.CountNRCs = SharedTestCodeQuoting.GetNRCsCount();
                beforeCleanQuote.CountUDRCs = SharedTestCodeQuoting.GetUDRCsCount();
                beforeCleanQuote.CountSubs = SharedTestCodeQuoting.GetSubsCount();
                beforeCleanQuote.CountRecurWindows = SharedTestCodeQuoting.GetRecurWindowsCount();

                #endregion

                #region Check

                Assert.AreEqual(result.Status, QuoteStatus.Complete,
                                "Quote wasn't completed. Failed message: " + result.FailedMessage);

                //Verify the number of charges was as expected
                Assert.AreEqual(expected.CountFlatRCs, beforeCleanQuote.CountFlatRCs - beforeCreateQuote.CountFlatRCs,
                                "Quoting process did not generate expected number of RCs");
                Assert.AreEqual(expected.CountNRCs, beforeCleanQuote.CountNRCs - beforeCreateQuote.CountNRCs,
                                "Quoting process did not generate expected number of NRCs");

                // Verify the number of UDRCs if needed
                if (expected.CountUDRCs.HasValue)
                {
                    Assert.AreEqual(expected.CountUDRCs, beforeCleanQuote.CountUDRCs - beforeCreateQuote.CountUDRCs,
                                    "Quoting process did not generate expected number of UDRCs");
                }

                //Verify the number of instances in the tables for quoting was as expected
                Assert.AreEqual(expected.CountHeaders, beforeCleanQuote.CountHeaders - beforeCreateQuote.CountHeaders,
                                "Quoting process did not generate expected number of headers for quote");
                Assert.AreEqual(expected.CountContents, beforeCleanQuote.CountContents - beforeCreateQuote.CountContents,
                                "Quoting process did not generate expected number of contents for quote");
                Assert.AreEqual(expected.CountAccounts, beforeCleanQuote.CountAccounts - beforeCreateQuote.CountAccounts,
                                "Quoting process did not generate expected number of accounts for quote");
                Assert.AreEqual(expected.CountProducts, beforeCleanQuote.CountProducts - beforeCreateQuote.CountProducts,
                                "Quoting process did not generate expected number of POs for quote");

                // Verify the quote total is as expected. If UDRCs are expected than TotalAmount with them is greater than without 
                Assert.AreEqual(expected.Total, result.TotalAmount, "Created quote total is not what was expected");
                /*if (expectedQuoteUDRCsCount.HasValue)
                {
                  Assert.AreEqual(expectedQuoteTotal < preparedQuote.TotalAmount, "Created quote total does not contain UDRCs amount");
                }
                else
                {
                  Assert.AreEqual(expectedQuoteTotal, preparedQuote.TotalAmount, "Created quote total is not what was expected");
                }*/
                Assert.AreEqual(expected.Currency, result.Currency);

                //Verify response is in repository
                SharedTestCodeQuoting.VerifyQuoteResponseCorrectInRepository(result.IdQuote, result,
                                                                             quoteImp.QuoteImplementation
                                                                                     .QuotingRepository);

                //Todo: Verify PDF generated

            }
            catch (QuoteException ex)
            {
                result = ex.Response;
                throw;
            }
            finally
            {
                if (!quoteImp.QuoteImplementation.Configuration.IsCleanupQuoteAutomaticaly && result != null)
                {
                    quoteImp.QuoteImplementation.Cleanup(result.Artefacts);

                }

                //Verify usage cleaned up: check count of RCs and NRCs before and after
                afterCleanQuote.CountFlatRCs = SharedTestCodeQuoting.GetFlatRCsCount();
                afterCleanQuote.CountNRCs = SharedTestCodeQuoting.GetNRCsCount();
                afterCleanQuote.CountUDRCs = SharedTestCodeQuoting.GetUDRCsCount();
                afterCleanQuote.CountSubs = SharedTestCodeQuoting.GetSubsCount();
                afterCleanQuote.CountRecurWindows = SharedTestCodeQuoting.GetRecurWindowsCount();


                Assert.AreEqual(beforeCreateQuote.CountFlatRCs, afterCleanQuote.CountFlatRCs, "Quoting left behind/didn't cleanup usage");
                Assert.AreEqual(beforeCreateQuote.CountNRCs, afterCleanQuote.CountNRCs, "Quoting left behind/didn't cleanup usage");
                Assert.AreEqual(beforeCreateQuote.CountUDRCs, afterCleanQuote.CountUDRCs, "Quoting left behind/didn't cleanup usage");
              Assert.AreEqual(beforeCreateQuote.CountSubs, afterCleanQuote.CountSubs,
                              "Quoting left behind/didn't cleanup subs " +
                              (afterCleanQuote.CountSubs - beforeCreateQuote.CountSubs).ToString());
              Assert.AreEqual(beforeCreateQuote.CountRecurWindows, afterCleanQuote.CountRecurWindows,
                              "Quoting left behind/didn't cleanup recur windows " +
                              (afterCleanQuote.CountRecurWindows - beforeCreateQuote.CountRecurWindows).ToString());

                usageAndFailedTransactionCount.VerifyNoChange();
            }

                #endregion

            return result;
        }

        public static QuotingImplementation GetDefaultQuotingImplementationForTestRun(IQuotingRepository quotingRepositoryForTestRun = null)
        {
            //Instantiate our implementation
            if (quotingRepositoryForTestRun == null)
                quotingRepositoryForTestRun = new QuotingRepositoryInMemory();

            var config = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();
            config.IsCleanupQuoteAutomaticaly = false;
            var quotingImplementation = new QuotingImplementation(config,
                                                                    SharedTestCode.LoginAsAdmin(),
                                                                    quotingRepositoryForTestRun);
            return quotingImplementation;
        }

        public static void RunTestCheckingBadInputs(IEnumerable<int> accountIds, IEnumerable<int> poIds, string expectedErrorMessagePartial)
        {
            var request = new QuoteRequest();

            request.Accounts.AddRange(accountIds);

            request.ProductOfferings.AddRange(poIds);

            request.ReportParameters = new ReportParams()
              {
                  PDFReport = RunPDFGenerationForAllTestsByDefault
              };

            QuoteImplementationData quoteImpl = new QuoteImplementationData(request);
            QuoteVerifyData expected = new QuoteVerifyData();

            // Run quote and make sure it throws the expected message
            try
            {
                CreateQuoteAndVerifyResults(quoteImpl, expected);

                //If we got here we didn't get an exception when we expected one
                Assert.Fail("Expected exception with text '{0}' but didn't get an exception", expectedErrorMessagePartial);
            }
            catch (Exception ex)
            {
                Assert.IsTrue(ex.Message.Contains(expectedErrorMessagePartial)
                    , "Expected exception with text '{0}' but got exception with text '{1}'"
                    , expectedErrorMessagePartial, ex.Message);
            }


        }
    }
}
