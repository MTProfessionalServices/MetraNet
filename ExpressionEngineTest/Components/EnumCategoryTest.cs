using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class UnitOfMeasureCategoryTest
    {
        [TestMethod()]
        public void UnitOfMeasureCategoryConstructorTest()
        {
            var parent = new EnumNamespace("MetraTech", null);
            string name = "Length";
            int id = 500;
            string description = "A linear measurement";
            var uomCategory = new EnumCategory(parent, EnumMode.UnitOfMeasure, name, id, description);
            Assert.AreSame(parent, uomCategory.EnumNamespace);
            Assert.AreEqual(name, uomCategory.Name);
            Assert.AreEqual(id, uomCategory.Id);
            Assert.AreEqual(description, uomCategory.Description);
            Assert.AreEqual(EnumMode.UnitOfMeasure, uomCategory.EnumMode);
        }
    }
}
