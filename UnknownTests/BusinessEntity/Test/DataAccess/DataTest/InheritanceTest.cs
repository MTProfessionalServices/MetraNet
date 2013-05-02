using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BmeTest.Group1;
using BmeTest.Group3;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.InheritanceTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  [TestFixture]
  public class InheritanceTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    [Test]
    public void TestCrudForDerived()
    {
      // G1Root <-- G2A <-- G3A
      var g3a = new G3A();
      g3a.G3A_StringProp = "G3A_StringProp";
      g3a.G2A_StringProp = "G2A_StringProp";
      g3a.G1Root_StringProp = "G1Root_StringProp";

      StandardRepository.Instance.SaveInstance(ref g3a);

      Assert.AreNotEqual(Guid.Empty, g3a.Id);

      // Load root
      var g1Root = StandardRepository.Instance.LoadInstance(typeof(G1Root).FullName, g3a.Id);
      Assert.IsNotNull(g1Root);
      var actual = g1Root as G3A;
      Assert.IsNotNull(actual);
      Assert.AreEqual("G3A_StringProp", actual.G3A_StringProp);
      Assert.AreEqual("G2A_StringProp", actual.G2A_StringProp);
      Assert.AreEqual("G1Root_StringProp", actual.G1Root_StringProp);
    }

  }
}
