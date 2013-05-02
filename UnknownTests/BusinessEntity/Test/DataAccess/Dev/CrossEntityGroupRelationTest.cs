using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using SmokeTest.OrderManagement;
using log4net;
using log4net.Core;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Rule;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.CrossEntityGroupRelationTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class CrossEntityGroupRelationTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Create BE directories.
      SystemConfig.CreateBusinessEntityDirectories(extensionName, firstEntityGroupName);
      SystemConfig.CreateBusinessEntityDirectories(extensionName, secondEntityGroupName);

      // Clean BE directories.
      SystemConfig.CleanEntityDir(extensionName, firstEntityGroupName);
      SystemConfig.CleanEntityDir(extensionName, secondEntityGroupName);
    }

    /// <summary>
    ///
    /// </summary>
    [Test]
    [Category("CreateRelationshipAcrossEntityGroups")]
    public void CreateRelationshipAcrossEntityGroups()
    {
      // Create 'A' in 'First' entity group
      string entityName = "A";
      string entityFullName = Name.GetEntityFullName(extensionName, firstEntityGroupName, "A");

      var entityA =
        new Entity(entityFullName)
        {
          Category = Category.ConfigDriven,
          Label = entityName + " Label",
          PluralName = entityName + "s",
          Description = entityName + " Description"
        };

      MetadataAccess.Instance.SaveEntity(entityA);
      List<ErrorObject> errors = MetadataAccess.Instance.Synchronize(extensionName, firstEntityGroupName);
      Assert.AreEqual(0, errors.Count);

      // Create 'B' in 'Second' entity group
      entityName = "B";
      entityFullName = Name.GetEntityFullName(extensionName, secondEntityGroupName, "B");

      var entityB =
        new Entity(entityFullName)
        {
          Category = Category.ConfigDriven,
          Label = entityName + " Label",
          PluralName = entityName + "s",
          Description = entityName + " Description"
        };

      // Create a relationship between B and A
      errors = MetadataAccess.Instance.CreateOneToManyRelationship(ref entityB, ref entityA);
      Assert.AreEqual(0, errors.Count);

      // Save B
      MetadataAccess.Instance.SaveEntities(new List<Entity>() {entityB, entityA});
      errors = MetadataAccess.Instance.Synchronize(extensionName, secondEntityGroupName);
      Assert.AreEqual(0, errors.Count);
    }

   

   
    #region Data

    private static readonly ILog logger = LogManager.GetLogger("CrossEntityGroupRelationTest");

    private string extensionName = "CrossEntityGroupRelationTest";
    private string firstEntityGroupName = "First";
    private string secondEntityGroupName = "Second";

    #endregion
  }
}
