using System;
using System.Collections;
using MetraTech.Test.Common;
using NUnit.Framework;
using MetraTech.Interop.MTAuth;
using MetraTech.Interop.MTServerAccess;

///nunit-console.exe /fixture:MetraTech.Security.Test.TestAuth /assembly:O:\debug\bin\MetraTech.Security.Test.dll
namespace MetraTech.Security.Test
{
  //[TestFixture]
  [Category("NoAutoRun")]
  public class TestAuth
  {
    private string corporate;
    private string coreSubName;
    private string coreSubName2;

    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [TestFixtureSetUp]
    public void Init()
    {
		//System.Threading.Thread.Sleep(10000);
      // Create corporate account.
      corporate = String.Format("SECURITY_CorpAccount_{0}", Utils.GetTestId());
      Utils.CreateCorporation(corporate, MetraTime.Now);
      int corporateAccountId = Utils.GetSubscriberAccountID(corporate);


      // Create Core Subscriber
      ArrayList accountSpecs = new ArrayList();
      coreSubName = String.Format("SECURITY_CoreSub_{0}", Utils.GetTestId());
      Utils.BillingCycle cycle = new Utils.BillingCycle(Utils.CycleType.MONTHLY, 1);
      Utils.AccountParameters param = new Utils.AccountParameters(coreSubName, cycle);
      accountSpecs.Add(param);
      Utils.CreateSubscriberAccounts(corporate, accountSpecs, MetraTime.Now);
      // Create 2nd Core Subscriber
      accountSpecs.Clear();
      coreSubName2 = String.Format("SECURITY_CoreSub2_{0}", Utils.GetTestId());
      Utils.AccountParameters param2 = new Utils.AccountParameters(coreSubName2, cycle);
      accountSpecs.Add(param2);
      Utils.CreateSubscriberAccounts(corporate, accountSpecs, MetraTime.Now);
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [TestFixtureTearDown]
    public void Dispose()
    {
    }

    /// <summary>
    /// Test login
    /// </summary>
    [Test]
    [Category("TestLogin")]
    public void TestLogin()
    {
      object sessionContext = null;  // IMTSessionContext
      Auth auth = new Auth();
      auth.Initialize(coreSubName2, "mt");
      LoginStatus status = auth.Login("123", "ZULU", ref sessionContext);
      Assert.AreEqual(status, LoginStatus.NoCapabilityToLogonToThisApplication);

      status = auth.Login("123", "MPS", ref sessionContext);
      if (auth.IsNewAccount())
      {
        Assert.AreEqual(status, LoginStatus.OKPasswordExpiringSoon);
      }
      else
      {
        Assert.AreEqual(status, LoginStatus.OK);
      }
    }


    [Test]
    [Category("TestChangePassword")]
    public void TestChangePassword()
    {
      Auth auth = new Auth();
      auth.Initialize(coreSubName, "mt");

      // force config
      MetraTech.Security.PasswordConfig.GetInstance().EnsureStrongPasswords = true;

      // test password strength
      Assert.AreEqual(auth.CheckPasswordStrength("hello world"), false);
      Assert.AreEqual(auth.CheckPasswordStrength("su123"), false);
      Assert.AreEqual(auth.CheckPasswordStrength("HelloWorld123!"), true);

      // change password
      Assert.AreEqual(auth.ChangePassword("123", "DemoMan123!", LoginAsSU()), true);

      // now try to login
      object sessionContext = null;  // IMTSessionContext
      auth.Initialize(coreSubName, "mt");
      LoginStatus status = auth.Login("DemoMan123!", "MPS", ref sessionContext);
      Assert.AreEqual(status, LoginStatus.OK);
    }

    [Test]
    [Ignore]
    [Category("TestEmailPasswordUpdate")]
    public void TestEmailPasswordUpdate()
    {
      Auth auth = new Auth();
      auth.Initialize(coreSubName, "mt");

      auth.EmailPasswordUpdate("schakraborty@metratech.com", "Sudip", "Chakraborty", "test", DateTime.Now, "US", null);
    }

    private IMTSessionContext LoginAsSU()
    {
      // sets the SU session context on the client
      IMTLoginContext loginContext = new MTLoginContextClass();
      IMTServerAccessDataSet sa = new MTServerAccessDataSet();
      sa.Initialize();
      IMTServerAccessData accessData = sa.FindAndReturnObject("SuperUser");
      string suName = accessData.UserName;
      string suPassword = accessData.Password;
      return loginContext.Login(suName, "system_user", suPassword);
    }
  }
}
