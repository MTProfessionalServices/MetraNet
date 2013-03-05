using MetraTech.ExpressionEngine.Components;
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
            var uomCategory = new UnitOfMeasureCategory(parent, name, id, description);
            Assert.AreEqual(name, uomCategory.Name);
            Assert.AreEqual(id, uomCategory.Id);
            Assert.AreEqual(description, uomCategory.Description);
            Assert.IsTrue(uomCategory.IsUnitOfMeasure, "IsUnitOfMeasure");
        }

        [TestMethod()]
        public void AddUomTest()
        {
            var parent = new EnumNamespace("MetraTech", null);
            var uomCategory = new UnitOfMeasureCategory(parent, "Length", 10, "Linear measurement");
            var name = "Inch";
            var id = 300;
            var isMetric = true;
            var uom = uomCategory.AddUnitOfMeasure(name, id, isMetric);
            Assert.AreEqual(name, uom.Name);
            Assert.AreEqual(id, uom.Id);
            Assert.AreEqual(isMetric, uom.IsMetric);
            Assert.AreEqual("FixedUnitOfMeasure.png", uom.Image);
            Assert.IsTrue(uom.IsUnitOfMeasure, "IsUnitOfMeasure");
        }

        [TestMethod()]
        public void SaveTest()
        {
            var enumNamespace = new EnumNamespace("MetraTech", null);
            var uomCategory = (UnitOfMeasureCategory)enumNamespace.AddCategory(true, "SuperLength", 10, null);
            uomCategory.AddUnitOfMeasure("SuperInch", 11, false);
            uomCategory.AddUnitOfMeasure("SuperMile", 12, false);
            enumNamespace.Save(@"C:\ExpressionEngine\Reference\Enumerations");
        }

    }
}
