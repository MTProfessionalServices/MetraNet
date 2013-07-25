using System;
using MetraTech.Domain.Quoting;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Shared.Test;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;

namespace MetraTech.Quoting.Test
{
    [TestClass]
    public class QuotingAccountSubscriptionVariationsFunctionalTests
    {
        #region Setup/Teardown

        [ClassInitialize]
        public static void InitTests(TestContext testContext)
        {
            SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
            SharedTestCode.MakeSureServiceIsStarted("Pipeline");
        }

        #endregion

        [TestMethod]
        public void QuotingWithMonthlyInAdvanceAndArrearsRC()
        {
          #region Prepare
          string testName = "QuotingWithMonthlyInAdvanceAndArrearsRC";
          string testShortName = "Q_MonAdv"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
          //string testDescription = @"";
          string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

          var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

          // Create account
          CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
          corpAccountHolder.Instantiate();

          Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
          int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

          // Create/Verify Product Offering Exists

          pofConfiguration.CountNRCs = 1;
          pofConfiguration.CountPairRCs = 1;

          IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
          Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
          int idProductOfferingToQuoteFor = productOffering.ID;

          IMTProductCatalog productCatalog = new MTProductCatalogClass();
          IMTSessionContext sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

          productCatalog.SetSessionContext(sessionContext);

          #region Add monthly in advance RC

          productOffering.AvailabilityDate.SetStartDateNull();

          IMTPriceableItemType priceableItemTypeFRRC = productCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge");

          if (priceableItemTypeFRRC == null)
          {
            throw new ApplicationException("'Flat Rate Recurring Charge' Priceable Item Type not found");
          }

          var pl = productOffering.GetNonSharedPriceList();

          string fullName = string.Concat("FRRC_Monthly_In_Advance_", MetraTime.Now);

          var piTemplate_FRRC = (IMTRecurringCharge)priceableItemTypeFRRC.CreateTemplate(false);
          piTemplate_FRRC.Name = fullName;
          piTemplate_FRRC.DisplayName = fullName;
          piTemplate_FRRC.Description = fullName;
          piTemplate_FRRC.ChargeInAdvance = true;
          piTemplate_FRRC.ProrateOnActivation = true;
          piTemplate_FRRC.ProrateOnDeactivation = true;
          piTemplate_FRRC.ProrateOnRateChange = true;
          piTemplate_FRRC.FixedProrationLength = false;
          piTemplate_FRRC.ChargePerParticipant = true;
          IMTPCCycle pcCycle = piTemplate_FRRC.Cycle;
          pcCycle.CycleTypeID = 1;
          pcCycle.EndDayOfMonth = 31;
          piTemplate_FRRC.Save();

          IMTParamTableDefinition pt = productCatalog.GetParamTableDefinitionByName("metratech.com/flatrecurringcharge");
          IMTRateSchedule sched = pt.CreateRateSchedule(pl.ID, piTemplate_FRRC.ID);
          sched.ParameterTableID = pt.ID;
          sched.Description = "Unit Test Rates";
          sched.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
          sched.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");

          sched.Save();

          sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                             Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
                             "flatrcrules1.xml"));

          sched.SaveWithRules();

          productOffering.AddPriceableItem((MTPriceableItem)piTemplate_FRRC);

          productOffering.AvailabilityDate.StartDate = MetraTime.Now;

          #endregion

          //Values to use for verification
          decimal expectedQuoteTotal = (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 ) + //First the in arrears monthly 'pairs' of per participant and per subscription
                                         pofConfiguration.RCAmount + //Then our one monthly in advance charge (same amount)
                                         pofConfiguration.CountNRCs * pofConfiguration.NRCAmount; //Then our 1 setup charge for the subscription (NRC)
          string expectedQuoteCurrency = "USD";

          int expectedQuoteNRCsCount = 1;
          int expectedQuoteFlatRCsCount = pofConfiguration.CountPairRCs * 2 + 1;

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

          //Give request to testing scenario along with expected results for verification; get back response for further verification
          QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                    expectedQuoteTotal,
                                                                                    expectedQuoteCurrency,
                                                                                    expectedQuoteFlatRCsCount,
                                                                                    expectedQuoteNRCsCount);

          #endregion
        }

        [TestMethod]
        public void QuotingWithYearlyInAdvanceAndArrearsRC()
        {
          #region Prepare
          string testName = "QuotingWithYearlyInAdvanceAndArrearsRC";
          string testShortName = "Q_YearAdv"; //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
          //string testDescription = @"";
          string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique


          // Create account
          CorporateAccountFactory corpAccountHolder = new CorporateAccountFactory(testShortName, testRunUniqueIdentifier);
          corpAccountHolder.CycleType = UsageCycleType.Annually;
          corpAccountHolder.Instantiate();

          Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
          int idAccountToQuoteFor = (int)corpAccountHolder.Item._AccountID;

          int countOfMonthsToCharge = (12 - MetraTime.Now.Month + 1);

          // Create/Verify Product Offering Exists
          var pofConfiguration = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier);

          pofConfiguration.CountNRCs = 1;
          pofConfiguration.CountPairRCs = 1;

          IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
          Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
          int idProductOfferingToQuoteFor = productOffering.ID;

          IMTProductCatalog productCatalog = new MTProductCatalogClass();
          IMTSessionContext sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

          productCatalog.SetSessionContext(sessionContext);

          #region Add monthly in advance RC

          productOffering.AvailabilityDate.SetStartDateNull();

          IMTPriceableItemType priceableItemTypeFRRC = productCatalog.GetPriceableItemTypeByName("Flat Rate Recurring Charge");

          if (priceableItemTypeFRRC == null)
          {
            throw new ApplicationException("'Flat Rate Recurring Charge' Priceable Item Type not found");
          }

          var pl = productOffering.GetNonSharedPriceList();

          string fullName = string.Concat("FRRC_Monthly_In_Advance_", MetraTime.Now);

          var piTemplate_FRRC = (IMTRecurringCharge)priceableItemTypeFRRC.CreateTemplate(false);
          piTemplate_FRRC.Name = fullName;
          piTemplate_FRRC.DisplayName = fullName;
          piTemplate_FRRC.Description = fullName;
          piTemplate_FRRC.ChargeInAdvance = true;
          piTemplate_FRRC.ProrateOnActivation = true;
          piTemplate_FRRC.ProrateOnDeactivation = true;
          piTemplate_FRRC.ProrateOnRateChange = true;
          piTemplate_FRRC.FixedProrationLength = false;
          piTemplate_FRRC.ChargePerParticipant = true;
          IMTPCCycle pcCycle = piTemplate_FRRC.Cycle;
          pcCycle.Relative = true;

          piTemplate_FRRC.Save();

          IMTParamTableDefinition pt = productCatalog.GetParamTableDefinitionByName("metratech.com/flatrecurringcharge");
          IMTRateSchedule sched = pt.CreateRateSchedule(pl.ID, piTemplate_FRRC.ID);
          sched.ParameterTableID = pt.ID;
          sched.Description = "Unit Test Rates";
          sched.EffectiveDate.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
          sched.EffectiveDate.EndDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");

          sched.Save();

          sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}",
                             Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"),
                             "flatrcrules1.xml"));

          sched.SaveWithRules();

          productOffering.AddPriceableItem((MTPriceableItem)piTemplate_FRRC);

          productOffering.AvailabilityDate.StartDate = MetraTime.Now;

          #endregion

          //Values to use for verification
          decimal expectedQuoteTotal  = (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 * countOfMonthsToCharge) + //First the in arrears monthly 'pairs' of per participant and per subscription
                                         pofConfiguration.RCAmount + //Then our one yearly in advance charge (same amount)
                                         pofConfiguration.CountNRCs * pofConfiguration.NRCAmount; //Then our 1 setup charge for the subscription (NRC)
          string expectedQuoteCurrency = "USD";

          int expectedQuoteNRCsCount = 1;
          int expectedQuoteFlatRCsCount = pofConfiguration.CountPairRCs * 2 * countOfMonthsToCharge + 1;
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

          //Give request to testing scenario along with expected results for verification; get back response for further verification
          QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                    expectedQuoteTotal,
                                                                                    expectedQuoteCurrency,
                                                                                    expectedQuoteFlatRCsCount,
                                                                                    expectedQuoteNRCsCount);

          #endregion
        }

    }
}
