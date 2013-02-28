using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class ProductViewEntityTest
    {
        /// <summary>
        ///A test for ProductViewEntity Constructor
        ///</summary>
        [TestMethod()]
        public void ProductViewEntityConstructorTest()
        {
            string name = "MyPv";
            string description = "Just a test";
            var pv = new ProductViewEntity(name, description);
            Assert.AreEqual(name, pv.Name);
            Assert.AreEqual(description, pv.Description);
            Assert.IsTrue(((PropertyBagType)pv.Type).IsProductView, "IsProductView");
            Assert.AreEqual("t_pv_MyPv", pv.DatabaseName);
        }

        [TestMethod()]
        public void PropertyDatabaseNameTest()
        {
            var pv = new ProductViewEntity("foo", null);
            var property = (ProductViewProperty)pv.Properties.AddCharge("Amount", "", true);
            Assert.AreEqual(BaseType.Money, property.Type.BaseType);
            Assert.AreEqual("c_Amount", property.DatabaseName, "Default name");

            var remappingName = "the reamaped name";
            property.DatabaseNameMapping = remappingName;
            Assert.AreEqual(remappingName, property.DatabaseName, "Remapped name");
        }
    }
}
