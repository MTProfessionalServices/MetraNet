using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class UnitOfMeasureTest
    {
        /// <summary>
        ///A test for UnitOfMeasure Constructor
        ///</summary>
        [TestMethod()]
        public void UnitOfMeasureConstructorTest()
        {
            var enumCategory = new EnumCategory(null, EnumMode.UnitOfMeasure, null, 0, null);
            var name = "Length";
            var id = 1212;
            var description = "linear dimension";
            var uom = EnumFactory.Create(enumCategory, name, id, description);
            Assert.AreSame(enumCategory, uom.EnumCategory);
            Assert.AreEqual(EnumMode.UnitOfMeasure, uom.EnumCategory.EnumMode);
            Assert.AreEqual(name, uom.Name);
            Assert.AreEqual(id, uom.Id);
            Assert.AreEqual(description, uom.Description);
        }
    }
}
