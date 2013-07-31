using System.Diagnostics;
using VertexServerTest.Properties;
using VertexSocketService;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace VertexServerTest
{
    
    
    /// <summary>
    ///This is a test class for VertexTest and is intended
    ///to contain all VertexTest Unit Tests
    ///</summary>
  [TestClass]
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
