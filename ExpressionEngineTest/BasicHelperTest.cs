using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class BasicHelperTest
    {
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
