using MetraTech.ExpressionEngine.MTProperties;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine.TypeSystem;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class ProductViewPropertyTest
    {

        /// <summary>
        ///A test for ProductViewProperty Constructor
        ///</summary>
        [TestMethod()]
        public void ProductViewPropertyConstructorTest()
        {
            string name = "Foo";
            var type = TypeFactory.CreateBoolean();
            bool isRequired = true;
            string description = "Hello";
            var property = new ProductViewProperty(name, type, isRequired, description);
            Assert.AreEqual(name, property.Name);
            Assert.AreEqual(isRequired, property.Required);
            Assert.AreEqual(description, property.Description);
        }

        [TestMethod()]
        public void DatabaseNameTest()
        {
            string name = "Foo";
            var type = TypeFactory.CreateBoolean();
            bool isRequired = true;
            string description = "Hello";
            var property = new ProductViewProperty(name, type, isRequired, description);
            Assert.AreEqual("c_Foo", property.DatabaseColumnName);
        }

        [TestMethod()]
        public void DatabaseNameMappingTest()
        {
            string name = "Foo";
            var type = TypeFactory.CreateBoolean();
            bool isRequired = true;
            string description = "Hello";
            string mappingName = "c_MyMappingName";
            var property = new ProductViewProperty(name, type, isRequired, description);
            property.DatabaseColumnNameMapping = mappingName;
            Assert.AreEqual(mappingName, property.DatabaseColumnName);
        }
    }
}
