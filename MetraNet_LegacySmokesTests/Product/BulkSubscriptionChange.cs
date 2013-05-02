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
	// nunit-console /fixture:MetraTech.Product.Test.BulkSubscriptionChangeTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class BulkSubscriptionChangeTests 
	{
		private PC.MTProductCatalog mPC;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
    private string mCorporate;
    private PC.IMTProductOffering mSongDownloads;
    private PC.IMTProductOffering mSongSession;

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

		public BulkSubscriptionChangeTests()
		{
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();
      
      string testid=Utils.GetTestId();
			Utils.GenerateSongDownloadsProductOffering();
			Utils.GenerateSongSessionProductOffering();
      mSongDownloads = mPC.GetProductOfferingByName(string.Format("PO_Song Downloads{0}", testid));
      mSongSession = mPC.GetProductOfferingByName(string.Format("PO_Song Session{0}", testid));

      mCorporate = String.Format("BulkSubscriptionTests{0}", testid);
      Utils.CreateCorporation(mCorporate, MetraTime.Now);
    }

    [Test]
    public void TestOneAccountNextBillCycleWithUpdateOldSubscription()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 1);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      span.EndDate = DateTime.Parse("1/1/2038");
      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, now.AddMonths(1), true);

      // Validate both subscriptions.
      System.DateTime expectedSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc2.dt_end FROM t_pc_interval pc1 \n" +
            "INNER JOIN t_pc_interval pc2 ON pc1.id_cycle=pc2.id_cycle AND dbo.AddSecond(pc1.dt_end)=pc2.dt_start \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  expectedSubEnd = reader.GetDateTime("dt_end");
              }
          }
      }

      System.DateTime actualSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  actualSubEnd = reader.GetDateTime("vt_end");
              }
          }
      }

      System.DateTime actualSubStart;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  actualSubStart = reader.GetDateTime("vt_start");
              }
          }
      }

      Assert.AreEqual(expectedSubEnd, actualSubEnd);
      Assert.AreEqual(expectedSubEnd.AddSeconds(1), actualSubStart);
    }
    [Test]
    public void TestOneAccountImmediateWithUpdateOldSubscription()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 2);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      span.EndDate = DateTime.Parse("1/1/2038");
      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, now.AddMonths(1), false);

      System.DateTime actualSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  actualSubEnd = reader.GetDateTime("vt_end");
              }
          }
      }

      System.DateTime actualSubStart;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  actualSubStart = reader.GetDateTime("vt_start");
              }
          }
      }

      Assert.AreEqual(now.AddMonths(1).AddSeconds(-1), actualSubEnd);
      Assert.AreEqual(now.AddMonths(1), actualSubStart);
    }
    [Test]
    public void TestOneAccountNextBillCycleWithDeleteOldSubscription()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 3);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually at the beginning of the second interval after current.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc3.dt_end FROM t_pc_interval pc1 \n" +
            "INNER JOIN t_pc_interval pc2 ON pc1.id_cycle=pc2.id_cycle AND dbo.AddSecond(pc1.dt_end)=pc2.dt_start \n" +
            "INNER JOIN t_pc_interval pc3 ON pc1.id_cycle=pc3.id_cycle AND dbo.AddSecond(pc2.dt_end)=pc3.dt_start \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  span.StartDate = reader.GetDateTime("dt_end");
              }
          }
      }

      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      span.EndDate = DateTime.Parse("1/1/2038");
      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, now.AddMonths(1), true);

      // Validate both subscriptions.
      System.DateTime expectedSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc2.dt_end FROM t_pc_interval pc1 \n" +
            "INNER JOIN t_pc_interval pc2 ON pc1.id_cycle=pc2.id_cycle AND dbo.AddSecond(pc1.dt_end)=pc2.dt_start \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  expectedSubEnd = reader.GetDateTime("dt_end");
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  Assert.AreEqual(false, reader.Read());
              }
          }
      }

      System.DateTime actualSubStart;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  actualSubStart = reader.GetDateTime("vt_start");
              }
          }
      }

      Assert.AreEqual(expectedSubEnd.AddSeconds(1), actualSubStart);
    }
    [Test]
    public void TestOneAccountImmediateWithDeleteOldSubscription()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 4);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc3.dt_end FROM t_pc_interval pc1 \n" +
            "INNER JOIN t_pc_interval pc2 ON pc1.id_cycle=pc2.id_cycle AND dbo.AddSecond(pc1.dt_end)=pc2.dt_start \n" +
            "INNER JOIN t_pc_interval pc3 ON pc1.id_cycle=pc3.id_cycle AND dbo.AddSecond(pc2.dt_end)=pc3.dt_start \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  span.StartDate = reader.GetDateTime("dt_end");
              }
          }
      }

      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      span.EndDate = DateTime.Parse("1/1/2038");
      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, now.AddMonths(1), false);

      // Validate both subscriptions.
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  Assert.AreEqual(false, reader.Read());
              }
          }
      }

      System.DateTime actualSubStart;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  actualSubStart = reader.GetDateTime("vt_start");
              }
          }
      }

      Assert.AreEqual(now.AddMonths(1), actualSubStart);
    }
    [Test]
    public void TestOneAccountNextBillCycleWithNoAction()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 5);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually ending at the end of the current interval.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  span.EndDate = reader.GetDateTime("dt_end");
              }
          }
      }

      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      try
      {
        mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, now.AddMonths(1), true);
        Assert.IsTrue(false);
      }
      catch(System.Runtime.InteropServices.COMException)
      {
      }

      // Validate both subscriptions.
      System.DateTime expectedSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  expectedSubEnd = reader.GetDateTime("dt_end");
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  System.DateTime actualSubEnd = reader.GetDateTime("vt_end");
                  Assert.AreEqual(expectedSubEnd, actualSubEnd);
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  Assert.AreEqual(false, reader.Read());
              }
          }
      }
    }
    [Test]
    public void TestOneAccountImmediateWithNoAction()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 6);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  span.EndDate = reader.GetDateTime("dt_end");
              }
          }
      }

      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      try
      {
        mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, now.AddMonths(1), false);
        Assert.IsTrue(false);
      }
      catch(System.Runtime.InteropServices.COMException)
      {
      }

      // Validate both subscriptions.
      System.DateTime expectedSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  expectedSubEnd = reader.GetDateTime("dt_end");
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  System.DateTime actualSubEnd = reader.GetDateTime("vt_end");
                  Assert.AreEqual(expectedSubEnd, actualSubEnd);
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  Assert.AreEqual(false, reader.Read());
              }
          }
      }
    }
    [Test]
    public void TestOneAccountNextBillCycleMiddleNextIntervalWithNoAction()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 7);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually ending at the end of the current interval.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  span.EndDate = reader.GetDateTime("dt_end").AddDays(15);
              }
          }
      }

      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, span.EndDate.AddDays(-1), true);

      // Validate both subscriptions.
      System.DateTime expectedSubEnd;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  expectedSubEnd = reader.GetDateTime("dt_end").AddDays(15);
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  System.DateTime actualSubEnd = reader.GetDateTime("vt_end");
                  Assert.AreEqual(expectedSubEnd, actualSubEnd);
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  Assert.AreEqual(false, reader.Read());
              }
          }
      }
    }
    [Test]
    public void TestOneAccountImmediateMiddleNextIntervalWithUpdate()
    {
      System.DateTime now = MetraTime.Now;

      Utils.BillingCycle accountBillingCycle = new Utils.BillingCycle (Utils.CycleType.MONTHLY, 8);
      // Create the accounts with the billing cycle, one for group one for individual.
      ArrayList subs = new ArrayList();
      string indivAccountName = String.Format("SUB_{0}{1}",
                                              accountBillingCycle.ToString(),
                                              Utils.GetTestId());
      subs.Add(new Utils.AccountParameters(indivAccountName, accountBillingCycle));
      Utils.CreateSubscriberAccounts(mCorporate, subs, MetraTime.Now);
      YAAC.IMTYAAC acc = mAccCatalog.GetAccountByName(indivAccountName, "mt", MetraTime.Now);      

      // Get interval
      int interval = GetCurrentOpenInterval(acc);

      // Subscribe individually.
      PC.IMTPCAccount pcAcc = mPC.GetAccount(acc.ID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT pc1.dt_end FROM t_pc_interval pc1 \n" +
            "WHERE pc1.id_interval=?"))
          {
              stmt.AddParam(MTParameterType.Integer, interval);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  span.EndDate = reader.GetDateTime("dt_end").AddDays(15);
              }
          }
      }

      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      object ignore;
      PC.IMTSubscription sub = pcAcc.Subscribe(mSongSession.ID, span, out ignore);
      sub.Save();

      // HACK: We'll get a tt_end collision if we don't pause here.
      System.Threading.Thread.Sleep(1000);

      // Move to song downloads.
      mPC.BulkSubscriptionChange(mSongSession.ID, mSongDownloads.ID, span.EndDate.AddDays(-1), false);

      // Validate both subscriptions.
      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_end FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongSession.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  System.DateTime actualSubEnd = reader.GetDateTime("vt_end");
                  Assert.AreEqual(span.EndDate.AddDays(-1).AddSeconds(-1), actualSubEnd);
              }
          }
      }

      using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
      {
          using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(
            "SELECT vt_start FROM t_sub WHERE id_acc=? AND id_po=?"))
          {
              stmt.AddParam(MTParameterType.Integer, acc.ID);
              stmt.AddParam(MTParameterType.Integer, mSongDownloads.ID);
              using (IMTDataReader reader = stmt.ExecuteReader())
              {
                  reader.Read();
                  System.DateTime actualSubStart = reader.GetDateTime("vt_start");
                  Assert.AreEqual(span.EndDate.AddDays(-1), actualSubStart);
              }
          }
      }
    }
  }
}
