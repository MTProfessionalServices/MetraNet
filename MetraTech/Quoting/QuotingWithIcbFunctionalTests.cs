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
          switch (possibleRC.Kind)
          {
              case MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
                  {
                      var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID,
                                                                              parameterTableUdrcTapered.ID, SharedTestCode.MetratechComUdrctapered);
                      pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                      piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableUdrcTiered.ID,
                                                                          SharedTestCode.MetratechComUdrctiered);
                      pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                  }
                  break;
              case MTPCEntityType.PCENTITY_TYPE_RECURRING:
                  {
                      var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableFlatRc.ID,
                                                                              SharedTestCode.MetratechComFlatrecurringcharge);
                      pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);
                  }
                  break;
              case MTPCEntityType.PCENTITY_TYPE_NON_RECURRING:
                  {
                      var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableNonRc.ID,
                                                                              SharedTestCode.MetratechComNonrecurringcharge);
                      pofConfiguration.PriceableItemsAndParameterTableForNonRc.Add(piAndPTParameters);
                  }
                  break;
          }
        }

        #endregion
      }

      //Values to use for verification
      string expectedQuoteCurrency = "USD";
      
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
            RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetFlatRcRateSchedule(66.66m) }
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
      var quoteIcbList = new List<QuoteIndividualPrice>();

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

        // Set Allow ICB for PIs and initialize ICB prices
        int ptRcId =
          productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(
            SharedTestCode.MetratechComFlatrecurringcharge).ID;
        var piInstances = productOffering.GetPriceableItems();
        foreach (IMTPriceableItem rcPiInstance in piInstances)
        {
          Assert.IsNotNull(rcPiInstance, "Created Product Offering does not contain any Pricable Items.");
          Assert.AreEqual(rcPiInstance.Kind, MTPCEntityType.PCENTITY_TYPE_RECURRING,
                          "Expecting Recurring Charge type only. Non-RC Pricable item was created.");
          // Set Allow ICB
          var piAndPtParams = SharedTestCode.SetAllowICBForPI(rcPiInstance, client, productOffering.ID, ptRcId,
                                                              SharedTestCode.MetratechComFlatrecurringcharge);
          pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPtParams);
          // Initialize ICB prices
          quoteIcbList.Add(new QuoteIndividualPrice
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
            });
        }
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
          IcbPrices = quoteIcbList,
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

    [TestMethod]
    [TestCategory("FunctionalTest")]
    public void QuotingWithIcb_NegativeTest()
    {
        #region Prepare

        //string testName = "QuotingWithIcb_NegativeTest";
        string testShortName = "TC_QICB_63"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
        
        string testRunUniqueIdentifier = MetraTime.Now.ToString(CultureInfo.InvariantCulture);        

        // Create account
        var corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
        corpAccountHolder.Instantiate();
        var idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

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
            var parameterTableUdrcTapered =
                productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComUdrctapered);
            var parameterTableUdrcTiered =
                productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComUdrctiered);
            var parameterTableNonRc =
                productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComNonrecurringcharge);

            #region Set Allow ICB for PIs

            foreach (IMTPriceableItem possibleRC in instances)
            {
                switch (possibleRC.Kind)
                {
                    case MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
                        {
                            var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID,
                                                                                    parameterTableUdrcTapered.ID, SharedTestCode.MetratechComUdrctapered);
                            pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                            piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableUdrcTiered.ID,
                                                                                SharedTestCode.MetratechComUdrctiered);
                            pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                        }
                        break;
                    case MTPCEntityType.PCENTITY_TYPE_RECURRING:
                        {
                            var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableFlatRc.ID,
                                                                                    SharedTestCode.MetratechComFlatrecurringcharge);
                            pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);
                        }
                        break;
                    case MTPCEntityType.PCENTITY_TYPE_NON_RECURRING: //ICB not allowed!
                        {
                            var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableNonRc.ID,
                                                        SharedTestCode.MetratechComNonrecurringcharge, false);
                            pofConfiguration.PriceableItemsAndParameterTableForNonRc.Add(piAndPTParameters);
                            
                        }
                        break;
                }
            }

            #endregion
        }

        //Values to use for verification
        var expectedErrorMessagePartialText = "ICB rates are not allowed for this parameter table on this product offering";

        #endregion

        #region Test

        // Ask backend to start quote

        //Prepare request
        var request = new QuoteRequest();
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
                RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetFlatRcRateSchedule(66.66m) }
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

        var erroredResponse = new QuoteResponse();

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

    /// <summary>
    /// TC_QICB_51
    /// </summary>
    [TestMethod]
    public void QuotingActivityServiceGenerateQuoteWithICBTwoTimesPositiveTest()
    {
        #region Prepare
        string testName = "QuotingActivityServiceGenerateQuoteWithICBTwoTimesPositiveTest";
        string testShortName = "TC_QICB_51"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
        string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

        // Create account
        CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

        // Create/Verify Product Offerings Exists
        var pofConfiguration1 = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier + "1")
        {
            CountNRCs = 0,
            CountPairRCs = 1,
            CountPairUDRCs = 0
        };

        var pofConfiguration2 = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier + "2")
        {
            CountNRCs = 0,
            CountPairRCs = 1,
            CountPairUDRCs = 0
        };

        var productOffering1 = ProductOfferingFactory.Create(pofConfiguration1);
        var productOffering2 = ProductOfferingFactory.Create(pofConfiguration2);
        int idProductOfferingToQuoteFor1 = productOffering1.ID;
        int idProductOfferingToQuoteFor2 = productOffering2.ID;

        using (var client = new PriceListServiceClient())
        {
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
            }

            IMTCollection instances1 = productOffering1.GetPriceableItems();
            IMTCollection instances2 = productOffering2.GetPriceableItems();

            var productOfferingFactory = new ProductOfferingFactory();
            productOfferingFactory.Initialize(testName, testRunUniqueIdentifier);

            var parameterTableFlatRc = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComFlatrecurringcharge);

            #region Set Allow ICB for PIs
            foreach (IMTPriceableItem possibleRC in instances1)
            {
                if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING)
                {
                    var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering1.ID, parameterTableFlatRc.ID, SharedTestCode.MetratechComFlatrecurringcharge);
                    pofConfiguration1.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);
                }
            }

            foreach (IMTPriceableItem possibleRC in instances2)
            {
                if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING)
                {
                    var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering2.ID, parameterTableFlatRc.ID, SharedTestCode.MetratechComFlatrecurringcharge);
                    pofConfiguration2.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);
                }
            }
            #endregion
        }

        decimal expectedQuoteTotal1 = 66.66m * 2;   //*2 because we generated RC per subscription and rep participant
        decimal expectedQuoteTotal2 = 66.66m * 2;

        #endregion

        #region Test and Verify

        #region Invoke CreateQuote for PO #1
        var request1 = new QuoteRequest();
        request1.Accounts.Add(idAccountToQuoteFor);
        request1.ProductOfferings.Add(idProductOfferingToQuoteFor1);
        request1.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
        request1.QuoteDescription = "Quote generated by Automated Test: " + testName;
        request1.ReportParameters = new ReportParams() { PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault };
        request1.EffectiveDate = MetraTime.Now;
        request1.EffectiveEndDate = MetraTime.Now;


        #region Initialize ICB prices

        var quoteId = DateTime.Now.Millisecond;

        request1.IcbPrices = new List<QuoteIndividualPrice>();
        foreach (var ptrc in pofConfiguration1.PriceableItemsAndParameterTableForRc)
        {
            var qip = new QuoteIndividualPrice
            {
                QuoteId = quoteId,
                ParameterTableId = ptrc.ParameterTableId,
                PriceableItemInstanceId = ptrc.PriceableItemId,
                ProductOfferingId = productOffering1.ID,
                RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetFlatRcRateSchedule(66.66m) }
            };
            request1.IcbPrices.Add(qip);
        }

        #endregion

        var response1 = new QuoteResponse();
        bool clientInvoked = false;
        try
        {
            response1 = SharedTestCodeQuoting.InvokeCreateQuote(request1);
            clientInvoked = true;
        }
        catch (Exception ex)
        {
            Assert.Fail("QuotingService_CreateQuote_Client thrown an exception: " + ex.Message);
        }

        Assert.IsFalse(response1.Status == QuoteStatus.Failed, response1.FailedMessage);
        Assert.IsTrue(clientInvoked, "QuotingService_CreateQuote_Client didn't executed propely");
        Assert.AreEqual(expectedQuoteTotal1, response1.TotalAmount, "Wrong TotalAmount");
        #endregion

        #region Invoke CreateQuote for PO #2

        #region Initialize ICB prices

        //backup ICBs for first request
        var ICBsReuest1Backup = request1.IcbPrices;

        request1.ProductOfferings.Clear();
        request1.ProductOfferings.Add(idProductOfferingToQuoteFor2);
        request1.IcbPrices = new List<QuoteIndividualPrice>();
        foreach (var ptrc in pofConfiguration2.PriceableItemsAndParameterTableForRc)
        {
            var qip = new QuoteIndividualPrice
            {
                QuoteId = quoteId,
                ParameterTableId = ptrc.ParameterTableId,
                PriceableItemInstanceId = ptrc.PriceableItemId,
                ProductOfferingId = productOffering2.ID,
                RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetFlatRcRateSchedule(66.66m) }
            };
            request1.IcbPrices.Add(qip);
        }

        #endregion

        var response2 = new QuoteResponse();

        clientInvoked = false;
        try
        {
            response2 = SharedTestCodeQuoting.InvokeCreateQuote(request1);
            clientInvoked = true;
        }
        catch (Exception ex)
        {
            Assert.Fail("QuotingService_CreateQuote_Client thrown an exception: " + ex.Message);
        }

        Assert.IsFalse(response2.Status == QuoteStatus.Failed, response2.FailedMessage);
        Assert.IsTrue(clientInvoked, "QuotingService_CreateQuote_Client didn't executed propely");
        Assert.AreEqual(expectedQuoteTotal2, response2.TotalAmount, "Wrong TotalAmount");

        Assert.AreEqual(response2.TotalAmount, response2.TotalAmount, "Total amount was different on the second run");
        #endregion



        #region Create Subscription for PO #2. Enter Custom Rates.

        MTSubscription subscription2 = null;
        MTPCAccount account2 = null;
        bool subscriptionForPO2Created = false;
        //bool ICBSForSubscription2Created = false;

        try
        {
            account2 = SharedTestCode.CurrentProductCatalog.GetAccount(idAccountToQuoteFor);

            var effDate = new MTPCTimeSpanClass
            {
                StartDate = request1.EffectiveDate,
                StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
            };

            object modifiedDate = MetraTime.Now;
            subscription2 = account2.Subscribe(idProductOfferingToQuoteFor2, effDate, out modifiedDate);
            subscriptionForPO2Created = true;

            //SharedTestCode.ApplyIcbPricesToSubscription(idProductOfferingToQuoteFor2, subscription2.ID, request1.IcbPrices);
            //ICBSForSubscription2Created = true;

        }
        catch (Exception ex)
        {
            Assert.Fail("Creating subscription after quote failed with exception: " + ex);
        }
        finally
        {
            if (subscription2 != null)
            {
                account2.RemoveSubscription(subscription2.ID);
            }
        }

        #endregion

        #region Create Subscription for PO #1. Enter Custom Rates.

        request1.IcbPrices = ICBsReuest1Backup;

        MTSubscription subscription1 = null;
        MTPCAccount account1 = null;
        bool subscriptionForPO1Created = false;
        //bool ICBSForSubscription1Created = false;

        try
        {
            account1 = SharedTestCode.CurrentProductCatalog.GetAccount(idAccountToQuoteFor);

            var effDate = new MTPCTimeSpanClass
            {
                StartDate = request1.EffectiveDate,
                StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
            };

            object modifiedDate = MetraTime.Now;
            subscription1 = account1.Subscribe(idProductOfferingToQuoteFor1, effDate, out modifiedDate);
            subscriptionForPO1Created = true;

            //SharedTestCode.ApplyIcbPricesToSubscription(idProductOfferingToQuoteFor1, subscription1.ID, request1.IcbPrices);
            //ICBSForSubscription1Created = true;

        }
        catch (Exception ex)
        {
            Assert.Fail("Creating subscription after quote failed with exception: " + ex);
        }
        finally
        {
            if (subscription1 != null)
            {
                account1.RemoveSubscription(subscription1.ID);
            }
        }

        Assert.IsTrue(subscriptionForPO1Created, "Subscription wasn't created for PO #1");
        Assert.IsTrue(subscriptionForPO2Created, "Subscription wasn't created for PO #2");
        //Assert.IsTrue(ICBSForSubscription1Created, "ICBS for subscription1 wasn't created");
        //Assert.IsTrue(ICBSForSubscription2Created, "ICBS for subscription1 wasn't created");

        #endregion

        #endregion
    }

    /// <summary>
    /// TC_QICB_71
    /// </summary>
    //[TestMethod]      
    public void QuotingWithICB_NoPrice_NegativeTest()
    {
        #region Prepare
        string testName = "QuotingWithICBNoPriceNegativeTest ";
        string testShortName = "TC_QICB_71"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
        string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

        // Create account
        CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

        // Create/Verify Product Offerings Exists
        var pofConfiguration = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier + "1")
        {
            CountNRCs = 0,
            CountPairRCs = 0,
            CountPairUDRCs = 1
        };

        var productOffering = ProductOfferingFactory.Create(pofConfiguration);
        int idProductOfferingToQuoteFor1 = productOffering.ID;

        using (var client = new PriceListServiceClient())
        {
            if (client.ClientCredentials != null)
            {
                client.ClientCredentials.UserName.UserName = "su";
                client.ClientCredentials.UserName.Password = "su123";
            }

            IMTCollection instances = productOffering.GetPriceableItems();

            var productOfferingFactory = new ProductOfferingFactory();
            productOfferingFactory.Initialize(testName, testRunUniqueIdentifier);

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

                    
                      ////todo remove dafault rate for PI
                      var rscheds = new List<BaseRateSchedule>();
                      List<BaseRateSchedule> tmprscheds;

                      client.GetRateSchedulesForProductOffering(
                          new PCIdentifier(productOffering.ID),
                          new PCIdentifier(possibleRC.ID),
                          new PCIdentifier(parameterTableUdrcTiered.ID),
                          out tmprscheds);
                      rscheds.AddRange(tmprscheds);

                      client.GetRateSchedulesForProductOffering(
                           new PCIdentifier(productOffering.ID),
                           new PCIdentifier(possibleRC.ID),
                           new PCIdentifier(parameterTableUdrcTapered.ID),
                           out rscheds);
                      rscheds.AddRange(tmprscheds);
                    
                      foreach (var rsched in rscheds.Where(rsched => rsched.ID != null))
                      {
                          client.RemoveRateScheduleFromProductOffering(
                              new PCIdentifier(productOffering.ID),
                              Convert.ToInt32(rsched.ID));                                                   
                      }

                  }
            }

            #endregion
        }

        //Values to use for verification
        var expectedErrorMessagePartialText = "ICB rates are not allowed for this parameter table on this product offering";

        #endregion

        #region Test and Verify

        var request = new QuoteRequest();
        request.Accounts.Add(idAccountToQuoteFor);
        request.ProductOfferings.Add(idProductOfferingToQuoteFor1);
        request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
        request.QuoteDescription = "Quote generated by Automated Test: " + testName;
        request.ReportParameters = new ReportParams() { PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault };
        request.EffectiveDate = MetraTime.Now;
        request.EffectiveEndDate = MetraTime.Now;
        request.SubscriptionParameters.UDRCValues = SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering, value: 40m);

        #region Initialize ICB prices

        var quoteId = DateTime.Now.Millisecond;

        request.IcbPrices = new List<QuoteIndividualPrice>();
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
                      {30, 55.5m}                      
                    })
                };
            }
            else
            {
                qip.RateSchedules = new List<BaseRateSchedule>
                {
                  SharedTestCode.GetTieredUdrcRateSchedule(30, 55.5m, 30m)
                };
            }

            request.IcbPrices.Add(qip);
        }

        #endregion

   // QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,0,"0",0,0,0);
        var erroredResponse = new QuoteResponse();

        try
        {
            //erroredResponse = SharedTestCodeQuoting.InvokeCreateQuote(request);
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

    [TestMethod]
    [TestCategory("FunctionalTest")]
    public void QuotingWithIcbForMultipleAccounts()
    {
        string billcycle = "Annually";

        #region Prepare

        string testName = "QuotingWithIcbForMultipleAccounts_BillingCycles_" + billcycle;
        string testShortName = "Q_GSub";//Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier

        string testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique

        #region create accounts

        List<MetraTech.DomainModel.BaseTypes.Account> Hierarchy = SharedTestCode.CreateHierarchyofAccounts(billcycle, testShortName,
                                                                              testRunUniqueIdentifier);
        Hierarchy.AddRange(SharedTestCode.CreateHierarchyofAccounts(billcycle, testShortName + "_2", testRunUniqueIdentifier + "_2"));

        var independent = new IndependentAccountFactory(testShortName, testRunUniqueIdentifier);
        independent.CycleType = UsageCycleType.Annually;
        independent.Instantiate();

        var independent2 = new IndependentAccountFactory(testShortName + "_2", testRunUniqueIdentifier + "_2");
        independent2.CycleType = UsageCycleType.Annually;
        independent2.Instantiate();

        #endregion

        #region Create/Verify Product Offering Exists

        IMTProductOffering productOffering;
        var pofConfiguration = SharedTestCode.CreateProductOfferingConfiguration(testName, testRunUniqueIdentifier, out productOffering);//set count of PIs inside this method

        #endregion


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
            productOfferingFactory.Initialize(testName, testRunUniqueIdentifier);

            var parameterTableFlatRc = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComFlatrecurringcharge);

            var parameterTableNonRc = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComNonrecurringcharge);
            var parameterTableUdrcTapered = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComUdrctapered);

            var parameterTableUdrcTiered = productOfferingFactory.ProductCatalog.GetParamTableDefinitionByName(SharedTestCode.MetratechComUdrctiered);

            #region Set Allow ICB for PIs

            foreach (IMTPriceableItem possibleRC in instances)
            {
                if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
                {
                    var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableUdrcTapered.ID, SharedTestCode.MetratechComUdrctapered);
                    pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                    piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableUdrcTiered.ID, SharedTestCode.MetratechComUdrctiered);
                    pofConfiguration.PriceableItemsAndParameterTableForUdrc.Add(piAndPTParameters);

                }
                else if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_RECURRING)
                {
                    var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableFlatRc.ID, SharedTestCode.MetratechComFlatrecurringcharge);
                    pofConfiguration.PriceableItemsAndParameterTableForRc.Add(piAndPTParameters);
                }
                else if (possibleRC.Kind == MTPCEntityType.PCENTITY_TYPE_NON_RECURRING)
                {
                    var piAndPTParameters = SharedTestCode.SetAllowICBForPI(possibleRC, client, productOffering.ID, parameterTableNonRc.ID, SharedTestCode.MetratechComNonrecurringcharge);
                    pofConfiguration.PriceableItemsAndParameterTableForNonRc.Add(piAndPTParameters);
                }
            }

            #endregion
        }

        //Values to use for verification
        string expectedQuoteCurrency = "USD";

        #endregion

        #region Test

        // Ask backend to start quote

        //Prepare request
        QuoteRequest request = new QuoteRequest();

        foreach (var hierarhy in Hierarchy)
        {
            request.Accounts.Add(hierarhy._AccountID.Value);
        }

        request.Accounts.Add((int)independent.Item._AccountID);
        request.Accounts.Add((int)independent2.Item._AccountID);

        request.ProductOfferings.Add(idProductOfferingToQuoteFor);
        request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
        request.QuoteDescription = "Quote generated by Automated Test: " + testName;
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
        int expectedQuoteNRCsCount = pofConfiguration.CountNRCs * numOfAccounts;
        int expectedQuoteFlatRCsCount = (pofConfiguration.CountPairRCs * numOfAccounts) * 2;
        int expectedQuoteUDRCsCount = (pofConfiguration.CountPairUDRCs * numOfAccounts) * 2;

        pofConfiguration.RCAmount = 66.66m;
        pofConfiguration.NRCAmount = 77.77m;
        decimal totalAmountForUDRC = 15 * 16.6m + 5 * 13m;

        decimal expectedQuoteTotal = (expectedQuoteFlatRCsCount * pofConfiguration.RCAmount) +
                                     (expectedQuoteUDRCsCount * totalAmountForUDRC) +
                                     (expectedQuoteNRCsCount * pofConfiguration.NRCAmount);

        #region Initialize ICB prices

        var quoteId = DateTime.Now.Millisecond;

        request.IcbPrices = new List<QuoteIndividualPrice>();

        foreach (var account in request.Accounts)
        {
            foreach (var ptrc in pofConfiguration.PriceableItemsAndParameterTableForRc)
            {
                var qip = new QuoteIndividualPrice
                {
                    QuoteId = quoteId,
                    ParameterTableId = ptrc.ParameterTableId,
                    PriceableItemInstanceId = ptrc.PriceableItemId,
                    ProductOfferingId = productOffering.ID,
                    RateSchedules = new List<BaseRateSchedule> { SharedTestCode.GetFlatRcRateSchedule(66.66m) }
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

  }
}
