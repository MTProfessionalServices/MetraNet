using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BmeTest.Group1;
using BmeTest.Group2;
using BmeTest.Group3;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.MiscTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  [TestFixture]
  public class MiscTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    [Test]
    [Category("TestLoadInstancesFor")]
    public void TestLoadInstancesFor()
    {
      var random = new Random();

      var g1A = new G1A();
      g1A.G1A_StringProp = "G1A_StringProp - " + random.Next();
      StandardRepository.Instance.SaveInstance(ref g1A);

      for (int i = 0; i < 5; i++)
      {
        var g1B = new G1B();
        g1B.G1B_StringProp = "G1B_StringProp - " + random.Next();
        StandardRepository.Instance.SaveInstance(ref g1B);
        StandardRepository.Instance.CreateRelationship(g1A, g1B);
      }

      var mtList = new MTList<G1B>();
      StandardRepository.Instance.LoadInstancesFor<G1A, G1B>(g1A.Id, ref mtList);

      Assert.AreEqual(5, mtList.Items.Count, "Expected 5 G1B items");
    }

    [Test]
    [Category("TestLoadInstances")]
    public void TestLoadInstances()
    {
      var random = new Random();
      for (int i = 0; i < 5; i++)
      {
        var g1A = new G1A();
        g1A.G1A_StringProp = "G1A_StringProp - " + random.Next();
        StandardRepository.Instance.SaveInstance(ref g1A);
      }

      var mtList = new MTList<G1A>();
      StandardRepository.Instance.LoadInstances(ref mtList);
    }


    [Test]
    [Category("TestMultiPropertyBusinessKey")]
    public void TestMultiPropertyBusinessKey()
    {
      var random = new Random();
      var g1MultiPropertyBusinessKey = new G1MultiBusinessKey();
      g1MultiPropertyBusinessKey.G1MultiBusinessKeyBusinessKey.StringPropBk = "StringPropBk - " + random.Next();
      g1MultiPropertyBusinessKey.G1MultiBusinessKeyBusinessKey.IntPropBk = random.Next();
      g1MultiPropertyBusinessKey.G1MultiBusinessKeyBusinessKey.Int64PropBk = random.Next();
      g1MultiPropertyBusinessKey.StringProp = "abc";

      StandardRepository.Instance.SaveInstance(g1MultiPropertyBusinessKey);

      var loadInstance = StandardRepository.Instance.LoadInstanceByBusinessKey<G1MultiBusinessKey, G1MultiBusinessKeyBusinessKey>
       (g1MultiPropertyBusinessKey.G1MultiBusinessKeyBusinessKey);

    }


    [Test]
    [Category("TestAddDataObjectToDictionary")]
    public void TestAddDataObjectToDictionary()
    {
      var g2A = new G2A();
      g2A.G2A_StringProp = "G2A_StringProp";

      var g2As = new Dictionary<G2A, int>();
      g2As.Add(g2A, 1);

      int value;
      Assert.IsTrue(g2As.TryGetValue(g2A, out value));
      Assert.AreEqual(1, value);
    }

    [Test]
    [Category("TestLoadInstancesUsingIdAsFilter")]
    public void TestLoadInstancesUsingIdAsFilter()
    {
      var a = new G1A();
      a.G1A_StringProp = "G1A_StringProp";
      
      StandardRepository.Instance.SaveInstance(ref a);
      Assert.AreNotEqual(Guid.Empty, a.Id);

      // Load using 'Id' as filter
      var mtList = new MTList<DataObject>();
      mtList.Filters.Add(new MTFilterElement("Id", MTFilterElement.OperationType.Equal, a.Id));
      MTList<DataObject> results = StandardRepository.Instance.LoadInstances(typeof(G1A).FullName, mtList);
      Assert.IsNotNull(results);
      Assert.AreEqual(1, results.Items.Count);

      var g1a = results.Items[0] as G1A;
      Assert.IsNotNull(g1a);
      Assert.AreEqual("G1A_StringProp", g1a.G1A_StringProp);
    }

    [Test]
    [Category("TestSaveInstanceLoadInstance")]
    public void TestSaveInstanceLoadInstance()
    {
      // Create G1A
      var g1a = new G1A();
      g1a.G1A_StringProp = "G1A_StringProp";

      StandardRepository.Instance.SaveInstance(ref g1a);
      Assert.AreNotEqual(Guid.Empty, g1a.Id);

      // LoadInstance
      G1A loadInstance = StandardRepository.Instance.LoadInstance<G1A>(g1a.Id);
      Assert.IsNotNull(loadInstance);
      Assert.AreEqual("G1A_StringProp", loadInstance.G1A_StringProp);
    }

    [Test]
    [Category("TestLoadInstanceByBusinessKey")]
    public void TestLoadInstanceByBusinessKey()
    {
      // Create G1A
      var g1a = new G1A();
      g1a.G1A_StringProp = "G1A_StringProp";

      StandardRepository.Instance.SaveInstance(ref g1a);
      Assert.AreNotEqual(Guid.Empty, g1a.Id);

      // LoadInstanceByBusinessKey
      G1A loadInstance = StandardRepository.Instance.LoadInstanceByBusinessKey<G1A, G1ABusinessKey>(g1a.G1ABusinessKey);
      Assert.IsNotNull(loadInstance);
      Assert.AreEqual("G1A_StringProp", loadInstance.G1A_StringProp);
    }

    [Test]
    [Category("TestSaveInstances")]
    public void TestSaveInstances()
    {
      var dataObjects = new List<G1A>();
      for (int i = 0; i < 5; i++)
      {
        dataObjects.Add(new G1A() {G1A_StringProp = "G1A_StringProp"});
      }

      StandardRepository.Instance.SaveInstances(ref dataObjects);
      dataObjects.ForEach(d => Assert.AreNotEqual(Guid.Empty, d.Id));
    }

    [Test]
    [Category("TestCreateInstanceFor")]
    public void TestCreateInstanceFor()
    {
      // Create G1A
      var g1a = new G1A();
      g1a.G1A_StringProp = "G1A_StringProp";

      StandardRepository.Instance.SaveInstance(ref g1a);
      Assert.AreNotEqual(Guid.Empty, g1a.Id);

      // Create G1B
      var g1b = new G1B();
      g1b.G1B_StringProp = "G1B_StringProp";

      // CreateInstanceFor
      StandardRepository.Instance.CreateInstanceFor<G1A, G1B>(g1a.Id, ref g1b);
      Assert.AreNotEqual(Guid.Empty, g1b.Id);
    }

    [Test]
    [Category("TestCreateInstancesFor")]
    public void TestCreateInstancesFor()
    {
      // Create G1A
      var g1a = new G1A();
      g1a.G1A_StringProp = "G1A_StringProp";

      StandardRepository.Instance.SaveInstance(ref g1a);
      Assert.AreNotEqual(Guid.Empty, g1a.Id);

      // Create G1B's
      var dataObjects = new List<G1B>();
      for (int i = 0; i < 5; i++)
      {
        dataObjects.Add(new G1B() { G1B_StringProp = "G1B_StringProp" });
      }

      // CreateInstancesFor
      StandardRepository.Instance.CreateInstancesFor<G1A, G1B>(g1a.Id, ref dataObjects);
      foreach(G1B g1b in dataObjects)
      {
        Assert.AreNotEqual(Guid.Empty, g1b.Id);
      }
    }

    [Test]
    [Category("TestCreateRelationship")]
    public void TestCreateRelationship()
    {
      // Create G1A
      var g1a = new G1A();
      g1a.G1A_StringProp = "G1A_StringProp";

      StandardRepository.Instance.SaveInstance(ref g1a);
      Assert.AreNotEqual(Guid.Empty, g1a.Id);

      // Create G1B
      var g1b = new G1B();
      g1b.G1B_StringProp = "G1B_StringProp";

      StandardRepository.Instance.SaveInstance(ref g1b);
      Assert.AreNotEqual(Guid.Empty, g1b.Id);

      // CreateRelationship
      StandardRepository.Instance.CreateRelationship(g1a, g1b);
      
      // 
    }

  }
}
