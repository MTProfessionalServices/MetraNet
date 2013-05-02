using System;
using System.Runtime.InteropServices;
using System.Collections;
using System.Diagnostics;
using System.Data;

using MetraTech.Test;
using MetraTech.Test.Common;
using NUnit.Framework;
//using NUnit.Framework.Extensions;

using PC = MetraTech.Interop.MTProductCatalog;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop;
using RS = MetraTech.Interop.Rowset;
using MetraTech.DataAccess;
using YAAC = MetraTech.Interop.MTYAAC;
using ServerAccess = MetraTech.Interop.MTServerAccess;
using Coll = MetraTech.Interop.GenericCollection;
using MetraTech.Interop.COMMeter;
using PipelineTransaction = MetraTech.Interop.PipelineTransaction;

namespace MetraTech.Accounts.Test.MoveAccountTestPlan
{
  [Category("NoAutoRun")]
  [TestFixture]
  public class MoveAccountTestPlan
  {
    private PC.MTProductCatalog mPC;
    private YAAC.IMTAccountCatalog mAccCatalog;
    private IMTSessionContext mSUCtx = null;
    private string mSuffix = "";
    private string mCorp = "";
    private string mDeptA = "";
    private string mDeptB = "";
    private DateTime mCurrentDate;
    private DateTime mCheckDate1;
    private DateTime mCheckDate2;

    // Setup basic items needed by the test such as Product Catalog object, 
    // security context, Account Catalog, and set metratime to now.
    public MoveAccountTestPlan()
    {
      Utils.TurnTraceOn();
      Utils.Trace("Starting MoveAccountTestPlan...");

      mPC = new PC.MTProductCatalogClass();
      mAccCatalog = new YAAC.MTAccountCatalog();
      mSUCtx = Utils.LoginAsSU();
      mAccCatalog.Init((YAAC.IMTSessionContext)mSUCtx);

      MetraTime.Reset();
      mCurrentDate = MetraTime.Now;
      mCheckDate1 = mCurrentDate;
    }

    /// <summary>
    /// Test setup creates a really simple hierarchy structure of accounts in different billing cycles
    /// </summary>
    [TestFixtureSetUp]
    public void TestCreateHierarchy()
    {
      Utils.Trace("Starting TestCreateHierarchy [TestFixtureSetup]...");

      // Create Corporate Account
      mSuffix = GetSuffix();
      mCorp = "MoveAccountCorp" + mSuffix;
      mDeptA = "DepartmentA" + mSuffix;
      mDeptB = "DepartmentB" + mSuffix;
      Utils.CreateCorporation(mCorp, mCurrentDate);
      
      // Create Subscriber Accounts
      ArrayList subs = new ArrayList();
      subs.Add(new Utils.AccountParameters(string.Format("SUB_DAILY{0}", mSuffix), new Utils.BillingCycle(Utils.CycleType.DAILY, -1)));
      subs.Add(new Utils.AccountParameters(string.Format("SUB_MONTHLY_EOM{0}", mSuffix), new Utils.BillingCycle(Utils.CycleType.MONTHLY, 31)));
      subs.Add(new Utils.AccountParameters(string.Format("SUB_WEEKLY_SUNDAY{0}", mSuffix), new Utils.BillingCycle(Utils.CycleType.WEEKLY, 1)));
      subs.Add(new Utils.AccountParameters(string.Format("SUB_ANNUAL_01_01{0}", mSuffix), new Utils.BillingCycle(Utils.CycleType.ANNUAL, 1)));
      Utils.CreateSubscriberAccounts(mCorp, subs, mCurrentDate);

      // Create Department A Account
      Utils.CreateDepartment(mDeptA, mCorp, mCurrentDate);

      // Create Department B Account
      Utils.CreateDepartment(mDeptB, mCorp, mCurrentDate);
    }

    [TestFixtureTearDown]
    public void ShutdownTest()
    {
      MetraTime.Reset();
    }

    [Test]
    [Category("Run")]
    public void T01Case1()
    {
      Utils.Trace("Starting Case1 [Simple Moves]...");

      // move accounts under dept a
      YAAC.MTYAAC acc = mAccCatalog.GetActorAccount(mCurrentDate);
      YAAC.MTAncestorMgr mgr = acc.GetAncestorMgr();
      mgr.MoveAccount(Utils.GetAccountID(mDeptA), Utils.GetAccountID(string.Format("SUB_DAILY{0}", mSuffix)), mCurrentDate);

      // move dept a under dept b
      mgr.MoveAccount(Utils.GetAccountID(mDeptB), Utils.GetAccountID(mDeptA), mCurrentDate);
     }

    [Test]
    [Category("NegativeTest")]
    [ExpectedException(typeof(System.Runtime.InteropServices.COMException))]
    public void T02AccountTypeNegativeCase()
    {
      Utils.Trace("Starting AccountTypeNegativeCase...");

      YAAC.MTYAAC acc = mAccCatalog.GetActorAccount(mCurrentDate);
      YAAC.MTAncestorMgr mgr = acc.GetAncestorMgr();
  
      // move deptB under sub_daily - error expected
      mgr.MoveAccount(Utils.GetAccountID(string.Format("SUB_WEEKLY_SUNDAY{0}", mSuffix)), Utils.GetAccountID(mDeptB), mCurrentDate);
    }

    [Test]
    [Category("Run")]
    public void T03Case2()
    {
      Utils.Trace("Starting Case2 [Future Moves]...");

      ChangeMetraTimeAddMonths(1);
      mCheckDate2 = mCurrentDate;

      // move accounts under deptA  in future
      YAAC.MTYAAC acc = mAccCatalog.GetActorAccount(mCurrentDate);
      YAAC.MTAncestorMgr mgr = acc.GetAncestorMgr();
      mgr.MoveAccount(Utils.GetAccountID(mDeptA), Utils.GetAccountID(string.Format("SUB_WEEKLY_SUNDAY{0}", mSuffix)), mCurrentDate);
    }

    [Test]
    [Category("Run")]
    public void T04CheckDatabaseValues1()
    {
      Utils.Trace("Starting CheckDatabaseValues1 [Make sure t_account_ancestor looks good]...");

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        string sql = @"select * from t_account_ancestor 
                       where id_descendent = (select id_acc from t_account_mapper where nm_login ='SUB_WEEKLY_SUNDAY%%SUFFIX%%')
                       order by num_generations";

        DataTable dt = null;
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(sql))
        {
            stmt.AddParam("%%SUFFIX%%", mSuffix.ToString());
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
                dt = rdr.GetDataTable();
            }
        }
        //                     id_ancestor                   id_descendent                   num_generations  b_children  vt_start                 vt_end                   tx_path
        string expectedCSV = @"%%SUB_WEEKLY_SUNDAY%%,        %%SUB_WEEKLY_SUNDAY%%,          0,               N,          %%CURRENT_DATE%%, 2038-01-01 00:00:00.000, %%SUB_WEEKLY_SUNDAY%%,
                               %%MOVE_ACCOUNT_CORP%%,        %%SUB_WEEKLY_SUNDAY%%,          1,               N,          %%CURRENT_DATE%%, %%CHECK_DATE3%%, %%MOVE_ACCOUNT_CORP%%/%%SUB_WEEKLY_SUNDAY%%,
                               %%DEPT_A%%,                   %%SUB_WEEKLY_SUNDAY%%,          1,               N,          %%CHECK_DATE2%%, 2038-01-01 00:00:00.000, %%DEPT_A%%/%%SUB_WEEKLY_SUNDAY%%,
                               1   ,                         %%SUB_WEEKLY_SUNDAY%%,          2,               N,          %%CURRENT_DATE%%, %%CHECK_DATE3%%, /%%MOVE_ACCOUNT_CORP%%/%%SUB_WEEKLY_SUNDAY%%,
                               %%DEPT_B%%,                   %%SUB_WEEKLY_SUNDAY%%,          2,               N,          %%CHECK_DATE2%%, 2038-01-01 00:00:00.000, %%DEPT_B%%/%%DEPT_A%%/%%SUB_WEEKLY_SUNDAY%%,
                               %%MOVE_ACCOUNT_CORP%%,        %%SUB_WEEKLY_SUNDAY%%,          3,               N,          %%CHECK_DATE2%%, 2038-01-01 00:00:00.000, %%MOVE_ACCOUNT_CORP%%/%%DEPT_B%%/%%DEPT_A%%/%%SUB_WEEKLY_SUNDAY%%,
                               1   ,                         %%SUB_WEEKLY_SUNDAY%%,          4,               N,          %%CHECK_DATE2%%, 2038-01-01 00:00:00.000, /%%MOVE_ACCOUNT_CORP%%/%%DEPT_B%%/%%DEPT_A%%/%%SUB_WEEKLY_SUNDAY%%";

        expectedCSV = expectedCSV.Replace("%%SUB_WEEKLY_SUNDAY%%", Utils.GetAccountID(string.Format("SUB_WEEKLY_SUNDAY{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%MOVE_ACCOUNT_CORP%%", Utils.GetAccountID(string.Format("MoveAccountCorp{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%DEPT_A%%", Utils.GetAccountID(string.Format("DepartmentA{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%DEPT_B%%", Utils.GetAccountID(string.Format("DepartmentB{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%CURRENT_DATE%%", mCheckDate1.ToString("yyyy-MM-dd") + " 00:00:00.000");
        expectedCSV = expectedCSV.Replace("%%CHECK_DATE2%%", mCheckDate2.ToString("yyyy-MM-dd") + " 00:00:00.000");
        mCheckDate2 = mCheckDate2.AddDays(-1);
        expectedCSV = expectedCSV.Replace("%%CHECK_DATE3%%", mCheckDate2.ToString("yyyy-MM-dd") + " 23:59:59.000");

        CheckDatabaseResults(dt, expectedCSV);  // Compares CSV to DataTable and throws when they don't match

         // Test case for CR15039 (this shouldn't fail)
        sql = @"select * from t_account_ancestor 
                where id_descendent = (select id_acc from t_account_mapper where nm_login ='DepartmentA%%SUFFIX%%')
                order by num_generations";

        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(sql))
        {
            stmt.AddParam("%%SUFFIX%%", mSuffix.ToString());
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
                dt = rdr.GetDataTable();
            }
        }

        //              id_ancestor                   id_descendent                   num_generations  b_children  vt_start                 vt_end                   tx_path
        expectedCSV = @"%%DEPT_A%%,                   %%DEPT_A%%,          0,               Y,          %%CURRENT_DATE%%, 2038-01-01 00:00:00.000, %%DEPT_A%%,
                        %%DEPT_B%%,                   %%DEPT_A%%,          1,               Y,          %%CURRENT_DATE%%, 2038-01-01 00:00:00.000, %%DEPT_B%%/%%DEPT_A%%,
                        %%MOVE_ACCOUNT_CORP%%,        %%DEPT_A%%,          2,               Y,          %%CURRENT_DATE%%, 2038-01-01 00:00:00.000, %%MOVE_ACCOUNT_CORP%%/%%DEPT_B%%/%%DEPT_A%%,
                        1,                            %%DEPT_A%%,          3,               Y,          %%CURRENT_DATE%%, 2038-01-01 00:00:00.000, /%%MOVE_ACCOUNT_CORP%%/%%DEPT_B%%/%%DEPT_A%%";

        expectedCSV = expectedCSV.Replace("%%SUB_WEEKLY_SUNDAY%%", Utils.GetAccountID(string.Format("SUB_WEEKLY_SUNDAY{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%MOVE_ACCOUNT_CORP%%", Utils.GetAccountID(string.Format("MoveAccountCorp{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%DEPT_A%%", Utils.GetAccountID(string.Format("DepartmentA{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%DEPT_B%%", Utils.GetAccountID(string.Format("DepartmentB{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%CURRENT_DATE%%", mCheckDate1.ToString("yyyy-MM-dd") + " 00:00:00.000");
        expectedCSV = expectedCSV.Replace("%%CHECK_DATE2%%", mCheckDate2.ToString("yyyy-MM-dd") + " 00:00:00.000");
        mCheckDate2 = mCheckDate2.AddDays(-1);
        expectedCSV = expectedCSV.Replace("%%CHECK_DATE3%%", mCheckDate2.ToString("yyyy-MM-dd") + " 23:59:59.000");

        CheckDatabaseResults(dt, expectedCSV);
 
      }
    }

    [Test]
    [Category("Run")]
    public void T05Case3()
    {
      Utils.Trace("Starting Case3 [Create a new account under future moved folder]...");

      // Create a new Department
      Utils.CreateDepartment("AutoMoveFolder" + mSuffix, mCorp, mCheckDate1);
      
      // Future move of folder
      // move accounts under deptA in future
      YAAC.MTYAAC acc = mAccCatalog.GetActorAccount(mCurrentDate);
      YAAC.MTAncestorMgr mgr = acc.GetAncestorMgr();
      mgr.MoveAccount(Utils.GetAccountID(mDeptA), Utils.GetAccountID(string.Format("AutoMoveFolder{0}", mSuffix)), mCurrentDate);
 
      // Create Subscriber Accounts
      ArrayList subs = new ArrayList();
      subs.Add(new Utils.AccountParameters(string.Format("AutoMovedAccount{0}", mSuffix), new Utils.BillingCycle(Utils.CycleType.DAILY, -1)));
      Utils.CreateSubscriberAccounts("AutoMoveFolder" + mSuffix, subs, mCheckDate1);


      // Check results
      Utils.Trace("Checking Database values for Case3 [Create a new account under future moved folder]...");
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        string sql = @"select * from t_account_ancestor 
                       where id_descendent = (select id_acc from t_account_mapper where nm_login ='AutoMovedAccount%%SUFFIX%%')
                       and num_generations = 5";

        DataTable dt = null;
        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(sql))
        {
            stmt.AddParam("%%SUFFIX%%", mSuffix.ToString());
            using (IMTDataReader rdr = stmt.ExecuteReader())
            {
                dt = rdr.GetDataTable();
            }
        }

        //                     id_ancestor                   id_descendent                   num_generations  b_children  vt_start                 vt_end                   tx_path
        string expectedCSV = @"1, %%AUTO_MOVED_ACCOUNT%%, 5, N, %%CURRENT_DATE%%, 2038-01-01 00:00:00.000, /%%MOVE_ACCOUNT_CORP%%/%%DEPT_B%%/%%DEPT_A%%/%%AUTO_MOVED_FOLDER%%/%%AUTO_MOVED_ACCOUNT%%";

        expectedCSV = expectedCSV.Replace("%%AUTO_MOVED_ACCOUNT%%", Utils.GetAccountID(string.Format("AutoMovedAccount{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%AUTO_MOVED_FOLDER%%", Utils.GetAccountID(string.Format("AutoMoveFolder{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%SUB_WEEKLY_SUNDAY%%", Utils.GetAccountID(string.Format("SUB_WEEKLY_SUNDAY{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%MOVE_ACCOUNT_CORP%%", Utils.GetAccountID(string.Format("MoveAccountCorp{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%DEPT_A%%", Utils.GetAccountID(string.Format("DepartmentA{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%DEPT_B%%", Utils.GetAccountID(string.Format("DepartmentB{0}", mSuffix)).ToString());
        expectedCSV = expectedCSV.Replace("%%CURRENT_DATE%%", mCurrentDate.ToString("yyyy-MM-dd") + " 00:00:00.000");

        CheckDatabaseResults(dt, expectedCSV);
      }
      
    }

      [Test]
    public void T06CreateCorpAccountWithEndDate()
      {
          Utils.Trace("Starting CreateCorpAccountWithEndDate...");
          string CorpName = "MoveAccountCorpEnd" + mSuffix;
          DateTime aStartDate = mCurrentDate;
          DateTime aEndDate = DateTime.Parse("2036-01-01T00:00:00");

          IMeter sdk = null;
          try
          {
              sdk = TestLibrary.InitSDK();
              ISessionSet sessionSet = sdk.CreateSessionSet();
              sessionSet.SessionContext = mSUCtx.ToXML();

              ISession session = sessionSet.CreateSession("metratech.com/accountcreation");
              session.RequestResponse = true;
              session.InitProperty("actiontype", "both");
              session.InitProperty("username", CorpName);
              session.InitProperty("password_", "123");
              session.InitProperty("name_space", "mt");
              session.InitProperty("language", "US");
              session.InitProperty("timezoneID", "18");
              session.InitProperty("taxexempt", "F");
              session.InitProperty("city", "Stalingrad");
              session.InitProperty("state", "MA");
              session.InitProperty("zip", "01451");
              session.InitProperty("usagecycletype", "Monthly");
              session.InitProperty("dayofmonth", "1");
              session.InitProperty("paymentmethod", "1");
              session.InitProperty("InvoiceMethod", "Detailed");
              session.InitProperty("transactioncookie", "");
              session.InitProperty("operation", "Add");
              session.InitProperty("firstname", string.Format("{0} NUnit test, ", "EndDate"));
              session.InitProperty("lastname", aStartDate.ToString() + " GMT");
              session.InitProperty("email", "account@unittest.com");
              session.InitProperty("phonenumber", "781-839-8300");
              session.InitProperty("company", "MetraTech");
              session.InitProperty("address1", "330 Bear Hill Road");
              session.InitProperty("address2", "Third Floor");
              session.InitProperty("address3", "");
              session.InitProperty("country", "USA");
              session.InitProperty("middleinitial", "");
              session.InitProperty("facsimiletelephonenumber", "781-839-8301");
              session.InitProperty("StatusReason", "0");
              session.InitProperty("accountstatus", "AC");
              session.InitProperty("ancestorAccountID", "1");
              session.InitProperty("folder", "T");
              session.InitProperty("billable", "T");
              session.InitProperty("currency", "USD");
              session.InitProperty("accounttype", "CORPORATEACCOUNT");
              session.InitProperty("contacttype", "bill-to");
              session.InitProperty("applydefaultsecuritypolicy", "F");
              session.InitProperty("accountstartdate", aStartDate);
              session.InitProperty("accountenddate", aEndDate);

              try
              {
                  sessionSet.Close();
              }
              catch (COMException err)
              {
                  TestLibrary.Trace(err.ToString());
              }
          }
          finally
          {
              if (sdk != null)
                  Marshal.ReleaseComObject(sdk);
          }
          Utils.Trace("Finished CreateCorpAccountWithEndDate...");
      }



    #region Test Helpers

    // Compares CSV to DataTable and throws when they don't match
    // TODO:  move to shared test location
    public void CheckDatabaseResults(System.Data.DataTable dt, string expectedCSV)
    {
      string[] expectedValues = expectedCSV.Split(new char[] { ',' });
      int i = 0;

      if (dt == null || dt.Rows.Count == 0)
      {
        throw new ApplicationException("No rows returned!  Expected: " + expectedCSV);
      }


      foreach (DataRow row in dt.Rows)
      {
        foreach (DataColumn col in dt.Columns)
        {
          string gotValue = row[col.ColumnName].ToString();
          string expectedValue = expectedValues[i].ToString().Trim();

          if(row[col.ColumnName] is DateTime)
          {
            DateTime dateTime = (DateTime)row[col.ColumnName];
            gotValue = dateTime.ToString("yyyy-MM-dd HH:mm:ss.fff");
          }

          if (expectedValue == gotValue)
          {
            Utils.Trace("Matched expected value: " + gotValue);
          }
          else
          {
            string msg = "Expected value '" + expectedValues[i].ToString().Trim() + "', but got '" + gotValue + "'!";
            Utils.Trace(msg);
            throw new ApplicationException(msg);
          }
          i++;
        }
      }
    }

    // A little registry trick, so we can keep running the test over and over with new account names
    public string GetSuffix()
    {
      int suffix = int.Parse(RegistryHelper.GetKeyValue("AccountSuffix"));
      suffix++;
      RegistryHelper.SetKeyValue("AccountSuffix", suffix.ToString());
      Utils.Trace("New Suffix = " + suffix.ToString());
      return suffix.ToString();
    }

    // Add a number of months to current date (metratime) and store in mCurrentDate.
    private void ChangeMetraTimeAddMonths(int number)
    {
      DateTime newDateTime = mCurrentDate.AddMonths(number);
      Utils.Trace("Changed MetraTime from " + mCurrentDate.ToString() + " to " + newDateTime.ToString());
      MetraTime.Now = newDateTime;
      mCurrentDate = newDateTime;
    }

    #endregion
  }
}