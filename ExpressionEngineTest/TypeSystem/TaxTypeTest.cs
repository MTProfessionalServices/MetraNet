using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
namespace ExpressionEngineTest
{
    [TestClass()]
    public class TaxTypeTest
    {
        [TestMethod()]
        public void TaxTypeConstructorTest()
        {
            var tax = new TaxType();
            Assert.AreEqual(BaseType.Tax, tax.BaseType);
            Assert.IsTrue(tax.IsNumeric, "IsNumeric");
        }

        [TestMethod()]
        public void FactoryTest()
        {
            var tax = TypeFactory.CreateTax();
            Assert.AreEqual(BaseType.Tax, tax.BaseType);
        }
    }
}
