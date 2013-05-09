using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.DomainModel.BaseTypes;
using NUnit.Framework;
using MetraTech.UI.CDT;
using MetraTech.DomainModel.AccountTypes;

namespace MetraTech.UI.CDT.Test
{
  /// <summary>
  ///   Unit Tests for Custom Data Type parsing.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console.exe /fixture:MetraTech.UI.CDT.Test.ParsingTests /assembly:MetraTech.UI.CDT.Test.dll
  /// </summary>
  [TestFixture] 
  public class ParsingTests
  {
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [TestFixtureSetUp]
    public void Init()
    {
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [TestFixtureTearDown]
    public void Dispose()
    {
    }

    /// <summary>
    /// TestParse - verifies that we can parse an object correctly
    /// </summary>
    [Test]
    [Category("TestParse")]
    public void TestParse()
    {
      Account acc = Account.CreateAccountWithViews("CoreSubscriber");
      Dictionary<string, string> propValueMap = new Dictionary<string, string>();

      GenericObjectParser.ParseObjectForValues(acc, "", propValueMap);

      Assert.IsTrue(propValueMap.ContainsKey("Internal.TaxExempt"));
      Assert.IsTrue(propValueMap["Internal.TaxExemptDisplayName"] == "Tax Exempt");
    }

  }
}
