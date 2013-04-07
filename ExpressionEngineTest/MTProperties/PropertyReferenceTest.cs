using MetraTech.ExpressionEngine.MTProperties;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine.TypeSystem;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class PropertyReferenceTest
    {
        /// <summary>
        ///A test for PropertyReference Constructor
        ///</summary>
        [TestMethod()]
        public void PropertyReferenceConstructorTest()
        {
            string propertyName = "MyProperty";
            var expectedType = TypeFactory.CreateDecimal();
            var required = true;
            var rObject = this;
            var rName = "rName";
            var reference = new PropertyReference(rObject, rName, expectedType, required);
            Assert.AreEqual(propertyName, reference.PropertyName);
            Assert.AreEqual(expectedType.BaseType, reference.ExpectedType.BaseType);
            Assert.AreEqual(required, reference.Required, "Required");
            Assert.AreEqual(this, rObject);
        }

        [TestMethod()]
        public void RenameTest()
        {
            //Create the property with a reference to MyDecmalUoM
            var type = TypeFactory.CreateDecimal();
            type.UnitOfMeasureProperty = "MyDecimalUoM";
            var decimalProperty = PropertyFactory.Create("MyDecimal", type, true, "Just a decimal");

            //Create a reference 
            var reference = new PropertyReference(decimalProperty.Type, "UnitOfMeasureProperty", TypeFactory.CreateUnitOfMeasure(), true);

            //Perform the rename
            var theNewName = "TheNewName";
            reference.RenameActualReference(theNewName);
            Assert.AreEqual(theNewName, reference.PropertyName, "The reference");
            Assert.AreEqual(theNewName, type.UnitOfMeasureProperty, "actual property");
        }

    }
}
