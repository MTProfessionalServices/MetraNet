using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;

using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.BusinessKeyTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class BusinessKeyTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      //// Create BE directories for 'MetadataTest' extension.
      //SystemConfig.CreateBusinessEntityDirectories(extensionName, entityGroupName);

      //// Clean BE directories for 'MetadataTest' extension.
      //SystemConfig.CleanEntityDir(extensionName, entityGroupName);

      //MetadataRepository.Instance.InitializeFromFileSystem();

    }

    [Test]
    [Category("Sync")]
    public void Sync()
    {
      // MetadataAccess.Instance.Synchronize("SmokeTest", "OrderManagement");
      //MetadataAccess.Instance.Synchronize("Core", "OrderManagement");
    }


    /// <summary>
    ///   Create an entity called 'A' without specifying a BusinessKey property.
    ///   Save it. 
    ///   The system should generate a BusinessKey property for the entity where:
    ///     - the type of the Property will be a generated class called 'ABusinessKey'
    ///     - the name of the Property will be 'BusinessKey'
    ///     - 'ABusinessKey' will have a single property called 'InternalKey' of type Guid
    /// </summary>
    // [Test]
    [Ignore]
    [Category("CreateEntityWithoutSpecifyingBusinessKey")]
    public void CreateEntityWithoutSpecifyingBusinessKey()
    {
      string entityName = "A";
      string entityFullName = Name.GetEntityFullName(extensionName, entityGroupName, "A");

      var entity =
        new Entity(entityFullName)
        {
          Category = Category.ConfigDriven,
          Label = entityName + " Label",
          PluralName = entityName + "s",
          Description = entityName + " Description"
        };

      MetadataAccess.Instance.SaveEntity(entity);
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      // Save Data
      Type dataObjectType = Type.GetType(entity.AssemblyQualifiedName);
      Assert.IsNotNull(dataObjectType, String.Format("Cannot retrieve type '{0}'", entity.AssemblyQualifiedName));

      object dataObject = Activator.CreateInstance(dataObjectType);
      Assert.IsNotNull(dataObject, String.Format("Cannot create instance of type '{0}'", entity.AssemblyQualifiedName));

      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      var savedDataObject = standardRepository.SaveInstance((DataObject)dataObject);
      Assert.AreNotEqual(Guid.Empty, savedDataObject.Id);
      MethodInfo methodInfo = dataObject.GetType().GetMethod("GetInternalBusinessKey");
      Guid internalKey = (Guid)methodInfo.Invoke(savedDataObject, null);
      Assert.AreNotEqual(Guid.Empty, internalKey);

      // Load Data
      var loadDataObject = standardRepository.LoadInstance(entity.FullName, savedDataObject.Id);
      Guid loadInternalKey = (Guid)methodInfo.Invoke(loadDataObject, null);
      Assert.AreNotEqual(Guid.Empty, loadInternalKey);
      Assert.AreEqual(internalKey, loadInternalKey);
    }

    // [Test]
    [Ignore]
    [Category("ExtractBusinessKeyPropertyColumnNames")]
    public void ExtractBusinessKeyPropertyColumnNames()
    {
      string entityName = "B";
      string entityFullName = Name.GetEntityFullName(extensionName, entityGroupName, entityName);

      var entity =
        new Entity(entityFullName)
        {
          Category = Category.ConfigDriven,
          Label = entityName + " Label",
          PluralName = entityName + "s",
          Description = entityName + " Description"
        };

      // Create business key properties of valid types
      string stringPropertyName = "StringProp";
      string stringPropertyValue = "StringProp";
      var stringProperty = new Property(stringPropertyName, "string");
      stringProperty.IsBusinessKey = true;
      entity.AddProperty(stringProperty);

      string int32PropertyName = "Int32Prop";
      int int32PropertyValue = Int32.MinValue;
      var int32Property = new Property(int32PropertyName, "int");
      int32Property.IsBusinessKey = true;
      entity.AddProperty(int32Property);

      string int64PropertyName = "Int64Prop";
      Int64 int64PropertyValue = Int64.MaxValue;
      var int64Property = new Property(int64PropertyName, "Int64");
      int64Property.IsBusinessKey = true;
      entity.AddProperty(int64Property);

      string guidPropertyName = "GuidProp";
      Guid guidPropertyValue = Guid.NewGuid();
      var guidProperty = new Property(guidPropertyName, "Guid");
      guidProperty.IsBusinessKey = true;
      entity.AddProperty(guidProperty);

      MetadataAccess.Instance.SaveEntity(entity);
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      // Create BusinessKey by itself and test
      var businessKey = BusinessKey.GetBusinessKey(entity.FullName);

      List<PropertyInfo> propertyInfos = businessKey.GetProperties();
      foreach(PropertyInfo propertyInfo in propertyInfos)
      {
        if (propertyInfo.Name == stringPropertyName)
        {
          propertyInfo.SetValue(businessKey, stringPropertyValue, null);
        }
        else if (propertyInfo.Name == int32PropertyName)
        {
          propertyInfo.SetValue(businessKey, int32PropertyValue, null);
        }
        else if (propertyInfo.Name == int64PropertyName)
        {
          propertyInfo.SetValue(businessKey, int64PropertyValue, null);
        }
        else if (propertyInfo.Name == guidPropertyName)
        {
          propertyInfo.SetValue(businessKey, guidPropertyValue, null);
        }
      }

      Dictionary<string, string> businessKeyPropertyColumnNames = businessKey.GetPropertyColumnNames();

      Assert.IsTrue(businessKeyPropertyColumnNames.ContainsKey(stringPropertyName));
      Assert.AreEqual(Property.GetColumnName(stringPropertyName),
                      businessKeyPropertyColumnNames[stringPropertyName]);

      Assert.IsTrue(businessKeyPropertyColumnNames.ContainsKey(int32PropertyName));
      Assert.AreEqual(Property.GetColumnName(int32PropertyName),
                      businessKeyPropertyColumnNames[int32PropertyName]);

      Assert.IsTrue(businessKeyPropertyColumnNames.ContainsKey(int64PropertyName));
      Assert.AreEqual(Property.GetColumnName(int64PropertyName),
                      businessKeyPropertyColumnNames[int64PropertyName]);

      Assert.IsTrue(businessKeyPropertyColumnNames.ContainsKey(guidPropertyName));
      Assert.AreEqual(Property.GetColumnName(guidPropertyName),
                      businessKeyPropertyColumnNames[guidPropertyName]);
    }

   
    #region Data

    private static readonly ILog logger = LogManager.GetLogger("BusinessKeyTest");

    private string extensionName = "BusinessKeyTest";
    private string entityGroupName = "Common";

    #endregion
  }
}
