using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    /// <summary>
    ///This is a test class for EnumSpaceTest and is intended
    ///to contain all EnumSpaceTest Unit Tests
    ///</summary>
    [TestClass()]
    public class EnumSpaceTest
    {
        /// <summary>
        ///A test for EnumSpace Constructor
        ///</summary>
        [TestMethod()]
        public void EnumSpaceConstructorTest()
        {
            string name = "MetraTech.com";
            string description = "Located in Waltham, MA";
            EnumSpace target = new EnumSpace(name, description);
            Assert.AreEqual(name, target.Name);
            Assert.AreEqual(description, target.Description);
        }

        /// <summary>
        ///A test for AddEnum
        ///</summary>
        [TestMethod()]
        public void AddEnumTest()
        {
            Context context = null; // TODO: Initialize to an appropriate value
            string enumSpace = string.Empty; // TODO: Initialize to an appropriate value
            string enumType = string.Empty; // TODO: Initialize to an appropriate value
            string enumValue = string.Empty; // TODO: Initialize to an appropriate value
            int enumId = 0; // TODO: Initialize to an appropriate value
            EnumValue expected = null; // TODO: Initialize to an appropriate value
            EnumValue actual;
            actual = EnumSpace.AddEnum(context, enumSpace, enumType, enumValue, enumId);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for AddType
        ///</summary>
        [TestMethod()]
        public void AddTypeTest()
        {
            var enumSpace = new EnumSpace("Test", null);

            //Add it
            string name = "Global";
            string description = "Primary enum type";
            var enumType = enumSpace.AddType(name, description);

            //Look it up
            EnumType enumTypeLookup;
            var result = enumSpace.TryGetEnumType(name, out enumTypeLookup);
            Assert.IsTrue(result, "Unable to find added enum type.");
            Assert.AreSame(enumType, enumTypeLookup);

            Assert.AreEqual(name, enumType.Name);
            Assert.AreEqual(description, enumType.Description);
        }

        /// <summary>
        ///A test for TryGetEnumType
        ///</summary>
        [TestMethod()]
        public void TryGetEnumTypeTest()
        {
            var enumSpace = new EnumSpace("Test", null);
            var name = "Global";
            EnumType enumType;

            //Ensure that nothing breaks when there is nothing
            Assert.IsFalse(enumSpace.TryGetEnumType(name, out enumType), "Empty list");

            //Add it
            var actualEnumType = enumSpace.AddType("Global", null);

            //Look it up
            Assert.IsTrue(enumSpace.TryGetEnumType(name, out enumType), "Expect to find");
            Assert.AreSame(actualEnumType, enumType);

            //Try no find case, null and empty string cases
            Assert.IsFalse(enumSpace.TryGetEnumType("foo" , out enumType), "Doesn't exist");
            Assert.IsFalse(enumSpace.TryGetEnumType(null, out enumType), "null");
            Assert.IsFalse(enumSpace.TryGetEnumType(string.Empty, out enumType), "empty string");
        }
    }
}
