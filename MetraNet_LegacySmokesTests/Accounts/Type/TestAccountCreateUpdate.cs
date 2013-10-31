
// nunit-console /assembly:MetraTech.Accounts.Type.Test.dll /fixture:MetraTech.Accounts.Type.Test.TestCreateUpdateAccounts
using System.Runtime.InteropServices;
using System.EnterpriseServices;


namespace MetraTech.Accounts.Type.Test
{
  using System;
  using NUnit.Framework;
  using MetraTech.Test;
  using MTAccountType = MetraTech.Interop.IMTAccountType;
  using MetraTech.Interop.COMMeter;
  using MetraTech.DataAccess;
  using System.Collections;
  using System.Collections.Specialized;

  [Category("NoAutoRun")]
  [TestFixture]
  public class TestCreateUpdateAccounts
  {

    private IMeter sdk;
    private string suffix;
    private string corpAccount;
    private string deptAccount;
    private string subAccount;
    private string subAccount2;
    private string GSMAcct;
    private string systemAccount;
    private string suName;
    private string suPassword;

    public TestCreateUpdateAccounts()
    {
      sdk = TestLibrary.InitSDK();
      suffix = DateTime.Now.ToShortTimeString();
      suffix = suffix.Replace(" ", "_"); //get rid of the spaces.
      suffix = suffix.Replace(":", "_"); //get rid of the :
      MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
      sa.Initialize();

      MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
      accessData = sa.FindAndReturnObject("SuperUser");
      suName = accessData.UserName;
      suPassword = accessData.Password;

    }

    [Test]
    public void T01CreateCorporateAccount()
    {
      corpAccount = "UnitTestCorp_" + suffix;
      YetAnotherCreateAccount(corpAccount, "USD", "monthly", "CorporateAccount", corpAccount,
      true, "", "", @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(corpAccount);
      
    }
    [Test]
    public void T02CreateDepartmentAccount1()
    {
      //under corp
      deptAccount = "UnitTestDept_" + suffix;
      YetAnotherCreateAccount(deptAccount, "USD", "monthly", "DepartmentAccount", deptAccount,
        true, "", corpAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(deptAccount);
    }
    [Test]
    public void T03CreateDepartmentAccount2()
    {
      //under dept
      string deptAccount2 = "UnitTestDept2_" + suffix;
      YetAnotherCreateAccount(deptAccount2, "USD", "monthly", "DepartmentAccount", deptAccount2,
        true, "", deptAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(deptAccount2);
    }
    [Test]
    public void T04CreateSubscriberAccount1()
    {
      //under dept.
      subAccount = "Subscriber_" + suffix;
      YetAnotherCreateAccount(subAccount, "USD", "monthly", "CoreSubscriber", subAccount,
        true, "", deptAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(subAccount);

    }
    [Test]
    public void T05CreateSubscriberAccount2()
    {
      //under corp
      subAccount2 = "Subscriber2_" + suffix;
      YetAnotherCreateAccount(subAccount2, "USD", "monthly", "CoreSubscriber", subAccount2,
        true, "", corpAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(subAccount2);
    }
    [Test]
    public void T06CreateSystemAccount1()
    {
      //under root
      systemAccount = "SysAcct_" + suffix;
      YetAnotherCreateAccount(systemAccount, "USD", "monthly", "SystemAccount", systemAccount,
        true, "", "", @"metratech.com/systemaccountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(systemAccount);

    }
    
    [Test]
    public void T07CreateSystemAccount2()
    {
      //under systemaccount AKA sales force hierarchy
      string sysAcct2 = "SysAcct2_" + suffix;
      YetAnotherCreateAccount(sysAcct2, "USD", "monthly", "SystemAccount", sysAcct2,
        true, "", systemAccount, @"metratech.com/systemaccountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(sysAcct2);

    }

    [Test]
    //[Ignore("")]
    public void T08CreateIndependentAccount()
    {
      //under root
      string IndAcct = "IndAcct_" + suffix;
      YetAnotherCreateAccount(IndAcct, "USD", "monthly", "IndependentAccount", IndAcct,
        true, "", "", @"metratech.com/AccountCreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(IndAcct);
    }

    [Test]
    //[Ignore("")]
    public void T09CreateAndConnectGSMAccountWithValidCurrency()
    {
      //under subscriberAccount1, USD currency, no usage cycle, subaccount is payer and parent
      GSMAcct = "GSMPhone_" + suffix;
      CreateAndConnectGSM(GSMAcct, "USD", subAccount);
      int accountid = GetAccountID(GSMAcct);
    }
    [Test]
    public void T10CreateAndConnectGSMAccountWithNoCurrency()
    {
      //under subscriberAccount1, no currency, no usage cycle, subaccount is payer and parent
      string GSMAcctNoCurrency = "GSMPhoneNoCurrency_" + suffix;
      CreateAndConnectGSM(GSMAcctNoCurrency, "", subAccount);
      int accountid = GetAccountID(GSMAcctNoCurrency);
    }
    [Test]
    public void T11AddShipToContactInfoToCoreSubscriber()
    {
      NameValueCollection propertyBag = new NameValueCollection();
      propertyBag["contacttype"] = "Ship-To";
      propertyBag["accounttype"] = "CoreSubscriber";
      propertyBag["operation"] = "update";
      propertyBag["actiontype"] = "Contact";
      propertyBag["name_space"] = "MT";
      propertyBag["company"]="IBM";
      propertyBag["firstname"]="ShipToFirstName";
      propertyBag["address1"]="105 conant road";
      propertyBag["city"]="Wellesley";

      UpdateAccount("metratech.com/accountcreation", subAccount, propertyBag);
    }

    [Test]
    public void T12UpdateContactInfoForCoreSubscriber()
    {
      NameValueCollection propertyBag = new NameValueCollection();
      propertyBag["contacttype"] = "Bill-To";
      propertyBag["firstname"] = "changedFirstName";
      propertyBag["password_"] = "xxx";
      propertyBag["accounttype"] = "CoreSubscriber";
      propertyBag["operation"] = "update";
      propertyBag["actiontype"] = "Both";
      propertyBag["name_space"] = "MT";
      UpdateAccount("metratech.com/accountcreation", subAccount, propertyBag);
    }

    [Test]
    public void T13MoveCoreSubscriber()
    {
      //move the account subAccount2 under deptaccount (deptAccount)
      NameValueCollection propertyBag = new NameValueCollection();
      propertyBag["accounttype"] = "CoreSubscriber";
      propertyBag["operation"] = "update";
      propertyBag["actiontype"] = "Both";
      propertyBag["name_space"] = "MT";
      propertyBag["ancestorAccount"] = deptAccount;
      propertyBag["ancestorAccountNS"] = "MT";
      propertyBag["hierarchy_startdate"] = (MetraTime.Now.AddMonths(1)).ToString();
      UpdateAccount("metratech.com/accountcreation", subAccount2, propertyBag);

    }

    [Test]
    public void T14ChangePayerCoreSubscriber()
    {
      //change the payer of subAccount2 to be the corporate account
      NameValueCollection propertyBag = new NameValueCollection();
      propertyBag["accounttype"] = "CoreSubscriber";
      propertyBag["operation"] = "update";
      propertyBag["actiontype"] = "Both";
      propertyBag["name_space"] = "MT";
      propertyBag["PayerAccount"] = corpAccount;
      propertyBag["PayerAccountNS"] = "MT";
      propertyBag["payment_startdate"] = (MetraTime.Now.AddMonths(1)).ToString();
      UpdateAccount("metratech.com/accountcreation", subAccount, propertyBag);

    }

   
    [Test]
    public void T15CreateAndDontConnectGSMAccount()
    {
      int accountid;
      //under SyntheticRoot
      CreateDisconnectedGSMAccount("HomelessPhone1" + suffix, "mt", "IMSI111", "MSISDN9999", 3292297, 100);
      accountid = GetAccountID("HomelessPhone1" + suffix);

      CreateDisconnectedGSMAccount("HomelessPhone2" + suffix, "mt", "IMSI111", "MSISDN9999", 3292297, 100);
      accountid = GetAccountID("HomelessPhone2" + suffix);

      CreateDisconnectedGSMAccount("HomelessPhone3" + suffix, "mt", "IMSI111", "MSISDN9999", 3292297, 100);
      accountid = GetAccountID("HomelessPhone3" + suffix);

      CreateDisconnectedGSMAccount("HomelessPhone4" + suffix, "mt", "IMSI111", "MSISDN9999", 3292297, 100);
      accountid = GetAccountID("HomelessPhone4" + suffix);

      CreateDisconnectedGSMAccount("HomelessPhone5" + suffix, "mt", "IMSI111", "MSISDN9999", 3292297, 100);
      accountid = GetAccountID("HomelessPhone5" + suffix);
    }

    [Test]
    public void T16CreateNonBillableSubscriberAccount()
    {
      //account is not billable.  Ancestor and payer are deptAccount.
      string nonBillableSubAccount = "NonBillableSubscriber_" + suffix;
      YetAnotherCreateAccount(nonBillableSubAccount, "USD", "monthly", "CoreSubscriber", nonBillableSubAccount,
        false, deptAccount, deptAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
      int accountid = GetAccountID(nonBillableSubAccount);

    }

    [Test]
    public void T17DisconnectGSMAccount()
    {
      DateTime disconnectTime = MetraTime.Now;
      
      DisconnectGSMAccount(GSMAcct, disconnectTime.AddDays(2));
    }
    //most positive testcases done!

    //negative tests
    [Test]
    [Category("NegativeTest")]
    public void T18CreateNonBillableNoPayerSubscriberAccount()
    {
      try
      {
        string nonBillableNoPayerAcct = "NonBillableNoPayerSubscriber_" + suffix;
        YetAnotherCreateAccount(nonBillableNoPayerAcct, "USD", "monthly", "CoreSubscriber", nonBillableNoPayerAcct,
          false, "", deptAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
        TestLibrary.Trace(e.Message);
      }
    }

    [Test]
    [Category("NegativeTest")]
    public void T19CreateCorpAccountUnderSubscriber()
    {
      //under subscriber
      try
      {
        string BadSub = "BadSub" + suffix;
        YetAnotherCreateAccount(BadSub, "USD", "monthly", "CorporateAccount", BadSub,
          true, "", subAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
        TestLibrary.Trace(e.Message);
      }

    }

    [Test]
    [Category("NegativeTest")]
    public void T20CreateGSMAccountUnderCorporate()
    {
      //under corp, USD currency, no usage cycle, corpaccount is payer and parent
      try
      {
        string GSMAcct = "BadPhone_" + suffix;
        CreateAndConnectGSM(GSMAcct, "USD", corpAccount);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
        TestLibrary.Trace(e.Message);
      }
 
    }
    [Test]
    [Category("NegativeTest")]
    public void T21CreateGSMAccountUnderDepartment()
    {
      //under dept, USD currency, no usage cycle, corpaccount is payer and parent
      try
      {
        string GSMAcct = "BadBadPhone_" + suffix;
        CreateAndConnectGSM(GSMAcct, "USD", deptAccount);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
        TestLibrary.Trace(e.Message);
      }
    }
    [Test]
    [Category("NegativeTest")]
    public void T22CreateSubscriberWithNoCurrency()
    {
      //create a subscriber account under a corporate account, self payer but has no currency
      try
      {
        string BadSub = "BadSub" + suffix;
        YetAnotherCreateAccount(BadSub, "", "monthly", "CoreSubscriber", BadSub,
          true, "", corpAccount, @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
        TestLibrary.Trace(e.Message);
      }
    }

    [Test]
    [Category("NegativeTest")]
    public void T23MoveGSMUnderDept()
    {
      //Move the GSMAcct under DeptAcct, should fail
      try
      {
        NameValueCollection propertyBag = new NameValueCollection();
        propertyBag["accounttype"] = "GSMServiceAccount";
        propertyBag["operation"] = "update";
        propertyBag["actiontype"] = "Both";
        propertyBag["name_space"] = "MT";
        propertyBag["ancestorAccount"] = deptAccount;
        propertyBag["ancestorAccountNS"] = "MT";
        propertyBag["hierarchy_startdate"] = (MetraTime.Now.AddMonths(1)).ToString();
        UpdateAccount("metratech.com/GSMConnect", GSMAcct, propertyBag);

        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
        TestLibrary.Trace(e.Message);
      }
    }

    [Test]
    [Category("NegativeTest")]
    public void T24CreateAccountsWithSyntheticRootAsAncestor()
    {
      //all these should fail, negative tests.
      string expectedExceptionMessage = "Invalid ancestor (-1) specified" ;
      try
      {
        YetAnotherCreateAccount("BadSubscriber" + suffix, "USD", "monthly", "CoreSubscriber", "BadSubscriber",
          true, "", "SyntheticRoot", @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
          TestLibrary.Trace("CreateAccountsWithSyntheticRoot for CoreSub: " + e.GetType().ToString());
          TestLibrary.Trace("CreateAccountsWithSyntheticRoot for CoreSub: " + e.Message);
        Assert.AreEqual(e.Message.StartsWith(expectedExceptionMessage), true);
      }
  
      try
      {
        YetAnotherCreateAccount("BadCorp" + suffix, "USD", "monthly", "CorporateAccount", "BadCorp",
          true, "", "SyntheticRoot", @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
          TestLibrary.Trace("CreateAccountsWithSyntheticRoot for Corporate: " + e.Message);
        Assert.AreEqual(e.Message.StartsWith(expectedExceptionMessage), true);
      }
      try
      {
        YetAnotherCreateAccount("BadDept" + suffix, "USD", "monthly", "DepartmentAccount", "BadDept",
          true, "", "SyntheticRoot", @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
          TestLibrary.Trace("CreateAccountsWithSyntheticRoot for Dept: " + e.Message);
        Assert.AreEqual(e.Message.StartsWith(expectedExceptionMessage), true);
      }

      try
      {
        YetAnotherCreateAccount("BadSystem" + suffix, "USD", "monthly", "SystemAccount", "BadSystem",
          true, "", "SyntheticRoot", @"metratech.com/systemaccountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
          TestLibrary.Trace("CreateAccountsWithSyntheticRoot for System: " + e.Message);
        Assert.AreEqual(e.Message.StartsWith(expectedExceptionMessage), true);
      }
      
      try
      {

        YetAnotherCreateAccount("BadIndependent" + suffix, "USD", "monthly", "IndependentAccount", "BadIndependent",
          true, "", "SyntheticRoot", @"metratech.com/accountcreation",31, MetraTime.Now, "USA", -1, null, false);
        Assert.Fail("Expected exception not generated!");
      }
      catch(Exception e)
      {
          TestLibrary.Trace("CreateAccountsWithSyntheticRoot for Independent: " + e.Message);
        Assert.AreEqual(e.Message.StartsWith(expectedExceptionMessage), true);
      }
    }

    private void VerifyLoadAndFind(string accountName)
    {
    }

    public void UpdateAccount(string serviceDef, string username, NameValueCollection propertyBag)
    {
      TestLibrary.Trace("Updating account {0}", username);
      ISessionSet sessionSet = sdk.CreateSessionSet();
      sessionSet.SessionContextUserName = suName;
      sessionSet.SessionContextPassword = suPassword;
      sessionSet.SessionContextNamespace = "system_user";

      ISession session = sessionSet.CreateSession(serviceDef);
      session.InitProperty("username", username);
      foreach (string propName in propertyBag)
      {
        // Hack for dates - if the property name has 'date' in it
        // attempt to convert the input string into a DateTime
        if (propName.ToLower().IndexOf("date") != -1) 
        {
          session.InitProperty(propName, Convert.ToDateTime(propertyBag[propName]));
        }
        else 
        {
          session.InitProperty(propName, propertyBag[propName]);
        }
      }
      session.RequestResponse = true;
      sessionSet.Close();
    }

    
    private void CreateAndConnectGSM(string username, string currency, string ancAcc)
    {
      TestLibrary.Trace("Creating account {0}", username);

      ISessionSet sessionSet = sdk.CreateSessionSet();
      sessionSet.SessionContextUserName = suName;
      sessionSet.SessionContextPassword = suPassword;
      sessionSet.SessionContextNamespace = "system_user";

      ISession session = sessionSet.CreateSession(@"metratech.com/GSMCreateAndConnect");
      session.InitProperty("actiontype", "both");	// account/contact/both
      session.InitProperty("operation", "Add");
      session.InitProperty("accounttype", "GSMServiceAccount");

      session.InitProperty("password_", "123");
      session.InitProperty("username", username);
      session.InitProperty("name_space", "MT");

      //t_av_internal properties.
      session.InitProperty("timezoneID", 18);
      if (currency != "")
        session.InitProperty("currency", currency);
      session.InitProperty("language", "US");

      //t_av_gsm properties.

      //state, ancestor, payer related properties.
      session.InitProperty("accountstatus", "Active");
      session.InitProperty("ancestorAccount", ancAcc);
      session.InitProperty("ancestorAccountNS", "MT");
  
      session.RequestResponse = true;

      sessionSet.Close();
    }


    public void YetAnotherCreateAccount(string username, string currency, 
                                        string cycleType, string accType, 
                                        string fName, bool billable, 
                                        string payerAcc, string ancAcc, 
                                        string serviceDef, int day, 
                                        DateTime startDate, string country,
                                        int timeZoneID, string pricelist, bool applyAccountTemplate)
    {
      TestLibrary.Trace("Creating account {0}", username);

      ISessionSet sessionSet = sdk.CreateSessionSet();
      sessionSet.SessionContextUserName = suName;
      sessionSet.SessionContextPassword = suPassword;
      sessionSet.SessionContextNamespace = "system_user";

      ISession session = sessionSet.CreateSession(serviceDef);
      session.InitProperty("actiontype", "both");	// account/contact/both
      session.InitProperty("password_", "123");
      session.InitProperty("_Accountid", 0);
     
      session.InitProperty("username", username);
      session.InitProperty("operation", "Add");
      session.InitProperty("accounttype", accType);
      if (accType.ToUpper() !=  "SYSTEMACCOUNT")
        session.InitProperty("name_space", "MT");
      else
        session.InitProperty("name_space", "system_user");

      //t_av_internal properties
      
      session.InitProperty("statusreason", "0");
      if (billable)
        session.InitProperty("billable", true);
      else if (accType.ToUpper() != "GSMSERVICEACCOUNT")
        session.InitProperty("billable", false);

      if ((accType.ToUpper() == "GSMSERVICEACCOUNT") ||
          (accType.ToUpper() == "CORESUBSCRIBER") ||
          (accType.ToUpper() == "INDEPENDENTACCOUNT"))
        session.InitProperty("folder", false);
      else if ((accType.ToUpper() == "DEPARTMENTACCOUNT") ||
               (accType.ToUpper() == "CORPORATEACCOUNT"))
        session.InitProperty("folder", true); //I don't care about the folder, but the load hierarchy queries use it.. need to remove them
      session.InitProperty("language", "US");
      if (!String.IsNullOrEmpty(currency))
        session.InitProperty("currency", currency);
      
      if (!String.IsNullOrEmpty(cycleType))
      {
        session.InitProperty("usagecycletype", cycleType);
        switch (cycleType.ToLower())
        {
          case "weekly":
            session.InitProperty("dayofweek", day);
            break;
          case "monthly":
            session.InitProperty("dayofmonth", day);
            break;
          default:
            throw new ApplicationException("only monthly and weekly cycles supported");
        }
      }

      if (timeZoneID == -1) 
      {
      session.InitProperty("timezoneID", 18);
      }
      else 
      {
        session.InitProperty("timezoneID", timeZoneID);
      }


      if (!String.IsNullOrEmpty(pricelist)) 
      {
        session.InitProperty("pricelist", pricelist);
      }

      session.InitProperty("taxexempt", false);
      
      if (accType.ToUpper() != "GSMSERVICEACCOUNT")
        session.InitProperty("paymentmethod", "CashOrCheck");
      
      //t_av_contact properties.
      if (accType.ToUpper() != "GSMSERVICEACCOUNT")
      {
        session.InitProperty("contacttype", "Bill-To");
        session.InitProperty("city", "Waltham");
        session.InitProperty("state", "MA");
        session.InitProperty("zip", "02451");
        session.InitProperty("firstname", fName);
        session.InitProperty("lastname", "User");
        session.InitProperty("email", "abc@hotmail.com");
        session.InitProperty("phonenumber", "555-5555");
        session.InitProperty("company", "MetraTech");
        session.InitProperty("address1", "300 Bear Hill Road.");
        session.InitProperty("address2", "");
        session.InitProperty("address3", "");
        session.InitProperty("country", country);
        session.InitProperty("facsimiletelephonenumber", "");
        session.InitProperty("middleinitial", "L");
      }

      session.InitProperty("accountstatus", "Active");
      if (!String.IsNullOrEmpty(ancAcc))
      {
        if (ancAcc == "SyntheticRoot")
        {
          session.InitProperty("ancestorAccountID", -1);
        }
        else
        {
          session.InitProperty("ancestorAccount", ancAcc);
          if (accType.ToUpper() !=  "SYSTEMACCOUNT")
            session.InitProperty("ancestorAccountNS", "MT");
          else
            session.InitProperty("ancestorAccountNS", "system_user");
        }
      }
      if (!String.IsNullOrEmpty(payerAcc))
      {
        session.InitProperty("PayerAccount", payerAcc);
        session.InitProperty("PayerAccountNS", "MT");
      }

      if ((accType.ToUpper() == "SYSTEMACCOUNT"))
        session.InitProperty("LoginApplication", "CSR");

      session.InitProperty("accountstartdate", startDate);

      if (applyAccountTemplate) 
      {
        session.InitProperty("ApplyAccountTemplate", true);
      }

      session.RequestResponse = true;

      sessionSet.Close();
      
    }


    private void DisconnectGSMAccount(string username, DateTime DisconnectTime)
    {
      TestLibrary.Trace("Disconnecting GSMaccount {0} at time {1}", username, DisconnectTime.ToString());
      ISessionSet sessionSet = sdk.CreateSessionSet();
      sessionSet.SessionContextUserName = suName;
      sessionSet.SessionContextPassword = suPassword;
      sessionSet.SessionContextNamespace = "system_user";

      ISession session = sessionSet.CreateSession(@"metratech.com/GSMDisconnect");
      session.InitProperty("actiontype", "both");	// account/contact/both
      session.InitProperty("operation", "Update");
      session.InitProperty("accounttype", "GSMServiceAccount");
      session.InitProperty("username", username);
      session.InitProperty("name_space", "mt");
      session.InitProperty("disconnect_time", DisconnectTime); 
      session.RequestResponse = true;

      sessionSet.Close();
    }


    private void CreateDisconnectedGSMAccount(string username, string name_space, string IMSI, string MSISDN, int cellIdentity, int HomeBID)
    {
      TestLibrary.Trace("Creating account {0}", username);

      ISessionSet sessionSet = sdk.CreateSessionSet();
      sessionSet.SessionContextUserName = suName;
      sessionSet.SessionContextPassword = suPassword;
      sessionSet.SessionContextNamespace = "system_user";

      ISession session = sessionSet.CreateSession(@"metratech.com/GSMCreate");
      session.InitProperty("actiontype", "both");	// account/contact/both
      session.InitProperty("password_", "123");
      session.InitProperty("username", username);
      session.InitProperty("operation", "Add");
      session.InitProperty("accounttype", "GSMServiceAccount");
      session.InitProperty("name_space", name_space);
      session.InitProperty("language", "US");
      session.InitProperty("timezoneID", 18);
      session.InitProperty("accountstatus", "Active");

      //put in the t_av_gsm properties.
      session.InitProperty("IMSI", IMSI);
      session.InitProperty("MSISDN", MSISDN);
      session.InitProperty("cellIdentity", cellIdentity);
      session.InitProperty("HomeBID", HomeBID);
      session.RequestResponse = true;

      sessionSet.Close();
    }

    public int GetAccountID(string username)
    {
        string query = String.Format("Select id_acc as accountid from t_account_mapper where nm_login = '{0}'", username);
        using(IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTStatement stmt = conn.CreateStatement(query))
            {
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    reader.Read();
                    int accountid = reader.GetInt32(0);
                    TestLibrary.Trace("AccountId was: {0}", accountid);
                    return accountid;
                }
            }
        }
    }
  }
}
