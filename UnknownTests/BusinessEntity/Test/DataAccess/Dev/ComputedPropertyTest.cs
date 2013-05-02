using System;
using System.Collections.Generic;
using System.IO;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using SmokeTest.OrderManagement;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using NUnit.Framework;

//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.BusinessEntity.Test.DataAccess.Dev.ComputedPropertyTest /assembly:O:\debug\bin\MetraTech.BusinessEntity.Test.dll
//

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  [TestFixture]
  public class ComputedPropertyTest
  {
    [TestFixtureSetUp]
    public void Setup()
    {
      // Create BE directories
      SystemConfig.CreateBusinessEntityDirectories(extensionName, firstEntityGroupName);
      SystemConfig.CreateBusinessEntityDirectories(extensionName, secondEntityGroupName);

      // Clean BE directories
      SystemConfig.CleanEntityDir(extensionName, firstEntityGroupName);
      SystemConfig.CleanEntityDir(extensionName, secondEntityGroupName);

    }

    [Test]
    [Category("ComputeSalesTax")]
    public void ComputeSalesTax()
    {
      // The 'Core.OrderManagement.Rule.dll' assembly contains a class called SalesTaxComputation.
      // The SalesTaxComputation class has a ComputedPropertyInfo attribute which specifies that
      // the sales tax computation is valid for the SalesTax property on the Order class.
      string computationTypeName = 
        MetadataAccess.Instance.GetComputationTypeName("SmokeTest.OrderManagement.Order", 
                                                       "SalesTax",
                                                       computedPropertyAssemblyName);
      Assert.IsFalse(String.IsNullOrEmpty(computationTypeName));

      // Synchronize
      MetadataAccess.Instance.Synchronize("SmokeTest", "OrderManagement");

      // Create Order. This will cause the SalesTax to be computed to 123.45
      var order = new Order();
      order.BusinessKey.ReferenceNumber = "Ref-123";
      order.InvoiceMethod = InvoiceMethod.Standard;
      order.Description = "Testing business rule execution";

      var repository = MetadataAccess.Instance.GetRepository();
      var savedOrder = repository.SaveInstance(order) as Order;

      Assert.AreEqual(123.45, savedOrder.SalesTax.Value);
    }

    [Test]
    [Category("ComputeSalesTaxForNewEntityAfterSpecifyingComputationType")]
    public void ComputeSalesTaxForNewEntityAfterSpecifyingComputationType()
    {
      // Clean BE directories
      SystemConfig.CleanEntityDir(extensionName, firstEntityGroupName);

      // The 'Core.OrderManagement.Rule.dll' assembly contains a class called SalesTaxComputationForTestEntity.
      // The SalesTaxComputation class has a ComputedPropertyInfo attribute which specifies that
      // the sales tax computation is valid for the 'SalesTax' property on the 'ComputedPropertyTest.Common.EntityA' class.
      var entity = new Entity(Name.CreateEntityFullName(extensionName, firstEntityGroupName, "EntityA"));
      entity.PluralName = entity.ClassName + "s";

      // Create a computed property without computation type
      var property = new Property("SalesTax", "System.Double");
      property.IsComputed = true;
      entity.AddProperty(property);

      // Add computation type
      property.ComputationTypeName =
       MetadataAccess.Instance.GetComputationTypeName(entity.FullName, "SalesTax", computedPropertyAssemblyName);

      // Save
      MetadataAccess.Instance.SaveEntity(entity);

      // Synchronize
      MetadataAccess.Instance.Synchronize(extensionName, firstEntityGroupName);

      // Create data
      var entityInstance = entity.GetEntityInstance();
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      entityInstance = standardRepository.SaveEntityInstance(entityInstance);

      // Verify that SalesTax is 123.45
      Assert.AreEqual(123.45, entityInstance["SalesTax"].Value);
    }

    [Test]
    [Category("ComputeSalesTaxForNewEntityWithoutSpecifyingComputationType")]
    public void ComputeSalesTaxForNewEntityWithoutSpecifyingComputationType()
    {
      var entity = new Entity(Name.CreateEntityFullName(extensionName, secondEntityGroupName, "EntityB"));
      entity.PluralName = entity.ClassName + "s";

      // Create a computed property without computation type
      var property = new Property("SalesTax", "System.Double");
      property.IsComputed = true;
      entity.AddProperty(property);

      // Save
      MetadataAccess.Instance.SaveEntity(entity);

      // Synchronize
      MetadataAccess.Instance.Synchronize(extensionName, secondEntityGroupName);

      // Create data
      var entityInstance = entity.GetEntityInstance();
      IStandardRepository standardRepository = MetadataAccess.Instance.GetRepository();
      entityInstance = standardRepository.SaveEntityInstance(entityInstance);

      // Verify that SalesTax is null
      Assert.IsNull(entityInstance["SalesTax"].Value);
    }

    [Test]
    [Category("TestComputedPropertyTreeLogicSimulation")]
    public void TestComputedPropertyTreeLogicSimulation()
    {
      string orderEntityName = "SmokeTest.OrderManagement.Order";
      string computedPropertyName = "SalesTax";

      // ICE -> Get Computed Property template 
      string fileContent =
        MetadataAccess.Instance.GetComputedPropertyTemplate(orderEntityName, computedPropertyName, null);

      // ICE -> Replace variable name 
      fileContent = fileContent.Replace("%%BME_VARIABLE%%", "order");

      // ICE -> Get business key properties for Product (sample lookup)
      string productEntityName = "SmokeTest.OrderManagement.Product";
      List<PropertyInstance> businessKeyProperties = BusinessKey.GetBusinessKeyProperties(productEntityName);

      // ICE -> Specify values for business key properties
      foreach(PropertyInstance propertyInstance in businessKeyProperties)
      {
        propertyInstance.Value = "abc";
      }

      // ICE -> Replace BUSINESS_LOGIC with code snippet for looking up Product
      fileContent =
        fileContent.Replace("%%BUSINESS_LOGIC%%", 
                             MetadataAccess.Instance.GetCodeSnippetForLookingUpDataObject(productEntityName, 
                                                                                          "product", 
                                                                                          businessKeyProperties,
                                                                                          false));

      // ICE -> Test compilation
      // Will throw MetadataException with compilation errors (if any)
      MetadataAccess.Instance.TestBuildComputedPropertyCode(orderEntityName, computedPropertyName, fileContent, null);

      // Synchronize
      var syncData = new SyncData();
      syncData.AddNewComputedPropertyData
        (new ComputedPropertyData(orderEntityName, computedPropertyName) {Code = fileContent});

      MetadataAccess.Instance.Synchronize(syncData);
    }

    #region Data

    private static readonly ILog logger = LogManager.GetLogger("ComputedPropertyTest");
    private const string computedPropertyAssemblyName = @"O:\debug\bin\SmokeTest.OrderManagement.Rule.dll";
    private string extensionName = "ComputedPropertyTest";
    private string firstEntityGroupName = "Common";
    private string secondEntityGroupName = "Sample";
    #endregion
  }
}
