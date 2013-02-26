using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class MoneyTypeTest
    {

        [TestMethod()]
        public void CreateMoneyTypeTest()
        {
            var mType = TypeFactory.CreateMoney();
            Assert.AreEqual(BaseType.Money, mType.BaseType);
            Assert.IsTrue(mType.IsNumeric);
        }
    }
}
