using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace ExpressionEngineTest
{  
    [TestClass()]
    public class EnumValueTest
    {
        [TestMethod()]
        public void ToMtsqlTest()
        {
            var enumValue = GetEnumValue("metratech.com", "global", "countryname", 320);
            Assert.AreEqual("#metratech.com/global/countryname#", enumValue.ToMtsql());
        }

        /// <summary>
        ///A test for Item Constructor
        ///</summary>
        [TestMethod()]
        public void EnumValueConstructorTest()
        {
            var parent = new EnumCategory(BaseType.Enumeration, "Global", "Country", 1, null);
            var name = "USA";
            var id = 500;
            var description = "Hello world";
            var target = new EnumItem(parent, name, id, description);
            Assert.AreSame(parent, target.EnumCategory, "EnumType");
            Assert.AreEqual(name, target.Name);
            Assert.AreEqual(id, target.Id);
            Assert.AreEqual(description, target.Description);
        }

        #region Helper Methods
        private EnumItem GetEnumValue(string namespaceName, string categoryName, string enumName, int id, string description = null)
        {
            var category = new EnumCategory(BaseType.Enumeration, namespaceName, categoryName, 1, null);
            var value = category.AddItem(enumName, id, description);
            return value;
        }
        #endregion
    }
}
