using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Linq;
using MetraTech.Core.Services;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using PropertyType = MetraTech.DomainModel.Enums.Core.Global.PropertyType;

namespace MetraTech.MTPCImportDynamicProperties
{
  [Guid("B5E28D05-6135-4E37-A45B-FC88D4E958BF")]
  [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
  public interface IDynamicPropertiesImport
  {
    [DispId(1)]
    bool ImportSpecCharacteristicForPO(long productOfferingID, string inputXML, string userName, string password,
                                       string nameSpace);

    [DispId(2)]
    bool ImportCharacteristicValuesForSub(long subscriptionID, string inputXML, string userName, string password,
                                          string nameSpace);
  }


  [Guid("C500CCD7-BD2A-449E-9CC5-EA4D73F6FB29")]
  [ClassInterface(ClassInterfaceType.None)]
  [ProgId("MetraTech.MTPCImportDynamicProperties.DynamicPropertiesImport")]
  [ComVisible(true)]
  public class DynamicPropertiesImport : IDynamicPropertiesImport
  {
    #region private members

    private static Logger mLogger = new Logger("[MTPCImportDynamicProperties]");

    #endregion

    public bool ImportSpecCharacteristicForPO(long productOfferingID, string inputXML, string userName, string password, string nameSpace)
    {
      //System.Diagnostics.Debugger.Launch();
      try
      {
        if (productOfferingID > 0 && !string.IsNullOrEmpty(inputXML) && !string.IsNullOrEmpty(userName) && !string.IsNullOrEmpty(password))
        {
          mLogger.LogDebug("Start Import SpecCharacteristic For PO");

          List<SpecificationCharacteristic> specificationCharacteristics = LoadSpecificationCharacteristicFromXML(inputXML);

          var service = new SpecificationsService();
          service.InitializeSecurity(userName, !string.IsNullOrEmpty(nameSpace) ? nameSpace : "mt", password);

          foreach (var specificationCharacteristic in specificationCharacteristics)
          {
            service.SaveOrMapSpecificationCharacteristicForEntity(Convert.ToInt32(productOfferingID), EntityType.ProductOffering, specificationCharacteristic);
          }

          mLogger.LogDebug("Import SpecCharacteristic For PO - successfully");
        }
        else
        {
          mLogger.LogDebug("Incorrect productOfferingID or input XML or credential");
          return false;
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception in ImportSpecCharacteristicForPO", e);
        return false;
      }
      return true;
    }

    public bool ImportCharacteristicValuesForSub(long subscriptionID, string inputXML, string userName, string password, string nameSpace)
    {
      try
      {
        if (subscriptionID > 0 && !string.IsNullOrEmpty(inputXML) && !string.IsNullOrEmpty(userName) && !string.IsNullOrEmpty(password))
        {
          mLogger.LogDebug("Start Import CharacteristicValues For Subscription");

          List<CharacteristicValue> characteristicValues = LoadCharacteristicValuesFromXML(inputXML);

          SubscriptionService service = new SubscriptionService();
          service.InitializeSecurity(userName, !string.IsNullOrEmpty(nameSpace) ? nameSpace : "mt", password);

          service.SaveCharacteristicValue(characteristicValues, subscriptionID);  

          mLogger.LogDebug("Import CharacteristicValues For PO - successfully");
        }
        else
        {
          mLogger.LogDebug("Incorrect subscriptionID or input XML or credential");
          return false;
        }
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception in ImportCharacteristicValuesForSub", e);
        return false;
      }
      return true;
    }

    private List<CharacteristicValue> LoadCharacteristicValuesFromXML(string inputXML)
    {
      var result = new List<CharacteristicValue>();

      XDocument doc = XDocument.Parse(inputXML);

      var characteristicValues =
        doc.Root.Elements("charvalues").Elements("charvalue");

      foreach (var characteristicValue in characteristicValues)
      {
        if (characteristicValue.Elements("property").Any())
        {
          CharacteristicValue characteristicValueResult = new CharacteristicValue();
          characteristicValueResult.Value = characteristicValue.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("nm_value")).Value;

          characteristicValueResult.StartDate = DateTime.Parse(characteristicValue.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_start_date")).Value);

          characteristicValueResult.EndDate = DateTime.Parse(characteristicValue.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_end_date")).Value);

          characteristicValueResult.SpecName = characteristicValue.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("nm_value")).Value;

          characteristicValueResult.SpecType =
            (PropertyType) Enum.Parse(typeof (PropertyType), characteristicValue.Elements("property").FirstOrDefault(
              p => p.Attribute("name").Value.Equals("c_spec_type")).Value);
          
          characteristicValueResult.SpecCharValId = int.Parse(characteristicValue.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("id_scv")).Value);

          result.Add(characteristicValueResult);
        }
      }

      return result;
    }


    private List<SpecificationCharacteristic> LoadSpecificationCharacteristicFromXML(string inputXML)
    {
      List<SpecificationCharacteristic> result = new List<SpecificationCharacteristic>();

      XDocument doc = XDocument.Parse(inputXML);

      var specificationcharacteristics =
        doc.Root.Elements("dynamicextendedproperties").Elements("specificationcharacteristic");

      foreach (var speccharacteristics in specificationcharacteristics)
      {
        if (speccharacteristics.Elements("property").Any())
        {
          SpecificationCharacteristic specificationCharacteristic = new SpecificationCharacteristic();

          specificationCharacteristic.SpecType =
            (PropertyType) Enum.Parse(typeof (PropertyType), speccharacteristics.Elements("property").FirstOrDefault(
              p => p.Attribute("name").Value.Equals("c_spec_type")).Value);
          specificationCharacteristic.Category = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_category")).Value;

          specificationCharacteristic.CategoryDisplayNames = new Dictionary<LanguageCode, string>();
          //specificationCharacteristic.CategoryDisplayNames.Add(LanguageCode.US, speccharacteristics.Elements("property").FirstOrDefault(
          //  p => p.Attribute("name").Value.Equals("c_category")).Value);

          specificationCharacteristic.IsRequired = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_is_required")).Value.Equals("Y");

          specificationCharacteristic.Name = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("nm_name")).Value;
          specificationCharacteristic.Description = speccharacteristics.Elements("property").FirstOrDefault(
           p => p.Attribute("name").Value.Equals("nm_description")).Value;
          specificationCharacteristic.UserVisible = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_user_visible")).Value.Equals("Y");
          specificationCharacteristic.UserEditable = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_user_editable")).Value.Equals("Y");
          specificationCharacteristic.MinValue = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_min_value")).Value;
          specificationCharacteristic.MaxValue = speccharacteristics.Elements("property").FirstOrDefault(
            p => p.Attribute("name").Value.Equals("c_max_value")).Value;

          specificationCharacteristic.LocalizedDisplayNames = GetLocalizedValues(speccharacteristics, "specificationcharacteristiclocalizednames");

          specificationCharacteristic.LocalizedDescriptions = GetLocalizedValues(speccharacteristics, "specificationcharacteristiclocalizeddescription");

          specificationCharacteristic.SpecCharacteristicValues = LoadSpecCharacteristicValuesFromXML(speccharacteristics);

          result.Add(specificationCharacteristic);
        }
      }

      return result;
    }

    
    private LanguageCode GetEnumValue(string iValue, out bool enumFound)
    {
        LanguageCode result = LanguageCode.GB;
        enumFound = true;
        var codesList = iValue.Split(new char[] {'-', ' '}, 10);

        if (codesList.Reverse().Any(code => Enum.TryParse(code, true, out result)))
        {
          return result;
        }
        enumFound = false;
        return result;

    }

    private Dictionary<LanguageCode, string> GetLocalizedValues(XElement speccharacteristicsEl, string tagName)
    {
      var result = new Dictionary<LanguageCode, string>();

      var xElement = speccharacteristicsEl.Element(tagName);
      if (xElement != null)
      {
        var localizedNames = xElement.Elements("language");

        foreach (var nameElement in localizedNames)
        {
          var xAttribute = nameElement.Attribute("name");
          if (xAttribute == null) continue;
          var enumFound = false;
          var languageCode = GetEnumValue(xAttribute.Value, out enumFound);
          if (enumFound)
            result.Add(languageCode, nameElement.Value);
        }
      }

      return result;
    }

    private List<SpecCharacteristicValue> LoadSpecCharacteristicValuesFromXML(XElement xElement)
    {
      var result = new List<SpecCharacteristicValue>();

      foreach (var speccharvalue in xElement.Elements("speccharvalues").Elements("speccharvalue"))
      {
        if (speccharvalue.Elements("property").Any())
        {
          var specCharacteristicValue = new SpecCharacteristicValue();

          specCharacteristicValue.IsDefault = speccharvalue.Elements("property").FirstOrDefault(
              p => p.Attribute("name").Value.Equals("c_is_default")).Value.Equals("Y");
          specCharacteristicValue.Value = speccharvalue.Elements("property").FirstOrDefault(
              p => p.Attribute("name").Value.Equals("nm_value")).Value;

          specCharacteristicValue.LocalizedDisplayValues = GetLocalizedValues(speccharvalue, "LocalizedSpecCharValue");

          result.Add(specCharacteristicValue);
        }
      }

      return result;
    }
  }
}
