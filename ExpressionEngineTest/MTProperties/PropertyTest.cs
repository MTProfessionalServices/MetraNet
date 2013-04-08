using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine.TypeSystem;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class PropertyTest
    {
        /// <summary>
        ///A test for IsInputOrInOut
        ///</summary>
        [TestMethod()]
        public void IsInputOrInOutTest()
        {
            var property = new Property("foo", TypeFactory.CreateFloat(), false);

            property.Direction = Direction.Input;
            Assert.IsTrue(property.IsInputOrInOut);
            Assert.IsFalse(property.IsOutputOrInOut);

            property.Direction = Direction.InputOutput;
            Assert.IsTrue(property.IsOutputOrInOut);
        }

        /// <summary>
        ///A test for IsOutputOrInOut
        ///</summary>
        [TestMethod()]
        public void IsOutputOrInOutTest()
        {
            var property = new Property("foo", TypeFactory.CreateFloat(), false);

            property.Direction = Direction.Output;
            Assert.IsTrue(property.IsOutputOrInOut);
            Assert.IsFalse(property.IsInputOrInOut);

            property.Direction = Direction.InputOutput;
            Assert.IsTrue(property.IsOutputOrInOut);
        }


        /// <summary>
        ///A test for PropertyDriven Constructor
        ///</summary>
        [TestMethod()]
        public void PropertyConstructorTest()
        {
            var name = "Foo";
            var type = new StringType();
            var required = true;
            var description = "Hello";
            var property = new Property(name, type, required, description);
            Assert.AreEqual(name, property.Name);
            Assert.AreEqual(BaseType.String, property.Type.BaseType);
            Assert.AreEqual(description, property.Description);
        }

    }
}
