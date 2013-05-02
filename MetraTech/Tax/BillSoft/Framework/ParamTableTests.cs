#region

using MetraTech.Tax.Framework.DataAccess;
using Microsoft.VisualStudio.TestTools.UnitTesting;

#endregion

// nunit-console /fixture:MetraTech.Tax.UnitTests.ParamTable /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

namespace MetraTech.Tax.UnitTests
{
  [TestClass]
  public class ParamTable
  {
    [TestMethod()]
    [TestCategory("TestCreateParameterObject")]
    public void TestCreateParameterObject()
    {
        // Test should be eliminated
#if false
      var parm = new TaxManagerBatchDbVendorParamRow
                                               {
                                                 CanonicalName = "myCustomField",
                                                 Default = "null",
                                                 Description = "Here is a description",
                                                 Type = "string",
                                                 IdVendor = 10
                                               };
#endif
    }
  }
}