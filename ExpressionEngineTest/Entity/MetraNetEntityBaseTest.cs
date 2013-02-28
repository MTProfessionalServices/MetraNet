using MetraTech.ExpressionEngine.PropertyBags;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class MetraNetEntityBaseTest
    {

        [TestMethod()]
        public void GetFileNameTest()
        {
            var entity = PropertyBagFactory.CreateProductViewEntity("Foo", null);
            entity.Extension = "Core";
            var file = entity.GetFileNameGivenExtensionsDirectory(@"C:\RMP\Extensions");
            Assert.AreEqual(@"C:\RMP\Extensions\Core\Config\ProductViews\Foo.xml", file);
        }
    }
}
