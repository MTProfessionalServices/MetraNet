using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

using BmeTest.BusinessKey;

//
// To run this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.BusinessKeyTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  /// <summary>
  ///   For these tests to run, the BmeTest extension must be present and synchronized.
  /// </summary>
  [TestFixture]
  public class BusinessKeyTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    /// <summary>
    ///   Create, read, update and delete instance data for a BME with an InternalKey
    ///   The predefined BME is: BmeTest.BusinessKey.A
    /// </summary>
    [Test]
    public void TestCRUDInternalKey()
    {
      // Create A
      var a = new A {StringProp = "abcd"};
      StandardRepository.Instance.SaveInstance(ref a);

      // Check that the business key has been created
      Assert.AreNotEqual(a.ABusinessKey.InternalKey, Guid.Empty,
                         "Expected 'ABusinessKey.InternalKey' to be a non-empty Guid");

      // Load A using business key
      a = StandardRepository.Instance.LoadInstanceByBusinessKey(typeof (A).FullName, (BusinessKey)a.ABusinessKey) as A;

    }
  }
}
