using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
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
            var enumSpace = new MetraTech.ExpressionEngine.Components.EnumNamespace("Test", null);

            //Add it
            string name = "Global";
            string description = "Primary enum type";
            var enumType = enumSpace.AddCategory(false, name, 1, description);

            //Look it up
            EnumCategory enumTypeLookup;
            var result = enumSpace.TryGetEnumCategory(name, out enumTypeLookup);
            Assert.IsTrue(result, "Unable to find added enum type.");
            Assert.AreSame(enumType, enumTypeLookup);

            Assert.AreEqual(name, enumType.Name);
            Assert.AreEqual(description, enumType.Description);
        }

        /// <summary>
        ///A test for TryGetEnumCategory
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
            var actualEnumType = enumSpace.AddCategory(false, "Global", 1, null);

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
