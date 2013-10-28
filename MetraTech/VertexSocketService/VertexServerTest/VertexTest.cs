using System.Diagnostics;
using VertexServer.Test.Properties;
using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace VertexServer.Test
{
  [TestClass]
  [Ignore]
  public class VertexTest
  {
    /// <summary>
    ///A test for CalculateTaxes
    ///</summary>
    [TestMethod]
    public void CalculateVertexTaxesTest()
    {
      var po = new PrivateObject(typeof (Vertex));
      var st = new Stopwatch();
      st.Start();
      for (var i = 0; i < 5000; i++)
      {
        var actual = po.Invoke("CalculateTaxes", new object[] {Resources.TestRequest});
        Assert.AreEqual(Resources.TestResponse, actual);
      }
      st.Stop();
      Assert.AreEqual(1000, st.ElapsedMilliseconds);
    }
  }
}
