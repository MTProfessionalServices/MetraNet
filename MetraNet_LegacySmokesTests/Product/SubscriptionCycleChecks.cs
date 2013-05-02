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
	// nunit-console /fixture:MetraTech.Product.Test.IndividualSubscriptionCycleCheckTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class IndividualSubscriptionCycleCheckTests 
	{

		private PC.MTProductCatalog mPC;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
		 

		public IndividualSubscriptionCycleCheckTests()
		{
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();
		}

		[Test]
		public void TestCreateHierarchy()
		{
      Utils.GenerateBillingCycleAccounts();
		}
		[Test]
		public void TestCreatePriceableItems()
		{
			Utils.GeneratePriceableItemTemplates();
		}
    
    private void PerformSubscription(int prodOffID, int accID, int expectedError)
    {
      bool dtModified;
      // Try various subscription combinations.  Use both the bulk API and individual API
      PC.IMTCollection col = (PC.IMTCollection) new Coll.MTCollectionClass();
      PC.IMTSubInfo si = new PC.MTSubInfoClass();
      si.ProdOfferingID = prodOffID;
      si.AccountID = accID;
      si.SubsStartDate = MetraTime.Now;
      si.SubsStartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      si.SubsEndDate = DateTime.Parse("1/1/2038");
      si.SubsEndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      col.Add(si);
      PC.IMTRowSet rs = mPC.SubscribeAccounts(col, null, out dtModified, null);
      if (0 == expectedError)
      {
        Assert.AreEqual(0, rs.RecordCount);
        // Now delete the subscription we just created to avoid conflicts in other test cases.
        // Business rule checks prevent this in general so we hack the database.
        Utils.MTSQLRowSetExecute(string.Format("DELETE FROM t_sub WHERE id_po={0} AND id_acc={1}", prodOffID, accID));
        Utils.MTSQLRowSetExecute(string.Format("UPDATE t_sub_history SET tt_end = {2} WHERE id_po={0} AND id_acc={1} AND tt_end=dbo.MTMaxDate()", prodOffID, accID, DBUtil.ToDBString(MetraTime.Now)));
      }
      else
      {
        Assert.AreEqual(1, rs.RecordCount);   
//         rs.MoveNext();
//         Assert.AreEqual(expectedError==-289472464 ? "" : "", rs.GetValue("description"));
      }

      PC.IMTPCAccount pcAcc = mPC.GetAccount(accID);
      PC.MTPCTimeSpan span = new PC.MTPCTimeSpanClass();
      span.StartDate = MetraTime.Now;
      span.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      span.EndDate = DateTime.Parse("1/1/2038");
      span.EndDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
      try
      {
        object ignore;
        PC.IMTSubscription sub = pcAcc.Subscribe(prodOffID, span, out ignore);
        dtModified = sub.Save();
        Assert.AreEqual(expectedError, 0);
        // Now delete the subscription we just created to avoid conflicts in other test cases.
        // Business rule checks prevent this in general so we hack the database.
        Utils.MTSQLRowSetExecute(string.Format("DELETE FROM t_sub WHERE id_po={0} AND id_acc={1}", prodOffID, accID));
        Utils.MTSQLRowSetExecute(string.Format("UPDATE t_sub_history SET tt_end = {2} WHERE id_po={0} AND id_acc={1} AND tt_end=dbo.MTMaxDate()", prodOffID, accID, DBUtil.ToDBString(MetraTime.Now)));
      }
      catch(System.Runtime.InteropServices.COMException e)
      {
        Assert.AreEqual(expectedError, e.ErrorCode);
      }
    }
		[Test]
		public void TestIndividualSubscriptionCycleCheck()
		{
      string testid = Utils.GetTestId();
      // The list of POs to subscribe
      ArrayList po = new ArrayList();
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_DAILY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_WEEKLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_MONTHLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_ANNUAL_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRU_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_DAILY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_WEEKLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_MONTHLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_ANNUAL_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_EBCR_WEEKLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_EBCR_MONTHLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_EBCR_ANNUAL_ARREARS_PERSUB{0}", testid)));
      // The list of accounts to subscribe
      ArrayList acc = new ArrayList();
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_DAILY{0}", testid), "mt", MetraTime.Now));
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_WEEKLY_SUNDAY{0}", testid), "mt", MetraTime.Now));
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_MONTHLY_EOM{0}", testid), "mt", MetraTime.Now));
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_ANNUAL_01_01{0}", testid), "mt", MetraTime.Now));
      // Make sure all account pay for themselves
      for(int i=0; i<acc.Count; i++)
      {
        YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
        pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)acc[i]);
        pmt.PayForAccount(((YAAC.IMTYAAC)acc[i]).ID, MetraTime.Now.Date, DateTime.Parse("1/1/2038"));
      }
      // Fixed cycle cases.  No errors here.
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      // BCR Unconstrained cases.  No errors here.
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0);
      // BCR Constrained cases.  Must have cycle type match.
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0);
      // EBCR cases.  Have subtle cycle matching rules.
      // Weekly EBCR matches Weekly or Bi-weekly account
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472444); 
      // Monthly EBCR matches Monthly, Quarterly or Annual
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      // Annual EBCR matches Monthly, Quarterly or Annual
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
		}
		[Test]
		public void TestIndividualSubscriptionCycleCheckPaymentRedirection()
		{
      string testid = Utils.GetTestId();
      // The list of POs to subscribe
      ArrayList po = new ArrayList();
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_DAILY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_WEEKLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_MONTHLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_FIXED_ANNUAL_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRU_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_DAILY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_WEEKLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_MONTHLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_BCRC_ANNUAL_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_EBCR_WEEKLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_EBCR_MONTHLY_ARREARS_PERSUB{0}", testid)));
      po.Add(mPC.GetProductOfferingByName(string.Format("PO_FLATRC_EBCR_ANNUAL_ARREARS_PERSUB{0}", testid)));
      // The list of accounts to subscribe
      ArrayList acc = new ArrayList();
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_DAILY{0}", testid), "mt", MetraTime.Now));
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_WEEKLY_SUNDAY{0}", testid), "mt", MetraTime.Now));
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_MONTHLY_EOM{0}", testid), "mt", MetraTime.Now));
      acc.Add(mAccCatalog.GetAccountByName(string.Format("SUB_ANNUAL_01_01{0}", testid), "mt", MetraTime.Now));

      // Perform payment redirection and validate that all checks are going agains payers
      for(int i=0; i<acc.Count; i++)
      {
        YAAC.IMTPaymentMgr pmt = new YAAC.MTPaymentMgrClass();
        pmt.Initialize((YAAC.IMTSessionContext) mSUCtx,true,(YAAC.MTYAAC)acc[i]);
        pmt.PayForAccount(((YAAC.IMTYAAC)acc[(i+1)%acc.Count]).ID, MetraTime.Now.Date, DateTime.Parse("1/1/2038"));
      }
      // In general the expected results are offset by 1 from the case without payment redirection.
      // Since 0 pays for 1, then 1 behaves as 0 absent redirection, etc.

      // Fixed cycle cases.  No errors here.
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[0]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[1]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[2]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[3]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      // BCR Unconstrained cases.  No errors here.
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[4]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0);
      // BCR Constrained cases.  Must have cycle type match.
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[1]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[5]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[6]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[7]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472464); 
      PerformSubscription(((PC.IMTProductOffering)po[8]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0);
      // EBCR cases.  Have subtle cycle matching rules.
      // Weekly EBCR matches Weekly or Bi-weekly account
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[2]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[3]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[9]).ID, ((YAAC.IMTYAAC)acc[0]).ID, -289472444); 
      // Monthly EBCR matches Monthly, Quarterly or Annual
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[10]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
      // Annual EBCR matches Monthly, Quarterly or Annual
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[1]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[2]).ID, -289472444); 
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[3]).ID, 0); 
      PerformSubscription(((PC.IMTProductOffering)po[11]).ID, ((YAAC.IMTYAAC)acc[0]).ID, 0); 
		}
	}
}

