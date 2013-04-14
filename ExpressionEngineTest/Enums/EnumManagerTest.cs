using MetraTech.ExpressionEngine.Components;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class EnumManagerTest
    {
        /// <summary>
        ///A test for TryParseEnumItemFullName
        ///</summary>
        [TestMethod()]
        public void TryParseEnumItemFullNameTest()
        {
            AssertTryParseEnumItemFullName(null, false, null, null, null);
            AssertTryParseEnumItemFullName("", false, null, null, null);
            AssertTryParseEnumItemFullName("Hello.World", false, null, null, null);
            AssertTryParseEnumItemFullName("Hello..World.Today", false, null, null, null);
            AssertTryParseEnumItemFullName("Hello.World.Today", true, "Hello", "World", "Today");
            AssertTryParseEnumItemFullName("MetraTech.Cloud.Metrics.Gb", true, "MetraTech.Cloud", "Metrics", "Gb");
        }

        private void AssertTryParseEnumItemFullName(string fullName, bool expectedResult, string expectedNamespace, string expectedCategory, string exprectedItem)
        {
            string actualNamespace;
            string actualCategory;
            string actualItem;
            var actualResult = EnumManager.TryParseEnumItemFullName(fullName, out actualNamespace, out actualCategory, out actualItem);
            Assert.AreEqual(expectedResult, actualResult, fullName);
            Assert.AreEqual(expectedNamespace, actualNamespace, fullName);
            Assert.AreEqual(expectedCategory, actualCategory, fullName);
            Assert.AreEqual(exprectedItem, actualItem, fullName);
        }
    }
}
