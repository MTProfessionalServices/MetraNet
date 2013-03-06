using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class ChargeTypeTest
    {
        [TestMethod()]
        public void ChargeTypeFactoryTest()
        {
            var chargeType = TypeFactory.CreateCharge();
            Assert.AreEqual(BaseType.Charge, chargeType.BaseType);
            Assert.IsTrue(chargeType.IsNumeric);
        }
    }
}
