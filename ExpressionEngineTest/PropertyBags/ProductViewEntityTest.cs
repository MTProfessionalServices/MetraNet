using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

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
            string _namespace = "MetraTech";
            string name = "MyPv";
            string description = "Just a test";
            var pv = new ProductViewEntity(_namespace, name, description);
            Assert.AreEqual(_namespace, pv.Namespace);
            Assert.AreEqual(name, pv.Name);
            Assert.AreEqual(description, pv.Description);
            Assert.IsTrue(((PropertyBagType)pv.Type).IsProductView, "IsProductView");
            Assert.AreEqual("t_pv_MyPv", pv.DatabaseColumnName);
        }

        [TestMethod()]
        public void PropertyDatabaseNameTest()
        {
            var pv = new ProductViewEntity("MetraTech", "Foo", null);
            var property = (ProductViewProperty)pv.Properties.AddCharge("Stuff", "", true);
            Assert.AreEqual(BaseType.Charge, property.Type.BaseType);
            Assert.AreEqual("c_Stuff", property.DatabaseColumnName, "Default name");

            var remappingName = "the reamaped name";
            property.DatabaseColumnNameMapping = remappingName;
            Assert.AreEqual(remappingName, property.DatabaseColumnName, "Remapped name");
        }

        [TestMethod]
        public void ProductViewEntityCorePropertiesUniqunessTest()
        {
          var entity = new ProductViewEntity("testNamespace", "testName", "testDescription");
          PropertyBagTestHelper.VerifyIfCorePropertiesInEntityDuplicated(entity);
        }
    }
}
