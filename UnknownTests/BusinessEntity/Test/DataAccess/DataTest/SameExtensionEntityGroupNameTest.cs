using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BmeTest.BusinessKey;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

using BmeTest.BmeTest;

//
// To run this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.SameExtensionEntityGroupNameTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  /// <summary>
  ///   For these tests to run, the BmeTest extension must be present and synchronized.
  /// </summary>
  [TestFixture]
  public class SameExtensionEntityGroupNameTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    /// <summary>
    /// </summary>
    [Test]
    [Category("TestCrudForA")]
    public void TestCrudForA()
    {
      // Create A
      var a = new BmeTest.BmeTest.A {StringProp = "abcd", IntProp = 123};
      StandardRepository.Instance.SaveInstance(ref a);

      // Check that the business key has been created
      Assert.AreNotEqual(a.ABusinessKey.InternalKey, Guid.Empty,
                         "Expected 'ABusinessKey.InternalKey' to be a non-empty Guid");

      // Load A using id
      var loadA = StandardRepository.Instance.LoadInstance(typeof(BmeTest.BmeTest.A).FullName, a.Id) as BmeTest.BmeTest.A;
      Assert.AreEqual("abcd", loadA.StringProp, "Mismatched string property value");
      Assert.AreEqual(123, loadA.IntProp, "Mismatched int property value");

      // Update A
      loadA.StringProp = "abcde";
      loadA.IntProp = 1234;

      // Save A
      StandardRepository.Instance.SaveInstance(loadA);

      // Load A
      loadA = StandardRepository.Instance.LoadInstance(typeof(BmeTest.BmeTest.A).FullName, a.Id) as BmeTest.BmeTest.A;
      Assert.AreEqual("abcde", loadA.StringProp, "Mismatched string property value");
      Assert.AreEqual(1234, loadA.IntProp, "Mismatched int property value");

      // Delete A
      StandardRepository.Instance.Delete(typeof(BmeTest.BmeTest.A).FullName, a.Id);

      // Load A
      loadA = StandardRepository.Instance.LoadInstance(typeof(BmeTest.BmeTest.A).FullName, a.Id) as BmeTest.BmeTest.A;
      Assert.IsNull(loadA, "expected A to be null");
    }

    [Test]
    [Category("TestHistoryForA")]
    public void TestHistoryForA()
    {
      // Create A
      var a = new BmeTest.BmeTest.A { StringProp = "abcd", IntProp = 123 };
      StandardRepository.Instance.SaveInstance(ref a);

      // Load by business key
      var b = 
        StandardRepository.Instance.LoadInstanceByBusinessKey(typeof (BmeTest.BmeTest.A).FullName,
                                                              (BusinessKey)a.ABusinessKey) as BmeTest.BmeTest.A;
      Assert.IsNotNull(b);
      Assert.AreEqual(a.Id, b.Id, "Mismtached Id");
      Assert.AreEqual(a.StringProp, b.StringProp, "Mismtached StringProp");
      Assert.AreEqual(a.IntProp, b.IntProp, "Mismtached IntProp");

      // Retrieve history for A
      var history =
        StandardRepository.Instance.LoadInstanceHistory(typeof(BmeTest.BmeTest.A).FullName, a.Id, DateTime.Now) as BmeTest.BmeTest.A;

      Assert.IsNotNull(history);
      Assert.AreEqual(a.Id, history.Id, "Mismtached Id");
      Assert.AreEqual(a.StringProp, history.StringProp, "Mismtached StringProp");
      Assert.AreEqual(a.IntProp, history.IntProp, "Mismtached IntProp");
    }

  }
}
