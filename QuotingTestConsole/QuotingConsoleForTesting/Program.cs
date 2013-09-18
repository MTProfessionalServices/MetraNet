using System;
using System.Collections.Generic;
using System.IO;
using System.Xml.Serialization;
using MetraTech.Domain.Quoting;
using MetraTech.Core.Services.ClientProxies;

namespace MetraTech.Quoting.Test.ConsoleForTesting
{
  class Program
  {

    static void Main(string[] args)
    {
      //MainFunctionalTest();
      QuotingActivityServiceTest();

    }

    private static void QuotingActivityServiceTest()
    {
      Console.WriteLine("QuotingActivityServiceTest started");

      List<int> idAccountToQuoteFor = new List<int> {-1} ;
      List<int> idProductOfferingToQuoteFor = new List<int> { -1 };
      string quoteIdentifier = "";
      bool runPDFGenerationForAllTestsByDefault = false;
      DateTime effectiveDate = MetraTime.Now;
      DateTime effectiveEndDate = MetraTime.Now;
      var icbPrices = new List<IndividualPrice>();

      var folder = Path.Combine(Environment.CurrentDirectory, "Quoting");
      if (!Directory.Exists(folder))
      {
        Directory.CreateDirectory(folder);
      }

      var requestFile = Path.Combine(folder, "Request.xml");

      if (File.Exists(requestFile))
      {
        var requestFileStream = new FileStream(requestFile, FileMode.Open);

        var xmlRequest = new XmlSerializer(typeof (FakeRequest));
        var fakeRequest = (FakeRequest)xmlRequest.Deserialize(requestFileStream);

        idAccountToQuoteFor = fakeRequest.IdAccountsToQuoteFor;
        idProductOfferingToQuoteFor = fakeRequest.IdProductOfferingsToQuoteFor;
        quoteIdentifier = fakeRequest.QuoteIdentifier;
        runPDFGenerationForAllTestsByDefault = fakeRequest.RunPDFGenerationForAllTestsByDefault;
        effectiveDate = fakeRequest.EffectiveDate;
        effectiveEndDate = fakeRequest.EffectiveEndDate;
        icbPrices = fakeRequest.IcbPrices;
      }
      else
      {
        #region Create fake request

        var fakeRequest = new FakeRequest
          {
            IdAccountsToQuoteFor = idAccountToQuoteFor,
            IdProductOfferingsToQuoteFor = idProductOfferingToQuoteFor,
            QuoteIdentifier = quoteIdentifier,
            RunPDFGenerationForAllTestsByDefault = runPDFGenerationForAllTestsByDefault,
            EffectiveDate = effectiveDate,
            EffectiveEndDate = effectiveEndDate,
            IcbPrices = icbPrices,
          };

        var requestFileStream = new FileStream(requestFile, FileMode.Create, FileAccess.ReadWrite, FileShare.ReadWrite);

        var xmlRequest = new XmlSerializer(fakeRequest.GetType());
        xmlRequest.Serialize(requestFileStream, fakeRequest);

        #endregion

      }

      #region Test

      //
      var request = new QuoteRequest();
      request.Accounts.AddRange(idAccountToQuoteFor);
      request.ProductOfferings.AddRange(idProductOfferingToQuoteFor);
      request.QuoteIdentifier = quoteIdentifier;
      request.ReportParameters.PDFReport = runPDFGenerationForAllTestsByDefault;
      request.EffectiveDate = effectiveDate;
      request.EffectiveEndDate = effectiveEndDate;
      request.IcbPrices = icbPrices;

      var response = new QuoteResponse();
      
      var quotingRepository = new QuotingRepository();
      //var quoteHeaderID = quotingRepository.CreateQuote(request);

      //Prepare request
      
      using (new MetraTech.Debug.Diagnostics.HighResolutionTimer("QuotingActivityServiceTest"))
      {
        
        var client = new QuotingService_CreateQuote_Client
          {
            UserName = "su",
            Password = "su123",            
            In_quoteRequest = request, 
            Out_quoteResponse = response
          };
        client.Invoke();
        response = client.Out_quoteResponse;
      }
      
      #endregion

      var responseFile = new FileStream(Path.Combine(folder, "Response.xml"), FileMode.OpenOrCreate, FileAccess.ReadWrite);

      var x = new XmlSerializer(response.GetType());
      x.Serialize(responseFile, response);

      Console.WriteLine("Quote Calculated");
      Console.WriteLine("Total Amount: {0} {1}", response.TotalAmount, response.Currency);
      
    }

   /* private static void MainFunctionalTest()
    {
      #region Prepare

      var pofConfiguration = new ProductOfferingFactoryConfiguration("Quote_Console", MetraTime.Now.ToString());
      
      // Create account
      //int idAccountToQuoteFor = 123; //Demo account for the moment
      MetraTech.Shared.Test.CorporateAccountFactory corpAccountHolder = new MetraTech.Shared.Test.CorporateAccountFactory(pofConfiguration.Name, pofConfiguration.UniqueIdentifier);
      corpAccountHolder.Instantiate();

      //Assert.IsNotNull(corpAccountHolder.Item.PayerID, "Unable to create account for test run");
      int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

      // Create/Verify Product Offering Exists
      pofConfiguration.CountPairRCs = 1;
      pofConfiguration.CountNRCs = 1;

      IMTProductOffering productOffering = MetraTech.Shared.Test.ProductOfferingFactory.Create(pofConfiguration);
      int idProductOfferingToQuoteFor = productOffering.ID;


      #endregion

      #region Test


      //Prepare request
      QuoteRequest request = new QuoteRequest();
      request.Accounts.Add(idAccountToQuoteFor);
      request.ProductOfferings.Add(idProductOfferingToQuoteFor);
      request.QuoteIdentifier = "MyQuoteId-1234";
      request.ReportParameters.PDFReport = false;
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;


      //For verification, get a count of NRCs and RCs in system before we start
      int nInitialNRCs = MetraTech.Shared.Test.SharedTestCodeQuoting.GetNRCsCount();

      QuotingImplementation quotingImplementation = new QuotingImplementation();

      //Ask backend to start a new quote based on request
      quotingImplementation.StartQuote(request);

      // Ask backend to calculate RCs
      quotingImplementation.AddRecurringChargesToQuote();

      //todo check that RC populated in t_pv tables

      // Ask backend to calculate NRCs
      quotingImplementation.AddNonRecurringChargesToQuote();
      int nTotalAfterGeneratingNRCs = SharedTestCodeQuoting.GetNRCsCount();

      // Ask backend to finalize quote
      QuoteResponse preparedQuote = quotingImplementation.FinalizeQuote();

      DumpQuoteLogToConsole(quotingImplementation.CurrentMessageLog);

      Console.WriteLine("Quote Calculated");
      Console.WriteLine("Total Amount: {0} {1}", preparedQuote.TotalAmount, preparedQuote.Currency);

      int nTotalAfterTestRunNRCS = SharedTestCodeQuoting.GetNRCsCount();

      Console.WriteLine("NRCs: {0} Before, {1} Generated, {2} Total Difference After", nInitialNRCs, nTotalAfterGeneratingNRCs - nInitialNRCs, nTotalAfterTestRunNRCS - nInitialNRCs);
      if (pofConfiguration.CountNRCs != (nTotalAfterGeneratingNRCs - nInitialNRCs))
        Console.WriteLine("ERROR: Expected {0} NRCs but generated {1} NRCs");
      else
        Console.WriteLine("Generated expected number of NRCs");

      //Todo: Verify we got a quote
      //Todo: Verify PDF generated
      //todo: verify that cleanup worked fine

      //Assert.AreNotSame(initialNRCsCount, finalNRCsCount);

      #endregion
    }

    */
    
    public static void DumpQuoteLogToConsole(List<string> messageLog)
    {
      Console.WriteLine();
      Console.WriteLine("==Processing Log==============================");
      foreach (string message in messageLog)
      {
        Console.WriteLine(message);
      }
      Console.WriteLine("==============================================");
      Console.WriteLine();

    }
  }
}
