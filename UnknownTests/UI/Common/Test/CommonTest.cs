using System;
using NUnit.Framework;
using MetraTech.Interop.RCD;

namespace MetraTech.UI.Common.Test
{
  /// <summary>
  ///   Unit Tests for Common.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console.exe /fixture:MetraTech.UI.Common.Test.CommonTests /assembly:MetraTech.UI.Common.Test.dll
  /// </summary>
  [TestFixture]
  public class CommonTests
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
    /// TestMenuManager - verifies that we can load the MetraCare menu correctly
    /// </summary>
    [Test]
    [Category("Common")]
    public void MTBinaryFilterOperatorTest()
    {
      var p = MTListServicePage.AddOrList("a", new string[] {"a", "b", "b"}, 0);

    }

   
  }
}
