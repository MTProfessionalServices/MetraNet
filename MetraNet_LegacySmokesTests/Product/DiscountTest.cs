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

/// Tests written:
/// Discount intervals must end in bill interval
/// Bill interval guided based on subscription adjusted discount interval end date
/// Payer guided based on subscription adjusted discount interval end date
/// Retroactive payer change (use of payment history at adapter invocation time).
/// BCR guiding on bill interval not dt_session
/// Tests still to be written:
/// Payer change first adapter wins rule
/// Payer bill cycle change  (validate no duplicate discount generation).
/// Discount interval must overlap subscription interval
/// Prebill adjustment application.
/// Tests for Flat Unconditional Discount
/// Tests for Flat Discount
/// Tests for Percent Unconditional Discount

namespace MetraTech.Product.Test
{
	using System;
	using System.Runtime.InteropServices;
	using NUnit.Framework;

	using MetraTech.DataAccess;
	using MetraTech.UsageServer;

  [ComVisible(false)]
	public class NullAdapterTest : MetraTech.UsageServer.Test.IAdapterTest
  {
    public void CleanData(MetraTech.UsageServer.Test.Interval interval) {}
    public void InitializeData(MetraTech.UsageServer.Test.Interval interval) {}
    public bool ValidateExecution(MetraTech.UsageServer.Test.Interval interval, 
                           MetraTech.UsageServer.Test.BillingGroup billingGroup, 
                           out string errors) 
    { 
      errors = "";
      return true; 
    }
    public bool ValidateReversal(MetraTech.UsageServer.Test.Interval interval, 
                          MetraTech.UsageServer.Test.BillingGroup billingGroup, 
                          out string errors) 
    { 
      errors = "";
      return true; 
    }
  }

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Product.Test.DiscountTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class DiscountTests 
	{

		private PC.MTProductCatalog mPC;
    private MetraTech.Interop.MTProductView.IProductViewCatalog mPvCatalog;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
    private string mCorporate;
    private PC.IMTProductOffering mMonthlyFixedPercentDiscount;
    private PC.IMTProductOffering mMonthlyFixedPercentDiscountBCR;
    private PC.IMTProductOffering mMonthlyFixedSumOfTwoPercentDiscount;
    private PC.IMTProductOffering mMonthlySumOfTwoPercentDiscountBCR;
    private PC.IMTProductOffering mMonthlyFixedPercentDiscountIntegerQualifier;
    private PC.IMTProductOffering mMonthlyFixedPercentDiscountNoDistributionCounter;

    private PC.IMTProductOffering mMonthlyFixedPercentUnconditionalDiscount;
    private PC.IMTProductOffering mMonthlyFixedFlatDiscount;
    private PC.IMTProductOffering mMonthlyFixedFlatUnconditionalDiscount;
    private PC.IMTProductOffering mMonthlyMultipleDiscountBCR;

    private IMeter mSDK;
		private MetraTech.Interop.NameID.IMTNameID mNameID;
    private string mPricelistName;

    private RS.IMTSQLRowset mDummyRowset;

		public DiscountTests()
		{
      // COM+ 15 second delay workaround
			mDummyRowset = new RS.MTSQLRowsetClass();
			mDummyRowset.Init("Queries\\database");

      // On SQL Server, turn on deadlock flags to help with debugging problems with the
      // YAAC.
      MetraTech.DataAccess.ConnectionInfo ci = MetraTech.DataAccess.ConnectionInfo.CreateFromDBAccessFile(@"Queries\Database");
      if (ci.IsSqlServer)
      {
        MetraTech.DataAccess.ConnectionInfo privateCi = ci.Clone() as MetraTech.DataAccess.ConnectionInfo;
        privateCi.UserName = "sa";
        privateCi.Password = "MetraTech1";
        using(MetraTech.DataAccess.IMTNonServicedConnection conn = MetraTech.DataAccess.ConnectionManager.CreateNonServicedConnection(privateCi))
        {
            using (MetraTech.DataAccess.IMTStatement stmt = conn.CreateStatement("DBCC TRACEON (3605,1204,-1)"))
            {
                stmt.ExecuteNonQuery();
            }

          conn.CommitTransaction();
        }
      }

      mNameID = new MetraTech.Interop.NameID.MTNameIDClass();
      mPvCatalog = new MetraTech.Interop.MTProductView.ProductViewCatalog();
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();

      mSDK = TestLibrary.InitSDK();
      
      string testid=Utils.GetTestId();
      mPricelistName = String.Format("DiscountTests_PL{0}", Utils.GetTestId());
      Utils.GenerateSharedPricelist(mPricelistName);
			Utils.GenerateMonthlyFixedPercentDiscountProductOffering();
			Utils.GenerateMonthlyFixedPercentDiscountBCRProductOffering();
      Utils.GenerateMonthlyFixedSumOfTwoPercentDiscountProductOffering();
      Utils.GenerateMonthlyTwoPriceableItemPercentDiscountProductOfferingBCR();
			Utils.GenerateMonthlyFixedPercentDiscountProductOfferingIntegerQualifier();
			Utils.GenerateMonthlyFixedPercentDiscountProductOfferingNoDistributionCounter();
			Utils.GenerateMonthlyFixedPercentUnconditionalDiscountProductOffering();
			Utils.GenerateMonthlyFixedFlatDiscountProductOffering();
			Utils.GenerateMonthlyFixedFlatUnconditionalDiscountProductOffering();
      Utils.GenerateMonthlyMultipleDiscountProductOfferingBCR();
      mMonthlyFixedPercentDiscount = mPC.GetProductOfferingByName(string.Format("PO_Percent_Discount{0}", testid));
      mMonthlyFixedPercentDiscountBCR = mPC.GetProductOfferingByName(string.Format("PO_Percent_Discount_BCR{0}", testid));
      mMonthlyFixedSumOfTwoPercentDiscount = mPC.GetProductOfferingByName(string.Format("PO_Percent_Discount_Sum_Of_Two{0}", testid));
      mMonthlySumOfTwoPercentDiscountBCR = mPC.GetProductOfferingByName(string.Format("PO_Percent_Discount_Sum_Of_Two_PI_BCR{0}", testid));
      mMonthlyFixedPercentDiscountIntegerQualifier = mPC.GetProductOfferingByName(string.Format("PO_Percent_Discount_Integer_Qualifier{0}", testid));
      mMonthlyFixedPercentDiscountNoDistributionCounter = mPC.GetProductOfferingByName(string.Format("PO_Percent_Discount_No_Distribution_Counter{0}", testid));
      mMonthlyFixedPercentUnconditionalDiscount = mPC.GetProductOfferingByName(string.Format("PO_Percent_Unconditional_Discount{0}", testid));
      mMonthlyFixedFlatDiscount = mPC.GetProductOfferingByName(string.Format("PO_Flat_Discount{0}", testid));
      mMonthlyFixedFlatUnconditionalDiscount = mPC.GetProductOfferingByName(string.Format("PO_Flat_Unconditional_Discount{0}", testid));
      mMonthlyMultipleDiscountBCR = mPC.GetProductOfferingByName(string.Format("PO_Multiple_Discount_BCR{0}", testid));
      mCorporate = String.Format("DiscountTests{0}", testid);
      // We'll be back dating accounts so backdate the corporation too.
      Utils.CreateCorporation(mCorporate, MetraTime.Now.AddYears(-1));

		} 

    YAAC.IMTYAAC GetAccountByName(string login, string space, DateTime time)
    {
      // On SQL Server this query will block until the account creation has either succeeded or failed.
      // This is what I want.
      // Loading the YAAC on the other hand seems to be prone to deadlocking.
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "SELECT id_acc FROM t_account_mapper WHERE nm_login=? AND nm_space=?"))
            {
                stmt.AddParam(MTParameterType.String, login);
                stmt.AddParam(MTParameterType.String, space);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                }
            }
        }
      
      return mAccCatalog.GetAccountByName(login, space, time);
    }

    int GetCurrentOpenInterval(YAAC.IMTYAAC acc)
    {
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "SELECT aui.id_usage_interval FROM t_acc_usage_interval aui " +
              "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
              "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'"))
            {
                stmt.AddParam(MTParameterType.Integer, acc.ID);
                stmt.AddParam(MTParameterType.DateTime, MetraTime.Now);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    return reader.GetInt32("id_usage_interval");
                }
            }
        }
    }

    void GetCurrentOpenInterval(YAAC.IMTYAAC acc, 
                                out int interval, 
                                out DateTime intervalStart, 
                                out DateTime intervalEnd)
    {
        using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
        {
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
              "SELECT aui.id_usage_interval, ui.dt_start, ui.dt_end FROM t_acc_usage_interval aui " +
              "INNER JOIN t_usage_interval ui ON aui.id_usage_interval=ui.id_interval " +
              "WHERE aui.id_acc = ? AND ? BETWEEN ui.dt_start AND ui.dt_end AND aui.tx_status='O'"))
            {
                stmt.AddParam(MTParameterType.Integer, acc.ID);
                stmt.AddParam(MTParameterType.DateTime, MetraTime.Now);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    interval = reader.GetInt32("id_usage_interval");
                    intervalStart = reader.GetDateTime("dt_start");
                    intervalEnd = reader.GetDateTime("dt_end");
                }
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

		public void CreateGroupSubscription(PC.IMTProductOffering po, 
                                        YAAC.IMTYAAC corporate, 
                                        System.Collections.Generic.List<YAAC.IMTYAAC> accounts, 
                                        Utils.BillingCycle accountBillingCycle,
                                        DateTime startDate,
                                        DateTime endDate,
                                        int discountAccount)
    {
			//create group subscription
			PC.IMTGroupSubscription gs  = mPC.CreateGroupSubscription();
			gs.ProductOfferingID = po.ID;
			gs.Name = String.Format("GROUPSUB_{0}_{1}", accountBillingCycle.ToString(), po.Name);
			gs.Description = gs.Name;
			gs.CorporateAccount = corporate.ID;
      gs.SupportGroupOps = true;
			PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
			eff.StartDate = startDate;
			
			PC.MTPCCycle cycle = new PC.MTPCCycleClass();
      accountBillingCycle.Set(cycle);
			
			gs.EffectiveDate = eff;
			gs.ProportionalDistribution = false;
      gs.DistributionAccount = discountAccount;
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

    class PercentDiscountRecord
    {
      public int AccountID;
      public DateTime DiscountIntervalStart;
      public DateTime DiscountIntervalEnd;
      public Decimal Qualifier;
      public Decimal Target;
      public PercentDiscountRecord(
        int accountID,
        DateTime discountIntervalStart,
        DateTime discountIntervalEnd,
        Decimal qualifier,
        Decimal target)
      {
        this.AccountID = accountID;
        this.DiscountIntervalStart = discountIntervalStart;
        this.DiscountIntervalEnd = discountIntervalEnd;
        this.Qualifier = qualifier;
        this.Target = target;
      }
    }

    class PercentDiscountRecordEqualityComparer : System.Collections.Generic.IEqualityComparer<PercentDiscountRecord>
    {
      public bool Equals(PercentDiscountRecord lhs, PercentDiscountRecord rhs)
      {
        return lhs.AccountID == rhs.AccountID && 
        lhs.DiscountIntervalStart == rhs.DiscountIntervalStart && 
        lhs.DiscountIntervalEnd == rhs.DiscountIntervalEnd;
      }
      public int GetHashCode(PercentDiscountRecord val)
      {
        return val.AccountID + val.DiscountIntervalStart.GetHashCode() + val.DiscountIntervalEnd.GetHashCode();
      }
    }

    void ValidateResults(System.Collections.Generic.ICollection<PercentDiscountRecord> recs,
                         int interval,
                         string testID)
    {
      System.Collections.Generic.List<PercentDiscountRecord> dbRecs = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT au.id_payee, pv.c_DiscountIntervalStart, pv.c_DiscountIntervalEnd, pv.c_Qualifier, pv.c_Target\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_percentdiscount pv ON pv.id_sess=au.id_sess INNER JOIN t_account_mapper am ON am.id_acc=au.id_payee\n" +
            "WHERE au.id_usage_interval = ? AND am.nm_login like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new PercentDiscountRecord(reader.GetInt32("id_payee"),
                                                               reader.GetDateTime("c_DiscountIntervalStart"),
                                                               reader.GetDateTime("c_DiscountIntervalEnd"),
                                                               reader.GetDecimal("c_Qualifier"),
                                                               reader.GetDecimal("c_Target")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<PercentDiscountRecord, PercentDiscountRecord> dupCheck =
      new System.Collections.Generic.Dictionary<PercentDiscountRecord, PercentDiscountRecord>(new PercentDiscountRecordEqualityComparer());
      foreach(PercentDiscountRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec));
        dupCheck.Add(rec, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<PercentDiscountRecord, PercentDiscountRecord> join =
      new System.Collections.Generic.Dictionary<PercentDiscountRecord, PercentDiscountRecord>(new PercentDiscountRecordEqualityComparer());
      foreach(PercentDiscountRecord rec in recs)
      {
        join.Add(rec, rec);
      }
      foreach(PercentDiscountRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec));
        Assert.AreEqual(join[rec].Qualifier, 
                        rec.Qualifier,
                        String.Format("Qualifier mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
        Assert.AreEqual(join[rec].Target, 
                        rec.Target,
                        String.Format("Target mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
      }
    }    

    class SharedPercentDiscountRecord
    {
      public int AccountID;
      public DateTime DiscountIntervalStart;
      public DateTime DiscountIntervalEnd;
      public Decimal DiscountPercent;
      public Decimal DiscountAmount;
      public SharedPercentDiscountRecord(
        int accountID,
        DateTime discountIntervalStart,
        DateTime discountIntervalEnd,
        Decimal discountPercent,
        Decimal discountAmount)
      {
        this.AccountID = accountID;
        this.DiscountIntervalStart = discountIntervalStart;
        this.DiscountIntervalEnd = discountIntervalEnd;
        this.DiscountPercent = discountPercent;
        this.DiscountAmount = discountAmount;
      }
    }

    class SharedPercentDiscountRecordEqualityComparer : System.Collections.Generic.IEqualityComparer<SharedPercentDiscountRecord>
    {
      public bool Equals(SharedPercentDiscountRecord lhs, SharedPercentDiscountRecord rhs)
      {
        return lhs.AccountID == rhs.AccountID && 
        lhs.DiscountIntervalStart == rhs.DiscountIntervalStart && 
        lhs.DiscountIntervalEnd == rhs.DiscountIntervalEnd;
      }
      public int GetHashCode(SharedPercentDiscountRecord val)
      {
        return val.AccountID + val.DiscountIntervalStart.GetHashCode() + val.DiscountIntervalEnd.GetHashCode();
      }
    }

    void ValidateResults(System.Collections.Generic.ICollection<SharedPercentDiscountRecord> recs,
                         int interval,
                         string testID)
    {
      System.Collections.Generic.List<SharedPercentDiscountRecord> dbRecs = 
      new System.Collections.Generic.List<SharedPercentDiscountRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT au.id_payee, pv.c_DiscountIntervalStart, pv.c_DiscountIntervalEnd, pv.c_DiscountPercent, au.amount\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_percentdiscount pv ON pv.id_sess=au.id_sess INNER JOIN t_account_mapper am ON am.id_acc=au.id_payee\n" +
            "WHERE au.id_usage_interval = ? AND am.nm_login like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new SharedPercentDiscountRecord(reader.GetInt32("id_payee"),
                                                               reader.GetDateTime("c_DiscountIntervalStart"),
                                                               reader.GetDateTime("c_DiscountIntervalEnd"),
                                                               reader.GetDecimal("c_DiscountPercent"),
                                                               reader.GetDecimal("amount")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<SharedPercentDiscountRecord, SharedPercentDiscountRecord> dupCheck =
      new System.Collections.Generic.Dictionary<SharedPercentDiscountRecord, SharedPercentDiscountRecord>(new SharedPercentDiscountRecordEqualityComparer());
      foreach(SharedPercentDiscountRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec));
        dupCheck.Add(rec, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<SharedPercentDiscountRecord, SharedPercentDiscountRecord> join =
      new System.Collections.Generic.Dictionary<SharedPercentDiscountRecord, SharedPercentDiscountRecord>(new SharedPercentDiscountRecordEqualityComparer());
      foreach(SharedPercentDiscountRecord rec in recs)
      {
        join.Add(rec, rec);
      }
      foreach(SharedPercentDiscountRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec));
        Assert.AreEqual(join[rec].DiscountPercent, 
                        rec.DiscountPercent,
                        String.Format("DiscountPercent mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
        Assert.AreEqual(join[rec].DiscountAmount, 
                        rec.DiscountAmount,
                        String.Format("DiscountAmount mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
      }
    }    

    class SharedPercentUnconditionalDiscountRecord
    {
      public int AccountID;
      public DateTime DiscountIntervalStart;
      public DateTime DiscountIntervalEnd;
      public Decimal DiscountPercent;
      public Decimal DiscountAmount;
      public SharedPercentUnconditionalDiscountRecord(
        int accountID,
        DateTime discountIntervalStart,
        DateTime discountIntervalEnd,
        Decimal discountPercent,
        Decimal discountAmount)
      {
        this.AccountID = accountID;
        this.DiscountIntervalStart = discountIntervalStart;
        this.DiscountIntervalEnd = discountIntervalEnd;
        this.DiscountPercent = discountPercent;
        this.DiscountAmount = discountAmount;
      }
    }

    class SharedPercentUnconditionalDiscountRecordEqualityComparer : System.Collections.Generic.IEqualityComparer<SharedPercentUnconditionalDiscountRecord>
    {
      public bool Equals(SharedPercentUnconditionalDiscountRecord lhs, SharedPercentUnconditionalDiscountRecord rhs)
      {
        return lhs.AccountID == rhs.AccountID && 
        lhs.DiscountIntervalStart == rhs.DiscountIntervalStart && 
        lhs.DiscountIntervalEnd == rhs.DiscountIntervalEnd;
      }
      public int GetHashCode(SharedPercentUnconditionalDiscountRecord val)
      {
        return val.AccountID + val.DiscountIntervalStart.GetHashCode() + val.DiscountIntervalEnd.GetHashCode();
      }
    }

    void ValidateResults(System.Collections.Generic.ICollection<SharedPercentUnconditionalDiscountRecord> recs,
                         int interval,
                         string testID)
    {
      System.Collections.Generic.List<SharedPercentUnconditionalDiscountRecord> dbRecs = 
      new System.Collections.Generic.List<SharedPercentUnconditionalDiscountRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT au.id_payee, pv.c_DiscountIntervalStart, pv.c_DiscountIntervalEnd, pv.c_DiscountPercent, au.amount\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_percentdiscount_nocond pv ON pv.id_sess=au.id_sess INNER JOIN t_account_mapper am ON am.id_acc=au.id_payee\n" +
            "WHERE au.id_usage_interval = ? AND am.nm_login like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new SharedPercentUnconditionalDiscountRecord(reader.GetInt32("id_payee"),
                                                               reader.GetDateTime("c_DiscountIntervalStart"),
                                                               reader.GetDateTime("c_DiscountIntervalEnd"),
                                                               reader.GetDecimal("c_DiscountPercent"),
                                                               reader.GetDecimal("amount")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<SharedPercentUnconditionalDiscountRecord, SharedPercentUnconditionalDiscountRecord> dupCheck =
      new System.Collections.Generic.Dictionary<SharedPercentUnconditionalDiscountRecord, SharedPercentUnconditionalDiscountRecord>(new SharedPercentUnconditionalDiscountRecordEqualityComparer());
      foreach(SharedPercentUnconditionalDiscountRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec));
        dupCheck.Add(rec, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<SharedPercentUnconditionalDiscountRecord, SharedPercentUnconditionalDiscountRecord> join =
      new System.Collections.Generic.Dictionary<SharedPercentUnconditionalDiscountRecord, SharedPercentUnconditionalDiscountRecord>(new SharedPercentUnconditionalDiscountRecordEqualityComparer());
      foreach(SharedPercentUnconditionalDiscountRecord rec in recs)
      {
        join.Add(rec, rec);
      }
      foreach(SharedPercentUnconditionalDiscountRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec));
        Assert.AreEqual(join[rec].DiscountPercent, 
                        rec.DiscountPercent,
                        String.Format("DiscountPercent mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
        Assert.AreEqual(join[rec].DiscountAmount, 
                        rec.DiscountAmount,
                        String.Format("DiscountAmount mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
      }
    }    

    class SharedFlatDiscountRecord
    {
      public int AccountID;
      public DateTime DiscountIntervalStart;
      public DateTime DiscountIntervalEnd;
      public Decimal DiscountAmount;
      public SharedFlatDiscountRecord(
        int accountID,
        DateTime discountIntervalStart,
        DateTime discountIntervalEnd,
        Decimal discountAmount)
      {
        this.AccountID = accountID;
        this.DiscountIntervalStart = discountIntervalStart;
        this.DiscountIntervalEnd = discountIntervalEnd;
        this.DiscountAmount = discountAmount;
      }
    }

    class SharedFlatDiscountRecordEqualityComparer : System.Collections.Generic.IEqualityComparer<SharedFlatDiscountRecord>
    {
      public bool Equals(SharedFlatDiscountRecord lhs, SharedFlatDiscountRecord rhs)
      {
        return lhs.AccountID == rhs.AccountID && 
        lhs.DiscountIntervalStart == rhs.DiscountIntervalStart && 
        lhs.DiscountIntervalEnd == rhs.DiscountIntervalEnd;
      }
      public int GetHashCode(SharedFlatDiscountRecord val)
      {
        return val.AccountID + val.DiscountIntervalStart.GetHashCode() + val.DiscountIntervalEnd.GetHashCode();
      }
    }

    void ValidateResults(System.Collections.Generic.ICollection<SharedFlatDiscountRecord> recs,
                         int interval,
                         string testID)
    {
      System.Collections.Generic.List<SharedFlatDiscountRecord> dbRecs = 
      new System.Collections.Generic.List<SharedFlatDiscountRecord>();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT au.id_payee, pv.c_DiscountIntervalStart, pv.c_DiscountIntervalEnd, au.amount\n" +
            "FROM t_acc_usage au INNER JOIN t_pv_flatdiscount pv ON pv.id_sess=au.id_sess INNER JOIN t_account_mapper am ON am.id_acc=au.id_payee\n" +
            "WHERE au.id_usage_interval = ? AND am.nm_login like ?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              stmt.AddParam(MTParameterType.String, "%" + testID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  while (reader.Read())
                  {
                      dbRecs.Add(new SharedFlatDiscountRecord(reader.GetInt32("id_payee"),
                                                               reader.GetDateTime("c_DiscountIntervalStart"),
                                                               reader.GetDateTime("c_DiscountIntervalEnd"),
                                                               reader.GetDecimal("amount")));
                  }
              }
          }
      }

      Assert.AreEqual(recs.Count, dbRecs.Count);

      // Check for duplicates
      System.Collections.Generic.Dictionary<SharedFlatDiscountRecord, SharedFlatDiscountRecord> dupCheck =
      new System.Collections.Generic.Dictionary<SharedFlatDiscountRecord, SharedFlatDiscountRecord>(new SharedFlatDiscountRecordEqualityComparer());
      foreach(SharedFlatDiscountRecord rec in dbRecs)
      {
        Assert.IsFalse(dupCheck.ContainsKey(rec));
        dupCheck.Add(rec, rec);
      }
      
      // Check Results by hash join
      System.Collections.Generic.Dictionary<SharedFlatDiscountRecord, SharedFlatDiscountRecord> join =
      new System.Collections.Generic.Dictionary<SharedFlatDiscountRecord, SharedFlatDiscountRecord>(new SharedFlatDiscountRecordEqualityComparer());
      foreach(SharedFlatDiscountRecord rec in recs)
      {
        join.Add(rec, rec);
      }
      foreach(SharedFlatDiscountRecord rec in dbRecs)
      {
        Assert.IsTrue(join.ContainsKey(rec));
        Assert.AreEqual(join[rec].DiscountAmount, 
                        rec.DiscountAmount,
                        String.Format("DiscountAmount mismatch: interval={0}; accountID={1}; discountIntervalStart={2}; discountIntervalEnd={3}",
                                      interval, rec.AccountID, rec.DiscountIntervalStart, rec.DiscountIntervalEnd));
      }
    }    

    class TestPITestRecord
    {
      public string Description;
      public string AccountName;
      public DateTime EventTimestamp;
      public Decimal Units;
      public int Duration;
      public int UsageIntervalID;
      public TestPITestRecord(string description,
                              string accountName,
                              DateTime eventTimestamp,
                              Decimal units,
                              int duration)
      {
        Description = description;
        AccountName = accountName;
        EventTimestamp = eventTimestamp;
        Units = units;
        Duration = duration;
        UsageIntervalID = -1;
      }
      public TestPITestRecord(string description,
                              string accountName,
                              DateTime eventTimestamp,
                              Decimal units,
                              int duration,
                              int usageIntervalID)
      {
        Description = description;
        AccountName = accountName;
        EventTimestamp = eventTimestamp;
        Units = units;
        Duration = duration;
        UsageIntervalID = usageIntervalID;
      }
    }
		void MeterTestPITestUsage(System.Collections.Generic.ICollection<TestPITestRecord> recs)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(TestPITestRecord rec in recs)
      {
        ISession session = sessionSet.CreateSession("metratech.com/testpi");
        session.InitProperty("description", rec.Description);
        session.InitProperty("accountname", rec.AccountName);
        session.InitProperty("Time", rec.EventTimestamp);
        session.InitProperty("Units", rec.Units);
        session.InitProperty("Duration", rec.Duration);
        session.InitProperty("DecProp1", 1);
        session.InitProperty("DecProp2", 1);
        session.InitProperty("DecProp3", 1);
        if (rec.UsageIntervalID != -1)
        {
          session.InitProperty("_IntervalId", rec.UsageIntervalID);
        }
        session.RequestResponse = true;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }
    class TestServiceTestRecord
    {
      public string Description;
      public string AccountName;
      public DateTime EventTimestamp;
      public Decimal Units;
      public Decimal DecProp1;
      public TestServiceTestRecord(string description,
                                   string accountName,
                                   DateTime eventTimestamp,
                                   Decimal units,
                                   Decimal decProp1)
      {
        Description = description;
        AccountName = accountName;
        EventTimestamp = eventTimestamp;
        Units = units;
        DecProp1 = decProp1;
      }
    }
		void MeterTestServiceTestUsage(System.Collections.Generic.ICollection<TestServiceTestRecord> recs)
		{
      ISessionSet sessionSet = mSDK.CreateSessionSet();
      foreach(TestServiceTestRecord rec in recs)
      {
        ISession session = sessionSet.CreateSession("metratech.com/testservice");
        session.InitProperty("description", rec.Description);
        session.InitProperty("accountname", rec.AccountName);
        session.InitProperty("Time", rec.EventTimestamp);
        session.InitProperty("Pipelinetime", rec.EventTimestamp);
        session.InitProperty("Units", rec.Units);
        session.InitProperty("DecProp1", rec.DecProp1);
        session.RequestResponse = true;
        System.Runtime.InteropServices.Marshal.ReleaseComObject(session);
      }
      sessionSet.Close(); 
      System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
    }

    void RunDiscountAdapterOneBillingGroup(System.Collections.Generic.List<YAAC.IMTYAAC> accounts, int usageIntervalID)
    {
      // Setup the adapter test manager with one interval, one account and one billgroup
      MetraTech.UsageServer.Test.AdapterTestConfig atc = new MetraTech.UsageServer.Test.AdapterTestConfig();
      atc.Intervals = new MetraTech.UsageServer.Test.Interval[] {new MetraTech.UsageServer.Test.Interval()};
      atc.Intervals[0].Id = usageIntervalID;
      atc.Intervals[0].BillingGroups = new MetraTech.UsageServer.Test.BillingGroup[] {new MetraTech.UsageServer.Test.BillingGroup()};
      atc.Intervals[0].BillingGroups[0].Name = "test1";
      atc.Intervals[0].BillingGroups[0].Description = "TestMonthlySecondOfMonthIndividualAndGroupSubscriptionWithSharedCountersSongDownloads";
      // All accounts into the same billing group
      atc.Intervals[0].BillingGroups[0].Accounts = new MetraTech.UsageServer.Test.Account[accounts.Count];
      for(int i=0; i<accounts.Count; i++)
      {
        MetraTech.UsageServer.Test.Account tmp = new MetraTech.UsageServer.Test.Account();
        tmp.Id = accounts[i].ID;
        atc.Intervals[0].BillingGroups[0].Accounts[i] = tmp;
      }
      atc.Adapters = new MetraTech.UsageServer.Test.Adapter[] {new MetraTech.UsageServer.Test.Adapter()};
      atc.Adapters[0].Name = "Discounts";
      atc.Adapters[0].TestClass = "MetraTech.Product.Test.NullAdapterTest,MetraTech.Product.Test";
      atc.Adapters[0].Ignore = false;
      atc.Adapters[0].Reverse = false;
      atc.Adapters[0].Intervals = new MetraTech.UsageServer.Test.Interval[] {new MetraTech.UsageServer.Test.Interval()};
      atc.Adapters[0].Intervals[0].Id = usageIntervalID;
      atc.UserId = 129;
      
      string errs;
      MetraTech.UsageServer.Test.AdapterTestManager.RunTests(atc, out errs);
      Assert.AreEqual(0, errs.Length);
    }

    void RunDiscountAdapterOneBillingGroup(YAAC.IMTYAAC acc, int usageIntervalID)
    {
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts =
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(acc);
      RunDiscountAdapterOneBillingGroup(accounts, usageIntervalID);
    }

    [SetUp]
    public void Init()
    {
    }

    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T01TestMonthlyFixedIndividualPercentDiscount()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 1);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("1_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(16).AddMonths(-1), pcIntervalStart.AddDays(16).AddSeconds(-1), 125, 125)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T02TestMonthlyFixedGroupNonSharedPercentDiscount()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 2);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("2_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle, mPricelistName));
      string groupAccountName2 = String.Format("3_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe individually at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyFixedPercentDiscount, corporateAcc, accounts,
                              accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), false);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc1.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc2.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accounts, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(groupAcc1.ID, pcIntervalStart.AddDays(15).AddMonths(-1), pcIntervalStart.AddDays(15).AddSeconds(-1), 75, 75)); 
      expectedResults.Add(new PercentDiscountRecord(groupAcc2.ID, pcIntervalStart.AddDays(15).AddMonths(-1), pcIntervalStart.AddDays(15).AddSeconds(-1), 50, 50)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T03TestMonthlyFixedIndividualPercentDiscountWithSubscribeAndUnsubscribe()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("4_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscount, pcIntervalStart.AddDays(2), pcIntervalStart.AddDays(7).AddSeconds(-1));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(3), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(4), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(5), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(6), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(7), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(8), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(14).AddMonths(-1), pcIntervalStart.AddDays(14).AddSeconds(-1), 125, 125)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T04TestMonthlyFixedGroupNonSharedPercentDiscountWithSubscribeAndUnsubscribe()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 4);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("5_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle, mPricelistName));
      string groupAccountName2 = String.Format("6_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe individually at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyFixedPercentDiscount, corporateAcc, accounts,
                              accountBillingCycle, pcIntervalStart.AddDays(2), pcIntervalStart.AddDays(7).AddSeconds(-1), false);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart.AddDays(3), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart.AddDays(4), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart.AddDays(5), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart.AddDays(6), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc1.LoginName, pcIntervalStart.AddDays(7), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc2.LoginName, pcIntervalStart.AddDays(8), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accounts, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(groupAcc1.ID, pcIntervalStart.AddDays(13).AddMonths(-1), pcIntervalStart.AddDays(13).AddSeconds(-1), 50, 50)); 
      expectedResults.Add(new PercentDiscountRecord(groupAcc2.ID, pcIntervalStart.AddDays(13).AddMonths(-1), pcIntervalStart.AddDays(13).AddSeconds(-1), 75, 75)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T05TestMonthlyFixedGroupNonSharedPercentDiscountDifferentCycles()
    {
      Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 5);
      Utils.BillingCycle accountBillingCycle2 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 6);
      int pcInterval1;
      DateTime pcIntervalStart1;
      DateTime pcIntervalEnd1;
      int pcInterval2;
      DateTime pcIntervalStart2;
      DateTime pcIntervalEnd2;
      accountBillingCycle1.GetPCInterval(MetraTime.Now, out pcInterval1, out pcIntervalStart1, out pcIntervalEnd1);
      accountBillingCycle2.GetPCInterval(MetraTime.Now, out pcInterval2, out pcIntervalStart2, out pcIntervalEnd2);
      DateTime pcIntervalStart = pcIntervalStart1 < pcIntervalStart2 ? pcIntervalStart1 : pcIntervalStart2;
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("7_{0}{1}",
                                               accountBillingCycle1.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle1, mPricelistName));
      string groupAccountName2 = String.Format("8_{0}{1}",
                                               accountBillingCycle2.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle2, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval1 = GetCurrentOpenInterval(groupAcc1);
      int interval2 = GetCurrentOpenInterval(groupAcc2);
      // Subscribe individually at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyFixedPercentDiscount, corporateAcc, accounts,
                              accountBillingCycle1, pcIntervalStart, DateTime.Parse("1/1/2038"), false);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart1.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart2.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart1.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart2.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart1.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart2.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc1.LoginName, pcIntervalStart1.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc2.LoginName, pcIntervalStart2.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart1.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(groupAcc1, interval1);
      RunDiscountAdapterOneBillingGroup(groupAcc2, interval2);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults1 = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      System.Collections.Generic.List<PercentDiscountRecord> expectedResults2 = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults1.Add(new PercentDiscountRecord(groupAcc1.ID, pcIntervalStart1.AddDays(12).AddMonths(-1), pcIntervalStart1.AddDays(12).AddSeconds(-1), 75, 75)); 
      expectedResults2.Add(new PercentDiscountRecord(groupAcc2.ID, pcIntervalStart2.AddDays(11).AddMonths(-1), pcIntervalStart2.AddDays(11).AddSeconds(-1), 50, 50)); 

      ValidateResults(expectedResults1, interval1, Utils.GetTestId());
      ValidateResults(expectedResults2, interval2, Utils.GetTestId());
    }
    /// This test validates that we guide discounts based on subscription adjusted discount interval.
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T06TestMonthlyFixedIndividualPercentDiscountUnsubscribeReguideDiscountInterval()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 7);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("9_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      // This subscription end after the 17th and before the 7th of the next month.  So we get
      // a second discount interval generated.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscount, pcIntervalStart.AddDays(2), pcIntervalStart.AddDays(20).AddSeconds(-1));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(3), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(5), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(7), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(13), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(15), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(17), 1, 100));
      testRecs.Add(new TestPITestRecord("10", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("11", indivAcc.LoginName, pcIntervalStart.AddDays(21), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(10).AddMonths(-1), pcIntervalStart.AddDays(10).AddSeconds(-1), 100, 100)); 
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(10), pcIntervalStart.AddDays(10).AddMonths(1).AddSeconds(-1), 125, 125)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T07TestMonthlyFixedIndividualPercentDiscountPayerChange()
    {
      Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 8);
      Utils.BillingCycle accountBillingCycle2 = new Utils.BillingCycle (Utils.CycleType.ANNUAL, 9);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle1.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      int annualInterval;
      DateTime annualIntervalStart;
      DateTime annualIntervalEnd;
      accountBillingCycle2.GetPCInterval(MetraTime.Now, out annualInterval, out annualIntervalStart, out annualIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName1 = String.Format("10_{0}{1}",
                                              accountBillingCycle1.ToString(),
                                              Utils.GetTestId());
      string indivAccountName2 = String.Format("10_{0}{1}",
                                              accountBillingCycle2.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName1, accountBillingCycle1, mPricelistName));
      subs.Add(new Utils.AccountParameters(indivAccountName2, accountBillingCycle2, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC payerAcc = GetAccountByName(indivAccountName2, "mt", MetraTime.Now);      

      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));  

      // Change payer so that it takes effect after the current discount interval.
      // Set up payer to pay for individual account.
      YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
      pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)payerAcc);
      pmt.PayForAccount(indivAcc.ID, pcIntervalStart.AddDays(20), DateTime.Parse("1/1/2038"));
      
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      // Generate a usage record for subsequent months to avoid zero discounts (suppressed by the framework).
      for(int i=1;i<=12;i++)
      {
        if (pcIntervalStart.AddDays(26).AddMonths(i).Year > pcIntervalStart.Year) break;
        testRecs.Add(new TestPITestRecord("10", indivAcc.LoginName, pcIntervalStart.AddDays(26).AddMonths(i), 1, 100));        
      }
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, pcInterval);

      // One discount on the current monthly
      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(9).AddMonths(-1), pcIntervalStart.AddDays(9).AddSeconds(-1), 50, 50)); 
      ValidateResults(expectedResults, pcInterval, Utils.GetTestId());
      // No discounts on the next monthly (due to payer changes).
      // TODO: Implement this check.  Not sure it can be done because this interval hasn't been created yet.
      // One discount for each month between next month and the end of the year for annual account (this can be zero discounts when the test runs in December).
      RunDiscountAdapterOneBillingGroup(payerAcc, annualInterval);
      expectedResults.Clear();
      // We have an expected discount for each discount interval that ends in the next month until the end of the year.
      for(int i=0;i<12;i++)
      {
        if (pcIntervalStart.AddDays(9).AddMonths(i+1).AddSeconds(-1).Year > pcIntervalStart.Year) break;
        int counter = i==0 ? 175 : 25;
        expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, 
                                                      pcIntervalStart.AddDays(9).AddMonths(i), 
                                                      pcIntervalStart.AddDays(9).AddMonths(i+1).AddSeconds(-1), 
                                                      counter, counter)); 
      }
      ValidateResults(expectedResults, annualInterval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T08TestMonthlyFixedIndividualPercentDiscountPayerChangeWithUnsubscribe()
    {
      Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 9);
      Utils.BillingCycle accountBillingCycle2 = new Utils.BillingCycle (Utils.CycleType.ANNUAL, 10);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle1.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      int annualInterval;
      DateTime annualIntervalStart;
      DateTime annualIntervalEnd;
      accountBillingCycle2.GetPCInterval(MetraTime.Now, out annualInterval, out annualIntervalStart, out annualIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName1 = String.Format("11_{0}{1}",
                                              accountBillingCycle1.ToString(),
                                              Utils.GetTestId());
      string indivAccountName2 = String.Format("11_{0}{1}",
                                              accountBillingCycle2.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName1, accountBillingCycle1, mPricelistName));
      subs.Add(new Utils.AccountParameters(indivAccountName2, accountBillingCycle2, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC payerAcc = GetAccountByName(indivAccountName2, "mt", MetraTime.Now);      

      // Subscribe individually at start of current interval.  Stop subscription during 2nd interval
      // and prior to payment change; this causes the discount interval to be billed to the first payer.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscount, pcIntervalStart, pcIntervalStart.AddDays(15));  

      // Change payer so that it takes effect after the current discount interval.
      // Set up payer to pay for individual account.
      YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
      pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)payerAcc);
      pmt.PayForAccount(indivAcc.ID, pcIntervalStart.AddDays(20), DateTime.Parse("1/1/2038"));
      
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      // Generate a usage record for subsequent months.  There should be no discounts because subscription ends.
      for(int i=1;i<=12;i++)
      {
        if (pcIntervalStart.AddDays(26).AddMonths(i).Year > pcIntervalStart.Year) break;
        testRecs.Add(new TestPITestRecord("10", indivAcc.LoginName, pcIntervalStart.AddDays(26).AddMonths(i), 1, 100));        
      }
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, pcInterval);

      // One discount on the current monthly
      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(8).AddMonths(-1), pcIntervalStart.AddDays(8).AddSeconds(-1), 50, 50)); 
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(8), pcIntervalStart.AddDays(8).AddMonths(1).AddSeconds(-1), 75, 75)); 
      ValidateResults(expectedResults, pcInterval, Utils.GetTestId());
      // No discounts on the next monthly (due to unsubscription and payer changes).
      // TODO: Implement this check.  Not sure it can be done because this interval hasn't been created yet.

      // No discounts due to unsubscription.
      RunDiscountAdapterOneBillingGroup(payerAcc, annualInterval);
      expectedResults.Clear();
      ValidateResults(expectedResults, annualInterval, Utils.GetTestId());
    }
    /// This test validates that old versions of payment history are ignored.
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T09TestMonthlyFixedIndividualPercentDiscountRetroactivePayerChange()
    {
      Utils.BillingCycle accountBillingCycle1 = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 10);
      Utils.BillingCycle accountBillingCycle2 = new Utils.BillingCycle (Utils.CycleType.ANNUAL, 11);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle1.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      int annualInterval;
      DateTime annualIntervalStart;
      DateTime annualIntervalEnd;
      accountBillingCycle2.GetPCInterval(MetraTime.Now, out annualInterval, out annualIntervalStart, out annualIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName1 = String.Format("12_{0}{1}",
                                              accountBillingCycle1.ToString(),
                                              Utils.GetTestId());
      string indivAccountName2 = String.Format("12_{0}{1}",
                                              accountBillingCycle2.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName1, accountBillingCycle1, mPricelistName));
      subs.Add(new Utils.AccountParameters(indivAccountName2, accountBillingCycle2, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC payerAcc = GetAccountByName(indivAccountName2, "mt", MetraTime.Now);      

      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));  

      // Change payer so that it takes effect after the current discount interval.
      // Set up payer to pay for individual account.
      YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
      pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)payerAcc);
      pmt.PayForAccount(indivAcc.ID, pcIntervalStart.AddDays(20), DateTime.Parse("1/1/2038"));
      System.Runtime.InteropServices.Marshal.ReleaseComObject(pmt);
      // Reset payment info.
      pmt = new YAAC.MTPaymentMgrClass();
      pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)indivAcc);
      pmt.PayForAccount(indivAcc.ID, pcIntervalStart, DateTime.Parse("1/1/2038"));
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, pcInterval);

      // One discount on the current monthly
      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(7).AddMonths(-1), pcIntervalStart.AddDays(7).AddSeconds(-1), 50, 50)); 
      ValidateResults(expectedResults, pcInterval, Utils.GetTestId());
      // Annual account has no discounts because we erased payment redir.
      RunDiscountAdapterOneBillingGroup(payerAcc, annualInterval);
      expectedResults.Clear();
      ValidateResults(expectedResults, annualInterval, Utils.GetTestId());
    }
    /// TODO: Can we cook up a good test for "late" usage in the BCR case.
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T10TestMonthlyFixedIndividualPercentDiscountBCR()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 11);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("13_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscountBCR, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is BCR unconstrained
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      // Force this one into the correct interval
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(32), 1, 100, pcInterval));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart, pcIntervalEnd, 225, 225)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T11TestMonthlyGroupSharedProportionalPercentDiscountBCR()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 12);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("14_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle, mPricelistName));
      string groupAccountName2 = String.Format("15_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe individually at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyFixedPercentDiscountBCR, corporateAcc, accounts,
                              accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), true);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly BCR.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart.AddDays(3), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc1.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc2.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accounts, interval);

      System.Collections.Generic.List<SharedPercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<SharedPercentDiscountRecord>();
      expectedResults.Add(new SharedPercentDiscountRecord(groupAcc1.ID, pcIntervalStart, pcIntervalEnd, 10, new System.Decimal(-12.50))); 
      expectedResults.Add(new SharedPercentDiscountRecord(groupAcc2.ID, pcIntervalStart, pcIntervalEnd, 10, -10)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T12TestMonthlyGroupSharedNonProportionalPercentDiscountBCR()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 13);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("16_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle, mPricelistName));
      string groupAccountName2 = String.Format("17_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe individually at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyFixedPercentDiscountBCR, corporateAcc, accounts,
                              accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), groupAcc1.ID);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly BCR.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart.AddDays(3), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc1.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc2.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accounts, interval);

      System.Collections.Generic.List<SharedPercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<SharedPercentDiscountRecord>();
      expectedResults.Add(new SharedPercentDiscountRecord(groupAcc1.ID, pcIntervalStart, pcIntervalEnd, 10, new System.Decimal(-22.50))); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T13TestMonthlyGroupSharedNonProportionalPercentDiscount()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 14);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("18_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle, mPricelistName));
      string groupAccountName2 = String.Format("19_{0}{1}",
                                               accountBillingCycle.ToString(),
                                               Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe individually at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyFixedPercentDiscount, corporateAcc, accounts,
                              accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), groupAcc1.ID);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart.AddDays(3), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc1.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc2.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accounts, interval);

      System.Collections.Generic.List<SharedPercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<SharedPercentDiscountRecord>();
      // Nothing should happen because this is non-BCR (should be picked up by scheduled discount adapter).
      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T14TestMonthlyFixedSumOfTwoIndividualPercentDiscount()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 15);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("20_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedSumOfTwoPercentDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(0), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(2).AddMonths(-1), pcIntervalStart.AddDays(2).AddSeconds(-1), 56, 56)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T15TestMonthlyFixedSumOfTwoIndividualPercentDiscountBCR()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 16);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("21_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlySumOfTwoPercentDiscountBCR, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(0), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      System.Collections.Generic.List<TestServiceTestRecord> testServiceRecs = 
      new System.Collections.Generic.List<TestServiceTestRecord>();
      testServiceRecs.Add(new TestServiceTestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(0), 30, 1));
      testServiceRecs.Add(new TestServiceTestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(1), 30, 3));
      testServiceRecs.Add(new TestServiceTestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(3), 0, 1));

      MeterTestServiceTestUsage(testServiceRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart, pcIntervalEnd, 69, 69)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T16TestMonthlyFixedIndividualPercentDiscountIntegerQualifier()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 17);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("22_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscountIntegerQualifier, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart, pcIntervalEnd, 900, 225)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T17TestMonthlyFixedIndividualPercentDiscountNoDistributionCounter()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 18);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("23_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedPercentDiscountNoDistributionCounter, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc.ID, pcIntervalStart.AddDays(-1), pcIntervalEnd.AddDays(-1), 225, 225)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    //[Test]
    public void T18TestMonthlyFixedAllDiscountTypesMultipleAccounts()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 19);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName1 = String.Format("23_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName1, accountBillingCycle, mPricelistName));
      string indivAccountName2 = String.Format("24_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName2, accountBillingCycle, mPricelistName));
      string indivAccountName3 = String.Format("25_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName3, accountBillingCycle, mPricelistName));
      string indivAccountName4 = String.Format("26_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName4, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc1 = GetAccountByName(indivAccountName1, "mt", MetraTime.Now);     
      YAAC.IMTYAAC indivAcc2 = GetAccountByName(indivAccountName2, "mt", MetraTime.Now);     
      YAAC.IMTYAAC indivAcc3 = GetAccountByName(indivAccountName3, "mt", MetraTime.Now);     
      YAAC.IMTYAAC indivAcc4 = GetAccountByName(indivAccountName4, "mt", MetraTime.Now);     
      int interval = GetCurrentOpenInterval(indivAcc1);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc1, mMonthlyFixedPercentDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      CreateIndividualSubscription(indivAcc2, mMonthlyFixedPercentUnconditionalDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      CreateIndividualSubscription(indivAcc3, mMonthlyFixedFlatDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      CreateIndividualSubscription(indivAcc4, mMonthlyFixedFlatUnconditionalDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", indivAcc2.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", indivAcc3.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", indivAcc4.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", indivAcc1.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", indivAcc2.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", indivAcc3.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", indivAcc4.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", indivAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      testRecs.Add(new TestPITestRecord("10", indivAcc3.LoginName, pcIntervalStart.AddDays(5), 1, 100));
      testRecs.Add(new TestPITestRecord("11", indivAcc3.LoginName, pcIntervalStart.AddDays(6), 1, 100));
      MeterTestPITestUsage(testRecs);
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(indivAcc1);
      accs.Add(indivAcc2);
      accs.Add(indivAcc3);
      accs.Add(indivAcc4);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accs, interval);

      System.Collections.Generic.List<PercentDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<PercentDiscountRecord>();
      expectedResults.Add(new PercentDiscountRecord(indivAcc1.ID, pcIntervalStart.AddDays(-1), pcIntervalEnd.AddDays(-1), 225, 225)); 

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T19TestMonthlyGroupMultipleDiscountBCR()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 20);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string groupAccountName1 = String.Format("27_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName1, accountBillingCycle, mPricelistName));
      string groupAccountName2 = String.Format("28_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(groupAccountName2, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC groupAcc1 = GetAccountByName(groupAccountName1, "mt", MetraTime.Now);     
      YAAC.IMTYAAC groupAcc2 = GetAccountByName(groupAccountName2, "mt", MetraTime.Now);     
      int interval = GetCurrentOpenInterval(groupAcc1);
      // Subscribe shared group at start of current interval.
      System.Collections.Generic.List<YAAC.IMTYAAC> accounts = 
      new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accounts.Add(groupAcc1);
      accounts.Add(groupAcc2);
      CreateGroupSubscription(mMonthlyMultipleDiscountBCR, corporateAcc, accounts,
                              accountBillingCycle, pcIntervalStart, DateTime.Parse("1/1/2038"), true);        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", groupAcc1.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      testRecs.Add(new TestPITestRecord("2", groupAcc2.LoginName, pcIntervalStart.AddDays(9), 1, 100));
      testRecs.Add(new TestPITestRecord("3", groupAcc1.LoginName, pcIntervalStart.AddDays(11), 1, 100));
      testRecs.Add(new TestPITestRecord("4", groupAcc2.LoginName, pcIntervalStart.AddDays(19), 1, 100));
      testRecs.Add(new TestPITestRecord("5", groupAcc1.LoginName, pcIntervalStart.AddDays(22), 1, 100));
      testRecs.Add(new TestPITestRecord("6", groupAcc2.LoginName, pcIntervalStart.AddDays(26), 1, 100));
      testRecs.Add(new TestPITestRecord("7", groupAcc2.LoginName, pcIntervalStart.AddDays(20), 1, 100));
      testRecs.Add(new TestPITestRecord("8", groupAcc1.LoginName, pcIntervalStart.AddDays(10), 1, 100));
      testRecs.Add(new TestPITestRecord("9", groupAcc1.LoginName, pcIntervalStart.AddDays(2), 1, 100));
      testRecs.Add(new TestPITestRecord("10", groupAcc2.LoginName, pcIntervalStart.AddDays(5), 1, 100));
      testRecs.Add(new TestPITestRecord("11", groupAcc1.LoginName, pcIntervalStart.AddDays(6), 1, 100));
      MeterTestPITestUsage(testRecs);
      System.Collections.Generic.List<YAAC.IMTYAAC> accs = new System.Collections.Generic.List<YAAC.IMTYAAC>();
      accs.Add(groupAcc1);
      accs.Add(groupAcc2);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(accs, interval);

      // Split a 3% discount on $275 ($8.25) 6 to 5
      System.Collections.Generic.List<SharedPercentUnconditionalDiscountRecord> expectedResults1 = 
      new System.Collections.Generic.List<SharedPercentUnconditionalDiscountRecord>();
      expectedResults1.Add(new SharedPercentUnconditionalDiscountRecord(groupAcc1.ID, pcIntervalStart, pcIntervalEnd, 3, new System.Decimal(-4.50))); 
      expectedResults1.Add(new SharedPercentUnconditionalDiscountRecord(groupAcc2.ID, pcIntervalStart, pcIntervalEnd, 3, new System.Decimal(-3.75))); 
      ValidateResults(expectedResults1, interval, Utils.GetTestId());

      // Split a discount of 19.95 6 to 5
      System.Collections.Generic.List<SharedFlatDiscountRecord> expectedResults2 = 
      new System.Collections.Generic.List<SharedFlatDiscountRecord>();
      expectedResults2.Add(new SharedFlatDiscountRecord(groupAcc1.ID, pcIntervalStart, pcIntervalEnd, new System.Decimal(-10.88))); 
      expectedResults2.Add(new SharedFlatDiscountRecord(groupAcc2.ID, pcIntervalStart, pcIntervalEnd, new System.Decimal(-9.07))); 

      ValidateResults(expectedResults2, interval, Utils.GetTestId());
    }
    [Test]
    [Ignore("Failing - Ignore Test")]
    public void T20TestMonthlyFixedIndividualFlatZeroDiscount()
    {
      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 21);
      int pcInterval;
      DateTime pcIntervalStart;
      DateTime pcIntervalEnd;
      accountBillingCycle.GetPCInterval(MetraTime.Now, out pcInterval, out pcIntervalStart, out pcIntervalEnd);
      // Create the accounts with the billing cycle
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("29_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle, mPricelistName));
      Utils.CreateSubscriberAccounts(mCorporate, subs, pcIntervalStart);

      // Get the current open interval for the account.
      YAAC.IMTYAAC corporateAcc = GetAccountByName(mCorporate, "mt", MetraTime.Now);      
      YAAC.IMTYAAC indivAcc = GetAccountByName(indivAccountName, "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(indivAcc);
      // Subscribe individually at start of current interval.
      CreateIndividualSubscription(indivAcc, mMonthlyFixedFlatDiscount, pcIntervalStart, DateTime.Parse("1/1/2038"));        
      // Meter usage 
      // Format:
      // Description Songs Mp3Bytes WavBytes AccountName StartTime TotalSongs TotalBytes
      // Description gives the order in which the usage was metered.
      // Running totals are with respect to the starttime.
      // The discount instance is monthly ending on the 17th.
      System.Collections.Generic.List<TestPITestRecord> testRecs = 
      new System.Collections.Generic.List<TestPITestRecord>();
      testRecs.Add(new TestPITestRecord("1", indivAcc.LoginName, pcIntervalStart.AddDays(1), 1, 100));
      MeterTestPITestUsage(testRecs);
      // Trigger 2nd pass processing for this pi template and interval.
      RunDiscountAdapterOneBillingGroup(indivAcc, interval);

      // Flat discount is $0 for counters < 50
      System.Collections.Generic.List<SharedFlatDiscountRecord> expectedResults = 
      new System.Collections.Generic.List<SharedFlatDiscountRecord>();

      ValidateResults(expectedResults, interval, Utils.GetTestId());
    }
  }
}
