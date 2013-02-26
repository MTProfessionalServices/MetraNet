using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class EnumerationTypeTest
    {
        [TestMethod()]
        public void CreateEnumerationTest()
        {
            var eType = TypeFactory.CreateEnumeration("Global", "Country");
            Assert.AreEqual(BaseType.Enumeration, eType.BaseType);
            Assert.IsFalse(eType.IsNumeric, "IsNumeric");
            Assert.AreEqual("Enumeration", eType.ToString(false));
            Assert.AreEqual("Enumeration.Global.Country", eType.ToString(true));
        }
    }
}
