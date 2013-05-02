using MetraTech.Security;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.Security.Crypto;

namespace MetraTech.SecurityFrameworkUnitTests
{
    
    
    /// <summary>
    ///This is a test class for PasswordConfigTest and is intended
    ///to contain all PasswordConfigTest Unit Tests
    ///</summary>
  [TestClass()]
  public class PasswordConfigTest
  {


    private TestContext testContextInstance;

    /// <summary>
    ///Gets or sets the test context which provides
    ///information about and functionality for the current test run.
    ///</summary>
    public TestContext TestContext
    {
      get
      {
        return testContextInstance;
      }
      set
      {
        testContextInstance = value;
      }
    }

    #region Additional test attributes
    // 
    //You can use the following additional attributes as you write your tests:
    //
    //Use ClassInitialize to run code before running the first test in the class
    //[ClassInitialize()]
    //public static void MyClassInitialize(TestContext testContext)
    //{
    //}
    //
    //Use ClassCleanup to run code after all tests in a class have run
    //[ClassCleanup()]
    //public static void MyClassCleanup()
    //{
    //}
    //
    //Use TestInitialize to run code before running each test
    //[TestInitialize()]
    //public void MyTestInitialize()
    //{
    //}
    //
    //Use TestCleanup to run code after each test has run
    //[TestCleanup()]
    //public void MyTestCleanup()
    //{
    //}
    //
    #endregion


    /// <summary>
    ///A test for GetInstance
    ///</summary>
    [TestMethod()]
    public void GetInstanceTest()
    {
      PasswordConfig actual;
      actual = PasswordConfig.GetInstance();
      Assert.IsNotNull(actual, "The instance of Password manager was not deserialized.");
    }

    /// <summary>
    ///A test for AuthenticationTypes
    ///</summary>
    [TestMethod()]
    public void AuthenticationTypes_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();

      Assert.IsNotNull(target.AuthenticationTypes, "AuthenticationTypes array was not deserialized.");
      CollectionAssert.AllItemsAreNotNull(target.AuthenticationTypes);
      Assert.AreEqual(2, target.AuthenticationTypes.Length, "2 items expected but {0} found", target.AuthenticationTypes.Length);
    }

    /// <summary>
    ///A test for DaysBeforePasswordExpires
    ///</summary>
    [TestMethod()]
    public void DaysBeforePasswordExpires_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      int expected = 90;
      int actual;
      target.DaysBeforePasswordExpires = expected;
      actual = target.DaysBeforePasswordExpires;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for DaysOfInactivityBeforeAccountLocked
    ///</summary>
    [TestMethod()]
    public void DaysOfInactivityBeforeAccountLocked_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      int expected = 90;
      int actual;
      target.DaysOfInactivityBeforeAccountLocked = expected;
      actual = target.DaysOfInactivityBeforeAccountLocked;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for DaysToStartWarningPasswordWillExpire
    ///</summary>
    [TestMethod()]
    public void DaysToStartWarningPasswordWillExpire_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      int expected = 14;
      int actual;
      target.DaysToStartWarningPasswordWillExpire = expected;
      actual = target.DaysToStartWarningPasswordWillExpire;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for EnsureStrongPasswords
    ///</summary>
    [TestMethod()]
    public void EnsureStrongPasswords_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      bool expected = false;
      bool actual;
      target.EnsureStrongPasswords = expected;
      actual = target.EnsureStrongPasswords;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for LoginAttemptsAllowed
    ///</summary>
    [TestMethod()]
    public void LoginAttemptsAllowed_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      int expected = 6;
      int actual;
      target.LoginAttemptsAllowed = expected;
      actual = target.LoginAttemptsAllowed;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for MinutesBeforeAutoResetPassword
    ///</summary>
    [TestMethod()]
    public void MinutesBeforeAutoResetPassword_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      int expected = 30;
      int actual;
      target.MinutesBeforeAutoResetPassword = expected;
      actual = target.MinutesBeforeAutoResetPassword;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for NumberOfLastPasswordsThatAreUnique
    ///</summary>
    [TestMethod()]
    public void NumberOfLastPasswordsThatAreUnique_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      int expected = 4;
      int actual;
      target.NumberOfLastPasswordsThatAreUnique = expected;
      actual = target.NumberOfLastPasswordsThatAreUnique;

      Assert.AreEqual(expected, actual, "{0} expected but {1} found.", expected, actual);
    }

    /// <summary>
    ///A test for PasswordStrengthRegex
    ///</summary>
    [TestMethod()]
    public void PasswordStrengthRegex_Get_Test()
    {
      PasswordConfig target = PasswordConfig.GetInstance();
      string expected = "^.*(?=.{7,1024})(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).*$";
      CDATA actual = target.PasswordStrengthRegex;
      actual = target.PasswordStrengthRegex;

      Assert.IsNotNull(actual);
      Assert.IsNotNull(actual.Text);
      Assert.AreEqual(expected, actual.Text.Trim(), "\"{0}\" expected but \"{1}\" found.", expected, actual.Text);
    }
  }
}
