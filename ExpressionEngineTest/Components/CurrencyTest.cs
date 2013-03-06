using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class CurrencyTest
    {
        /// <summary>
        ///A test for Currency Constructor
        ///</summary>
        [TestMethod()]
        public void CurrencyConstructorTest()
        {
            var enumCategory = new EnumCategory(null, EnumMode.Currency, null, 0, null);
            var name = "Tokens";
            var id = 231;
            var description = "this is a good description";
            var currency = EnumFactory.Create(enumCategory, name, id, description);
            Assert.AreSame(enumCategory, currency.EnumCategory);
            Assert.AreEqual(EnumMode.Currency, currency.EnumCategory.EnumMode);
            Assert.AreEqual(name, currency.Name);
            Assert.AreEqual(id, currency.Id);
            Assert.AreEqual(description, currency.Description);
        }
    }
}
