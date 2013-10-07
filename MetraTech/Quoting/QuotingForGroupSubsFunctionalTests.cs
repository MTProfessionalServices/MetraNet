using System;
using System.Collections.Generic;
using MetraTech.Domain.Quoting;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Quoting.Test.Domain;
using MetraTech.Shared.Test;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Quoting.Test
{
  /// <summary>
  ///   Quoting for Group Subscription. Functional tests.
  /// </summary>
  [TestClass]
  public class QuotingForGroupSubsFunctionalTests
  {
    #region Setup/Teardown

    [ClassInitialize]
    public static void InitTests(TestContext testContext)
    {
      SharedTestCode.MakeSureServiceIsStarted("ActivityServices");
      SharedTestCode.MakeSureServiceIsStarted("Pipeline");
    }

    #endregion

    #region Quoting for 1 account. Tests for GroupSBs with 2 RC (flat RC), 1 NRC, 2 UDRC. Hierarchy: Corporate account->Department account->Department account->Core Subscriber account.Different types of billing cycles

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#1
    public void QuotingCorpAnnualAccount()
    {
      /*
       Account: Corporate. Billing Cycle: Annual
       Effective date: Today
       Action: Invoke CreateQuote with 1 such user
       */

      QuotingGroupSbsCorpAccount_diffBillingCycle("");
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore] //#2
    public void QuotingCorpSemiAnnualAccount()
    {
      QuotingGroupSbsCorpAccount_diffBillingCycle("Semi_Annually");
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#3
    public void QuotingCorpQuarterlyAccount()
    {
      QuotingGroupSbsCorpAccount_diffBillingCycle("Quarterly");
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#4
    public void QuotingCorpMonthlyAccount()
    {
      QuotingGroupSbsCorpAccount_diffBillingCycle("Monthly");
    }
    
    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#8
    public void QuotingCorpDailyAccount()
    {
      QuotingGroupSbsCorpAccount_diffBillingCycle("Daily");
    }

    #endregion
    
    #region Test Methods

      private DateTime AddTimeForCycle(DateTime initial, string billcycle)
      {
          switch (billcycle)
          {
              case "Semi_Annually":
                  return initial.AddMonths(7);

              case "Quarterly":
                  return initial.AddMonths(4);
                  
              case "Monthly":
                  return initial.AddMonths(2);

              case "Semi_monthly":
                  return initial.AddMonths(1);

              case "Bi_weekly":
                  return initial.AddDays(15);

              case "Weekly":
                  return initial.AddDays(8);

              case "Daily":
                  return initial.AddDays(2);

              default:
                  return initial;
          }
      }

      public void QuotingGroupSbsCorpAccount_diffBillingCycle(string billcycle)
    {
      string testName = "QuotingWithGroupSubscription_AccountBillingCycles" + billcycle;
      string testShortName = "Q_GSub";//Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier

      string testRunUniqueIdentifier = MetraTime.NowWithMilliSec; //Identifier to make this run unique

      QuoteImplementationData quoteImpl = new QuoteImplementationData();
      QuoteVerifyData expected = new QuoteVerifyData();

      #region create accounts

      List<DomainModel.BaseTypes.Account> Hierarchy = CreateHierarchyofAccounts(billcycle, testShortName,
                                                                                testRunUniqueIdentifier);

      #endregion

      #region Create/Verify Product Offering Exists
      
      IMTProductOffering productOffering;
      var pofConfiguration = CreateProductOfferingConfiguration(testName, testRunUniqueIdentifier, out productOffering);//set count of PIs inside this method

      #endregion

      #region Test

      // Ask backend to start quote

      //Prepare request
      
     /* foreach (DomainModel.BaseTypes.Account acc in Hierarchy)
      {
        request.Accounts.Add(acc._AccountID.Value);
        break;
      }*/
     /* testRunUniqueIdentifier = MetraTime.NowWithMilliSec; 
      var deptAccountHolder = new DepartmentAccountFactory(testShortName, testRunUniqueIdentifier);
      deptAccountHolder.CycleType = UsageCycleType.Monthly;
      deptAccountHolder.AncestorID = Hierarchy[2]._AccountID.Value;
      deptAccountHolder.Instantiate();*/

      quoteImpl.Request.Accounts.Add(Hierarchy[0]._AccountID.Value);
      quoteImpl.Request.Accounts.Add(Hierarchy[1]._AccountID.Value);
      quoteImpl.Request.Accounts.Add(Hierarchy[2]._AccountID.Value);
      quoteImpl.Request.Accounts.Add(Hierarchy[3]._AccountID.Value);
      //request.Accounts.Add(deptAccountHolder.Item._AccountID.Value);


      quoteImpl.Request.ProductOfferings.Add(productOffering.ID);
      quoteImpl.Request.QuoteIdentifier = "MyQuoteId-" + testShortName + "-1234";
      quoteImpl.Request.QuoteDescription = "Quote generated by Automated Test: " + testName;
      quoteImpl.Request.ReportParameters = new ReportParams
        {
          PDFReport = QuotingTestScenarios.RunPDFGenerationForAllTestsByDefault
        };
      quoteImpl.Request.EffectiveDate = MetraTime.Now;
      quoteImpl.Request.EffectiveEndDate = AddTimeForCycle(MetraTime.Now, billcycle);
      quoteImpl.Request.Localization = "en-US";
      quoteImpl.Request.SubscriptionParameters.UDRCValues = SharedTestCode.GetUDRCInstanceValuesSetToMiddleValues(productOffering);
      quoteImpl.Request.SubscriptionParameters.CorporateAccountId = Hierarchy[0]._AccountID.Value;
      quoteImpl.Request.SubscriptionParameters.IsGroupSubscription = true;

      expected.CountAccounts = quoteImpl.Request.Accounts.Count;
      expected.CountNRCs = pofConfiguration.CountNRCs * expected.CountAccounts;
      expected.CountFlatRCs = pofConfiguration.CountPairRCs + (pofConfiguration.CountPairRCs * expected.CountAccounts);
      expected.CountUDRCs = pofConfiguration.CountPairUDRCs + (pofConfiguration.CountPairUDRCs * expected.CountAccounts);

      expected.TotalForUDRCs = 30; //introduce formula based on PT

      expected.Total = (expected.CountFlatRCs * pofConfiguration.RCAmount) +
                                   (expected.CountUDRCs.Value * expected.TotalForUDRCs) +
                                   (expected.CountNRCs *pofConfiguration.NRCAmount);
      expected.Currency = "USD";

      //Give request to testing scenario along with expected results for verification; get back response for further verification
      quoteImpl.Response = QuotingTestScenarios.CreateQuoteAndVerifyResults(quoteImpl, expected);

      #endregion
    }

    private static ProductOfferingFactoryConfiguration CreateProductOfferingConfiguration(string testName, string testRunUniqueIdentifier,
                                                                             out IMTProductOffering productOffering)
    {
      var pofConfiguration = new ProductOfferingFactoryConfiguration(testName, testRunUniqueIdentifier);
      pofConfiguration.CountNRCs = 1;
      pofConfiguration.CountPairRCs = 1;
      pofConfiguration.CountPairUDRCs = 1;
      productOffering = ProductOfferingFactory.Create(pofConfiguration);
      Assert.IsNotNull(productOffering.ID, "Unable to create PO for test run");
      Console.WriteLine("Product Offering for quote:" + productOffering.ID + "; " + productOffering.DisplayName);
      return pofConfiguration;
    }

    public DepartmentAccountFactory createDeptAccount(DepartmentAccountFactory dept, int ancestorID)
    {
      dept.AncestorID = ancestorID;
      dept.Instantiate();
      Assert.IsNotNull(dept.Item._AccountID, "Unable to create department account for test run");
      return dept;
    }

    public List<DomainModel.BaseTypes.Account> CreateHierarchyofAccounts(string billcycle, string testShortName,
                                                                         string testRunUniqueIdentifier)
    {
      var Hierarchy = new List<DomainModel.BaseTypes.Account>();
      var corpAccountHolder = new CorporateAccountFactory(testShortName + "0", testRunUniqueIdentifier);
      testRunUniqueIdentifier = MetraTime.NowWithMilliSec;
      var deptAccountHolder1 = new DepartmentAccountFactory(testShortName+"1", testRunUniqueIdentifier);
      testRunUniqueIdentifier = MetraTime.NowWithMilliSec;
      var deptAccountHolder2 = new DepartmentAccountFactory(testShortName+"2", testRunUniqueIdentifier);
      testRunUniqueIdentifier = MetraTime.NowWithMilliSec;
      var coresubscriberAccountHolder = new CoreSubscriberAccountFactory(testShortName, testRunUniqueIdentifier);
      switch (billcycle)
      {
        case "Semi_Annually":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Semi_Annually);
          break;

        case "Quarterly":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Quarterly);
          break;
        case "Monthly":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Monthly);
          break;
        case "Semi_monthly":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Semi_monthly);
          break;
        case "Bi_weekly":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Bi_weekly);
          break;
        case "Weekly":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Weekly);
          break;
        case "Daily":
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Monthly);
          break;
        default:
          GetHierarchy(ref corpAccountHolder, ref deptAccountHolder1, ref deptAccountHolder2,
                       ref coresubscriberAccountHolder, UsageCycleType.Annually);
          break;
      }
      Hierarchy.Add(corpAccountHolder.Item);
      Hierarchy.Add(deptAccountHolder1.Item);
      Hierarchy.Add(deptAccountHolder2.Item);
      Hierarchy.Add(coresubscriberAccountHolder.Item);
      Console.WriteLine("Billing Cycle:" + corpAccountHolder.CycleType);
      Console.WriteLine("Corporate Account:" + corpAccountHolder.Item._AccountID + "; Account name:"+corpAccountHolder.Item.UserName);
      Console.WriteLine("1st Department Account:" + deptAccountHolder1.Item._AccountID + "; Account name:" + deptAccountHolder1.Item.UserName);
      Console.WriteLine("2nd Department Account:" + deptAccountHolder2.Item._AccountID + "; Account name:" + deptAccountHolder2.Item.UserName);
      Console.WriteLine("CoreSubscriber Account:" + coresubscriberAccountHolder.Item._AccountID + "; Account name:" + coresubscriberAccountHolder.Item.UserName);
      return Hierarchy;
    }

    private void GetHierarchy(ref CorporateAccountFactory corpAccountHolder,
                              ref DepartmentAccountFactory deptAccountHolder1,
                              ref DepartmentAccountFactory deptAccountHolder2,
                              ref CoreSubscriberAccountFactory coresubscriberAccountHolder, UsageCycleType usageCycleType)
    {
      // Create account #1 Corporate root
      corpAccountHolder.CycleType = usageCycleType;
      corpAccountHolder.Instantiate();
      Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create corporate account for test run");
      // Create account #2 Department child
      deptAccountHolder1.CycleType = usageCycleType;
      deptAccountHolder1 = createDeptAccount(deptAccountHolder1, corpAccountHolder.Item._AccountID.Value);
      // Create account #3 Department child
      deptAccountHolder2.CycleType = usageCycleType;
      deptAccountHolder2 = createDeptAccount(deptAccountHolder2, deptAccountHolder1.Item._AccountID.Value);
      //Create account #4 CoreSubscriber child
      //coresubscriberAccountHolder.is
      //coresubscriberAccountHolder = deptAccountHolder2.AddCoreSubscriber("User");
      coresubscriberAccountHolder.AncestorID = deptAccountHolder2.Item._AccountID.Value;
      coresubscriberAccountHolder.CycleType = usageCycleType;
      coresubscriberAccountHolder.Instantiate();
      Assert.IsNotNull(coresubscriberAccountHolder.Item._AccountID, "Unable to create CoreSubscriber account for test run");
    }

    #endregion

    #region Commented tests
    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#6
    public void QuotingCorpBiweeklyAccount()
    {
      QuotingGroupSbsCorpAccount_diffBillingCycle("Bi_weekly");
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting), Ignore] //#7
    public void QuotingCorpWeeklyAccount()
    {
      QuotingGroupSbsCorpAccount_diffBillingCycle("Weekly");
    }

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#5
    public void QuotingCorpSemiMonthlyAccount()
    {
        QuotingGroupSbsCorpAccount_diffBillingCycle("Semi_monthly");
    }

    #region EOP

    /*
    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#6
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs * 2;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2 * 2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                    pofConfiguration.CountPairUDRCs * 2; //???
      decimal expectedQuoteTotal = expectedQuoteFlatRCsCount * pofConfiguration.RCAmount +
                                   expectedQuoteNRCsCount * pofConfiguration.NRCAmount + expectedQuoteUDRCsCount * 30;
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

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#8
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2; //???
      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
                                    pofConfiguration.CountNRCs * pofConfiguration.NRCAmount +
                                    pofConfiguration.CountPairUDRCs * 2 * 30);
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


    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#1
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
                                    pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#2
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
                                    pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#4
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
                                    pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#7
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                    pofConfiguration.CountPairUDRCs * 2; //???
      decimal expectedQuoteTotal = expectedQuoteFlatRCsCount * pofConfiguration.RCAmount +
                                   expectedQuoteNRCsCount * pofConfiguration.NRCAmount + expectedQuoteUDRCsCount * 30;
      string expectedQuoteCurrency = "USD";

      #endregion

      #region Test Quote and Verify

      //Prepare request
      var request = new QuoteRequest();
      var AccID = new List<int> { corpAccountHolders[0] };
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#3 Needs loaded "Localized Audio Conference Product Offering USD" PO
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
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2; //???

      decimal expectedQuoteTotal = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   (pofConfiguration.CountPairRCs * pofConfiguration.RCAmount * 2 +
                                    pofConfiguration.CountNRCs * pofConfiguration.NRCAmount);
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

    [TestMethod, MTFunctionalTest(TestAreas.Quoting)] //#5
    public void QuotingSubscribedMultipleAccounts_EOP()
    {
      #region Prepare

      string testName = "QuotingWithMultipleAccountsAndMultiplePOs";
      string testShortName = "Q_MAMPO";
      //Account name and perhaps others need a 'short' (less than 40 when combined with testRunUniqueIdentifier
      //string testDescription = @"Given a quote request for multiple accounts and multiple Product Offerings, When quote is run Then it includes all the usage";
      string testRunUniqueIdentifier = MetraTime.Now.ToString(); //Identifier to make this run unique

      const int numberOfAccountsToIncludeInQuote = 10;
      const int numberProductOfferingsToIncludeInQuote = 10;

      #region Create account

      // Create accounts
      var corpAccountHolders = new List<int>();

      for (int i = 1; i < numberOfAccountsToIncludeInQuote + 1; i++)
      {
        var corpAccountHolder = new CorporateAccountFactory(testShortName + i.ToString(), testRunUniqueIdentifier);

        corpAccountHolder.Instantiate();

        Assert.IsNotNull(corpAccountHolder.Item._AccountID, "Unable to create account for test run");
        corpAccountHolders.Add((int)corpAccountHolder.Item._AccountID);
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
      var sessionContext = (IMTSessionContext)SharedTestCode.LoginAsSU();

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
      int expectedQuoteNRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                   pofConfiguration.CountNRCs * 2;
      int expectedQuoteFlatRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                      pofConfiguration.CountPairRCs * 2 * 2; //???
      int expectedQuoteUDRCsCount = numberOfAccountsToIncludeInQuote * numberProductOfferingsToIncludeInQuote *
                                    pofConfiguration.CountPairUDRCs * 2; //???
      decimal expectedQuoteTotal = expectedQuoteFlatRCsCount * pofConfiguration.RCAmount +
                                   expectedQuoteNRCsCount * pofConfiguration.NRCAmount + expectedQuoteUDRCsCount * 30;
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


    }
     */

    #endregion
    #endregion
  }
}
