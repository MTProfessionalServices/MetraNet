using System;
using System.Collections;
using System.Linq;
using System.Collections.Generic;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NUnit.Framework;

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  public sealed class SaveRestoreInvoiceMetadata : DataAccessTestCase
  {
    public SaveRestoreInvoiceMetadata()
    {
      TenantName = "Test";
    }

    public override ICollection<Entity> CreateEntities()
    {
      IList<Entity> entities = new List<Entity>();
    
      #region Define DemandForPayment

      demandForPayment =
        new Entity()
          {
            ClassName = "DemandForPayment",
            Namespace = TenantName + ".BusinessEntity.OrderManagement",
            AssemblyName = TenantName + ".BusinessEntity",
            Category = Category.ConfigDriven,
            Tenant = TenantName,
            Label = "DemandForPayment Label",
            PluralName = "DemandForPayments",
            Description = "DemandForPayment Description"
          };

      demandForPaymentProperty1 =
        (new Property(demandForPayment)
          {
            Name = "Property1",
            QualifiedName = new QualifiedName("System.String", TenantName),
            Label = "Property1 Label",
            Description = "Property1 Description",
            DefaultValue = "abc",
            IsEncrypted = true,
            IsRequired = true,
            IsUnique = true
          });

      demandForPayment.Properties.Add(demandForPaymentProperty1);


      demandForPaymentProperty2 =
        (new Property(demandForPayment)
          {
            Name = "Property2",
            QualifiedName = new QualifiedName("System.Int32", TenantName),
            Label = "Property2 Label",
            Description = "Property2 Description",
            DefaultValue = "32",
            IsEncrypted = true,
            IsBusinessKey = true
          });

      demandForPayment.Properties.Add(demandForPaymentProperty2);

      entities.Add(demandForPayment);
      #endregion

      #region Define Invoice
      invoice =
        new Entity()
          {
            Tenant = TenantName,
            ClassName = "Invoice",
            PluralName = "Invoices",
            Namespace = TenantName + ".BusinessEntity.OrderManagement",
            AssemblyName = TenantName + ".BusinessEntity",
          };

      invoiceProperty1 = 
        new Property(invoice)
         {
           Name = "Property1",
           QualifiedName = new QualifiedName("System.String", TenantName),
           IsBusinessKey = true
         };

      invoice.Properties.Add(invoiceProperty1);

      invoiceProperty2 = 
        new Property(invoice)
          {
            Name = "Property2",
            QualifiedName = new QualifiedName("System.Int32", TenantName)
          };

      invoice.Properties.Add(invoiceProperty2);

      entities.Add(invoice);
      #endregion

      return entities;
    }

    public override void AfterCreateEntities(ICollection<Entity> entities)
    {
      // Find DemandForPayment
      Entity freshDemandForPayment = MetadataAccess.Instance.GetEntity("Test", "Test.BusinessEntity.OrderManagement.DemandForPayment");
      Check.Require(freshDemandForPayment != null, "Expected to find entity with class name 'DemandForPayment'", SystemConfig.CallerInfo);

      // Check properties for DemandForPayment
      Assert.IsTrue(freshDemandForPayment.Equals(demandForPayment));

      // Expect to find Invoice
      Entity freshInvoice = MetadataAccess.Instance.GetEntity("Test", "Test.BusinessEntity.OrderManagement.Invoice");
      Assert.IsNotNull(freshInvoice, "Expected to find entity with class name 'Invoice'");

      // Check properties for Invoice
      Assert.IsTrue(freshInvoice.Equals(invoice));
    }

    public override bool UpdateEntities(ICollection<Entity> entities)
    {
      // Find Invoice
      Entity freshInvoice = MetadataAccess.Instance.GetEntity("Test", "Test.BusinessEntity.OrderManagement.Invoice");
      Check.Require(freshInvoice != null, "Expected to find entity with class name 'Invoice'", SystemConfig.CallerInfo);

      // Find Property1
      Property property = freshInvoice["Property1"];
      Check.Require(property != null, "Expect to find property with name 'Property1' on entity 'Invoice'", SystemConfig.CallerInfo);
      // Update Label
      property.Label = "Property1 Label";

      // Add new property
      freshInvoice.Properties.Add(new Property(invoice) { Name = "Property3", QualifiedName = new QualifiedName("System.Double", TenantName) });

      CreateEntityMetadataAndSchema(TenantName, new List<Entity>{freshInvoice});

      freshInvoice = MetadataAccess.Instance.GetEntity("Test", "Test.BusinessEntity.OrderManagement.Invoice");
      Check.Require(freshInvoice != null, "Expected to find entity with class name 'Invoice'", SystemConfig.CallerInfo);

      property = freshInvoice["Property3"];
      Assert.IsNotNull(property);
      Assert.AreEqual(PropertyType.Double, property.PropertyType, "Expected Property3 to be Double");

      property = freshInvoice["Property1"];
      Assert.IsNotNull(property);
      Assert.AreEqual("Property1 Label", property.Label, "Mismatched label");

      return true;
    }

    public override ICollection<Relationship> CreateRelationships(ICollection<Entity> entities)
    {
      List<Relationship> relationships = new List<Relationship>();

      // Find Invoice
      Entity freshInvoice = MetadataAccess.Instance.GetEntity("Test", "Test.BusinessEntity.OrderManagement.Invoice");
      Check.Require(freshInvoice != null, "Expected to find entity with class name 'Invoice'", SystemConfig.CallerInfo);

      // Find DemandForPayment
      Entity freshDemandForPayment = MetadataAccess.Instance.GetEntity("Test", "Test.BusinessEntity.OrderManagement.DemandForPayment");
      Check.Require(freshDemandForPayment != null, "Expected to find entity with class name 'DemandForPayment'", SystemConfig.CallerInfo);

      // Create a Relationship
      MetadataAccess.Instance.CreateOneToManyRelationship(ref freshInvoice, ref freshDemandForPayment);
      MetadataAccess.Instance.SaveEntities(TenantName, new List<Entity>() { freshInvoice, freshDemandForPayment });
    
      // Delete the Relationship
      MetadataAccess.Instance.DeleteRelationship(ref freshInvoice, ref freshDemandForPayment);
      MetadataAccess.Instance.SaveEntities(TenantName, new List<Entity>() { freshInvoice, freshDemandForPayment });

      // Create it again
      MetadataAccess.Instance.CreateOneToManyRelationship(ref freshInvoice, ref freshDemandForPayment);
      MetadataAccess.Instance.SaveEntities(TenantName, new List<Entity>() { freshInvoice, freshDemandForPayment });

      CreateEntityMetadataAndSchema(TenantName, new List<Entity> { freshInvoice, freshDemandForPayment });

      return relationships;
    }

    #region Data

    private Entity demandForPayment;
    private Entity invoice;
    private Property demandForPaymentProperty1;
    private Property demandForPaymentProperty2;
    private Property invoiceProperty1;
    private Property invoiceProperty2;
    #endregion
  }
}