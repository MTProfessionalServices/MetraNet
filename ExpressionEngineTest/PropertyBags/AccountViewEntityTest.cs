using MetraTech.ExpressionEngine.PropertyBags;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
  [TestClass]
  public class AccountViewEntityTest
  {
    [TestMethod]
    public void AccountViewEntityCorePropertiesUniqunessTest()
    {
      var entity = new AccountViewEntity("testNamespace", "testName", "testDescription");
      PropertyBagTestHelper.VerifyIfCorePropertiesInEntityDuplicated(entity);
    }
  }
}
