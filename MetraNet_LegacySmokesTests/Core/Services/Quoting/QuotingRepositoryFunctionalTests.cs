using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Core.Services.Quoting;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.Test.Quoting
{
  [TestClass]
  public class QuotingRepositoryFunctionalTests
  {
    #region Setup/Teardown

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
    }

    #endregion

    /// <summary>
    /// Test check whether QuoteHeader and QuoteContent saved in db based on  QuoteRequest and QuoteResponse
    /// </summary>
    [TestMethod, MTFunctionalTest(TestAreas.Quoting)]
    public void T01QuotingRepositorySaveBMEs_PositiveTest()
    {
      #region prepare QuoteRequest

      var request = new QuoteRequest
          {
            QuoteIdentifier = "MyQuoteId-1234",
            QuoteDescription = "Quote for QuotingRepositorySaveFunctionalTest",
            ReportParameters = new ReportParams() { PDFReport = false },
            EffectiveDate = new DateTime(2013, 04, 10, 10, 55, 30),
            EffectiveEndDate = new DateTime(2013, 04, 10, 10, 55, 30)
          };

      request.Accounts.Add(123);
      request.Accounts.Add(150);
      request.ProductOfferings.Add(535);
      request.ProductOfferings.Add(600);

      #region Create UDRCs
      
      List<UDRCInstanceValueBase> udrcValues = new List<UDRCInstanceValueBase>();

      var udrcValue = new UDRCInstanceValue
        {
          UDRC_Id = 5351,
          StartDate = MetraTime.Now,
          EndDate = MetraTime.Now,
          Value = 20
        };
      udrcValues.Add(udrcValue);

      request.SubscriptionParameters.UDRCValues.Add("535", udrcValues);

      udrcValue = new UDRCInstanceValue
      {
        UDRC_Id = 6001,
        StartDate = MetraTime.Now,
        EndDate = MetraTime.Now,
        Value = 20
      };
      udrcValues.Add(udrcValue);

      request.SubscriptionParameters.UDRCValues.Add("600", udrcValues); 

      #endregion

      #endregion

      #region Test and Verify how QuoteHeader created and saved into DB before quote generation started (check of QuotingRepository.CreateQuote method)

      var quotingRepository = new QuotingRepository();
      var requestSaved = false;
      var quoteHeaderID = -1;
      try
      {
        var config = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();
        quoteHeaderID = quotingRepository.CreateQuote(request, null, config);
        requestSaved = true;
      }
      catch (Exception ex)
      {
        Assert.Fail("Exception on request save: " + ex.Message);
      }

      Assert.IsTrue(requestSaved, "Request not saved");

      Assert.AreNotEqual(quoteHeaderID, -1, "Wrong quoteHeaderID");

      #endregion

      #region prepare QuoteResponse

      var response = new QuoteResponse(request)
          {
            IdQuote = quoteHeaderID,
            TotalAmount = 200,
            TotalTax = 20,
            ReportLink = "Test Report Link",
            CreationDate = new DateTime(2013, 05, 10, 10, 55, 30),
            FailedMessage = "",
            Status = QuoteStatus.Complete
          };

      #endregion

      #region Test and Verify how QuoteContent created and saved into DB after quote generated (check of QuotingRepository.UpdateQuoteWithResponse method)

      var responseSaved = false;
      try
      {
        quotingRepository.UpdateQuoteWithResponse(response);
        responseSaved = true;
      }
      catch (Exception ex)
      {
        Assert.Fail("Exception on response save: " + ex.Message);
      }

      Assert.IsTrue(responseSaved, "Response not saved");

      #endregion

      #region Test and Verify how QuoteHeader and related BMEs saved into DB before (check of QuotingRepository.GetQuoteHeader method)
      //todo add assert to verify QuoteContent

      SharedTestCodeQuoting.VerifyQuoteRequestCorrectInRepository(quoteHeaderID, request, new QuotingRepository());
      SharedTestCodeQuoting.VerifyQuoteResponseCorrectInRepository(quoteHeaderID, response, new QuotingRepository());
      #endregion

      #region Cleanup of QuoteHeader, QuoteContent, AccountsForQuote, POsforQuote tables

      //todo Cleanup of QuoteHeader, QuoteContent, AccountsForQuote, POsforQuote tables

      #endregion

    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)]
    public void T02QuotingRepositorySaveLogRecords_PositiveTest()
    {
      var repository = new QuotingRepository();

      int initialRecordsCount = repository.GetQuoteLogRecordsCount();

      var quoteList = new List<QuoteLogRecord>();
      quoteList.AddRange(Enumerable.Range(0, 2).Select(e => new QuoteLogRecord() { DateAdded = MetraTime.Now })); // Add 2 dummy objects

      repository.SaveQuoteLog(quoteList);

      int currentRecordsCount = repository.GetQuoteLogRecordsCount();

      Assert.AreEqual(initialRecordsCount + 2, currentRecordsCount);
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore]
    public void T03QuotingRepositoryDeleteAccUsageQuoting_PositiveTest()
    {
      var repository = new QuotingRepository();
      var config = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();

      //var initialRecordsCountBefore = repository.GetAssUsageQuotingRecordsCount(config);

      int testQuoteId = 8;

      repository.DeleteAccUsageQuoting(testQuoteId, config);

      //var initialRecordsCountAfter = repository.GetAssUsageQuotingRecordsCount(config);

      //Assert.IsTrue((initialRecordsCountBefore - initialRecordsCountAfter) > 0);
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore]
    public void T04QuotingRepositoryDeletePdfReport_PositiveTest()
    {
      var repository = new QuotingRepository();
      var config = QuotingConfigurationManager.LoadConfigurationFromDefaultSystemLocation();

      //var initialRecordsCountBefore = repository.GetAssUsageQuotingRecordsCount(config);

      int testQuoteId = 10;

      repository.DeleteQuotePDF(testQuoteId, config);

      //var initialRecordsCountAfter = repository.GetAssUsageQuotingRecordsCount(config);

      //Assert.IsTrue((initialRecordsCountBefore - initialRecordsCountAfter) > 0);
    }
  }
}
