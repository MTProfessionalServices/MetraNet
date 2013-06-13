using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class IOHelperTest
    {
        /// <summary>
        ///A test for GetMetraNetExtension
        ///</summary>
        [TestMethod()]
        public void GetMetraNetExtensionTest()
        {
            var extension = IOHelper.GetMetraNetExtension( @"C:\RMP\Extensions\Cloud\Stuff");
            Assert.AreEqual("Cloud", extension);

            extension = IOHelper.GetMetraNetExtension(@"C:\RMP\Extensions");
            Assert.AreEqual(null, extension);

            extension = IOHelper.GetMetraNetExtension(@"C:\RMP\Extensions\Cloud");
            Assert.AreEqual("Cloud", extension);

            extension = IOHelper.GetMetraNetExtension(@"C:\RMP\extensions\Cloud");
            Assert.AreEqual("Cloud", extension);

            extension = IOHelper.GetMetraNetExtension(@"C:\RMP\Extension\Cloud\Stuff");
            Assert.AreEqual(null, extension);
        }
    }
}
