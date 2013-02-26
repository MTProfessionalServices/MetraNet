using MetraTech.ExpressionEngine.Entities;
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
            var file = entity.GetFileNameGivenExtensionsDirectory(@"C:\Temp\Extensions");
            Assert.AreEqual(@"C:\Temp\Extensions\Core\ProductViews\Foo.xml", file);
        }
    }
}
