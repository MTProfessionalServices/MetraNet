using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

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
        ///A test for EnumValue Constructor
        ///</summary>
        [TestMethod()]
        public void EnumValueConstructorTest()
        {
            var parent = new EnumCategory(null, EnumMode.EnumValue, "Country", 1, null);
            var name = "USA";
            var id = 500;
            var description = "Hello world";
            var target = new EnumValue(parent, name, id, description);
            Assert.AreSame(parent, target.EnumCategory, "EnumType");
            Assert.AreEqual(name, target.Name);
            Assert.AreEqual(id, target.Id);
            Assert.AreEqual(description, target.Description);
        }

        #region Helper Methods
        private EnumValue GetEnumValue(string namespaceName, string categoryName, string enumName, int id, string description = null)
        {
            var enumNamespace = new EnumNamespace(namespaceName, null);
            var category = enumNamespace.AddCategory(EnumMode.EnumValue, categoryName, 1, null);
            var value = category.AddEnumValue(enumName, id, description);
            return value;
        }
        #endregion
    }
}
