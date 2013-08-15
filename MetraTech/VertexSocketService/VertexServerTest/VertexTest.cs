using System.Diagnostics;
using VertexServerTest.Properties;
using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace VertexServerTest
{
  [TestClass]
  [Ignore]
  public class VertexTest
  {
    /// <summary>
    ///A test for CalculateTaxes
    ///</summary>
    [TestMethod]
    [DeploymentItem("VertexSocketService.exe")]
    public void CalculateVertexTaxesTest()
    {
      var target = new Vertex_Accessor();
      target.InitializeVertex();
      var st = new Stopwatch();
      st.Start();
      for (var i = 0; i < 5000; i++)
      {
        var actual = target.CalculateTaxes(Resources.TestRequest);
        Assert.AreEqual(Resources.TestResponse, actual);
      }
      st.Stop();
      Assert.AreEqual(1000, st.ElapsedMilliseconds);
    }
  }
}
