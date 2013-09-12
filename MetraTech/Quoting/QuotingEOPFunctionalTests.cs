using System;
using System.Collections.Generic;
using System.Linq;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MeterRowset;
using MetraTech.Shared.Test;
using MetraTech.UsageServer;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Quoting.Test
{
  //[TestClass]
  public class QuotingEOPFunctionalTests
  {
    #region Setup/Teardown

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
      SharedTestCode.MakeSureServiceIsStarted("Pipeline");
    }

    #endregion

    #region : Quoting for 1 account. Tests for PO with 1 RC (flat RC), different type of accounts and billing cycles

    [TestMethod] //#1
    public void QuotingCorpAnnualAccount()
    {
      /*
       Account: Corporate. Billing Cycle: Annual
       Effective date: Today
       Action: Invoke CreateQuote with 1 such user
       */

      QuotingCorpAccount_diffBillingCycle("");
    }

    [TestMethod] //#2
    public void QuotingCorpSemiAnnualAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Semi_Annually");
    }

    [TestMethod] //#3
    public void QuotingCorpQuarterlyAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Quarterly");
    }

    [TestMethod] //#4
    public void QuotingCorpMonthlyAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Monthly");
    }

    [TestMethod] //#5
    public void QuotingCorpSemiMonthlyAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Semi_monthly");
    }

    [TestMethod] //#6
    public void QuotingCorpBiweeklyAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Bi_weekly");
    }

    [TestMethod] //#7
    public void QuotingCorpWeeklyAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Weekly");
    }

    [TestMethod] //#8
    public void QuotingCorpDailyAccount()
    {
      QuotingCorpAccount_diffBillingCycle("Daily");
    }

    public void QuotingCorpAccount_diffBillingCycle(string billcycle)
    {
      #region Prepare

      string testName = "QuotingCorpAccount" + billcycle;
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;
      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2; //???
      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   (pofConfiguration.CountPairRCs*pofConfiguration.RCAmount*2 +
                                    pofConfiguration.CountNRCs*pofConfiguration.NRCAmount +
                                    pofConfiguration.CountPairUDRCs*30*2);
      int mult;
      int m;
      // Create account

      #region create account

      var corpAccountHolder = new CorporateAccountFactory(testShortName + "0", testRunUniqueIdentifier);

      switch (billcycle)
      {
        case "Semi_Annually":
          corpAccountHolder.CycleType = UsageCycleType.Semi_Annually;
          break;
        case "Quarterly":
          corpAccountHolder.CycleType = UsageCycleType.Quarterly;
          break;
        case "Monthly":
          corpAccountHolder.CycleType = UsageCycleType.Monthly;

          break;
        case "Semi_monthly":
          corpAccountHolder.CycleType = UsageCycleType.Semi_monthly;
          m = DateTime.Now.Day;
          mult = 0;
          expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*mult; //???
          expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2*mult; //???
          expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount + expectedQuoteUDRCsCount*30 +
                               expectedQuoteNRCsCount*pofConfiguration.NRCAmount;
          break;
        case "Bi_weekly":
          corpAccountHolder.CycleType = UsageCycleType.Bi_weekly;
          m = DateTime.Now.Day;
          mult = 0;
          expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*mult; //???
          expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2*mult; //???
          expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount + expectedQuoteUDRCsCount*30 +
                               expectedQuoteNRCsCount*pofConfiguration.NRCAmount;
          break;
        case "Weekly":
          corpAccountHolder.CycleType = UsageCycleType.Weekly;
          m = DateTime.Now.Day;
          mult = 0;
          expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*mult; //???
          expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2*mult; //???
          expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount + expectedQuoteUDRCsCount*30 +
                               expectedQuoteNRCsCount*pofConfiguration.NRCAmount;
          break;
        case "Daily":
          corpAccountHolder.CycleType = UsageCycleType.Daily;
          m = DateTime.Now.Day;
          mult = 0;
          expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*mult; //???
          expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2*mult; //???
          expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount + expectedQuoteUDRCsCount*30 +
                               expectedQuoteNRCsCount*pofConfiguration.NRCAmount;
          break;
        default:
          corpAccountHolder.CycleType = UsageCycleType.Annually;
          int month = DateTime.Now.Month;
          mult = 12 - month + 1;
          expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*mult; //???
          expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2*mult; //???
          expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount + expectedQuoteUDRCsCount*30 +
                               expectedQuoteNRCsCount*pofConfiguration.NRCAmount;
          break;
      }


      corpAccountHolder.Instantiate();
      Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
      Console.WriteLine("Account:" + corpAccountHolder.Item._AccountID + ", Billing Cycle:" +
                        corpAccountHolder.CycleType);
      Console.WriteLine("expectedQuoteFlatRCsCount  " + expectedQuoteFlatRCsCount +
                        "  amount expectedQuoteFlatRCsCount: " + pofConfiguration.RCAmount);
      Console.WriteLine("expectedQuoteFlatUDRCsCount  " + expectedQuoteUDRCsCount + "  amount expectedQuoteUDRCsCount: " +
                        30);
      Console.WriteLine("expectedQuoteNRCCount  " + expectedQuoteNRCsCount + "  amount expectedQuoteNRCsCount: " +
                        pofConfiguration.NRCAmount);

      #endregion

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();
      var productOfferingS = new List<IMTProductOffering>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        productOfferingS.Add(productOffering);
        posToAdd.Add(productOffering.ID);
        Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name" + productOffering.Name);
      }


      //Values to use for verification


      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();
      var corpAccountHolders = new List<int> {corpAccountHolder.Item._AccountID.Value};
      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      foreach (IMTProductOffering productOffering in productOfferingS)
      {
        List<UDRCInstanceValueBase> list =
          SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
        request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
      }

      request.Localization = "en-US";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount,
                                                                                expectedQuoteUDRCsCount);

      #endregion
    }

    #endregion

    #region EOP

    [TestMethod] //#6
    public void QuotingSubscribedAccountforUDRC_NRC_RC_EOP()
    {
      #region Prepare

      string testName = "QuotingAccUDRC_NRC_RC_Subscribe_EOP";
      string testShortName = "Q_NRCRCUD";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for one account and multiple Product Offerings, When quote is run User subscriprion runs";
      string testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      // Create accounts

      #region Create account

      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
        Console.WriteLine("Account ID:" + corpAccountHolder.Item._AccountID);
      }

      #endregion

      // Subscribe account to PO

      #region Subscribe account to POs

      // Subscribe account to PO
      var POs_name = new List<string>();

      var pofSubs = new ProductOfferingFactoryConfiguration(testShortName + "_For_Subscription_",
                                                            testRunUniqueIdentifier + "S");
      pofSubs.CountNRCs = 2;
      pofSubs.CountPairRCs = 1; //????
      //pofSubs.CountPairUDRCs = 0; //????

      var pos = new List<IMTProductOffering>();
      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofSubs.Name = testShortName + "_for_Subscription" + i;
        pofSubs.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofSubs);
        pos.Add(productOffering);
        POs_name.Add(productOffering.Name);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        Console.WriteLine("PO ID for Subscription :" + productOffering.ID + ", PO name for Subscription:" +
                          productOffering.Name);
      }


      var effDate = new MTPCTimeSpanClass
        {
          StartDate = MetraTime.Now,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };
      object modifiedDate = MetraTime.Now;

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);

      #region Check and turn off InstantRCs if needed

      bool instantRCsEnabled = QuotingHelper.GetInstanceRCStateAndSwitchItOff();

      #endregion

      foreach (int accID in corpAccountHolders)
      {
        MTPCAccount acc = productCatalog.GetAccount(accID);
        foreach (string name in POs_name)
        {
          MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
          MTSubscription subscription = acc.Subscribe(PO.ID, effDate, out modifiedDate);
        }
      }

      #region Turn InstantRCs back on

      QuotingHelper.BackOnInstanceRC(instantRCsEnabled);

      #endregion

      foreach (string name in POs_name)
      {
        MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
        Console.WriteLine("PO ID:" + PO.ID + ", PO name:" + PO.Name);
      }

      #endregion

      testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique
      // Create/Verify Product Offering Exists

      #region Create/Verify Product Offering Exists

      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 2; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();
      var productOfferingS = new List<IMTProductOffering>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        productOfferingS.Add(productOffering);
        posToAdd.Add(productOffering.ID);
        Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name:" + productOffering.Name);
      }

      #endregion

      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs*2;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2; //???
      decimal expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount +
                                   expectedQuoteNRCsCount*pofConfiguration.NRCAmount + expectedQuoteUDRCsCount*30;
      string expectedQuoteCurrency = "USD";
      Console.WriteLine("expectedQuoteFlatRCsCount  " + expectedQuoteFlatRCsCount +
                        "  amount expectedQuoteFlatRCsCount: " + pofConfiguration.RCAmount);
      Console.WriteLine("expectedQuoteFlatUDRCsCount  " + expectedQuoteUDRCsCount + "  amount expectedQuoteUDRCsCount: " +
                        30);
      Console.WriteLine("expectedQuoteNRCCount  " + expectedQuoteNRCsCount + "  amount expectedQuoteNRCsCount: " +
                        pofConfiguration.NRCAmount);

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      foreach (IMTProductOffering productOffering in productOfferingS)
      {
        List<UDRCInstanceValueBase> list =
          SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
        request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
      }

      request.Localization = "en-US";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount,
                                                                                expectedQuoteUDRCsCount);

      #endregion
    }

    [TestMethod] //#8
    public void QuotingAccountforUDRC_NRC_RC_EOP()
    {
      #region Prepare

      string testName = "QuotingAccUDRC_NRC_RC_Subscribe_EOP";
      string testShortName = "Q_NRCRCUDRC";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for one account and multiple Product Offerings, When quote is run User subscriprion runs";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      // Create accounts

      #region Create account

      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
        Console.WriteLine("Account ID:" + corpAccountHolder.Item._AccountID);
      }

      #endregion

      // Create/Verify Product Offering Exists

      #region Create/Verify Product Offering Exists

      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 2; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();
      var productOfferingS = new List<IMTProductOffering>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        productOfferingS.Add(productOffering);
        posToAdd.Add(productOffering.ID);
        Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name:" + productOffering.Name);
      }

      #endregion

      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???
      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   (pofConfiguration.CountPairRCs*pofConfiguration.RCAmount*2 +
                                    pofConfiguration.CountNRCs*pofConfiguration.NRCAmount +
                                    pofConfiguration.CountPairUDRCs*2*30);
      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      foreach (IMTProductOffering productOffering in productOfferingS)
      {
        List<UDRCInstanceValueBase> list =
          SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
        request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
      }

      request.Localization = "en-US";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount);

      #endregion
    }


    [TestMethod] //#1
    public void QuotingAccount_EOP()
    {
      #region Prepare

      string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      // Create accounts
      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
      }

      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        posToAdd.Add(productOffering.ID);
      }


      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   (pofConfiguration.CountPairRCs*pofConfiguration.RCAmount*2 +
                                    pofConfiguration.CountNRCs*pofConfiguration.NRCAmount);
      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
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

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);
      Console.WriteLine("Account:" + corpAccountHolders[0]);
      for (int i = 0; i < numberProductOfferingsToIncludeInQuote; i++)
      {
        Console.WriteLine("PO ID for Quoting:" + posToAdd[i] + ", PO name" +
                          productCatalog.GetProductOffering(posToAdd[i]));
      }
      //move time
      DateTime date = DateTime.Now;
      DateTime movedDate = CycleUtils.MoveToDay(date, 30);

      MeterRowset waiter = new MeterRowsetClass();
      //waiter.WaitForCommit(5, 120);
      //metters["RC"].WaitForCommit(countMeteredRecords, 120);
    }

    [TestMethod] //#2
    public void QuotedAccount_and_SubscribedEOP()
    {
      #region Prepare

      string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      // Create accounts
      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
      }


      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        posToAdd.Add(productOffering.ID);
      }


      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   (pofConfiguration.CountPairRCs*pofConfiguration.RCAmount*2 +
                                    pofConfiguration.CountNRCs*pofConfiguration.NRCAmount);
      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
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

      // Subscribe account to PO
      var effDate = new MTPCTimeSpanClass
        {
          StartDate = MetraTime.Now,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };
      object modifiedDate = MetraTime.Now;

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);

      MTPCAccount acc = productCatalog.GetAccount(corpAccountHolders[0]);

      MTProductOffering po = productCatalog.GetProductOffering(posToAdd[0]);

      Assert.IsNotNull(po, "Does not resolve PO by name");
      Assert.IsFalse(po.ID <= 0, "ID was not found by name");


      //var subscription = acc.Subscribe(1023, effDate, out modifiedDate);
      MTSubscription subscription = acc.Subscribe(po.ID, effDate, out modifiedDate);

      //put data to console
      Console.WriteLine("Account:" + corpAccountHolders[0]);
      Console.WriteLine("PO ID:" + po.ID + ", PO name " + po.Name);
      for (int i = 0; i < numberProductOfferingsToIncludeInQuote; i++)
      {
        Console.WriteLine("PO ID for Quoting:" + posToAdd[i] + ", PO name" +
                          productCatalog.GetProductOffering(posToAdd[i]));
      }
    }

    [TestMethod] //#4
    public void QuotedAccount_and_Subscribefo_quotedPOsEOP()
    {
      #region Prepare

      string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      #region Create account

      // Create accounts
      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
      }

      #endregion

      #region create POs for quoting

      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        posToAdd.Add(productOffering.ID);
      }

      #endregion

      #region Values to use for verification

      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   (pofConfiguration.CountPairRCs*pofConfiguration.RCAmount*2 +
                                    pofConfiguration.CountNRCs*pofConfiguration.NRCAmount);
      string expectedQuoteCurrency = "USD";

      #endregion

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
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

      #region Subscribe account to quoted POs

      // Subscribe account to PO
      var effDate = new MTPCTimeSpanClass
        {
          StartDate = MetraTime.Now,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };
      object modifiedDate = MetraTime.Now;

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);

      MTPCAccount acc = productCatalog.GetAccount(corpAccountHolders[0]);


      foreach (int PO in posToAdd)
      {
        MTSubscription subscription = acc.Subscribe(PO, effDate, out modifiedDate);
      }

      #endregion

      //var subscription = acc.Subscribe(1023, effDate, out modifiedDate);


      //put data to console
      Console.WriteLine("Account:" + corpAccountHolders[0]);
      foreach (int PO in posToAdd)
      {
        Console.WriteLine("PO ID for Quoting:" + PO + ", PO name" + productCatalog.GetProductOffering(PO));
      }
      //move time
      DateTime date = DateTime.Now;
      DateTime movedDate = CycleUtils.MoveToDay(date, 30);

      MeterRowset waiter = new MeterRowsetClass();
      //waiter.WaitForCommit(5, 120);
      //metters["RC"].WaitForCommit(countMeteredRecords, 120);
    }

    #endregion

    #region commented tests

    [TestMethod] //#7
    public void QuotingAccountsforUDRC_NRC_RC_Subscribe_EOP()
    {
      #region Prepare

      string testName = "QuotingAccUDRC_NRC_RC_Subscribe_EOP";
      string testShortName = "Q_NRCRCUDRC";
        //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for one account and multiple Product Offerings, When quote is run User subscriprion runs";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      // Create accounts

      #region Create account

      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
        Console.WriteLine("Account ID:" + corpAccountHolder.Item._AccountID);
      }

      #endregion

      // Create/Verify Product Offering Exists

      #region Create/Verify Product Offering Exists

      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();
      var productOfferingS = new List<IMTProductOffering>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        productOfferingS.Add(productOffering);
        posToAdd.Add(productOffering.ID);
        Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name:" + productOffering.Name);
      }

      #endregion

      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2; //???
      decimal expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount +
                                   expectedQuoteNRCsCount*pofConfiguration.NRCAmount + expectedQuoteUDRCsCount*30;
      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();
      var AccID = new List<int> {corpAccountHolders[0]};
      request.Accounts.AddRange(AccID);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      foreach (IMTProductOffering productOffering in productOfferingS)
      {
        List<UDRCInstanceValueBase> list =
          SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
        request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
      }

      request.Localization = "en-US";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount);

      #endregion

      // Subscribe account to PO

      #region Subscribe account to POs

      // Subscribe account to PO
      var poS = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????


      //Now generate the Product Offerings we need

      var posToSbs = new List<IMTProductOffering>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        posToSbs.Add(productOffering);
        Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name:" + productOffering.Name);
      }


      var effDate = new MTPCTimeSpanClass
        {
          StartDate = MetraTime.Now,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };
      object modifiedDate = MetraTime.Now;

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);

      foreach (int accID in corpAccountHolders)
      {
        MTPCAccount acc = productCatalog.GetAccount(accID);
        foreach (IMTProductOffering id in posToSbs)
        {
          MTSubscription subscription = acc.Subscribe(id.ID, effDate, out modifiedDate);
        }
      }

      foreach (IMTProductOffering id in posToSbs)
      {
        Console.WriteLine("PO ID:" + id.ID + ", PO name:" + id.Name);
      }

      #endregion
    }

    [TestMethod] //#3 Needs loaded "Localized Audio Conference Product Offering USD" PO
    public void QuotingWithSubscribedAccount_EOP()
    {
      #region Prepare

      string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 4;

      #region create account

      // Create accounts
      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
      }

      #endregion

      #region subscribe account to PO

      // Subscribe account to PO
      var effDate = new MTPCTimeSpanClass
        {
          StartDate = MetraTime.Now,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };
      object modifiedDate = MetraTime.Now;

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);

      MTPCAccount acc = productCatalog.GetAccount(corpAccountHolders[0]);

      MTProductOffering po = productCatalog.GetProductOfferingByName("Localized Audio Conference Product Offering USD");

      Assert.IsNotNull(po, "Does not resolve PO by name");
      Assert.IsFalse(po.ID <= 0, "ID was not found by name");

      Console.WriteLine("Account:" + corpAccountHolders[0]);


      MTSubscription subscription = acc.Subscribe(po.ID, effDate, out modifiedDate);
      Console.WriteLine("PO ID:" + po.ID + ", PO name Localized Audio Conference Product Offering USD");

      #endregion

      // Create/Verify Product Offering Exists
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();
      var productOfferingS = new List<IMTProductOffering>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        productOfferingS.Add(productOffering);
        posToAdd.Add(productOffering.ID);
      }

      for (int i = 0; i < numberProductOfferingsToIncludeInQuote; i++)
      {
        Console.WriteLine("PO ID for Quoting:" + posToAdd[i] + ", PO name" +
                          productCatalog.GetProductOffering(posToAdd[i]));
      }
      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   (pofConfiguration.CountPairRCs*pofConfiguration.RCAmount*2 +
                                    pofConfiguration.CountNRCs*pofConfiguration.NRCAmount);
      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      foreach (IMTProductOffering productOffering in productOfferingS)
      {
        List<UDRCInstanceValueBase> list =
          SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering).Values.First();
        request.SubscriptionParameters.UDRCValues.Add(productOffering.ID.ToString(), list);
      }

      request.Localization = "en-US";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount);

      #endregion

      //move time
      DateTime date = DateTime.Now;
      DateTime movedDate = CycleUtils.MoveToDay(date, 30);

      MeterRowset waiter = new MeterRowsetClass();
    }

    [TestMethod] //#5
    public void QuotingSubscribedMultipleAccounts_EOP()
    {
      #region Prepare

      string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 1;
      const int numberProductOfferingsToIncludeInQuote = 15;

      #region Create account

      // Create accounts
      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int) corpAccountHolder.Item._AccountID);
        Console.WriteLine("Account:" + corpAccountHolder.Item._AccountID + ", Account name:" +
                          corpAccountHolder.Item.UserName);
      }

      #endregion

      #region Subscribe account to POs

      // Subscribe account to PO
      var POs_name = new List<string>();

      var pofSubs = new ProductOfferingFactoryConfiguration(testShortName + "_For_Subscription_",
                                                            testRunUniqueIdentifier + "S");
      pofSubs.CountNRCs = 2;
      pofSubs.CountPairRCs = 1; //????
      pofSubs.CountPairUDRCs = 2; //????
      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofSubs.Name = testShortName + "_for_Subscription" + i;
        pofSubs.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofSubs);
        POs_name.Add(productOffering.Name);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        Console.WriteLine("PO ID for Subscription :" + productOffering.ID + ", PO name for Subscription:" +
                          productOffering.Name);
      }
      //var subscription = acc.Subscribe(1023, effDate, out modifiedDate);

      var effDate = new MTPCTimeSpanClass
        {
          StartDate = MetraTime.Now,
          StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE
        };
      object modifiedDate = MetraTime.Now;

      IMTProductCatalog productCatalog = new MTProductCatalogClass();
      var sessionContext = (IMTSessionContext) SharedTestCode.LoginAsSU();

      productCatalog.SetSessionContext(sessionContext);

      foreach (int accID in corpAccountHolders)
      {
        MTPCAccount acc = productCatalog.GetAccount(accID);
        foreach (string name in POs_name)
        {
          MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
          MTSubscription subscription = acc.Subscribe(PO.ID, effDate, out modifiedDate);
        }
      }

      foreach (string name in POs_name)
      {
        MTProductOffering PO = productCatalog.GetProductOfferingByName(name);
        Console.WriteLine("PO ID:" + PO.ID + ", PO name:" + PO.Name);
      }

      #endregion

      #region create POs for quoting

      // Create/Verify Product Offering Exists
      testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testShortName, testRunUniqueIdentifier);

      pofConfiguration.CountNRCs = 2;
      pofConfiguration.CountPairRCs = 1; //????
      pofConfiguration.CountPairUDRCs = 1; //????

      //Now generate the Product Offerings we need
      var posToAdd = new List<int>();

      for (int i = 1; i < numberProductOfferingsToIncludeInQuote + 1; i++)
      {
        pofConfiguration.Name = testShortName + "_" + i;
        pofConfiguration.UniqueIdentifier = testRunUniqueIdentifier + "_" + i;
        IMTProductOffering productOffering = ProductOfferingFactory.Create(pofConfiguration);
        Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
        posToAdd.Add(productOffering.ID);
        Console.WriteLine("PO ID for Quoting:" + productOffering.ID + ", PO name" + productOffering.Name);
      }

      #endregion

      #region Values to use for verification

      //Values to use for verification
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                   pofConfiguration.CountNRCs*2;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                      pofConfiguration.CountPairRCs*2*2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote*numberProductOfferingsToIncludeInQuote*
                                    pofConfiguration.CountPairUDRCs*2; //???
      decimal expectedQuoteTotal = expectedQuoteFlatRCsCount*pofConfiguration.RCAmount +
                                   expectedQuoteNRCsCount*pofConfiguration.NRCAmount + expectedQuoteUDRCsCount*30;
      string expectedQuoteCurrency = "USD";

      #endregion

      #endregion

      #region Test Quote and Verify

      //Prepare request

      var request = new QuoteRequest();

      request.Accounts.AddRange(corpAccountHolders);
      request.ProductOfferings.AddRange(posToAdd);

      request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      request.EffectiveDate = MetraTime.Now;
      request.EffectiveEndDate = MetraTime.Now;
      request.Localization = "en-US";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      QuoteResponse response = QuotingTestScenarios.CreateQuoteAndVerifyResults(request,
                                                                                expectedQuoteTotal,
                                                                                expectedQuoteCurrency,
                                                                                expectedQuoteFlatRCsCount,
                                                                                expectedQuoteNRCsCount,
                                                                                expectedQuoteUDRCsCount);

      #endregion

      //move time
      DateTime date = DateTime.Now;
      DateTime movedDate = CycleUtils.MoveToDay(date, 30);

      MeterRowset waiter = new MeterRowsetClass();
      //waiter.WaitForCommit(5, 120);
      //metters["RC"].WaitForCommit(countMeteredRecords, 120);
    }

    #endregion
  }
}
