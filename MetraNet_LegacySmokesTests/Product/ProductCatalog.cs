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
	// nunit-console /fixture:MetraTech.Product.Test.ProductOfferingTests /assembly:o:\debug\bin\MetraTech.Product.Test.dll
	//
	[TestFixture]
  [Category("NoAutoRun")]
  [ComVisible(false)]
	public class ProductOfferingTests 
	{

		private PC.MTProductCatalog mPC;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;
		 

		public ProductOfferingTests()
		{
			mPC = new PC.MTProductCatalogClass();
			mAccCatalog = new YAAC.MTAccountCatalog();
			mSUCtx = Utils.LoginAsSU();
			mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
			mPC.SetSessionContext((PC.IMTSessionContext)mSUCtx);
			Utils.TurnTraceOn();
		}

		[Test]
    public void T01_TestCreateHierarchy()
		{
			Utils.SetupHierarchy("PC");
		}


		/// <summary>
		/// Tests operations on constrained product offerings
		/// </summary>
		/// 
		[Test]
    public void T02_CreateProductOffering()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.CreateProductOffering();
			po.Name = Utils.GeneratePOName();
			po.DisplayName = po.Name;
			po.Description = po.Name;
			po.SelfSubscribable = true;
			po.SelfUnsubscribable = false;
			po.EffectiveDate.StartDateType = PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE;
			po.EffectiveDate.StartDate = MetraTime.Now;
			po.EffectiveDate.EndDateType = PC.MTPCDateType.PCDATE_TYPE_NULL;
			po.EffectiveDate.SetEndDateNull();
			//Find Usage Charge
			PC.MTPriceableItem usage = mPC.GetPriceableItemByName("Test Usage Charge");
			po.AddPriceableItem(usage);

			po.AvailabilityDate.StartDate = MetraTime.Now;
			po.AvailabilityDate.SetEndDateNull();
			po.SetCurrencyCode("USD");

			

			po.Save();
		}
		[Test]
    public void T03_TestWideOpenPO()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
		}

		[Test]
    public void T04_TestAddConstraintsThroughCollection()
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
			po.SubscribableAccountTypes.Add("CoreSubscriber");
			po.SubscribableAccountTypes.Add("GSMServiceAccount");
			Assert.AreEqual(2, po.SubscribableAccountTypes.Count);
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
			po.Save();
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(2, rs.RecordCount);
		}

		[Test]
    public void T05_TestRemoveConstraintsThroughCollection()
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(2, rs.RecordCount);
			((IMTCollectionEx)po.SubscribableAccountTypes).Clear();
			Assert.AreEqual(0, po.SubscribableAccountTypes.Count);
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(2, rs.RecordCount);
			po.Save();
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
		}

		[Test]
    public void T06_TestAddConstraintsThroughMTProperties()
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
			PC.IMTProperty satprop  = (PC.IMTProperty)po.Properties["SubscribableAccountTypes"];
			PC.IMTCollection sat = (PC.IMTCollection)satprop.Value;
			sat.Add("CoreSubscriber");
			sat.Add("GSMServiceAccount");
			Assert.AreEqual(2, sat.Count);
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
			po.Save();
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(2, rs.RecordCount);
		}

		[Test]
    public void T07_TestRemoveConstraintsThroughMTProperties()
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(2, rs.RecordCount);
			PC.IMTProperty satprop  = (PC.IMTProperty)po.Properties["SubscribableAccountTypes"];
			Coll.IMTCollectionEx sat = (Coll.IMTCollectionEx)satprop.Value;
			Assert.AreEqual(2, sat.Count);
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(2, rs.RecordCount);
			sat.Clear();
			po.Save();
			rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			Assert.AreEqual(0, rs.RecordCount);
		}

		
		
		[Test]
    public void T08_TestAddConstraintToPO()
		{
			Utils.AddConstraintToPO("CoreSubscriber");
		}

    [Test]
		//#define MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE ((DWORD)0xEEBF004EL) -289472434
		//[ExpectedCOMException(0xEEBF004EL)]
    public void T09_TestAddInvalidConstraintToPO()
    {
      Assert.Catch(delegate { Utils.AddConstraintToPO("SystemAccount"); });
			//Utils.AddConstraintToPO("SystemAccount");
		}
		[Test]
    public void T10_TestMTPropertiesToString()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTProperties props = po.Properties;
			props.ToString();
		}

		[Test]
    public void T11_TestCreateCopyPO()
		{
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTProductOffering copy = po.CreateCopy(string.Format("{0}_{1}", Utils.GeneratePOName(), "Copied"), "USD");
			copy.Save();
			PC.IMTProductOffering pocopy = mPC.GetProductOfferingByName(string.Format("{0}_{1}", Utils.GeneratePOName(), "Copied"));
			PC.IMTCollection sat = pocopy.SubscribableAccountTypes;
			
			Assert.AreEqual(1, sat.Count, "SubscribableAccountTypes cound has to be 1 at this point");
			foreach(string str in sat)
			{
				Assert.AreEqual("CoreSubscriber", str);
			}
		}

		[Test]
    public void T12_TestDumpMTProperties()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTProperties props = po.Properties;
			string tempval;
			foreach(PC.IMTProperty prop in props)
			{
				
				if (prop.DataTypeAsString == "object")
				{
					if (prop.Value.GetType() == typeof(Coll.IMTCollectionEx))
					{
						tempval = prop.Value.ToString();
					}
					else if (prop.Value.GetType() == typeof(Coll.IMTCollection))
					{
						tempval = Utils.DumpCollection((Coll.IMTCollection)prop.Value);
					}
				}
				else 
					tempval = prop.Value.ToString();
			}
  
		}

		[Test]
    public void T13_TestSubscribableAccountTypes()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTCollection sat = po.SubscribableAccountTypes;
			
			Assert.IsTrue(sat.Count == 1, "SubscribableAccountTypes cound has to be 1 at this point");
			foreach(string str in sat)
			{
				Assert.AreEqual("CoreSubscriber", str);
			}

		}

		[Test]
    public void T14_TestSubscribableAccountTypesToString()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			object sat = po.SubscribableAccountTypes;
			Coll.IMTCollectionEx ex = sat as Coll.IMTCollectionEx;
			Assert.IsTrue(ex != null, "Failed to cast SubscribableAccountTypes to IMTCollectionEx");
			Assert.IsTrue(ex.Count == 1, "SubscribableAccountTypes cound has to be 1 at this point");
			
			Assert.AreEqual("CoreSubscriber", ex.ToString());
			
		}

		[Test]
    public void T15_TestSubscribableAccountTypesMTProperties()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTProperties props = po.Properties;
			object o = props["SubscribableAccountTypes"];
			Assert.IsNotNull(o, "SubscribableAccountTypes property not found");
			

			foreach(PC.MTProperty p in props)
			{
				string nm = p.Name;
				object val = p.Value;
				bool iscol = val is PC.IMTCollection;
				if(iscol)
				{
					PC.IMTCollection col = (PC.IMTCollection)val;
					Assert.IsTrue(col.Count == 1, "SubscribableAccountTypes cound has to be 1 at this point");
					foreach(string str in col)
					{
						Assert.AreEqual("CoreSubscriber", str);
					}
				}

			}

		}

		[Test]
    public void T16_CreateGroupSubscription()
		{
			//get product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			//should be 1 now
			Assert.AreEqual(1, rs.RecordCount);
			//create group subscription
			PC.IMTGroupSubscription gs  = mPC.CreateGroupSubscription();
			gs.ProductOfferingID = po.ID;
			gs.Name = Utils.GenerateGSubName();
			gs.Description = Utils.GenerateGSubName();
			gs.CorporateAccount = Utils.GetSubscriberAccountID(Utils.GenerateCorporateAccountName());
			PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
			eff.StartDate = MetraTime.Now;
			
			PC.MTPCCycle cycle = new PC.MTPCCycleClass();
			cycle.CycleTypeID = 1; // monthly
			cycle.EndDayOfMonth = 30;
			
			gs.EffectiveDate = eff;
			gs.ProportionalDistribution = true;
			gs.Cycle = cycle;
			gs.Save();
			
		}

		[Test]
		//[ExpectedCOMException(0xE2FF000EL/*MT_GROUP_SUB_CORPORATE_ACCOUNT_INVALID*/)]
    public void T17_CreateGroupSubscriptionForInvalidCorporateAccount()
		{
			//get product offering
			
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			//should be 1 now
			Assert.AreEqual(1, rs.RecordCount);
			//create group subscription
			PC.IMTGroupSubscription gs  = mPC.CreateGroupSubscription();
			gs.ProductOfferingID = po.ID;
			gs.Name = string.Format("{0}_Invalid", Utils.GenerateGSubName());
			gs.Description = Utils.GenerateGSubName();
			gs.CorporateAccount = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1));
			PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
			eff.StartDate = MetraTime.Now;
			
			PC.MTPCCycle cycle = new PC.MTPCCycleClass();
			cycle.CycleTypeID = 1; // monthly
			cycle.EndDayOfMonth = 30;
			
			gs.EffectiveDate = eff;
			gs.ProportionalDistribution = true;
			gs.Cycle = cycle;
			//gs.Save();
      Assert.Catch(delegate { gs.Save(); });

		}

		[Test]
    public void T18_TestAvailableGroupSubscriptionsOnIncompatibleAccountType()
		{
			YAAC.IMTYAAC yaac = Utils.GetSubscriberAccount(Utils.GenerateGSMUserName(1));
			YAAC.IMTSQLRowset rs = (YAAC.IMTSQLRowset)yaac.GetAvailableGroupSubscriptionsAsRowset(MetraTime.Now, null);
			//make sure that the group sub we jsut created is not in the list
			string gsname = Utils.GenerateGSubName();
			while(System.Convert.ToBoolean(rs.EOF) == false)
			{
				string avail = (string)rs.get_Value("tx_name");
				Assert.IsTrue(gsname != avail, "This Group Sub should not be available for this account type");
				rs.MoveNext();
			}
		}

		[Test]
    public void T19_TestAvailableGroupSubscriptionsOnCompatibleAccountType()
		{
			YAAC.IMTYAAC yaac = Utils.GetSubscriberAccount(Utils.GenerateSubscriberUserName(1));
			YAAC.IMTSQLRowset rs = (YAAC.IMTSQLRowset)yaac.GetAvailableGroupSubscriptionsAsRowset(MetraTime.Now, null);
			//make sure that the group sub we jsut created is not in the list
			string gsname = Utils.GenerateGSubName();
			bool found = false;
			while(System.Convert.ToBoolean(rs.EOF) == false)
			{
				string avail = (string)rs.get_Value("tx_name");
				if(gsname == avail)
				{
					found = true; break;
				}
				rs.MoveNext();
			}
			Assert.IsTrue(found == true, "This Group Sub should be available for this account type");
		}

		
		[Test]
    public void T20_TestRemoveConstraintToPO()
		{
			Utils.RemoveConstraintFromPO("CoreSubscriber");
		}

		[Test]
    public void T21_TestMTPropertiesToString1()
		{

			//Create product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTProperties props = po.Properties;
			props.ToString();
		}


		[Test]
    public void T22_TestAvailableGroupSubscriptionsOnFormelyInCompatibleAccountType()
		{
			YAAC.IMTYAAC yaac = Utils.GetSubscriberAccount(Utils.GenerateGSMUserName(1));
			YAAC.IMTSQLRowset rs = (YAAC.IMTSQLRowset)yaac.GetAvailableGroupSubscriptionsAsRowset(MetraTime.Now, null);
			//make sure that the group sub we jsut created is not in the list
			string gsname = Utils.GenerateGSubName();
			bool found = false;
			while(System.Convert.ToBoolean(rs.EOF) == false)
			{
				string avail = (string)rs.get_Value("tx_name");
				if(gsname == avail)
				{
					found = true; break;
				}
				rs.MoveNext();
			}
			Assert.IsTrue(found == true, "This Group Sub should now be available for this account type");
		}


		/*	MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434
		 * Test this for system accounts (b_cansubscribe = false, b_canparticipateingsub = false)
		 * 
		 * 
		 */
		[Test]
		//[ExpectedCOMException(-289472434)]
    public void T23_TestNonBatchGroupSubscriptionForMTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLEAccountType()
		{
			PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
			PC.MTGSubMember member = new PC.MTGSubMemberClass();
			member.AccountID = Utils.GetSystemUserAccountID("csr1");
			member.StartDate = MetraTime.Now.AddDays(1);
			member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
			//gs.AddAccount(member);
      Assert.Catch(delegate { gs.AddAccount(member); });

		}

		[Test]
		/*	MTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUB 0xEEBF004FL -289472433
		 * Test this for independent accounts (b_cansubscribe = true, b_canparticipateingsub = false)
		 * 
		 * 
		 */

		/* BP: Ignore for now, because MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT is raised first
		 * No easy way to test this business rule. Need more account types or relax corporate business rule
		 * */
		[Ignore("ignore")]
		//[ExpectedCOMException(-289472434)]
    public void T24_TestNonBatchGroupSubscriptionForMTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUBAccountType()
		{
			PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
			PC.MTGSubMember member = new PC.MTGSubMemberClass();
			member.AccountID = Utils.GetSubscriberAccountID("demo");
			member.StartDate = MetraTime.Now.AddDays(1);
			member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
			gs.AddAccount(member);
			
		}

		[Test]
		/* BP: Ignore for now, because __GET_SUBSCRIBE_TO_GROUP_BATCH_ERRORS__  inner joins against vw_mps_acc_mapper = 
		 * Does not work for system users. We probably need more subsscriber like account types to tests these business rules
		 * */
		[Ignore("ignore")]
    public void T25_estBatchGroupSubscriptionForPartialMTPCUSER_ACCOUNT_TYPE_CANNOT_PARTICIPATE_IN_GSUBAccountTypes()
		{
			try
			{
				//BP TODO: Create system users on setup, for now stage is broken
				string[] users = new string[]{"jcsr", "ops", "scsr", "csr1"};

				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				//for (int i = 10; i < 50; i++)
				for(int i = 0; i <= users.Length; i++)
				{
					PC.MTGSubMember member = new PC.MTGSubMemberClass();
					int id_acc = -1;
					if(i == users.Length)
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1));
					else
						id_acc = Utils.GetSystemUserAccountID(users[i]);
					member.AccountID = id_acc;

					member.StartDate = MetraTime.Now.AddDays(1);
					member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
				Assert.AreEqual(4, rs.RecordCount);
				Utils.DumpErrorRowset((MetraTech.Interop.MTYAAC.IMTSQLRowset)rs);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		

		[Test]
		//Re-add constraints again for further testing
    public void T26_TestAddConstraintToPO1()
		{
			Utils.AddConstraintToPO("GSMServiceAccount");
		}

		

		[Test]
		[ExpectedException(typeof(System.Runtime.InteropServices.COMException))]
    public void T27_TestNonBatchGroupSubscriptionForIncompatibleAccountType()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.MTGSubMember member = new PC.MTGSubMemberClass();
				member.AccountID = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1));
				member.StartDate = MetraTime.Now.AddDays(1);
				member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
				gs.AddAccount(member);
			}
			catch(Exception)
			{
				throw;
			}
		}

		[Test]
    public void T28_TestNonBatchGroupSubscriptionForCompatibleAccountType()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.MTGSubMember member = new PC.MTGSubMemberClass();
				member.AccountID = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(1));
				member.StartDate = MetraTime.Now.AddDays(1);
				member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
				gs.AddAccount(member);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T29_TestBatchGroupSubscriptionForPartiallyIncompatibleAccountTypes()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 10; i < 50; i++)
				{
					PC.MTGSubMember member = new PC.MTGSubMemberClass();
					int id_acc = -1;
					if(i % 5 == 0)
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(i));
					else
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(i));

					member.AccountID = id_acc;

					member.StartDate = MetraTime.Now.AddDays(1);
					member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
				Assert.AreEqual(8, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		

		[Test]
    public void T30_TestBatchGroupSubscriptionForIncompatibleAccountTypes()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 10; i < 50; i++)
				{
					PC.MTGSubMember member = new PC.MTGSubMemberClass();
					int id_acc = -1;
					id_acc = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(i));
					
					member.AccountID = id_acc;

					member.StartDate = MetraTime.Now.AddDays(1);
					member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
				Assert.AreEqual(40, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		[Test]
    public void T31_TestBatchGroupSubscriptionForCompatibleAccountTypes()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 50; i < 60; i++)
				{
					PC.MTGSubMember member = new PC.MTGSubMemberClass();
					int id_acc = -1;
					id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(i));
					
					member.AccountID = id_acc;

					member.StartDate = MetraTime.Now.AddDays(1);
					member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
				Assert.AreEqual(0, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		

		/// <summary>
		/// Open Product Offering to all account types and repeat
		/// </summary>
		/// 
		[Test]
    public void T32_TestRemoveAllConstraints()
		{
			Utils.RemoveAllConstraintsFromPO();
		}


		[Test]
			//Re-add constraints again for further testing
    public void T33_TestAddConstraintToPO2()
		{
			Utils.AddConstraintToPO("GSMServiceAccount");
		}


		[Test]
		//[ExpectedCOMException(-289472435)]
    public void T34_TestNonBatchIndividualSubscriptionForIncompatibleAccountType()
		{
			
			//get product offering
			PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
			PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
			//should be 1
			Assert.AreEqual(1, rs.RecordCount);
			PC.IMTPCAccount acc = mPC.GetAccount(Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(61)));
			PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
			eff.StartDate = MetraTime.Now;
			eff.SetEndDateNull();

			PC.IMTSubscription sub = acc.CreateSubscription(po.ID, eff);
			//sub.Save();
      Assert.Catch(delegate { sub.Save(); });

		}

		[Test]
    public void T35_TestNonBatchIndividualSubscriptionForCompatibleAccountType()
		{
			try
			{
				//get product offering
				PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
				//should be 1
				Assert.AreEqual(1, rs.RecordCount);
				PC.IMTPCAccount acc = mPC.GetAccount(Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(62)));
				PC.MTPCTimeSpan eff = new PC.MTPCTimeSpanClass();
				eff.StartDate = MetraTime.Now;
				eff.SetEndDateNull();

				PC.IMTSubscription sub = acc.CreateSubscription(po.ID, eff);
				sub.Save();
			}
			catch(Exception)
			{
				throw;
			}
		}

		[Test]
    public void T36_TestBatchIndividualSubscriptionForPartiallyIncompatibleAccountTypes()
		{
			try
			{
				PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
				//should be 1
				Assert.AreEqual(1, rs.RecordCount);
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 70; i < 80; i++)
				{
					PC.MTSubInfo member = new PC.MTSubInfoClass();
					int id_acc = -1;
					if(i % 5 == 0)
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(i));
					else
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(i));

					int id_corporate =  Utils.GetSubscriberAccountID(Utils.GenerateCorporateAccountName());

					member.PutAll(	id_acc, 
													id_corporate, 
													-1, 
													MetraTime.Now, 
													PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE,
													MetraTime.Now.AddDays(100),
													PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE,
													po.ID,
													false, 
													-1);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset errrs = (PC.IMTSQLRowset)mPC.SubscribeAccounts(members, null, out mod, null);
				Assert.AreEqual(2, errrs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T37_TestBatchIndividualSubscriptionForIncompatibleAccountTypes()
		{
			try
			{
				PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
				//should be 1
				Assert.AreEqual(1, rs.RecordCount);
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 80; i < 90; i++)
				{
					PC.MTSubInfo member = new PC.MTSubInfoClass();
					int id_acc = -1;
					
					id_acc = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(i));
					
					int id_corporate =  Utils.GetSubscriberAccountID(Utils.GenerateCorporateAccountName());

					member.PutAll(	id_acc, 
						id_corporate, 
						-1, 
						MetraTime.Now, 
						PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE,
						MetraTime.Now.AddDays(100),
						PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE,
						po.ID,
						false, 
						-1);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset errrs = (PC.IMTSQLRowset)mPC.SubscribeAccounts(members, null, out mod, null);
				Assert.AreEqual(10, errrs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T38_TestBatchIndividualSubscriptionForCompatibleAccountTypes()
		{
			try
			{
				PC.IMTProductOffering po = mPC.GetProductOfferingByName(Utils.GeneratePOName());
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)po.GetSubscribableAccountTypesAsRowset();
				//should be 1
				Assert.AreEqual(1, rs.RecordCount);
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 90; i < 95; i++)
				{
					PC.MTSubInfo member = new PC.MTSubInfoClass();
					int id_acc = -1;
					
					id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(i));
					
					int id_corporate =  Utils.GetSubscriberAccountID(Utils.GenerateCorporateAccountName());

					member.PutAll(	id_acc, 
						id_corporate, 
						-1, 
						MetraTime.Now, 
						PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE,
						MetraTime.Now.AddDays(100),
						PC.MTPCDateType.PCDATE_TYPE_ABSOLUTE,
						po.ID,
						false, 
						-1);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset errrs = (PC.IMTSQLRowset)mPC.SubscribeAccounts(members, null, out mod, null);
				Assert.AreEqual(0, errrs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		/// <summary>
		/// Test duplicate member entries
		/// </summary>
		/// 
		[Test]
    public void T39_TestBatchGroupSubscriptionForPartiallyDuplicateEntries()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 96; i <	101; i++)
				{
					PC.MTGSubMember member = new PC.MTGSubMemberClass();
					int id_acc = -1;
					if(i % 5 == 0)
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(i-1));
					else
						id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(i));

					member.AccountID = id_acc;

					member.StartDate = MetraTime.Now.AddDays(1);
					member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
				Assert.AreEqual(2, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		/// <summary>
		/// Test duplicate member entries
		/// </summary>
		/// 
		[Test]
    public void T40_TestBatchGroupSubscriptionForDuplicateEntries()
		{
			try
			{
				PC.IMTGroupSubscription gs = mPC.GetGroupSubscriptionByName(MetraTime.Now, Utils.GenerateGSubName());
				PC.IMTCollection members = (MetraTech.Interop.MTProductCatalog.IMTCollection)new Coll.MTCollectionClass();
				for (int i = 10; i < 50; i++)
				{
					PC.MTGSubMember member = new PC.MTGSubMemberClass();
					int id_acc = -1;
					
					id_acc = Utils.GetSubscriberAccountID(Utils.GenerateGSMUserName(10));

					member.AccountID = id_acc;

					member.StartDate = MetraTime.Now.AddDays(1);
					member.EndDate = MetraTech.MetraTime.Now.AddDays(100);
					members.Add(member);
				}
				bool mod;
				PC.IMTSQLRowset rs = (PC.IMTSQLRowset)gs.AddAccountBatch(members, null, out mod, null);
				Assert.AreEqual(40, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}



	}
	

}

