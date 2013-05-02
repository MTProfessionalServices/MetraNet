using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
//using NUnit.Framework.Extensions;
using MetraTech.Test;
using MetraTech.Test.Common;
using PC=MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using Account = MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;

namespace MetraTech.Product.Test
{
	using System;
	using System.Runtime.InteropServices;
	using NUnit.Framework;

	using MetraTech.DataAccess;
	using MetraTech.UsageServer;

	
	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Product.Test.RecurringChargeTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class RecurringChargeTests 
	{

		private PC.MTProductCatalog mPC;
    private MetraTech.Interop.MTProductView.IProductViewCatalog mPvCatalog;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
    private string mCorporate;
    private PC.IMTProductOffering mFlatFixedAdvanceMonthly;
    private PC.IMTProductOffering mFlatFixedAdvanceMonthlyPerPart;
    private PC.IMTProductOffering mFlatBCRAdvancePerSubMonthly;
    private PC.IMTProductOffering mFlatEBCRAdvancePerSubMonthly;
    private PC.IMTProductOffering mFlatEBCRAdvancePerSubAnnual;
    private PC.IMTProductOffering mFlatBCRArrearsPerSubMonthly;
    private IMeter mSDK;
    private RS.IMTSQLRowset mDummyRowset;
    private MetraTech.Interop.MTEnumConfig.IEnumConfig mEnumConfig;

		public RecurringChargeTests()
		{
      // COM+ 15 second delay workaround
			mDummyRowset = new RS.MTSQLRowsetClass();
			mDummyRowset.Init("Queries\\database");

      mEnumConfig = new MetraTech.Interop.MTEnumConfig.EnumConfigClass();
      mPvCatalog = new MetraTech.Interop.MTProductView.ProductViewCatalog();
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();

      mSDK = TestLibrary.InitSDK();
      
      string testid=Utils.GetTestId();

      mCorporate = String.Format("RecurringChargeTests{0}", testid);
      // We'll be back dating accounts so backdate the corporation too.
      Utils.CreateCorporation(mCorporate, MetraTime.Now.AddYears(-1));

			mFlatFixedAdvanceMonthly = GenerateFlatRecurringChargeProductOffering(
        new Utils.CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, Utils.CycleType.MONTHLY, 31),
        "ADVANCE",
        "PERSUB");
			mFlatFixedAdvanceMonthlyPerPart = GenerateFlatRecurringChargeProductOffering(
        new Utils.CycleOption(PC.MTCycleMode.CYCLE_MODE_FIXED, Utils.CycleType.MONTHLY, 31),
        "ADVANCE",
        "PERPART");
      mFlatBCRAdvancePerSubMonthly = GenerateFlatRecurringChargeProductOffering(
        new Utils.CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, Utils.CycleType.MONTHLY, -1),
        "ADVANCE",
        "PERSUB");
      mFlatEBCRAdvancePerSubMonthly = GenerateFlatRecurringChargeProductOffering(
        new Utils.CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, Utils.CycleType.MONTHLY, -1),
        "ADVANCE",
        "PERSUB");
      mFlatEBCRAdvancePerSubAnnual = GenerateFlatRecurringChargeProductOffering(
        new Utils.CycleOption(PC.MTCycleMode.CYCLE_MODE_EBCR, Utils.CycleType.ANNUAL, -1),
        "ADVANCE",
        "PERSUB");
      mFlatBCRArrearsPerSubMonthly = GenerateFlatRecurringChargeProductOffering(
        new Utils.CycleOption(PC.MTCycleMode.CYCLE_MODE_BCR_CONSTRAINED, Utils.CycleType.MONTHLY, -1),
        "ARREARS",
        "PERSUB");
		}

    public PC.IMTProductOffering GenerateFlatRecurringChargeProductOffering(Utils.CycleOption co,
                                                                            string advanceArrears,
                                                                            string perSubPerPart)
    {
      PC.IMTPriceableItemType piType = mPC.GetPriceableItemTypeByName("Flat Rate Recurring Charge");
      if (piType == null) throw new ApplicationException("Flat Rate Recurring Charge pi type not found");

      PC.IMTRecurringCharge piTemplate = (PC.IMTRecurringCharge) piType.CreateTemplate(false);
      string nm;
      nm = string.Format("FLATRC_{0}_{1}_{2}{3}", co.Description, advanceArrears, perSubPerPart, Utils.GetTestId());
      piTemplate.Name = nm;
      piTemplate.DisplayName = nm;
      piTemplate.Description = "";
      piTemplate.ChargeInAdvance = advanceArrears=="ADVANCE";
      piTemplate.ProrateOnActivation = true;
 //     piTemplate.ProrateInstantly= false;
      piTemplate.ProrateOnDeactivation = true;
      piTemplate.ProrateOnRateChange = true;
      piTemplate.FixedProrationLength = false;
      piTemplate.ChargePerParticipant = perSubPerPart == "PERPART";
      co.Set(piTemplate.Cycle);
      piTemplate.Save();

      // Lastly, make a product offering containing just this pi
      PC.IMTProductOffering po = mPC.CreateProductOffering();
      po.Name = string.Format("PO_{0}", piTemplate.Name);
      po.DisplayName = po.Name;
      po.Description = po.Name;
      po.SelfSubscribable = true;
      po.SelfUnsubscribable = false;
      po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      po.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
      po.EffectiveDate.SetEndDateNull();
      po.AddPriceableItem((PC.MTPriceableItem) piTemplate);
      po.SetCurrencyCode("USD");
      po.Save();
              
      // Put rates onto a PO pricelist
      int idPriceList = po.NonSharedPriceListID;
      PC.IMTParamTableDefinition pt = 
      mPC.GetParamTableDefinitionByName("metratech.com/flatrecurringcharge");
      PC.IMTRateSchedule sched = pt.CreateRateSchedule(idPriceList, piTemplate.ID);
      sched.ParameterTableID = pt.ID;
      sched.Description = "Unit test rates";
      sched.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.StartDate = DateTime.Parse("1/1/2000");
      sched.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      sched.EffectiveDate.EndDate = DateTime.Parse("1/1/2038");

      sched.RuleSet.Read(string.Format("{0}\\Development\\Core\\MTProductCatalog\\{1}", 
                                       Environment.GetEnvironmentVariable("METRATECHTESTDATABASE"), 
                                       "flatrcrules1.xml"));
      sched.SaveWithRules();

      po.AvailabilityDate.StartDate = DateTime.Parse("1/1/2000");
      po.AvailabilityDate.SetEndDateNull();
      po.Save();

      return po;
    }

    int GetOpenInterval(YAAC.IMTYAAC acc, DateTime at)
    {
      using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        IMTPreparedStatement stmt = conn.CreatePreparedStatement(
          "SELECT aui.id_usage_interval FROM t_acc_usage_interval aui " +
          "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
          "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'");
        stmt.AddParam(MTParameterType.Integer, acc.ID); 
        stmt.AddParam(MTParameterType.DateTime, at); 
        using(IMTDataReader reader = stmt.ExecuteReader())
        {
          reader.Read();
          return reader.GetInt32("id_usage_interval");
        }
      }
    }

    int GetCurrentOpenInterval(YAAC.IMTYAAC acc)
    {
      using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        IMTPreparedStatement stmt = conn.CreatePreparedStatement(
          "SELECT aui.id_usage_interval FROM t_acc_usage_interval aui " +
          "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
          "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'");
        stmt.AddParam(MTParameterType.Integer, acc.ID); 
        stmt.AddParam(MTParameterType.DateTime, MetraTime.Now); 
        using(IMTDataReader reader = stmt.ExecuteReader())
        {
          reader.Read();
          return reader.GetInt32("id_usage_interval");
        }
      }
    }

    void GetCurrentOpenInterval(YAAC.IMTYAAC acc, 
                                out int interval, 
                                out DateTime intervalStart, 
                                out DateTime intervalEnd)
    {
      using(IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
        IMTPreparedStatement stmt = conn.CreatePreparedStatement(
          "SELECT aui.id_usage_interval, ui.dt_start, ui.dt_end FROM t_acc_usage_interval aui " +
          "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
          "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'");
        stmt.AddParam(MTParameterType.Integer, acc.ID); 
        stmt.AddParam(MTParameterType.DateTime, MetraTime.Now); 
        using(IMTDataReader reader = stmt.ExecuteReader())
        {
          reader.Read();
          interval = reader.GetInt32("id_usage_interval");
          intervalStart = reader.GetDateTime("dt_start");
          intervalEnd = reader.GetDateTime("dt_end");
        }
      }
    }

    void CreateIndividualSubscription(YAAC.IMTYAAC account,
                                      System.Collections.Generic.ICollection<PC.IMTProductOffering> pos,
                                      DateTime startDate, DateTime endDate)
    {
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(account);
      CreateIndividualSubscription(accounts, pos, startDate, endDate);
    }

    void CreateIndividualSubscription(System.Collections.Generic.ICollection<YAAC.IMTYAAC> accounts,
                                      PC.IMTProductOffering po, DateTime startDate, DateTime endDate)
    {
      System.Collections.Generic.List<PC.IMTProductOffering> pos = new System.Collections.Generic.List<PC.IMTProductOffering>();
      pos.Add(po);
      CreateIndividualSubscription(accounts, pos, startDate, endDate);
    }

    void CreateIndividualSubscription(YAAC.IMTYAAC account,
                                      PC.IMTProductOffering po,
                                      DateTime startDate, 
                                      DateTime endDate)
    {
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(account);
      System.Collections.Generic.List<PC.IMTProductOffering> pos = new System.Collections.Generic.List<PC.IMTProductOffering>();
      pos.Add(po);
      CreateIndividualSubscription(accounts, pos, startDate, endDate);
    }

    void CreateIndividualSubscription(System.Collections.Generic.ICollection<YAAC.IMTYAAC> accounts,
                                      System.Collections.Generic.ICollection<PC.IMTProductOffering> pos,
                                      DateTime startDate, DateTime endDate)
    {
      foreach(PC.IMTProductOffering po in pos)
      {
        foreach(YAAC.IMTYAAC accs in accounts)
        {
          PC.IMTPCAccount pcAcc = mPC.GetAccount(accs.ID);
          PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
          span.StartDate = startDate;
          span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          span.EndDate = endDate;
          span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
          object ignore;
          PC.IMTSubscription sub = pcAcc.Subscribe(po.ID, span, out ignore);
          sub.Save();
        }      
      }
    }

		public void CreateGroupSubscription(PC.IMTProductOffering po, 
                                        YAAC.IMTYAAC corporate, 
                                        System.Collections.Generic.List<YAAC.IMTYAAC> accounts, 
                                        Utils.BillingCycle accountBillingCycle,
                                        DateTime startDate,
                                        DateTime endDate,
                                        bool sharedCounters)
    {
			//create group subscription
			PC.IMTGroupSubscription gs  = mPC.CreateGroupSubscription();
			gs.ProductOfferingID = po.ID;
			gs.Name = String.Format("GROUPSUB_{0}_{1}", accountBillingCycle.ToString(), po.Name);
			gs.Description = gs.Name;
			gs.CorporateAccount = corporate.ID;
      gs.SupportGroupOps = sharedCounters;
			PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
			eff.StartDate = startDate;
			
			PC.MTPCCycle cycle = new PC.MTPCCycleClass();
      accountBillingCycle.Set(cycle);
			
			gs.EffectiveDate = eff;
			gs.ProportionalDistribution = true;
			gs.Cycle = cycle;
			gs.Save();

      PC.IMTCollection members = (PC.IMTCollection) new Coll.MTCollectionClass();
      foreach(YAAC.IMTYAAC acc in accounts)
      {
        PC.IMTGSubMember member = new PC.MTGSubMemberClass();
        member.AccountID = acc.ID;
        member.StartDate = startDate;
        member.EndDate = endDate;
        members.Add(member);
      }
			bool mod;
      PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
    }

		public void CreateGroupSubscription(PC.IMTProductOffering po, YAAC.IMTYAAC corporate, YAAC.IMTYAAC account, Utils.BillingCycle accountBillingCycle, DateTime startDate, DateTime endDate, bool sharedCounters)
		{
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(account);
      CreateGroupSubscription(po, corporate, accounts, accountBillingCycle, startDate, endDate, sharedCounters);
		}

    public void UnsubscribeIndividualSubscription(YAAC.IMTYAAC acct, PC.IMTProductOffering po)
    {
      PC.IMTPCAccount pcAcct = mPC.GetAccount(acct.ID);
      PC.IMTSubscription sub = pcAcct.GetSubscriptionByProductOffering(po.ID);
      pcAcct.Unsubscribe(sub.ID, MetraTime.Now, PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE);
    }

    public System.Collections.Generic.IEnumerable<MetraNetBillingEvent> FlatBCRWithCurrentPayerAndCycleChange
    {
      get
      {
        string testTag = "1";

        // Request setting MetraTime
        yield return new MetraTimeEvent(DateTime.Parse("2011-01-01"));

        // Create the accounts with the billing cycle, one for group one for individual.
        Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 2);
        Utils.BillingCycle accountBillingCycle2 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 23);

        ArrayList subs = new ArrayList();
        string indivAccountName = String.Format("SUB_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        string payingAccountName = String.Format("PAY_{0}{1}{2}",
                                                 testTag,
                                                 accountBillingCycle2.ToString(),
                                                 Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle1));
        subs.Add(new Utils.AccountParameters(payingAccountName, accountBillingCycle2));
        Utils.CreateSubscriberAccounts(mCorporate, subs, DateTime.Parse("2011-01-01"));

        // Subscribe to FlatBCR
        YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
        YAAC.IMTYAAC payerAcc = mAccCatalog.GetAccountByName(payingAccountName, "mt", MetraTime.Now);      
        CreateIndividualSubscription(indivAcc,
                                     mFlatBCRAdvancePerSubMonthly,
                                     DateTime.ParseExact("2011-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                     DateTime.ParseExact("2038-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture)
          );

        // Run a couple of months rcs
        DateTime baseDate = DateTime.Parse("2011-01-03");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-01-24");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-02-03");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-02-24");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        // Change payer to new cycle
        // Set up payer to pay for individual account.
        yield return new MetraTimeEvent(DateTime.Parse("2011-02-27"));
        YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
        pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)payerAcc);
        pmt.PayForAccount(indivAcc.ID, DateTime.Parse("2011-02-27"), DateTime.Parse("1/1/2038"));
        
        // Run a couple of months rcs
        baseDate = DateTime.Parse("2011-03-03");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-03-24");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-04-03");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-04-24");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");

      }
    }

    public System.Collections.Generic.IEnumerable<MetraNetBillingEvent> FlatMonthlyEBCRSelfPayerAnnualJanuary3Cycle
    {
      get
      {
        string testTag = "2";

        // Request setting MetraTime
        yield return new MetraTimeEvent(DateTime.Parse("2011-01-01"));

        // Create the accounts with the billing cycle, one for group one for individual.
        Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.ANNUAL, 3);

        ArrayList subs = new ArrayList();
        string indivAccountName = String.Format("SUB_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle1));
        Utils.CreateSubscriberAccounts(mCorporate, subs, DateTime.Parse("2011-01-01"));

        // Subscribe to FlatEBCR
        YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
        CreateIndividualSubscription(indivAcc,
                                     mFlatEBCRAdvancePerSubMonthly,
                                     DateTime.ParseExact("2011-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                     DateTime.ParseExact("2038-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture)
          );

        // Run a couple of years rcs
        DateTime baseDate = DateTime.Parse("2011-01-03");
        yield return new IntervalAdapterEvent(baseDate, "Annually", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2012-01-03");
        yield return new IntervalAdapterEvent(baseDate, "Annually", baseDate.AddSeconds(-1), "RecurringCharges");

      }
    }

    public System.Collections.Generic.IEnumerable<MetraNetBillingEvent> FlatAnnualEBCRSelfPayerMonthly3Cycle
    {
      get
      {
        string testTag = "3";

        // Request setting MetraTime
        yield return new MetraTimeEvent(DateTime.Parse("2011-01-01"));

        // Create the accounts with the billing cycle, one for group one for individual.
        Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);

        ArrayList subs = new ArrayList();
        string indivAccountName = String.Format("SUB_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle1));
        Utils.CreateSubscriberAccounts(mCorporate, subs, DateTime.Parse("2011-01-01"));

        // Subscribe to FlatEBCR
        YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
        CreateIndividualSubscription(indivAcc,
                                     mFlatEBCRAdvancePerSubAnnual,
                                     DateTime.ParseExact("2011-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                     DateTime.ParseExact("2038-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture)
          );

        // Run a couple of months rcs
        DateTime baseDate = DateTime.Parse("2011-01-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-02-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");

      }
    }

    public System.Collections.Generic.IEnumerable<MetraNetBillingEvent> FlatArrearsMonthlyBCRSelfPayerMonthly3Cycle
    {
      get
      {
        string testTag = "4";

        // Request setting MetraTime
        yield return new MetraTimeEvent(DateTime.Parse("2011-01-01"));

        // Create the accounts with the billing cycle, one for group one for individual.
        Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);

        ArrayList subs = new ArrayList();
        string indivAccountName = String.Format("SUB_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle1));
        Utils.CreateSubscriberAccounts(mCorporate, subs, DateTime.Parse("2011-01-01"));

        // Subscribe to FlatEBCR
        YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
        CreateIndividualSubscription(indivAcc,
                                     mFlatBCRArrearsPerSubMonthly,
                                     DateTime.ParseExact("2011-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                     DateTime.ParseExact("2038-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture)
          );

        // Run a couple of months rcs
        DateTime baseDate = DateTime.Parse("2011-01-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-02-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-03-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
      }
    }

    public System.Collections.Generic.IEnumerable<MetraNetBillingEvent> FlatAdvanceMonthlyFixedSelfPayerMonthly3Cycle
    {
      get
      {
        string testTag = "5";

        // Request setting MetraTime
        yield return new MetraTimeEvent(DateTime.Parse("2011-01-01"));

        // Create the accounts with the billing cycle, one for group one for individual.
        Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);

        ArrayList subs = new ArrayList();
        string indivAccountName = String.Format("SUB_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle1));
        Utils.CreateSubscriberAccounts(mCorporate, subs, DateTime.Parse("2011-01-01"));

        // Subscribe to FlatFixedAdvance
        YAAC.IMTYAAC indivAcc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
        CreateIndividualSubscription(indivAcc,
                                     mFlatFixedAdvanceMonthly,
                                     DateTime.ParseExact("2011-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                     DateTime.ParseExact("2038-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture)
          );

        
        // Run a couple of months rcs
        DateTime baseDate = DateTime.Parse("2011-01-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-02-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-03-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-03-12");
        yield return new MetraTimeEvent(baseDate);
        UnsubscribeIndividualSubscription(indivAcc, mFlatFixedAdvanceMonthly);
        baseDate = DateTime.Parse("2011-04-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-05-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
      }
    }

    public System.Collections.Generic.IEnumerable<MetraNetBillingEvent> FlatAdvanceMonthlyFixedGroupSubPerPartSelfPayerMonthly3Cycle
    {
      get
      {
        string testTag = "6";

        // Request setting MetraTime
        yield return new MetraTimeEvent(DateTime.Parse("2011-01-01"));

        // Create the accounts with the billing cycle, one for group one for individual.
        Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);

        // Create the accounts with the billing cycle
        ArrayList subs = new ArrayList();
        string groupAccountName1 = String.Format("SUBA_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle1));
        string groupAccountName2 = String.Format("SUBB_{0}{1}{2}",
                                                testTag,
                                                accountBillingCycle1.ToString(),
                                                Utils.GetTestId());
        subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle1));
        Utils.CreateSubscriberAccounts(mCorporate, subs, DateTime.Parse("2011-01-01"));

        // Get the current open interval for the account.
        YAAC.IMTYAAC corporateAcc = mAccCatalog.GetAccountByName(mCorporate, "mt", MetraTime.Now);      
        YAAC.IMTYAAC groupAcc1 = mAccCatalog.GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
        YAAC.IMTYAAC groupAcc2 = mAccCatalog.GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
        // Subscribe individually at start of current interval.
        System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
          new System.Collections.Generic.List<YAAC.IMTYAAC>();
        accounts.Add(groupAcc1);
        accounts.Add(groupAcc2);
        CreateGroupSubscription(mFlatFixedAdvanceMonthlyPerPart, corporateAcc, accounts,
                                accountBillingCycle1, 
                                DateTime.ParseExact("2011-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                DateTime.ParseExact("2038-01-01", "yyyy-MM-dd", System.Globalization.CultureInfo.InvariantCulture),
                                false);        

        // Run a couple of months rcs
        DateTime baseDate = DateTime.Parse("2011-01-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-02-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-03-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-03-12");
        yield return new MetraTimeEvent(baseDate);
        baseDate = DateTime.Parse("2011-04-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
        baseDate = DateTime.Parse("2011-05-04");
        yield return new IntervalAdapterEvent(baseDate, "Monthly", baseDate.AddSeconds(-1), "RecurringCharges");
      }
    }

    [SetUp]
    public void Init()
    {
    }

    [Test]
    public void TestAdvanceMonthlyFixedCycle()
    {
      MetraNetBillingTestScheduler scheduler = new MetraNetBillingTestScheduler();
      scheduler.AddTest(FlatBCRWithCurrentPayerAndCycleChange);
      scheduler.AddTest(FlatMonthlyEBCRSelfPayerAnnualJanuary3Cycle);
      scheduler.AddTest(FlatAnnualEBCRSelfPayerMonthly3Cycle);
      scheduler.AddTest(FlatArrearsMonthlyBCRSelfPayerMonthly3Cycle);
      scheduler.AddTest(FlatAdvanceMonthlyFixedSelfPayerMonthly3Cycle);
      scheduler.AddTest(FlatAdvanceMonthlyFixedGroupSubPerPartSelfPayerMonthly3Cycle);
      scheduler.Run();
    }
  }
}
