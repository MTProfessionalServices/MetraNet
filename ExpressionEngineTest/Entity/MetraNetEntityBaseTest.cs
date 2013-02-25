using MetraTech.ExpressionEngine.Entities;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class MetraNetEntityBaseTest
    {

        [TestMethod()]
        public void GetFileNameTest()
        {
            var entity = EntityFactory.CreateProductViewEntity("Foo", null);
            entity.Extension = "Core";
            var file = entity.GetFileNameGivenExtensionsDirectory(@"C:\Temp\Extensions");
            Assert.AreEqual(@"C:\Temp\Extensions\Core\ProductViews\Foo.xml", file);
        }
    }
}
