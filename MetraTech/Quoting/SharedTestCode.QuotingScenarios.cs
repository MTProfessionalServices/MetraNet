using System;
using System.Collections.Generic;
using MetraTech.Domain.Quoting;
using MetraTech.Quoting;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Shared.Test
{
  public class QuotingTestScenarios
  {
    public const bool RunPDFGenerationForAllTestsByDefault = false; //Might eventually be a test setting

    public static QuoteResponse CreateQuoteAndVerifyResults(QuoteRequest request,
                                                            decimal expectedQuoteTotal,
                                                            string expectedQuoteCurrency,
                                                            int expectedQuoteFlatRCsCount,
                                                            int expectedQuoteNRCsCount,
                                                            int? expectedQuoteUDRCsCount = null,
                                                            QuotingImplementation quotingImplementation = null)
    {
      //Instantiate our implementation
      var quotingRepositoryForTestRun = new QuotingRepository();

      //Record pv counts before test
      int beforeQuoteNRCsCount = SharedTestCodeQuoting.GetNRCsCount();
      int beforeQuoteFlatRCsCount = SharedTestCodeQuoting.GetFlatRCsCount();
      int beforeQuoteUDRCsCount = SharedTestCodeQuoting.GetUDRCsCount();
      int beforeQuoteHeadersCount = quotingRepositoryForTestRun.GetQuoteHeaderCount();
      int beforeQuoteContentsCount = quotingRepositoryForTestRun.GetQuoteContentCount();
      int beforeAccountsForQuoteCount = quotingRepositoryForTestRun.GetAccountForQuoteCount();
      int beforePOsforQuoteCount = quotingRepositoryForTestRun.GetPOForQuoteCount();

      UsageAndFailedTransactionCount usageAndFailedTransactionCount = UsageAndFailedTransactionCount.CreateSnapshot();

      // Record expected values
      const int expectedQuoteHeadersCount = 1;
      const int expectedQuoteContentsCount = 1;
      int expectedAccountsForQuoteCount = request.Accounts.Count;
      int expectedPOsforQuoteCount = request.ProductOfferings.Count;

      //Instantiate our implementation
      if (quotingImplementation == null)
      {
        quotingImplementation = GetDefaultQuotingImplementationForTestRun(quotingRepositoryForTestRun);
      }

      #region CreateQuote

      QuoteResponse preparedQuote = quotingImplementation.CreateQuote(request);

      int duringQuoteHeadersCount = quotingRepositoryForTestRun.GetQuoteHeaderCount();
      int duringQuoteContentsCount = quotingRepositoryForTestRun.GetQuoteContentCount();
      int duringQuoteAccountsCount = quotingRepositoryForTestRun.GetAccountForQuoteCount();
      int duringQuotePOsCount = quotingRepositoryForTestRun.GetPOForQuoteCount();

      SharedTestCodeQuoting.VerifyQuoteRequestCorrectInRepository(preparedQuote.idQuote, request, quotingImplementation.QuotingRepository);
        
      int duringQuoteFlatRCsCount = SharedTestCodeQuoting.GetFlatRCsCount();
      int duringQuoteNRCsCount = SharedTestCodeQuoting.GetNRCsCount();

      int duringQuoteUDRCsCount = SharedTestCodeQuoting.GetUDRCsCount();

      int afterQuoteFlatRCsCount = SharedTestCodeQuoting.GetFlatRCsCount();
      int afterQuoteNRCsCount = SharedTestCodeQuoting.GetNRCsCount();
      int afterQuoteUDRCsCount = SharedTestCodeQuoting.GetUDRCsCount();

      #endregion

      #region Check

      //Verify the number of charges was as expected
      Assert.AreEqual(expectedQuoteFlatRCsCount, duringQuoteFlatRCsCount - beforeQuoteFlatRCsCount,
                      "Quoting process did not generate expected number of RCs");
      Assert.AreEqual(expectedQuoteNRCsCount, duringQuoteNRCsCount - beforeQuoteNRCsCount,
                      "Quoting process did not generate expected number of NRCs");

      // Verify the number of UDRCs if needed
      if (expectedQuoteUDRCsCount.HasValue)
      {
        Assert.AreEqual(expectedQuoteUDRCsCount, duringQuoteUDRCsCount - beforeQuoteUDRCsCount,
                        "Quoting process did not generate expected number of UDRCs");
      }

      //Verify the number of instances in the tables for quoting was as expected
      Assert.AreEqual(expectedQuoteHeadersCount, duringQuoteHeadersCount - beforeQuoteHeadersCount,
                      "Quoting process did not generate expected number of headers for quote");
      Assert.AreEqual(expectedQuoteContentsCount, duringQuoteContentsCount - beforeQuoteContentsCount,
                      "Quoting process did not generate expected number of contents for quote");
      Assert.AreEqual(expectedAccountsForQuoteCount, duringQuoteAccountsCount - beforeAccountsForQuoteCount,
                      "Quoting process did not generate expected number of accounts for quote");
      Assert.AreEqual(expectedPOsforQuoteCount, duringQuotePOsCount - beforePOsforQuoteCount,
                      "Quoting process did not generate expected number of POs for quote");

      // Verify the quote total is as expected. If UDRCs are expected than TotalAmount with them is greater than without 
      Assert.AreEqual(expectedQuoteTotal, preparedQuote.TotalAmount, "Created quote total is not what was expected");
      /*if (expectedQuoteUDRCsCount.HasValue)
      {
        Assert.AreEqual(expectedQuoteTotal < preparedQuote.TotalAmount, "Created quote total does not contain UDRCs amount");
      }
      else
      {
        Assert.AreEqual(expectedQuoteTotal, preparedQuote.TotalAmount, "Created quote total is not what was expected");
      }*/
      Assert.AreEqual(expectedQuoteCurrency, preparedQuote.Currency);

      //Verify response is in repository
      SharedTestCodeQuoting.VerifyQuoteResponseCorrectInRepository(preparedQuote.idQuote, preparedQuote,
                                                                   quotingImplementation.QuotingRepository);

      //Todo: Verify PDF generated

      //Verify usage cleaned up: check count of RCs and NRCs before and after
      if (!request.DebugDoNotCleanupUsage)
      {
        Assert.AreEqual(beforeQuoteFlatRCsCount, afterQuoteFlatRCsCount, "Quoting left behind/didn't cleanup usage");
        Assert.AreEqual(beforeQuoteNRCsCount, afterQuoteNRCsCount, "Quoting left behind/didn't cleanup usage");
        Assert.AreEqual(beforeQuoteUDRCsCount, afterQuoteUDRCsCount, "Quoting left behind/didn't cleanup usage");

        usageAndFailedTransactionCount.VerifyNoChange();
      }

      #endregion

      return preparedQuote;
    }

    public static QuotingImplementation GetDefaultQuotingImplementationForTestRun(IQuotingRepository quotingRepositoryForTestRun = null)
    {
      //Instantiate our implementation
      if (quotingRepositoryForTestRun == null)
        quotingRepositoryForTestRun = new QuotingRepositoryInMemory();

      var quotingImplementation = new QuotingImplementation(QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation(),
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

      // Run quote and make sure it throws the expected message
      try
      {
        CreateQuoteAndVerifyResults(request, 0, string.Empty, 0, 0);

        //If we got here we didn't get an exception when we expected one
        Assert.Fail("Expected exception with text '{0]' but didn't get an exception", expectedErrorMessagePartial);
      }
      catch (Exception ex)
      {
        Assert.IsTrue(ex.Message.Contains(expectedErrorMessagePartial), "Expected exception with text '{0}' but got exception with text '{1}'", expectedErrorMessagePartial, ex.Message);
        return;
      }


    }
  }
}
