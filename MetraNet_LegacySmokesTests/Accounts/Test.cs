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
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;

namespace MetraTech.Accounts.Test
{
	/// <summary>
	/// Summary description for Test.
	/// </summary>
  [Category("NoAutoRun")]
  
  [TestFixture]
  public class AccountFinderTest
	{
		private PC.MTProductCatalog mPC;
		private YAAC.IMTAccountCatalog mAccCatalog;
		private IMTSessionContext mSUCtx = null;

		public AccountFinderTest()
		{
      try
      {
        Utils.TurnTraceOn();

			  mPC = new PC.MTProductCatalogClass();
			  mAccCatalog = new YAAC.MTAccountCatalog();
			  mSUCtx = Utils.LoginAsSU();
			  mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);
      }
      catch (Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
		}

		[TestFixtureSetUp]
		public void TestCreateHierarchy()
		{
      try
      {
			  Utils.SetupHierarchy("Account");
			  //for the fiorst subscriber generate second namespace mapping
			  string login = Utils.GenerateSubscriberUserName(1);
			  Utils.AddMapping(login, "mt", "ar/external");
      }
      catch (Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
    }

		[Test]
		[Category("Run")]
    public void T01TestFindSelfByID()
		{
      try
      {
        int id = Utils.GetSystemUserAccountID("csr1");
        YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalog();
        IMTSessionContext ctx = Utils.Login1("csr1", "csr123", "system_user");
        cat.Init((YAAC.IMTSessionContext)ctx);
        YAAC.IMTSQLRowset rs = cat.FindAccountByIDAsRowset(MetraTime.Now, id, null);
        Assert.AreEqual(1, rs.RecordCount);
      }
      catch (Exception e)
      {
        Utils.Trace(e.Message); throw;
      }
		}

		[Test]
    public void T02TestAccountLoaderForCSRByName()
		{
			YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByNameAsRowset(MetraTime.Now, "csr1", "system_user", null);
			Assert.AreEqual(1, rs.RecordCount);
		}
		
		[Test]
    public void T03TestAccountLoaderByIDWithTransaction()
		{
      MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
              new MetraTech.Interop.PipelineTransaction.CMTTransaction();
      try
			{
				transaction.Begin("Account Test", 600 * 1000);

				int id = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1));
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByIDAsRowset(MetraTime.Now, id, transaction.GetTransaction());
				Assert.AreEqual(1, rs.RecordCount);
				transaction.Commit();
			}
			catch(Exception e)
			{
        transaction.Rollback();
				Utils.Trace(e.Message); throw;
			}
		}
		[Test]
    public void T04TestAccountLoaderByIDNoTransaction()
		{
			int tz = -1;
			try
			{
				int id = Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1));
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByIDAsRowset(MetraTime.Now, id, null);
				Assert.AreEqual(1, rs.RecordCount);
				tz = (int)rs.get_Value("timezoneid");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		[Test]
    public void T05TestAccountLoaderByNameWithTransaction()
		{
			int tz = -1;
			MetraTech.Interop.PipelineTransaction.IMTTransaction transaction =
          					new MetraTech.Interop.PipelineTransaction.CMTTransaction();
      try
      {
        transaction.Begin("Account Test", 600 * 1000);
			  string login = Utils.GenerateSubscriberUserName(1);
			  YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByNameAsRowset(MetraTime.Now, login, "mt", transaction.GetTransaction());
			  tz = (int)rs.get_Value("timezoneid");
			  Assert.AreEqual(1, rs.RecordCount);
			  transaction.Commit();
			}
			catch(Exception e)
			{
        transaction.Rollback();
				Utils.Trace(e.Message); throw;
			}
		}
		[Test]
    public void T06TestAccountLoaderByNameNoTransaction()
		{
			try
			{
				string login = Utils.GenerateSubscriberUserName(1);
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByNameAsRowset(MetraTime.Now, login, "mt", null);
				Assert.AreEqual(1, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T07TestFutureAccountLoaderByIDNoTransaction()
		{
			int tz = -1;
			try
			{
				DateTime refdate = MetraTime.Now.AddMonths(1);
				IMTSessionContext ctx = Utils.LoginAsSU();
				YAAC.IMTAccountCatalog cat = new YAAC.MTAccountCatalogClass();
				cat.Init((MetraTech.Interop.MTYAAC.IMTSessionContext)ctx);
				YAAC.IMTYAAC acc = cat.GetAccountByName(Utils.GenerateSubscriberUserName(101), "mt", refdate);
				int id = acc.AccountID;
				
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByIDAsRowset(refdate, id, null);
				Assert.AreEqual(1, rs.RecordCount);
				tz = (int)rs.get_Value("timezoneid");
			}
			catch (Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		[Test]
    public void T08TestFutureAccountLoaderByNameNoTransaction()
		{
			try
			{
				string login = Utils.GenerateSubscriberUserName(101);
				DateTime refdate = MetraTime.Now.AddMonths(1);
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByNameAsRowset(refdate, login, "mt", null);
				Assert.AreEqual(1, rs.RecordCount);
			}
			catch (Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
		[Category("Multimap")]
    public void T09TestAccountLoaderByNameMultipleMappings()
		{
			try
			{
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("_NameSpaceType", eq, "system_mps");

				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountByNameAsRowset(MetraTime.Now, Utils.GenerateSubscriberUserName(1), "mt", null);
				Assert.AreEqual(1, rs.RecordCount);
			}
			catch (Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		
		[Test]
    public void T10TestFindSubscribers()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType like = RS.MTOperatorType.OPERATOR_TYPE_LIKE_W;
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("_NameSpaceType", eq, "system_mps");
				filter.Add("_PayerAccountNSType", eq, "system_mps");
				filter.Add("UserName", like, string.Format("%{0}", Utils.GetTestId()));
				filter.Add("AccountTypeName", eq, "CORESUBSCRIBER");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.AreEqual(100, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
		[Category("thisone")]
    public void T11TestFindSubscribersByAccountID()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
			
				filter.Add("AccountTypeName", eq, "CORESUBSCRIBER");
				filter.Add("_AccountID", eq,  Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1)));
				filter.Add("_NameSpaceType", eq, "system_mps");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.AreEqual(1, rs.RecordCount);

				object inv = rs.get_Value("InvoiceMethod");
				Assert.IsTrue(inv != null);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
		
		[Test]
    public void T12TestFindNotSubscribable()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("username", eq, "csr1");
				filter.Add("CanSubscribe", eq, false);
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);

        //csr1 is non subscribable
				Assert.AreEqual(1, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T13TestFindAllGSMAccounts()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				RS.MTOperatorType like = RS.MTOperatorType.OPERATOR_TYPE_LIKE_W;
				filter.Add("AccountTypeName", eq, "GSMSERVICEACCOUNT");
				filter.Add("UserName", like, string.Format("%{0}", Utils.GetTestId()));
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.AreEqual(100, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T14TestFindAllGSMAccountsSelectedProperties()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				columns.Add("IMSI");
				columns.Add("MSISDN");
				columns.Add("MIN");
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				RS.MTOperatorType like = RS.MTOperatorType.OPERATOR_TYPE_LIKE_W;
				filter.Add("AccountTypeName", eq, "GSMSERVICEACCOUNT");
				filter.Add("UserName", like, string.Format("%{0}", Utils.GetTestId()));
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.AreEqual(100, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
		//Find GSM account (extended properties live in metratech.com/GSM)
    public void T15TestFindGSMAccountsWithExtendedProperties()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("AccountTypeName", eq, "GSMSERVICEACCOUNT");
				filter.Add("MSISDN", eq, "12345MSIDN");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				//Assert.(rs.RecordCount > 0);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T16TestFindSubsetOfAccountViewsForGSMAccountsByAccountType()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("AccountTypeName", eq, "GSMSERVICEACCOUNT");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.IsTrue(rs.RecordCount > 0, "Rowset record count");
				//test some property from t_av_internal
				object billable = rs.get_Value("billable");
				//test some property from t_av_GSM
				object msisdn = rs.get_Value("MSISDN");
				Assert.IsTrue(msisdn != null);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
		[ExpectedException(typeof(System.Runtime.InteropServices.COMException))]
    public void T17TestFindSubsetOfAccountViewsForGSMAccountsByAccountType1()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("AccountTypeName", eq, "GSMSERVICEACCOUNT");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.IsTrue(rs.RecordCount > 0, "Rowset record count");
				//GSM accounts have no t_av_contact association - return error
				string firstname = (string)rs.get_Value("firstname");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
			//Find GSM account (extended properties live in metratech.com/GSM)
    public void T18TestFindSubsetOfAccountViewsForGSMAccountsByProperty()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("MSISDN", eq, "123_MSISDN_1");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.IsTrue( rs.RecordCount > 0, "Rowset record count");
				//test some property from t_av_internal
				object billable = rs.get_Value("billable");
				//test some property from t_av_GSM
				string msisdn = (string)rs.get_Value("MSISDN");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
		[ExpectedException(typeof(System.Runtime.InteropServices.COMException))]
    public void T19TestFindSubsetOfAccountViewsForGSMAccountsByProperty1()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("MSISDN", eq, "123_MSISDN_1");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.IsTrue( rs.RecordCount > 0, "Rowset record count");
				//GSM accounts have no t_av_contact association - return error
				string firstname = (string)rs.get_Value("firstname");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
			//Find GSM account (extended properties live in metratech.com/GSM)
    public void T20TestFindSubsetOfAccountViewsByMultipleProperties()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("MSISDN", eq, "123_MSISDN_1");
				filter.Add("billable", eq, "0");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				//test some property from t_av_internal
				object billable = rs.get_Value("billable");
				//test some property from t_av_GSM
				string msisdn = (string)rs.get_Value("MSISDN");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
		//search for subscriber account utilizing GSM properties
		//Right now it won't return anything - but no error
    public void T21TestFindSubscriberAccountWithGSMExtendedProperties()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("AccountTypeName", eq, "CORESUBSCRIBER");
				filter.Add("MSISDN", eq, "12345MSIDN");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				//csr1 is non subscribable
				Assert.AreEqual(0, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
			//search for subscriber account utilizing GSM properties
			//Right now it won't return anything - but no error
    public void T22TestFindSubscriberAndGSMAccountsWithGSMExtendedProperties()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType @in = RS.MTOperatorType.OPERATOR_TYPE_IN;
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("AccountTypeName", @in, "'CORESUBSCRIBER', 'GSMSERVICEACCOUNT'");
				filter.Add("MSISDN", eq, "12345MSIDN");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);

				//csr1 is non subscribable
				//Assert.AreEqual(0, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		//search for subscriber account utilizing GSM properties
		//Right now it won't return anything - but no error
    [Test]
    public void T23TestFindRelevantProperties()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType @in = RS.MTOperatorType.OPERATOR_TYPE_IN;
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("AccountTypeName", @in, "'CORPORATEACCOUNT','CORESUBSCRIBER','DEPARTMENTACCOUNT','INDEPENDENTACCOUNT'");
				filter.Add("_AccountID", eq,  Utils.GetSubscriberAccountID(Utils.GenerateSubscriberUserName(1)));
				filter.Add("_NameSpaceType", eq, "system_mps");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);

				Assert.AreEqual(1, rs.RecordCount);

				//see that relevant properties came back
				object inv = rs.get_Value("InvoiceMethod");
				object fn = rs.get_Value("FirstName");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		// Find account by pricelist name
    [Test]
    public void T24TestFindByPricelist()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("PricelistName", eq, "Some pricelist name");
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);

				Assert.AreEqual(0, rs.RecordCount);
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T25TestGetDescedentsOfType_NoTypePredicate()
		{
			YAAC.IMTYAAC acc = Utils.GetSubscriberAccount(Utils.GenerateCorporateAccountName());
			YAAC.IMTCollection descendents = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			acc.GetDescendents(descendents, 
				MetraTime.Now, 
				YAAC.MTHierarchyPathWildCard.RECURSIVE, 
				true,
				System.Reflection.Missing.Value);
			Assert.AreEqual(201, descendents.Count, "Corporation should have 200 descendent accounts!");
		}

		[Test]
    public void T26TestGetDescedentsOfType_EmptyTypePredicateColl()
		{
			YAAC.IMTYAAC acc = Utils.GetSubscriberAccount(Utils.GenerateCorporateAccountName());
			YAAC.IMTCollection descendents = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			YAAC.IMTCollection acctypenames = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			acc.GetDescendents(descendents, 
				                  MetraTime.Now, 
				                  YAAC.MTHierarchyPathWildCard.RECURSIVE, 
				                  true,
				                  acctypenames);
			Assert.AreEqual(201, descendents.Count, "Corporation should have 201 descendent accounts (including self)!");
		}

		[Test]
    public void T27TestGetDescedentsOfType_1TypePredicate()
		{
			YAAC.IMTYAAC acc = Utils.GetSubscriberAccount(Utils.GenerateCorporateAccountName());
			YAAC.IMTCollection descendents = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			YAAC.IMTCollection acctypenames = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			acctypenames.Add("CORESUBSCRIBER");
			acc.GetDescendents(descendents, 
				                MetraTime.Now, 
				                YAAC.MTHierarchyPathWildCard.RECURSIVE, 
				                true,
				                acctypenames);
			Assert.AreEqual(100, descendents.Count, "Corporation should have 100 'CORESUBSCRIBER' descendent accounts!");
		}
		[Test]
    public void T28TestGetDescedentsOfType_2TypePredicates()
		{
			YAAC.IMTYAAC acc = Utils.GetSubscriberAccount(Utils.GenerateCorporateAccountName());
			YAAC.IMTCollection descendents = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			YAAC.IMTCollection acctypenames = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			acctypenames.Add("CORESUBSCRIBER");
			acctypenames.Add("GSMSERVICEACCOUNT");
			acc.GetDescendents(descendents, 
				                  MetraTime.Now, 
				                  YAAC.MTHierarchyPathWildCard.RECURSIVE, 
				                  true,
				                  acctypenames);
			Assert.AreEqual(200, descendents.Count, "Corporation should have 200 descendent accounts!");
		}

		[Test]
		[ExpectedException(typeof(System.Runtime.InteropServices.COMException))]
    public void T29TestNoBillingGroupIDIfNoBillingGroupPredicate()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType like = RS.MTOperatorType.OPERATOR_TYPE_LIKE_W;
				filter.Add("username", like, "%a%");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);
				Assert.IsTrue(rs.RecordCount > 0, "Rowset record count");
				int bgid = (int)rs.get_Value("BillingGroupID");
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}

		[Test]
    public void T30TestFinder_WithBillingGroupID()
		{
			//it is important for the columns collection to be NULL. Finder does not like empty collection
			YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
			YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
			YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
			RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
			filter.Add("BillingGroupID", eq, 123456);
			object out1;
			YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);

			Assert.AreEqual(0, rs.RecordCount);
		}

    [Test]
    // Find an account using an enum property (here Country)
    public void T31TestFindWithEnumFilter()
		{
			try
			{
				//it is important for the columns collection to be NULL. Finder does not like empty collection
				YAAC.IMTCollection columns = null;//(YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTCollection order = (YAAC.IMTCollection)new Coll.MTCollectionClass();
				YAAC.IMTDataFilter filter = (YAAC.IMTDataFilter)new RS.MTDataFilterClass();
				RS.MTOperatorType eq = RS.MTOperatorType.OPERATOR_TYPE_EQUAL;
				filter.Add("Country", eq, "USA");
				
				//"_NameSpaceType" , MT_OPERATOR_TYPE_EQUAL , NameSpaceType
				object out1;
				YAAC.IMTSQLRowset rs = mAccCatalog.FindAccountsAsRowset(MetraTime.Now, columns, filter, null, null, 100, out out1, null);

        // Should be some matches (we really don't know how many).  Each should have the correct enum
        // value for country (which is the ISO country code for USA=208).
        while (!System.Convert.ToBoolean(rs.EOF))
        {
            Assert.AreEqual(208, (int) rs.get_Value("Country"));
            rs.MoveNext();
        }
			}
			catch(Exception e)
			{
				Utils.Trace(e.Message); throw;
			}
		}
	}
}