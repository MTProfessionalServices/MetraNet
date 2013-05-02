using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.UnitTests
{
  // To Run this fixture
  // nunit-console /fixture:MetraTech.Core.Services.UnitTests.SpecificationsServiceUnitTests /assembly:O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll
  [TestClass]
  public class SpecificationsServiceUnitTests
  {
    private static Random random;
    private string m_Name = "";
    private string m_Name2 = "";
    /// <summary>
    ///    Runs once before any of the tests are run.
    /// </summary>
    [ClassInitialize]
	public static void InitTests(TestContext testContext)
    {
      random = new Random();
    }

    /// <summary>
    ///   Runs once after all the tests are run.
    /// </summary>
    [ClassCleanup]
    public static void Dispose()
    {
    }

    [TestMethod]
    [TestCategory("SaveSpecificationCharacteristic")]
    public void SaveSpecificationCharacteristic()
    {

      SpecificationsServiceClient client = new SpecificationsServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      SpecificationCharacteristic spec = new SpecificationCharacteristic();
      int rand = random.Next();
      m_Name = String.Format("unittest_{0}", rand);
      // TODO: put in random gen
      spec.Name = m_Name;
      spec.Category = "UnitTest";
      spec.Description = "UnitTest";
      spec.DisplayName = m_Name;
      spec.SpecType = PropertyType.String;
      spec.UserEditable = true;
      spec.UserVisible = true;
      spec.IsRequired = true;
      spec.CategoryDisplayNames = SetLocalizedData("mycategory", false);
      spec.LocalizedDisplayNames = SetLocalizedData(m_Name, true);
      spec.LocalizedDescriptions = SetLocalizedData(m_Name, true);
      client.SaveSpecificationCharacteristic(ref spec);
      SpecificationCharacteristic check;
      client.GetSpecificationCharacteristic(spec.ID.Value, out check);
      Assert.AreEqual(spec.Name, check.Name);
      Assert.AreEqual(spec.Category, check.Category);
      Assert.AreEqual(spec.SpecType, check.SpecType);
      Assert.AreEqual(spec.UserEditable, check.UserEditable);
      Assert.AreEqual(spec.UserVisible, check.UserVisible);
      Assert.AreEqual(spec.IsRequired, check.IsRequired);
    }

    [TestMethod]
    [TestCategory("SaveSpecificationCharacteristicWithVals")]
    public void SaveSpecificationCharacteristicWithVals()
    {

      SpecificationsServiceClient client = new SpecificationsServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      SpecificationCharacteristic spec = new SpecificationCharacteristic();
      int rand = random.Next();
      m_Name2 = String.Format("unittest_{0}", rand);
      // TODO: put in random gen
      spec.Name = m_Name2;
      spec.Category = "UnitTest";
      spec.Description = "UnitTest";
      spec.DisplayName = m_Name2;
      spec.SpecType = PropertyType.String;
      spec.UserEditable = true;
      spec.UserVisible = true;
      spec.IsRequired = true;
      spec.CategoryDisplayNames = SetLocalizedData("mycategory", false);
      spec.LocalizedDisplayNames = SetLocalizedData(m_Name2, true);
      spec.LocalizedDescriptions = SetLocalizedData(m_Name2, true);
      spec.SpecCharacteristicValues = new List<SpecCharacteristicValue>();
      SpecCharacteristicValue v = new SpecCharacteristicValue();
      v.IsDefault = false;
      v.Value = "test";
      spec.SpecCharacteristicValues.Add(v);
      client.SaveSpecificationCharacteristic(ref spec);
      MTList<SpecCharacteristicValue> specCharVals = new MTList<SpecCharacteristicValue>();

      client.GetSpecCharacteristicValuesForSpec(spec.ID.Value, ref specCharVals);
      Assert.AreEqual(1, specCharVals.Items.Count);
      foreach (SpecCharacteristicValue val in specCharVals.Items)
      {
        Assert.AreEqual(v.Value, val.Value);
        Assert.AreEqual(v.IsDefault, v.IsDefault);
      }
    }

    [TestMethod]
    [TestCategory("UpdateSpecCharacteristicWithVals")]
    public void UpdateSpecCharacteristicWithVals()
    {
      SpecificationsServiceClient client = new SpecificationsServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      MTList<SpecificationCharacteristic> specs = new MTList<SpecificationCharacteristic>();
      MTList<SpecCharacteristicValue> vals = new MTList<SpecCharacteristicValue>();
      specs.Filters.Add(new MTFilterElement("name", MTFilterElement.OperationType.Equal, m_Name2));
      client.GetSpecificationCharacteristics(ref specs);
      
      client.GetSpecCharacteristicValuesForSpec(specs.Items[0].ID.Value, ref vals);
     
      vals.Items[0].Value = "rico";
      SpecCharacteristicValue v = new SpecCharacteristicValue();
      v.Value = "testme";
      v.IsDefault = false;
      vals.Items.Add(v);
      SpecificationCharacteristic s = specs.Items[0];
      s.SpecCharacteristicValues = vals.Items;
      client.SaveSpecificationCharacteristic(ref s);

      MTList<SpecCharacteristicValue> specCharVals = new MTList<SpecCharacteristicValue>();

      client.GetSpecCharacteristicValuesForSpec(s.ID.Value, ref specCharVals);
      Assert.AreEqual(2, specCharVals.Items.Count);
    }

    [TestMethod]
    [TestCategory("GetSpecificationCharacteristics")]
    public void GetSpecificationCharacteristics()
    {

      SpecificationsServiceClient client = new SpecificationsServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      MTList<SpecificationCharacteristic> specs = new MTList<SpecificationCharacteristic>();
      client.GetSpecificationCharacteristics(ref specs);
      int id = specs.Items[0].ID.Value;
      SpecificationCharacteristic spec;
      client.GetSpecificationCharacteristic(id, out spec);
      Assert.IsNotNull(spec);
      // additional test logic
    }
    
    [TestMethod]
    [TestCategory("DeleteSpecificationCharacteristic")]
    public void DeleteSpecificationCharacteristic()
    {
      SpecificationsServiceClient client = new SpecificationsServiceClient();
      client.ClientCredentials.UserName.UserName = "su";
      client.ClientCredentials.UserName.Password = "su123";

      client.Open();
      MTList<SpecificationCharacteristic> specs = new MTList<SpecificationCharacteristic>();
      client.GetSpecificationCharacteristics(ref specs);
      int count = specs.Items.Count; 
      SpecificationCharacteristic sc = specs.Items[0];
      client.DeleteSpecificationCharacteristic(sc.ID.Value);

      MTList<SpecificationCharacteristic> afterDelete = new MTList<SpecificationCharacteristic>();
      client.GetSpecificationCharacteristics(ref afterDelete);
      Assert.AreEqual((count - 1), afterDelete.Items.Count);
    }

    #region private methods
    private Dictionary<LanguageCode, string> SetLocalizedData(string name, bool popDesc)
    {
      Dictionary<LanguageCode, string> dict = new Dictionary<LanguageCode, string>();
      if (popDesc)
      {
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, String.Format("{0} English Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, String.Format("{0} Japanese Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, String.Format("{0} Italian Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, String.Format("{0} French Description", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, String.Format("{0} German Description", name));
      }
      else
      {
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, String.Format("{0} English names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, String.Format("{0} Japanese Names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, String.Format("{0} Italian Names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, String.Format("{0} French Names", name));
        dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, String.Format("{0} German Names", name));
      }
      return dict;
    }
    #endregion
  }
}
