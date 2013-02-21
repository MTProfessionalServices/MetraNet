using MetraTech.ExpressionEngine.TypeSystem;
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
        public void CreateStringTest()
        {
            var str = TypeFactory.CreateString();
            Assert.AreEqual(BaseType.String, str.BaseType);
            Assert.IsTrue(str.IsString);
            Assert.AreEqual(0, str.Length);
            Assert.AreEqual("String", str.ToString(false));
            Assert.AreEqual("String", str.ToString(true));

            str = TypeFactory.CreateString(55);
            Assert.AreEqual(BaseType.String, str.BaseType);
            Assert.IsTrue(str.IsString);
            Assert.AreEqual(55, str.Length);
            Assert.AreEqual("String", str.ToString(false));
            Assert.AreEqual("String(50)", str.ToString(true));

        }


    }
}
