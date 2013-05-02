using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using NUnit.Framework;
//using NUnit.Framework.Extensions;

using YAAC = MetraTech.Interop.MTYAAC;

namespace MetraTech.Product.Test
{
	using System;
	using System.Runtime.InteropServices;
	using NUnit.Framework;

	using MetraTech.DataAccess;
	using MetraTech.UsageServer;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Product.Test.AdapterTestTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
	[ComVisible(false)]
	public class AdapterTestTests 
	{

		public AdapterTestTests()
		{
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
    public void TestEmptyDiscountTest()
    {
      YAAC.IMTAccountCatalog accCatalog = new YAAC.MTAccountCatalog();
			MetraTech.Interop.MTAuth.IMTSessionContext superUserContext = MetraTech.Test.Common.Utils.LoginAsSU();
			accCatalog.Init((YAAC.IMTSessionContext)superUserContext);
      YAAC.IMTYAAC demoAcc = accCatalog.GetAccountByName("demo", "mt", MetraTime.Now);      
      int interval = GetCurrentOpenInterval(demoAcc);
      RunDiscountAdapterOneBillingGroup(demoAcc, interval);
    }
  }
}
