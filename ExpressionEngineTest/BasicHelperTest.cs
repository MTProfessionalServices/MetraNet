using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class BasicHelperTest
    {
        [TestMethod()]
        public void IsValidNameTest()
        {
            AssertNameIsValidTest(null, false);
            AssertNameIsValidTest("", false);
            AssertNameIsValidTest("Hello", true);
            AssertNameIsValidTest("hello", true);
            AssertNameIsValidTest("Hello9_", true);
            AssertNameIsValidTest("Hello^", false);
            AssertNameIsValidTest("4Hello", false);
            AssertNameIsValidTest("_Hello", false);
            AssertNameIsValidTest("Hello.", false);
            AssertNameIsValidTest("Hello.World", false);
        }
        private void AssertNameIsValidTest(string name, bool expectedValue)
        {
            Assert.AreEqual(expectedValue, BasicHelper.NameIsValid(name), name);
        }

        [TestMethod()]
        public void IsValidNamespaceTest()
        {
            AssertNamespaceIsValidTest(null, false);
            AssertNamespaceIsValidTest("", false);
            AssertNamespaceIsValidTest("Hello", true);
            AssertNamespaceIsValidTest("hello", true);
            AssertNamespaceIsValidTest("Hello9_", true);
            AssertNamespaceIsValidTest("Hello^", false);
            AssertNamespaceIsValidTest("4Hello", false);
            AssertNamespaceIsValidTest("_Hello", false);
            AssertNamespaceIsValidTest("Hello.", false);
            AssertNamespaceIsValidTest("Hello.World", true);
            AssertNamespaceIsValidTest("Hello_3.World", true);
            AssertNamespaceIsValidTest("Hello.World.A.Very.Nice.Day", true);
            AssertNamespaceIsValidTest("Hello.World.", false);
            AssertNamespaceIsValidTest("Hello..World.", false);
            AssertNamespaceIsValidTest(".Hello..World", false);
        }
        private void AssertNamespaceIsValidTest(string name, bool expectedValue)
        {
            Assert.AreEqual(expectedValue, BasicHelper.NamespaceIsValid(name), name);
        }

        [TestMethod()]
        public void IsValidFullNameTest()
        {
            AssertFullNameIsValidTest(null, false);
            AssertFullNameIsValidTest("", false);
            AssertFullNameIsValidTest("Hello", false);
            AssertFullNameIsValidTest("hello", false);
            AssertFullNameIsValidTest("Hello9_", false);
            AssertFullNameIsValidTest("Hello^", false);
            AssertFullNameIsValidTest("4Hello", false);
            AssertFullNameIsValidTest("_Hello", false);
            AssertFullNameIsValidTest("Hello.", false);
            AssertFullNameIsValidTest("Hello.World", true);
            AssertFullNameIsValidTest("Hello_3.World", true);
            AssertFullNameIsValidTest("Hello.World.A.Very.Nice.Day", true);
            AssertFullNameIsValidTest("Hello.World.", false);
            AssertFullNameIsValidTest("Hello..World.", false);
            AssertFullNameIsValidTest(".Hello..World", false);
        }
        private void AssertFullNameIsValidTest(string name, bool expectedValue)
        {
            Assert.AreEqual(expectedValue, BasicHelper.FullNameIsValid(name), name);
        }

        [TestMethod()]
        public void IsEvenTest()
        {
            Assert.IsTrue(BasicHelper.IsEven(0), "0");
            Assert.IsTrue(BasicHelper.IsEven(2), "2");
            Assert.IsTrue(BasicHelper.IsEven(4), "4");
            Assert.IsTrue(BasicHelper.IsEven(101982278), "101982278");
            Assert.IsTrue(BasicHelper.IsEven(-101982278), "-101982278");

            Assert.IsFalse(BasicHelper.IsEven(1), "1");
            Assert.IsFalse(BasicHelper.IsEven(-1), "-1");
            Assert.IsFalse(BasicHelper.IsEven(3), "3");
            Assert.IsFalse(BasicHelper.IsEven(9373657), "9373657");
            Assert.IsFalse(BasicHelper.IsEven(-9373657), "-9373657");
        }

        /// <summary>
        ///A test for GetNamespaceFromFullName
        ///</summary>
        [TestMethod()]
        public void GetNamespaceFromFullNameTest()
        {
            Assert.AreEqual(null, BasicHelper.GetNamespaceFromFullName(""), "EmptyString");
            Assert.AreEqual(null, BasicHelper.GetNamespaceFromFullName(null), "null");
            Assert.AreEqual(null, BasicHelper.GetNamespaceFromFullName("Hello"), "Hello");
            Assert.AreEqual("Hello", BasicHelper.GetNamespaceFromFullName("Hello.World"), "Hello.World");
            Assert.AreEqual("Hello.World.It.Is.A.Nice", BasicHelper.GetNamespaceFromFullName("Hello.World.It.Is.A.Nice.Day"), "Hello.World.It.Is.A.Nice.Day");
            Assert.AreEqual(".....", BasicHelper.GetNamespaceFromFullName("......MyName"), "......MyName");
        }

        /// <summary>
        ///A test for GetNameFromFullName
        ///</summary>
        [TestMethod()]
        public void GetNameFromFullNameTest()
        {
            Assert.AreEqual(null, BasicHelper.GetNameFromFullName(""), "EmptyString");
            Assert.AreEqual(null, BasicHelper.GetNameFromFullName(null), "null");
            Assert.AreEqual("Hello", BasicHelper.GetNameFromFullName("Hello"), "Hello");
            Assert.AreEqual("World", BasicHelper.GetNameFromFullName("Hello.World"), "Hello.World");
            Assert.AreEqual("Day", BasicHelper.GetNameFromFullName("Hello.World.It.Is.A.Nice.Day"), "Hello.World.It.Is.A.Nice.Day");
            Assert.AreEqual("MyName", BasicHelper.GetNameFromFullName("......MyName"), "MyName");
        }
    }
}
