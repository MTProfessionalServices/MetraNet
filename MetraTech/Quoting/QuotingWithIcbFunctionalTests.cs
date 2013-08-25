using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Shared.Test;

namespace MetraTech.Quoting.Test
{
  [TestClass]
  public class QuotingWithIcbFunctionalTests
  {
    private static TestContext _testContext;

    #region Setup/Teardown

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      _testContext = testContext;
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
      SharedTestCode.MakeSureServiceIsStarted("Pipeline");

    }

    #endregion

    [TestMethod]
    [TestCategory("FunctionalTest")]
    public void QuotingWithIcb_BasicScenario_QuoteCreated()
    {
      #region Prepare

      const string testShortName = "Q_Basic";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      string testRunUniqueIdentifier = MetraTime.Now.ToString(CultureInfo.InvariantCulture);
        //Identifier to make this run unique

      // Create account
      var corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
      corpAccountHolder.Instantiate();

      var idAccountToQuoteFor = (int) corpAccountHolder.Item._AccountID;

      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(_testContext.TestName, testRunUniqueIdentifier);
      pofConfiguration.CountNRCs = 1;
      pofConfiguration.CountPairRCs = 1;
      pofConfiguration.CountPairUDRCs = 1;

      //IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
      var productOffering = ProductOfferingFactory.Create(pofConfiguration);
      int idProductOfferingToQuoteFor = productOffering.ID;

      using (var client = new PriceListServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";
        }

        IMTCollection instances = productOffering.GetPriceableItems();

        var productOfferingFactory = new ProductOfferingFactory();
        productOfferingFactory.Initialize(_testContext.TestName, testRunUniqueIdentifier);

        var parameterTableFlatRc =
          productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComFlatrecurringcharge);

        var parameterTableNonRc =
          productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComNonrecurringcharge);
        var parameterTableUdrcTapered =
          productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComUdrctapered);

        var parameterTableUdrcTiered =
          productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComUdrctiered);

        #region Set Allow ICB for PIs

        foreach (IMTPriceableItem possibleRC in instances)
        {
          if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
          {
            var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID,
                                                     parameterTableUdrcTapered.ID, SharedTestCode.MetratechComUdrctapered);
            pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

            piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableUdrcTiered.ID,
                                                 SharedTestCode.MetratechComUdrctiered);
            pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

          }
          else if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING)
          {
            var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableFlatRc.ID,
                                                     SharedTestCode.MetratechComFlatrecurringcharge);
            pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);
          }
          else if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_NON_RECURRING)
          {
            var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableNonRc.ID,
                                                     SharedTestCode.MetratechComNonrecurringcharge);
            pofConfiguration.PriceableItemsAndParameterTableForNonRc.Add(piAndPTParameters);
          }
        }

        #endregion
      }

      //Values to use for verification
      string expectedQuoteCurrency = "USD";
      DateTime startDateOfRcRate = DateTime.Parse("1/1/2000");
      DateTime endDateOfRcRate = DateTime.Parse("1/1/2038");
      
      #endregion

      #region Test

      // Ask backend to start quote

      //Prepare request
      QuoteRequest request = new QuoteRequest();
      request.Accounts.Add(idAccountToQuoteFor);
      request.ProductOfferings.Add(idProductOfferingToQuoteFor);
      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + _testContext.TestName;
      request.ReportParameters = new ReportParams()
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      request.Localization = "en-US";
      request.SubscriptionParameters.UDRCValues =
        SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering);

      int numOfAccounts = request.Accounts.Count;
      int expectedQuoteNRCsCount = pofConfiguration.CountNRCs*numOfAccounts;
      int expectedQuoteFlatRCsCount = pofConfiguration.CountPairRCs +
                                      (pofConfiguration.CountPairRCs*numOfAccounts);
      int expectedQuoteUDRCsCount = pofConfiguration.CountPairUDRCs +
                                    (pofConfiguration.CountPairUDRCs*numOfAccounts);

      pofConfiguration.RCAmount = 66.66m;
      pofConfiguration.NRCAmount = 77.77m;
      decimal totalAmountForUDRC = 15*16.6m + 5*13m;

      decimal expectedQuoteTotal = (expectedQuoteFlatRCsCount*pofConfiguration.RCAmount) +
                                   (expectedQuoteUDRCsCount*totalAmountForUDRC) +
                                   (expectedQuoteNRCsCount*pofConfiguration.NRCAmount);

      #region Initialize ICB prices

      var quoteId = DateTime.Now.Millisecond;

      request.IcbPrices = new List<QuoteIndividualPrice>();
      foreach (var ptrc in pofConfiguration.PriceableItemsAndParameterTableForRc)
      {
        var qip = new QuoteIndividualPrice
          {
            QuoteId = quoteId,
            ParameterTableId = ptrc.ParameterTableId,
            PriceableItemInstanceId = ptrc.PriceableItemId,
            ProductOfferingId = productOffering.ID,
            RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetFlatRcRateSchedule(66.66m, startDateOfRcRate, endDateOfRcRate) }
          };
        request.IcbPrices.Add(qip);
      }

      foreach (var ptUDRC in pofConfiguration.PriceableItemsAndParameterTableForUdrc)
      {
        var qip = new QuoteIndividualPrice
          {
            QuoteId = quoteId,
            ParameterTableId = ptUDRC.ParameterTableId,
            PriceableItemInstanceId = ptUDRC.PriceableItemId,
            ProductOfferingId = productOffering.ID
          };

        if (ptUDRC.ParameterTableName == SharedTestCode.MetratechComUdrctapered)
        {
          qip.RateSchedules = new List<BaseRateSchedule>
            {
              SharedTestCode.GetTaperedUdrcRateSchedule(new Dictionary<decimal, decimal>
                {
                  {15, 16.6m},
                  {40, 13m}
                })
            };
        }
        else
        {
          qip.RateSchedules = new List<BaseRateSchedule>
            {
              SharedTestCode.GetTieredUdrcRateSchedule(20, 16.6m, 10m)
            };
        }

        request.IcbPrices.Add(qip);
      }

      foreach (var ptNRC in pofConfiguration.PriceableItemsAndParameterTableForNonRc)
      {
        var qip = new QuoteIndividualPrice
          {
            QuoteId = quoteId,
            ParameterTableId = ptNRC.ParameterTableId,
            PriceableItemInstanceId = ptNRC.PriceableItemId,
            ProductOfferingId = productOffering.ID,
            RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetNonRcRateSchedule(77.77m) }
          };
        request.IcbPrices.Add(qip);
      }

      #endregion

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount,
                                                                                expectedQuoteUDRCsCount);


      #endregion

    }

    [TestMethod]
    [TestCategory("FunctionalTest")]
    public void QuotingWithIcb_3DiffIcbIntervals_QuoteCreated()
    {
      #region Prepare

      const string testAccountName = "Q_3IcbIntvs";
      const UsageCycleType billingCycle = UsageCycleType.Annually;
      const decimal rcDefaultRate = 30;
      const string localization = "en-US";

      // ICB1
      const decimal icb1Value = 66.66m;
      DateTime icb1StartDate = MetraTime.Now.AddDays(1);
      DateTime icb1EndDate = MetraTime.Now.AddDays(4);
      
      // ICB2
      const decimal icb2Value = 77.77m;
      DateTime icb2StartDate = MetraTime.Now.AddDays(5);
      DateTime icb2EndDate = MetraTime.Now.AddDays(8);
      
      // ICB3
      const decimal icb3Value = 55.55m;
      DateTime icb3StartDate = MetraTime.Now.AddDays(9);
      DateTime icb3EndDate = MetraTime.Now.AddDays(11);

      // Class for ICBs
      QuoteIndividualPrice quoteIcb;

      // Unique values for test
      var uniqueValue = MetraTime.Now;
      var testRunUniqueIdentifierInt = uniqueValue.Millisecond;
      var testRunUniqueIdentifierStr = uniqueValue.ToString(CultureInfo.InvariantCulture);

      // Create account
      var corpAccountHolder = new CorporateAccountFactory(testAccountName, testRunUniqueIdentifierStr);
      corpAccountHolder.Instantiate();
      corpAccountHolder.CycleType = billingCycle;

      Assert.IsNotNull(corpAccountHolder.Item._AccountID);
      int idAccountToQuoteFor = (int) corpAccountHolder.Item._AccountID;

      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(_testContext.TestName, testRunUniqueIdentifierStr)
        {
          CountPairRCs = 1,
          RCAmount = rcDefaultRate,
          CountNRCs = 0,
          CountPairUDRCs = 0,
          NRCAmount = 0
        };


      //IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
      var productOffering = ProductOfferingFactory.Create(pofConfiguration);
      int idProductOfferingToQuoteFor = productOffering.ID;

      using (var client = new PriceListServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";
        }

        var productOfferingFactory = new ProductOfferingFactory();
        productOfferingFactory.Initialize(_testContext.TestName, testRunUniqueIdentifierStr);

        // Set Allow ICB for PIs
		// TODO: Use foreach for 2 created RC PIs
        var piEnumerator = productOffering.GetPriceableItems().GetEnumerator();
        piEnumerator.MoveNext();
        var rcPiInstance = piEnumerator.Current as IMTPriceableItem;
        Assert.IsNotNull(rcPiInstance, "Created Product Offering does not contain any Pricable Items.");
        Assert.AreEqual(rcPiInstance.Kind, MTPCEntityType.PCENTITY_TYPE_RECURRING,
                        "Expecting Recurring Charge type only. Non-RC Pricable item was created.");

        var ptRc = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComFlatrecurringcharge);
        var piAndPtParams = SharedTestCode.SetAllowICBForPI(rcPiInstance, client, productOffering.ID, ptRc.ID,
                                             SharedTestCode.MetratechComFlatrecurringcharge);
        pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPtParams);
        
        // Initialize ICB prices
        quoteIcb = new QuoteIndividualPrice
          {
            QuoteId = testRunUniqueIdentifierInt,
            ParameterTableId = piAndPtParams.ParameterTableId,
            PriceableItemInstanceId = piAndPtParams.PriceableItemId,
            ProductOfferingId = productOffering.ID,
            RateSchedules = new List<BaseRateSchedule>
              {
                SharedTestCode.GetFlatRcRateSchedule(icb1Value, icb1StartDate, icb1EndDate),
                SharedTestCode.GetFlatRcRateSchedule(icb2Value, icb2StartDate, icb2EndDate),
                SharedTestCode.GetFlatRcRateSchedule(icb3Value, icb3StartDate, icb3EndDate)
              }
          };
      }

      #endregion

      #region Test

      // Ask backend to start quote

      //Prepare request
      var request = new QuoteRequest
        {
          QuoteIdentifier = testRunUniqueIdentifierStr,
          QuoteDescription = "Quote generated by Automated Test: " + _testContext.TestName,
          EffectiveDate = MetraTime.Now,
          EffectiveEndDate = MetraTime.Now,
          Localization = localization,
          IcbPrices = new List<QuoteIndividualPrice> { quoteIcb },
          ReportParameters = new ReportParams
            {
              PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
            }
        };
      request.Accounts.Add(idAccountToQuoteFor);
      request.ProductOfferings.Add(idProductOfferingToQuoteFor);

      var expectedQuoteFlatRCsCount = pofConfiguration.CountPairRCs*2;
      const decimal expectedQuoteTotal = 31.14m; // From task TA515: "Expected total = 30/365*354+66.6/365*4+77.77/365*4+55.55/365*3=31.14"
      const string expectedQuoteCurrency = "USD";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                       expectedQuoteTotal,
                                                       expectedQuoteCurrency,
                                                       expectedQuoteFlatRCsCount,
                                                       0);

      #endregion
    }
  }
}
