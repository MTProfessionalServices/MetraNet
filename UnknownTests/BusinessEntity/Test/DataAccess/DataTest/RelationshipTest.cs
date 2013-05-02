using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.RelationshipTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  [TestFixture]
  public class RelationshipTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    [Test]
    public void TestOneToMany()
    {
      var a = new BmeTest.Group1.G1A();
      a.G1A_StringProp = "G1A_StringProp";
      StandardRepository.Instance.SaveInstance(ref a);

      var b = new BmeTest.Group1.G1B();
      b.G1B_StringProp = "G1B_StringProp";
      StandardRepository.Instance.SaveInstance(ref b);

      StandardRepository.Instance.CreateRelationship(a, b);
      var mtList = new MTList<DataObject>();
      var mtListNew =
        StandardRepository.Instance.LoadInstancesFor(typeof (BmeTest.Group1.G1B).FullName,
                                                     typeof (BmeTest.Group1.G1A).FullName,
                                                     a.Id,
                                                     mtList);
      Assert.AreEqual(1, mtListNew.Items.Count);
      Assert.AreEqual(b.Id, mtListNew.Items[0].Id, "Mismatched Id after running LoadInstancesFor");
    }

    [Test]
    public void TestOneToManyCrossGroup()
    {
      var g1b = new BmeTest.Group1.G1B();
      g1b.G1B_StringProp = "G1B_StringProp";
      StandardRepository.Instance.SaveInstance(ref g1b);

      var g2b = new BmeTest.Group2.G2B();
      g2b.G2B_StringProp = "G2B_StringProp";
      StandardRepository.Instance.SaveInstance(ref g2b);

      StandardRepository.Instance.CreateRelationship(g1b, g2b);
      var mtList = new MTList<DataObject>();
      var mtListNew =
        StandardRepository.Instance.LoadInstancesFor(typeof(BmeTest.Group1.G1B).FullName,
                                                     typeof(BmeTest.Group2.G2B).FullName,
                                                     g2b.Id,
                                                     mtList);
      Assert.AreEqual(1, mtListNew.Items.Count);
      Assert.AreEqual(g1b.Id, mtListNew.Items[0].Id, "Mismatched Id after running LoadInstancesFor");
    }
  }
}
