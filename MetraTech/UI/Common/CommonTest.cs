using MetraTech.ActivityServices.Common;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.UI.Common.Test
{
  /// <summary>
  ///   Unit Tests for Common.
  ///   
  ///   To run the this test fixture:
  ///    nunit-console.exe /fixture:MetraTech.UI.Common.Test.CommonTests /assembly:MetraTech.UI.Common.Test.dll
  /// </summary>
  [TestClass]
  public class CommonTests
  {
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [ClassInitialize]
    public void Init()
    {
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [ClassCleanup]
    public void Dispose()
    {
    }

	///// <summary>
	///// TestMenuManager - verifies that we can load the MetraCare menu correctly
	///// </summary>
	//[TestMethod]
	//[TestCategory("Common")]
	//public void MTBinaryFilterOperatorTest()
	//{
	//  var p = MTListServicePage.AddOrList("Testing", new[] {"a", "b", "c"}, 0);

	//  Assert. (typeof (MTFilterElement), p.LeftHandElement);
	//  Assert.IsInstanceOfType(typeof(MTBinaryFilterOperator), p.RightHandElement);
	//  Assert.IsInstanceOf(typeof(MTFilterElement), ((MTBinaryFilterOperator)p.RightHandElement).LeftHandElement);
	//  Assert.IsInstanceOf(typeof(MTFilterElement), ((MTBinaryFilterOperator)p.RightHandElement).RightHandElement);
	//  Assert.AreEqual("c", ((MTFilterElement)((MTBinaryFilterOperator)p.RightHandElement).RightHandElement).Value);
	//}

   
  }
}
