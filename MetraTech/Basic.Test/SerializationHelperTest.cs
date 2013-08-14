using System;
using System.Linq;
using System.Runtime.Serialization;
using MetraTech.TestCommon;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Basic.Test
{
  [DataContract(Namespace = "MetraTech")]
  public class TestClass
  {
    [DataMember(EmitDefaultValue = false)]
    public string TestProperty1 { get; set; }

    [DataMember(EmitDefaultValue = false)]
    public bool TestProperty2 { get; set; }

  }

  [TestClass]
  public class SerializationHelperTest
  {

    [MTUnitTest]
    [TestMethod]
    [ExpectedException(typeof(ArgumentNullException))]
    public void SerializeDataContractXmlNull()
    {
      SerializationHelper.SerializeDataContractXml<TestClass>(null);
    }

    [MTUnitTest]
    [TestMethod]
    [ExpectedException(typeof(ArgumentNullException))]
    public void DesrializeDataContractXmlNull()
    {
      SerializationHelper.DeserializeDataContractXml<TestClass>(null);
    }

    [MTUnitTest]
    [TestMethod]
    [ExpectedException(typeof(ArgumentNullException))]
    public void DesrializeDataContractXmlEmpty()
    {
      SerializationHelper.DeserializeDataContractXml<TestClass>(string.Empty);
    }

    [MTUnitTest]
    [TestMethod]
    public void SerializeDesrializeDataContractXml()
    {
      var sampleInstanse = new TestClass
      {
        TestProperty1 = "test123",
        TestProperty2 = true
      };

      var serialized = SerializationHelper.SerializeDataContractXml<TestClass>(sampleInstanse);
      var deserialized = SerializationHelper.DeserializeDataContractXml<TestClass>(serialized.ToString());

      Assert.AreEqual(sampleInstanse.TestProperty1, deserialized.TestProperty1);
      Assert.AreEqual(sampleInstanse.TestProperty2, deserialized.TestProperty2);
    }

  }
}
