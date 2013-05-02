using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.OptimisticConcurrencyTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class OptimisticConcurrencyTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Create BE directories for 'MetadataTest' extension.
      SystemConfig.CreateBusinessEntityDirectories(extensionName, entityGroupName);

      // Clean BE directories for 'MetadataTest' extension.
      Name.CleanEntityDir(extensionName, entityGroupName);

    }

    /// <summary>
    /// </summary>
    [Test]
    [Category("TestOptimisticConcurrency")]
    public void TestOptimisticConcurrency()
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

      entity.AddProperty(new Property("testProp", "string"));

      MetadataAccess.Instance.SaveEntity(entity);
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      // Create instance 
      var firstEntityInstanceVersion = entity.GetEntityInstance();
      Assert.IsNotNull(firstEntityInstanceVersion[Property.VersionPropertyName]);
      firstEntityInstanceVersion["testProp"].Value = "abc";

      // Save (version 1)
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      firstEntityInstanceVersion = standardRepository.SaveEntityInstance(firstEntityInstanceVersion);

      // Load instance
      var secondEntityInstanceVersion = standardRepository.LoadEntityInstance(entity.FullName, firstEntityInstanceVersion.Id);
      secondEntityInstanceVersion["testProp"].Value = "pqr";
      
      // Save. Version is incremented.
      standardRepository.SaveEntityInstance(secondEntityInstanceVersion);

      // Try to save the first one. Should throw a OptimisticConcurrencyException
      try
      {
        standardRepository.SaveEntityInstance(firstEntityInstanceVersion);
        Assert.Fail("Expected 'OptimisticConcurrencyException'");
      }
      catch (Exception e)
      {
        var concurrencyException = e.InnerException as OptimisticConcurrencyException;
        Assert.IsNotNull(concurrencyException);
        Assert.IsTrue(concurrencyException.ErrorMessage.Contains(firstEntityInstanceVersion.EntityFullName));
        Assert.IsTrue(concurrencyException.ErrorMessage.Contains(firstEntityInstanceVersion.Id.ToString()));
      }
    }

   

   
    #region Data

    private static readonly ILog logger = LogManager.GetLogger("OptimisticConcurrencyTest");

    private string extensionName = "OptimisticConcurrencyTest";
    private string entityGroupName = "Common";

    #endregion
  }
}
