using System;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DomainModel.Enums.Core.Global;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.DefaultValueTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class DefaultValueTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Create BE directories
      SystemConfig.CreateBusinessEntityDirectories(extensionName, entityGroupName);

      // Clean BE directories
      Name.CleanEntityDir(extensionName, entityGroupName);

    }

    [Test]
    [Category("CreateEntityWithDefaultValues")]
    public void CreateEntityWithDefaultValues()
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

      // Nullable
      var dateTime = DateTime.Now;
      var guid = Guid.NewGuid();
      entity.AddProperty(new Property("boolProp", "bool") {DefaultValue = "false"});
      entity.AddProperty(new Property("dateTimeProp", "DateTime") { DefaultValue = dateTime.ToString() });
      entity.AddProperty(new Property("decimalProp", "decimal") {DefaultValue = "1.11"});
      entity.AddProperty(new Property("doubleProp", "double") { DefaultValue = "1.22" });
      entity.AddProperty(new Property("guidProp", "Guid") { DefaultValue = guid.ToString() });
      entity.AddProperty(new Property("int32Prop", "int") { DefaultValue = Int32.MaxValue.ToString() });
      entity.AddProperty(new Property("int64Prop", "Int64") { DefaultValue = Int64.MaxValue.ToString() });
      entity.AddProperty(new Property("stringProp", "string") {DefaultValue = "abc"});
      entity.AddProperty(new Property("enumProp", 
                                      "MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek, MetraTech.DomainModel.Enums.Generated") 
                                      {DefaultValue = DayOfTheWeek.Friday.ToString()});

      // Required
      entity.AddProperty(new Property("boolProp_r", "bool") { DefaultValue = "false", IsRequired = true});
      entity.AddProperty(new Property("dateTimeProp_r", "DateTime") { DefaultValue = dateTime.ToString(), IsRequired = true });
      entity.AddProperty(new Property("decimalProp_r", "decimal") { DefaultValue = "1.11", IsRequired = true });
      entity.AddProperty(new Property("doubleProp_r", "double") { DefaultValue = "1.22", IsRequired = true });
      entity.AddProperty(new Property("guidProp_r", "Guid") { DefaultValue = guid.ToString(), IsRequired = true });
      entity.AddProperty(new Property("int32Prop_r", "int") { DefaultValue = Int32.MaxValue.ToString(), IsRequired = true });
      entity.AddProperty(new Property("int64Prop_r", "Int64") { DefaultValue = Int64.MaxValue.ToString(), IsRequired = true });
      entity.AddProperty(new Property("stringProp_r", "string") { DefaultValue = "abc", IsRequired = true });
      entity.AddProperty(new Property("enumProp_r",
                                      "MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek, MetraTech.DomainModel.Enums.Generated") 
                                      { DefaultValue = DayOfTheWeek.Friday.ToString(), IsRequired = true });

      MetadataAccess.Instance.SaveEntity(entity);
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      // Create data
      var entityInstance = entity.GetEntityInstance();

      // Should have all the default values
      Assert.AreEqual(false, entityInstance["boolProp"].Value);
      // Assert.AreEqual(dateTime, entityInstance["dateTimeProp"].Value);
      Assert.AreEqual(new Decimal(1.11), entityInstance["decimalProp"].Value);
      Assert.AreEqual(1.22, entityInstance["doubleProp"].Value);
      Assert.AreEqual(guid, entityInstance["guidProp"].Value);
      Assert.AreEqual(Int32.MaxValue, entityInstance["int32Prop"].Value);
      Assert.AreEqual(Int64.MaxValue, entityInstance["int64Prop"].Value);
      Assert.AreEqual("abc", entityInstance["stringProp"].Value);
      Assert.AreEqual(DayOfTheWeek.Friday, entityInstance["enumProp"].Value);

      Assert.AreEqual(false, entityInstance["boolProp_r"].Value);
      // Assert.AreEqual(dateTime, entityInstance["dateTimeProp_r"].Value);
      Assert.AreEqual(new Decimal(1.11), entityInstance["decimalProp_r"].Value);
      Assert.AreEqual(1.22, entityInstance["doubleProp_r"].Value);
      Assert.AreEqual(guid, entityInstance["guidProp_r"].Value);
      Assert.AreEqual(Int32.MaxValue, entityInstance["int32Prop_r"].Value);
      Assert.AreEqual(Int64.MaxValue, entityInstance["int64Prop_r"].Value);
      Assert.AreEqual("abc", entityInstance["stringProp_r"].Value);
      Assert.AreEqual(DayOfTheWeek.Friday, entityInstance["enumProp_r"].Value);


      IStandardRepository repository = MetadataAccess.Instance.GetRepository();
      entityInstance = repository.SaveEntityInstance(entityInstance);

      // Load data. Should have all the default values
      entityInstance = repository.LoadEntityInstance(entityInstance.EntityFullName, entityInstance.Id);

      Assert.AreEqual(false, entityInstance["boolProp"].Value);
      // Assert.AreEqual(dateTime, entityInstance["dateTimeProp"].Value);
      Assert.AreEqual(new Decimal(1.11), entityInstance["decimalProp"].Value);
      Assert.AreEqual(1.22, entityInstance["doubleProp"].Value);
      Assert.AreEqual(guid, entityInstance["guidProp"].Value);
      Assert.AreEqual(Int32.MaxValue, entityInstance["int32Prop"].Value);
      Assert.AreEqual(Int64.MaxValue, entityInstance["int64Prop"].Value);
      Assert.AreEqual("abc", entityInstance["stringProp"].Value);
      Assert.AreEqual(DayOfTheWeek.Friday, entityInstance["enumProp"].Value);

      Assert.AreEqual(false, entityInstance["boolProp_r"].Value);
      // Assert.AreEqual(dateTime, entityInstance["dateTimeProp_r"].Value);
      Assert.AreEqual(new Decimal(1.11), entityInstance["decimalProp_r"].Value);
      Assert.AreEqual(1.22, entityInstance["doubleProp_r"].Value);
      Assert.AreEqual(guid, entityInstance["guidProp_r"].Value);
      Assert.AreEqual(Int32.MaxValue, entityInstance["int32Prop_r"].Value);
      Assert.AreEqual(Int64.MaxValue, entityInstance["int64Prop_r"].Value);
      Assert.AreEqual("abc", entityInstance["stringProp_r"].Value);
      Assert.AreEqual(DayOfTheWeek.Friday, entityInstance["enumProp_r"].Value);

    }

    
   
    #region Data

    private string extensionName = "DefaultValueTest";
    private string entityGroupName = "Common";

    #endregion
  }
}
