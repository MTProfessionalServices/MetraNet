using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Reflection;
using System.Threading;
using NUnit.Framework;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;


namespace MetraTech.DomainModel.Test
{
  /// <summary>
  ///   Unit Tests for CreateAccountActivity.
  ///   
  ///   To run the this test fixture:
  //    nunit-console /fixture:MetraTech.DomainModel.Test.LocalizationTest /assembly:O:\debug\bin\MetraTech.DomainModel.Test.dll
  /// </summary>
  [TestFixture]
  public class LocalizationTest
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
    [Category("TestEnglish")]
    public void TestEnglish()
    {
      AccountTypes.GSMView view = View.CreateView("metratech.com/gsm") as AccountTypes.GSMView;
      Assert.IsNotNull(view);

      Thread.CurrentThread.CurrentUICulture = new CultureInfo("ja");

      string viewCellIdentity = view.CellIdentityDisplayName;
    }
  }
}
