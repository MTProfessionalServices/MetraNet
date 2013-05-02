using System;
using System.Collections.Generic;
using System.IO;

using log4net;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.RequiredPropertyTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class RequiredPropertyTest
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
    [Category("TestRequiredProperty")]
    public void TestRequiredProperty()
    {
      var entity = new Entity(Name.CreateEntityFullName(extensionName, entityGroupName, "EntityA"));
      entity.PluralName = entity.ClassName + "s";

      // Create an encrypted property
      var property = new Property("ReferenceNumber", "System.String");
      property.IsBusinessKey = true;
      entity.AddProperty(property);

      // Save
      MetadataAccess.Instance.SaveEntity(entity);

      // Synchronize
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      // Create data
      var entityInstance = entity.GetEntityInstance();
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();

      try
      {
        standardRepository.SaveEntityInstance(entityInstance);
        Assert.Fail("Expected 'MissingRequiredPropertyException'");
      }
      catch (Exception e)
      {
        var exception = e.InnerException as MissingRequiredPropertyException;
        Assert.IsNotNull(exception);
        Assert.IsTrue(exception.ErrorMessage.Contains(entity.FullName));
        Assert.IsTrue(exception.ErrorMessage.Contains("ReferenceNumber"));
      }

    }

    

    #region Data
    private string extensionName = "RequiredPropertyTest";
    private string entityGroupName = "Common";
    #endregion
  }
}
