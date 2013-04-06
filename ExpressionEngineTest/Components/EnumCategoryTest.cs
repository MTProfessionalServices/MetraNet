using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class UnitOfMeasureCategoryTest
    {
        [TestMethod()]
        public void UnitOfMeasureCategoryConstructorTest()
        {
            string _namespace = "MetraTech";
            string name = "Length";
            int id = 500;
            string description = "A linear measurement";
            var uomCategory = new EnumCategory(BaseType.UnitOfMeasure, _namespace, name, id, description);
            Assert.AreSame(_namespace, uomCategory.Namespace);
            Assert.AreEqual(name, uomCategory.Name);
            Assert.AreEqual(id, uomCategory.Id);
            Assert.AreEqual(description, uomCategory.Description);
            Assert.AreEqual(BaseType.UnitOfMeasure, uomCategory.BaseType);
        }

        [TestMethod()]
        public void FullNameTest()
        {
            var category = new EnumCategory(BaseType.Enumeration, "MetraTech.Hello", "World", 0, null);
            Assert.AreEqual("MetraTech.Hello.World", category.FullName);
        }

        [TestMethod()]
        public void FullNameWithNoSlashesTest()
        {
            var category = new EnumCategory(BaseType.Enumeration, "MetraTech/Hello", "World", 0, null);
            Assert.AreEqual("MetraTech_Hello.World", category.FullNameWithNoSlashes);
        }
    }
}
