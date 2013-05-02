using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BmeTest.Group1;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.DataTest.HistoryTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//
namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest.HistoryTest
{
  [TestFixture]
  public class HistoryTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      DataTest.Initialize();
    }

    [Test]
    public void TestHistory()
    {
      var g1a = new G1A();
      g1a.G1A_StringProp = "G1A_StringProp";
      StandardRepository.Instance.SaveInstance(ref g1a);

      Assert.IsTrue(g1a is IRecordHistory);

      G1A historyG1A = StandardRepository.Instance.LoadInstanceHistory<G1A>(g1a.Id, DateTime.Now);
      Assert.IsNotNull(historyG1A);
      Assert.AreEqual("G1A_StringProp", historyG1A.G1A_StringProp);
    }

   
  }
}
