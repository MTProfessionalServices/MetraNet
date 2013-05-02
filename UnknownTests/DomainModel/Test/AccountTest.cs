using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using MetraTech.DomainModel.Enums;
using NUnit.Framework;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.Test
{
  /// <summary>
  ///   Unit Tests for CreateAccountActivity.
  ///   
  ///   To run the this test fixture:
  //    nunit-console /fixture:MetraTech.DomainModel.Test.AccountTest /assembly:O:\debug\bin\MetraTech.DomainModel.Test.dll
  /// </summary>
  [TestFixture]
  public class AccountTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
    }
    
    [TestFixtureTearDown]
    public void TearDown()
    {
    }

    [Test]
    [Category("TestSetView")]
    public void TestSetView()
    {
      Account account = Account.CreateAccount("CoreSubscriber");
      Assert.IsNotNull(account);

      View view = View.CreateView("metratech.com/contact");
      Assert.IsNotNull(view);

      account.AddView(view, "ContactViews");
      account.AddView(view, "ContactViews");

      view = View.CreateView("metratech.com/internal");
      Assert.IsNotNull(view);

      account.AddView(view, "Internal");

    }

    [Test]
    [Category("TestCreateAccountWithViews")]
    public void TestCreateAccountWithViews()
    {
      Account account = Account.CreateAccountWithViews("GSMServiceAccount");
      Assert.IsNotNull(account);
    }

    [Test]
    [Category("TestAccountSetValue")]
    public void TestAccountSetValue()
    {
      Account account = Account.CreateAccount("CoreSubscriber");
      Assert.IsNotNull(account);
      account.SetValue("DayOfWeek", MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek.Monday);
      object value = account.GetValue("DayOfWeek");
      Assert.AreEqual(MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek.Monday, value);
    }

		[Test]
		[Category("TestFQN")]
		public void TestFQN()
		{
			string contactFQN = EnumHelper.GetFQN(MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation.ActionType.Contact);
			Assert.AreEqual("metratech.com/accountcreation/actiontype/contact", contactFQN.ToLower());
		}
  }
}
