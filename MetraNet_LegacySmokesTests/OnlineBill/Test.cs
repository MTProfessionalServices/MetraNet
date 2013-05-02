using System.Runtime.InteropServices;
using System.Threading;

[assembly: GuidAttribute("b6ac76f7-dd18-4580-9538-715c46bb64ff")]

namespace MetraTech.OnlineBill.Test
{
	using System;
	using System.Collections;

	using NUnit.Framework;
	using MetraTech.Test;

	using MetraTech.Interop.MTProductCatalog;
	using MetraTech.Interop.MTAuth;
	using MetraTech.Interop.MTYAAC;

  using MetraTech.OnlineBill;

  /// <summary>
  ///   Unit Tests for MetraTech.OnlineBill.
  ///   
  ///   To run the this test fixture:
  //    nunit-console /fixture:MetraTech.OnlineBill.Test.SmokeTest /assembly:O:\debug\bin\MetraTech.OnlineBill.Test.dll
 /// </summary>
  [Category("NoAutoRun")]
  [TestFixture]
	public class SmokeTest
	{
		private string mTestId;
		private string [] mUsernamesForNormalSubscription;
		private string [] mUsernamesForGroupSubscription;
		private string [] mUsernamesForPaymentRedirection;
		private string nm_po = "AudioConferencing - MetraView Smoke Test";
		private string msCorporateAccount = "Acme";

		//[Test]
		//	[Ignore("ignore")]
		public void TestPropertyBag()
		{
			PropertyBag config = new PropertyBag();

			config.Initialize("SmokeTest");
			object temp=config["TestID"];
			
		}

		[Test]
    public void T01SetupTestEnvironment()
		{
			PropertyBag config = new PropertyBag();

			config.Initialize("SmokeTest");

			mTestId=config["TestID"].ToString();

			mUsernamesForNormalSubscription=config["NormalSubscriptionUserNameList"].ToString().Split(',');
			if (mUsernamesForNormalSubscription.Length==0)
			{
				throw new ApplicationException("The NormalSubscriptionUserNameList property bag value is empty or not in the correct format.");
			}

			mUsernamesForPaymentRedirection=config["PaymentRedirectionUserNameList"].ToString().Split(',');
			if (mUsernamesForPaymentRedirection.Length==0)
			{
				throw new ApplicationException("The PaymentRedirectionUserNameList property bag value is empty or not in the correct format.");
			}

			mUsernamesForGroupSubscription=config["GroupSubscriptionUserNameList"].ToString().Split(',');
			if (mUsernamesForPaymentRedirection.Length==0)
			{
				throw new ApplicationException("The GroupSubscriptionUserNameList property bag value is empty or not in the correct format.");
			}

			try
			{
				//  metratime = 06/01/2003 10:30:00
				MetraTech.MetraTime.Now = new DateTime(2003, 06, 01, 10, 30, 00);
				
				SetupProductCatalog();
				SetupGroupSubscriptions();
				SetupNormalSubscriptions();
				SetupPaymentRedirection();
			}
			finally
			{
				MetraTech.MetraTime.Reset();
			}
		}
	
		private MetraTech.Interop.MTYAAC.IMTSessionContext GetContext()
		{
			MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			sa.Initialize();
			
			MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			accessData = sa.FindAndReturnObject("SuperUser");
			string suName = accessData.UserName;
			string suPassword = accessData.Password;
			
			IMTLoginContext login = new MTLoginContext();
			return (MetraTech.Interop.MTYAAC.IMTSessionContext) login.Login(suName, "system_user", suPassword);
		}

    public void SetupProductCatalog()
		{
			TestLibrary.Trace("Setting Up Product Catalog");

			
			//string nm_po = "Friday AudioConferencing - MetraView Smoke Test";

			IMTProductCatalog pc = new MTProductCatalog();
			IMTProductOffering po;
			po = pc.GetProductOfferingByName(nm_po);
			
			if (po==null)
			{
				TestLibrary.Trace("Importing Product Offering: {0}", nm_po);
				TestLibrary.ImportPO(TestLibrary.TestDatabaseFolder + @"\Development\UI\Application Tests\MetraView\AudioConferencingPO.xml");
			}
			else
			{
				TestLibrary.Trace("Product Offering \"{0}\" already exists. No need to import again.", nm_po);
			}

			//TestLibrary.ImportPO(TestLibrary.TestDatabaseFolder + @"Development\AggregateRating\PO-AggMovieWeekly.xml");
		}

    public void SetupNormalSubscriptions()
		{

			IMTAccountCatalog ac = new MTAccountCatalog();
			MetraTech.Interop.MTYAAC.IMTSessionContext ctx = GetContext();
			//	(MetraTech.Interop.MTYAAC.IMTSessionContext) login.Login(suName, "system_user", suPassword);
			
			ac.Init(ctx);
			
			IMTProductCatalog pc = new MTProductCatalog();
			IMTProductOffering po;
			pc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) ctx);

			po = pc.GetProductOfferingByName(nm_po);

			IMTPCTimeSpan timespan = new MTPCTimeSpan();
			timespan.StartDate = MetraTech.MetraTime.Now;
			timespan.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;

			timespan.SetEndDateNull();
			
			MetraTech.Interop.MTYAAC.IMTYAAC yaac;
			IMTPCAccount acct;
			
			object modified;

			foreach (string sUsername in mUsernamesForNormalSubscription)
			{
				try
				{
					yaac = ac.GetAccountByName(sUsername + mTestId, "mt", MetraTech.MetraTime.Now);
				}
				catch (COMException err)
				{
					string temp = string.Format("Unable to find account \"{0}\" using date of {1} so it could be subscribed to. Error:{2}", sUsername + mTestId, MetraTech.MetraTime.Now, err.ToString());
					TestLibrary.Trace(temp);
					throw new ApplicationException("The accounts do not appear to be setup correctly. " + temp);
				}

				try
				{
					acct = pc.GetAccount(yaac.AccountID);
					acct.Subscribe(po.ID, (MTPCTimeSpan) timespan, out modified);
				}
				catch (COMException err)
				{
					TestLibrary.Trace("Unable to subscribe account {0}(Id:{1}) to product offering \"{2}\"(Id:{3}) using start date of {4}. Error:{5}", sUsername + mTestId, yaac.AccountID, nm_po, po.ID, timespan.StartDate, err.ToString());
					//We'll continue on because the subscription may already exist
				}

			}
		}

    public void SetupPaymentRedirection()
		{
			//MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
			//sa.Initialize();

			//MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
			//accessData = sa.FindAndReturnObject("SuperUser");
			//string suName = accessData.UserName;
			//string suPassword = accessData.Password;

			IMTAccountCatalog ac = new MTAccountCatalog();
			//IMTLoginContext login = new MTLoginContext();
			
			
			MetraTech.Interop.MTYAAC.IMTSessionContext ctx = GetContext();
			ac.Init(ctx);
			
			MetraTech.Interop.MTYAAC.IMTYAAC yaac;
			MetraTech.Interop.MTYAAC.IMTYAAC yaacPayer;
			//IMTPCAccount acct;
			//object modified;

			string sPayerName = "BeanCounter";

			try
			{
				yaacPayer = ac.GetAccountByName(sPayerName + mTestId, "mt", MetraTech.MetraTime.Now);
			}
			catch (COMException err)
			{
				string temp = string.Format("Unable to find account \"{0}\" using date of {1} so it could pay for accounts. Error:{2}", sPayerName + mTestId, MetraTech.MetraTime.Now, err.ToString());
				TestLibrary.Trace(temp);
				throw new ApplicationException("The accounts do not appear to be setup correctly. " + temp);
			}


			MetraTech.Interop.MTYAAC.IMTPaymentMgr PaymentMgr = yaacPayer.GetPaymentMgr();

			
			foreach (string sUsername in mUsernamesForPaymentRedirection)
			{
				try
				{
					yaac = ac.GetAccountByName(sUsername + mTestId, "mt", MetraTech.MetraTime.Now);
				}
				catch (COMException err)
				{
					string temp = string.Format("Unable to find account \"{0}\" using date of {1} so it could have its payer assigned. Error:{2}", sUsername + mTestId, MetraTech.MetraTime.Now, err.ToString());
					TestLibrary.Trace(temp);
					throw new ApplicationException("The accounts do not appear to be setup correctly. " + temp);
				}

				try
				{
					PaymentMgr.PayForAccount(yaac.AccountID, MetraTech.MetraTime.Now,null);
				}
				catch (COMException err)
				{
					TestLibrary.Trace("Unable to have {0}(Id:{1}) pay for account {2}(Id:{3}) using start date of {4}. Error:{5}",sPayerName+mTestId, yaacPayer.AccountID, sUsername + mTestId, yaac.AccountID, MetraTech.MetraTime.Now, err.ToString());
					//We'll continue on because the subscription may already exist
				}

			}



		}

    public void SetupGroupSubscriptions()
		{

			IMTAccountCatalog ac = new MTAccountCatalog();
	
			
			MetraTech.Interop.MTYAAC.IMTSessionContext ctx = GetContext();
			
			ac.Init(ctx);
			
			MetraTech.Interop.MTYAAC.IMTYAAC yaac;
			try
			{
				yaac = ac.GetAccountByName(msCorporateAccount + mTestId, "mt", MetraTech.MetraTime.Now);
			}
			catch (COMException err)
			{
				string temp = string.Format("Unable to find account \"{0}\" using date of {1} so it be used to create a group subscription. Error:{2}", msCorporateAccount + mTestId, MetraTech.MetraTime.Now, err.ToString());
				TestLibrary.Trace(temp);
				throw new ApplicationException("The accounts do not appear to be setup correctly. " + temp);
			}

			IMTGroupSubscription groupSub;

			try
			{
				IMTProductCatalog pc = new MTProductCatalog();
				IMTProductOffering po;
				pc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext) ctx);

				po = pc.GetProductOfferingByName(nm_po);

				IMTPCTimeSpan timespan = new MTPCTimeSpan();
				timespan.StartDate = MetraTech.MetraTime.Now;
				timespan.StartDateType = MTPCDateType.PCDATE_TYPE_ABSOLUTE;

				timespan.SetEndDateNull();

				groupSub = pc.CreateGroupSubscription();

				groupSub.EffectiveDate = (MTPCTimeSpan) timespan;
				groupSub.ProductOfferingID = po.ID;

				groupSub.Name = "MetraView Smoketest Group Subscription " + mTestId;
				groupSub.Description = "MetraView Smoketest Group Subscription " + mTestId;
		
				groupSub.SupportGroupOps = true;
		
				groupSub.CorporateAccount = yaac.AccountID;
				groupSub.DistributionAccount = yaac.AccountID;

				MTPCCycle cycle = new MTPCCycle();
				cycle.CycleTypeID = 1;
				cycle.EndDayOfMonth = 1;
				groupSub.Cycle=cycle;

				groupSub.Save();
			}
			catch (COMException err)
			{
				string temp = string.Format("Unable to create group subscription for corporate account \"{0}\" using date of {1}. Error:{2}", msCorporateAccount + mTestId, MetraTech.MetraTime.Now, err.ToString());
				TestLibrary.Trace(temp);
				throw new ApplicationException(temp);
			}

			
			foreach (string sUsername in mUsernamesForGroupSubscription)
			{
				try
				{
					yaac = ac.GetAccountByName(sUsername + mTestId, "mt", MetraTech.MetraTime.Now);
				}
				catch (COMException err)
				{
					string temp = string.Format("Unable to find account \"{0}\" using date of {1} so it could be subscribed to in Group Subscription. Error:{2}", sUsername + mTestId, MetraTech.MetraTime.Now, err.ToString());
					TestLibrary.Trace(temp);
					throw new ApplicationException("The accounts do not appear to be setup correctly. " + temp);
				}

				MTGSubMember subMember = new MTGSubMember();

				try
				{
					subMember.AccountID = yaac.AccountID;
					subMember.StartDate = MetraTech.MetraTime.Now;
					//subMember.EndDate = null;	
					groupSub.AddAccount(subMember);
					TestLibrary.Trace("Added {0} to group subscription", sUsername + mTestId);
				}
				catch (COMException err)
				{
					TestLibrary.Trace("Unable to add account {0}(Id:{1}) to group subscription Id:{2}) using start date of {3}. Error:{4}", sUsername + mTestId, yaac.AccountID, groupSub.GroupID, subMember.StartDate, err.ToString());
					//We'll continue on because the subscription may already exist
				}

			}
		}

	}
}
