using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

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
            var parent = new EnumCategory(null, "Country", 1, null);
            string name = "USA";
            int id = 500; 
            var target = new EnumValue(parent, name, id);
            Assert.AreSame(parent, target.EnumType, "EnumType");
            Assert.AreEqual(name, target.Name);
            Assert.AreEqual(id, target.Id);
        }

        #region Helper Methods
        private EnumValue GetEnumValue(string @namespace, string category, string enumValue, int id)
        {
            var space = new MetraTech.ExpressionEngine.Components.EnumNamespace(@namespace, null);
            var type = space.AddType(category, 1, null);
            var value = type.AddValue(enumValue, id);
            return value;
        }
        #endregion
    }
}
