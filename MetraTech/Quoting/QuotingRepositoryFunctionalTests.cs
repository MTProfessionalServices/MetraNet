using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.DataAccess;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Quoting;
using MetraTech.Domain.Test.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Shared.Test;

namespace MetraTech.Quoting.Test
{
  [TestClass]
  public class QuotingRepositoryFunctionalTests
  {
    private const string FunctionalTestCategory = "FunctionalTest";

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
    [TestMethod]
    [TestCategory(FunctionalTestCategory)]
    public void QuotingRepositorySaveBMEsFunctionalTest()
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
        quoteHeaderID = quotingRepository.CreateQuote(request, null);
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

      var response = new QuoteResponse
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

    [TestMethod]
    [TestCategory(FunctionalTestCategory)]
    public void QuotingRepositorySaveLogRecordsFunctionalTests()
    {
      var repository = new QuotingRepository();

      int initialRecordsCount = repository.GetQuoteLogRecordsCount();

      var quoteList = new List<QuoteLogRecord>();
      quoteList.AddRange(Enumerable.Range(0, 2).Select(e => new QuoteLogRecord() { DateAdded = MetraTime.Now })); // Add 2 dummy objects

      repository.SaveQuoteLog(quoteList);

      int currentRecordsCount = repository.GetQuoteLogRecordsCount();

      Assert.AreEqual(initialRecordsCount + 2, currentRecordsCount);
    }

    [TestMethod]
    [TestCategory(FunctionalTestCategory)]
    public void QuotingRepositorySaveIcbPricesPositiveTest()
    {
      // Prepare product offering
      var poConfiguration = new ProductOfferingFactoryConfiguration("QuotingRepositorySaveIcbPrices", Guid.NewGuid().ToString());
      var productOffering = ProductOfferingFactory.Create(poConfiguration);
      var priceableItem = productOffering.GetPriceableItems().Cast<IMTPriceableItem>().First();

      // Prepare ICB price
      var price = new QuoteIndividualPrice
        {
          QuoteId = DateTime.Now.Millisecond,
          ParameterTableId = 28,
          PriceableItemInstanceId = priceableItem.ID,
          ProductOfferingId = productOffering.ID,
          RateSchedules = QuoteIndividualPriceTest.PrepareSampleRates()
        };

      // Prepare quote request
      var quoteRequest = new QuoteRequest
      {
        QuoteIdentifier = "QuoteId" + Guid.NewGuid(),
        ReportParameters = new ReportParams { PDFReport = false },
        EffectiveDate = DateTime.UtcNow,
        EffectiveEndDate = DateTime.UtcNow,
        Accounts = new List<int> { 123 },
        ProductOfferings = new List<int> { productOffering.ID },
        IcbPrices = new List<QuoteIndividualPrice> { price }
      };

      // Create quote
      var quotingRepository = new QuotingRepository();
      quotingRepository.CreateQuote(quoteRequest, null);
      
      QuoteIndividualPrice createdPrice;
      using (var connection = ConnectionBase.GetDbConnection(new ConnectionInfo("NetMeter"), false))
      using (var dbContext = new MetraNetContext(connection))
        createdPrice = dbContext.QuoteIndividualPrices.SingleOrDefault(p => p.QuoteId == price.QuoteId);
      
      Assert.IsNotNull(createdPrice);
      QuoteIndividualPriceTest.CompareQuoteIndividualPrice(price, createdPrice);
    }
  }
}
