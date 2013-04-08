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
            var type = TypeFactory.CreateDecimal();
            type.UnitOfMeasureProperty = propertyName;
            var required = true;
            var reference = new PropertyReference(type, "UnitOfMeasureProperty", type, required);
            Assert.AreEqual(propertyName, reference.PropertyName);
            Assert.AreEqual(type.BaseType, reference.ExpectedType.BaseType);
            Assert.AreEqual(required, reference.Required, "Required");;
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
