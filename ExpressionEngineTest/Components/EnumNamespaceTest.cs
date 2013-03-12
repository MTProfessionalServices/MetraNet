using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    /// <summary>
    ///This is a test class for EnumNamespace and is intended
    ///to contain all EnumNamespace Unit Tests
    ///</summary>
    [TestClass()]
    public class EnumNamespaceTest
    {
        /// <summary>
        ///A test for EnumNamespace Constructor
        ///</summary>
        [TestMethod()]
        public void EnumSpaceConstructorTest()
        {
            string name = "MetraTech.com";
            string description = "Located in Waltham, MA";
            var target = new EnumNamespace(name, description);
            Assert.AreEqual(name, target.Name);
            Assert.AreEqual(description, target.Description);
        }

        /// <summary>
        ///A test for AddCategory
        ///</summary>
        [TestMethod()]
        public void AddTypeTest()
        {
            var enumSpace = new EnumNamespace("Test", null);

            //Add it
            var enumMode = EnumMode.EnumValue;
            var name = "Global";
            var description = "Primary enum type";
            var enumCategory = enumSpace.AddCategory(enumMode, name, 1, description);

            //Look it up
            EnumCategory enumCategoryLookup;
            var result = enumSpace.TryGetEnumCategory(name, out enumCategoryLookup);
            Assert.IsTrue(result, "Unable to find added enum type.");
            Assert.AreSame(enumCategory, enumCategoryLookup);

            Assert.AreEqual(name, enumCategory.Name);
            Assert.AreEqual(description, enumCategory.Description);
        }

        /// <summary>
        ///A test for GetEnumCategory
        ///</summary>
        [TestMethod()]
        public void TryGetEnumTypeTest()
        {
            var enumSpace = new MetraTech.ExpressionEngine.Components.EnumNamespace("Test", null);
            var name = "Global";
            EnumCategory enumType;

            //Ensure that nothing breaks when there is nothing
            Assert.IsFalse(enumSpace.TryGetEnumCategory(name, out enumType), "Empty list");

            //Add it
            var actualEnumType = enumSpace.AddCategory(EnumMode.EnumValue, "Global", 1, null);

            //Look it up
            Assert.IsTrue(enumSpace.TryGetEnumCategory(name, out enumType), "Expect to find");
            Assert.AreSame(actualEnumType, enumType);

            //Try no find case, null and empty string cases
            Assert.IsFalse(enumSpace.TryGetEnumCategory("foo" , out enumType), "Doesn't exist");
            Assert.IsFalse(enumSpace.TryGetEnumCategory(null, out enumType), "null");
            Assert.IsFalse(enumSpace.TryGetEnumCategory(string.Empty, out enumType), "empty string");
        }
    }
}
