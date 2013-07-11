using MetraTech.ExpressionEngine.PropertyBags;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class PropertyBagTest
    {
        [TestMethod()]
        public void GetFileNameTest()
        {
            var entity = PropertyBagFactory.CreateProductViewEntity("MetraTech", "Foo", null);
            entity.Extension = "Core";
            var file = entity.GetFileNameGivenExtensionsDirectory(@"C:\RMP\Extensions");
            Assert.AreEqual(@"C:\RMP\Extensions\Core\Config\ProductViews\Foo.xml", file);
        }
    }
}
