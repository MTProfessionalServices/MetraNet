using System;
using System.Collections.Generic;
using System.IO;

using log4net;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.EncryptedPropertyTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class EncryptedPropertyTest
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
    [Category("TestEncryptDecrypt")]
    public void TestEncryptDecrypt()
    {
      var entity = new Entity(Name.CreateEntityFullName(extensionName, entityGroupName, "EntityA"));
      entity.PluralName = entity.ClassName + "s";

      // Create an encrypted property
      var property = new Property("CreditCardNumber", "System.String");
      property.IsEncrypted = true;
      entity.AddProperty(property);

      // Save
      MetadataAccess.Instance.SaveEntity(entity);

      // Synchronize
      // MetadataAccess.Instance.Synchronize(extensionName, entityGroupName);

      // Create data
      var entityInstance = entity.GetEntityInstance();
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();

      string creditCardNumber = "1234-5678-5555";
      entityInstance["CreditCardNumber"].Value = creditCardNumber;
      entityInstance = standardRepository.SaveEntityInstance(entityInstance);

      // Verify 
      Assert.AreEqual(creditCardNumber, entityInstance["CreditCardNumber"].Value);

      // Load
      var loadEntityInstance = standardRepository.LoadEntityInstance(entity.FullName, entityInstance.Id);
      Assert.AreEqual(creditCardNumber, loadEntityInstance["CreditCardNumber"].Value);

      // Update
      creditCardNumber = "9999-8888-7777-6666-5555";
      loadEntityInstance["CreditCardNumber"].Value = creditCardNumber;
      standardRepository.SaveEntityInstance(loadEntityInstance);

      // Load
      loadEntityInstance = standardRepository.LoadEntityInstance(entity.FullName, entityInstance.Id);
      Assert.AreEqual(creditCardNumber, loadEntityInstance["CreditCardNumber"].Value);
    }

    

    #region Data
    private string extensionName = "EncryptedPropertyTest";
    private string entityGroupName = "Common";
    #endregion
  }
}
