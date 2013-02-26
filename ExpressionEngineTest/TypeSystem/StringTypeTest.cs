using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class StringTypeTest
    {
        /// <summary>
        ///A test Create String
        ///</summary>
        [TestMethod()]
        public void CreateStringTestNoLength()
        {
            var str = TypeFactory.CreateString();
            Assert.AreEqual(BaseType.String, str.BaseType);
            Assert.IsTrue(str.IsString);
            Assert.AreEqual(0, str.Length);
        }

        [TestMethod()]
        public void CreateStringWithLength()
        {
            var str = TypeFactory.CreateString(55);
            Assert.AreEqual(BaseType.String, str.BaseType);
            Assert.IsTrue(str.IsString);
            Assert.AreEqual(55, str.Length);
        }

        [TestMethod()]
        public void ToStringTest()
        {
            var str = TypeFactory.CreateString();
            Assert.AreEqual(BaseType.String, str.BaseType);
            Assert.AreEqual("String", str.ToString(false));
            Assert.AreEqual("String", str.ToString(true));

            str.Length = 100;
            Assert.AreEqual("String", str.ToString(false));
            Assert.AreEqual("String(100)", str.ToString(true));
        }

    }
}
