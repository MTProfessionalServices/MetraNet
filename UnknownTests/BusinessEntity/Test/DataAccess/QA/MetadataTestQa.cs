using System;
using System.Collections.Generic;
using System.IO;
//using System.Threading;
//using System.Reflection;

using NUnit.Framework;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;

using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.Test.DataAccess.QA.MetadataQa
{
	class MetadataTestQa
	{
	}

	[TestFixture]
	[Category("QA")]
	[Category("QAMetadata")]
	public class EntityDataTypeTests
	{
		[TestFixtureSetUp]
		public void Setup()
		{
			// Create 'MetadataTest' tenant. If 'MetadataTest' exists, it will do nothing.
			MetadataAccess.Instance.CreateNewTenant(tenantName);

			// Clean 'MetadataTest' tenant
			MetadataAccess.Instance.CleanTenant(tenantName);

		}

		/// <summary></summary>
		[Test(Description = "SaveEntity00_SimpleSave")]
		public void Entity00_SimpleSave()
		{
			// Define the entity
			Entity entity = new Entity()
			  {
				  ClassName = "DemandForPayment",
				  Namespace = tenantName + ".BusinessentityName.OrderManagement",
				  AssemblyName = tenantName + ".BusinessEntity",
				  Category = Category.ConfigDriven,
				  Tenant = tenantName,
				  Label = "DemandForPayment Label",
				  PluralName = "DemandForPayment",
				  Description = "DemandForPayment Description"
			  };
			Property refProperty = new Property(entity)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			entity.Properties.Add(refProperty);

			// Save Entities
			MetadataAccess.Instance.SaveEntity(entity);


			// Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
			Assert.IsTrue(File.Exists(entity.MappingFileWithPath));

			// Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
			Assert.IsTrue(File.Exists(entity.CodeFileWithPath));

			// Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
			Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entity.Tenant, entity.CodeFile));
			Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entity.Tenant, entity.MappingFile));

		}

		[Test(Description = "Test supported datat types")]
		public void Entity01_PosAllDataTypes()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessentityName.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "Property1",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property2",
				QualifiedName = new QualifiedName("System.Int32", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "0",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property4",
				QualifiedName = new QualifiedName("System.Boolean", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "true",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property5",
				QualifiedName = new QualifiedName("System.DateTime", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property6",
				QualifiedName = new QualifiedName("System.Decimal", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "0",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property7",
				QualifiedName = new QualifiedName("System.Double", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "100",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property9",
				QualifiedName = new QualifiedName("System.Guid", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property10",
				QualifiedName = new QualifiedName("System.Int64", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "100",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			Property enumProperty = new Property(order)
			{
				Name = "DayOfTheWeek",
				QualifiedName =
				  new QualifiedName("MetraTech.DomainModel.Enums.Core.Global.DayOfTheWeek",
									"MetraTech.DomainModel.Enums.Generated",
									tenantName),
				Label = "Description",
				Description = "Description",
				//DefaultValue = "1"
			};
			order.Properties.Add(enumProperty);

			#endregion

			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				//Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsTrue(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsTrue(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}

			#endregion
		}

		[Test(Description = "Test that duplicate names are not allowed")]
		public void Entity02_NegDuplicateName()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessentityName.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "Property1",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property1",
				QualifiedName = new QualifiedName("System.Int32", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			#endregion

			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsFalse(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsFalse(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsFalse(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsFalse(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}
			#endregion
		}

		[Test]
		public void Entity03_PosDeleteEntity()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessEntity.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			Property descProperty = new Property(order)
			{
				Name = "Description",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Description",
				Description = "Description",
			};
			order.Properties.Add(descProperty);


			// LineItem
			Entity lineItem = new Entity()
			{
				ClassName = tenantName + "_LineItem",
				Namespace = tenantName + ".BusinessEntity.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "LineItem Label",
				PluralName = "LineItems",
				Description = "LineItem Description"
			};
			entities.Add(lineItem);

			refProperty = new Property(lineItem)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			lineItem.Properties.Add(refProperty);

			descProperty = new Property(lineItem)
			{
				Name = "Description",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Description",
				Description = "Description",
			};
			lineItem.Properties.Add(descProperty);

			// Product
			Entity product = new Entity()
			{
				ClassName = tenantName + "_Product",
				Namespace = tenantName + ".BusinessEntity.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Product Label",
				PluralName = "Products",
				Description = "Product Description"
			};
			entities.Add(product);

			refProperty = new Property(product)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			product.Properties.Add(refProperty);

			descProperty = new Property(product)
			{
				Name = "Description",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Description",
				Description = "Description",
			};
			product.Properties.Add(descProperty);

			#endregion

			// Create Relationships
			//MetadataAccess.Instance.CreateOneToManyRelationship(ref order, ref lineItem);
			
			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				//Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsTrue(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsTrue(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}

			#endregion

			List<ErrorObject> errors;
			List<Entity> changedEntities = MetadataAccess.Instance.DeleteEntity(order, out errors);
			Assert.AreEqual(1, changedEntities.Count, "Mismatched counts");

		}

		[Test(Description = "Test Int32 type without 'System.'")]
		public void Entity04_NegPropertyDecaration()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessentityName.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "Property2",
				QualifiedName = new QualifiedName("Int32", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			#endregion

			#region properties

			#endregion

			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				//Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsFalse(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsFalse(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsFalse(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsFalse(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}

			#endregion
		}

		[Test(Description = "Test > 50 properties")]
		public void Entity05_PosGrt50Properties()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessentityName.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "Property1",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			 refProperty = new Property(order)
			{
				Name = "Property2",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property3",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property4",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property5",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property6",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property7",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property8",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property9",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property10",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property11",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property12",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property13",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property14",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property15",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property16",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property17",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property18",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property19",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property20",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property21",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property22",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property23",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property24",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property25",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property26",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property27",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property28",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property29",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property30",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property31",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property32",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property33",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

				refProperty = new Property(order)
			{
				Name = "Property34",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property35",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property36",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property37",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property38",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property39",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property40",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property41",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property42",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property43",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property44",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property45",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property46",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property47",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property48",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property49",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property50",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property51",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			refProperty = new Property(order)
			{
				Name = "Property52",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			#endregion

			#region properties

			#endregion

			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				//Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsTrue(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsTrue(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}

			#endregion
		}

		[Test(Description = "Test String type without 'System.'")]
		public void Entity06_PosPropertyDecaration()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessentityName.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "Property1",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			#endregion

			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				//Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsTrue(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsTrue(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}

			#endregion
		}

		[Test(Description = "Test String type without 'System.'")]
		public void Entity061_PosPropertyDecaration()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessentityName.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "Property1",
				QualifiedName = new QualifiedName("String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			//refProperty = new Property(order)
			//{
			//    Name = "Property2",
			//    QualifiedName = new QualifiedName("Int32", tenantName),
			//    Label = "Ref# Label",
			//    Description = "Ref# Description",
			//    DefaultValue = "abc",
			//    IsBusinessKey = true
			//};
			//order.Properties.Add(refProperty);

			#endregion

			try
			{
				// Save Entities
				MetadataAccess.Instance.SaveEntities(tenantName, entities);
			}
			#region checks
			catch (Exception ex)
			{
				//Assert.IsTrue("Entity validation failed." == ex.Message);
			}
			finally
			{
				// Check that the .hbm.xml file exists
				Assert.IsTrue(File.Exists(order.MappingFileWithPath));

				// Check that the .cs file exists
				Assert.IsTrue(File.Exists(order.CodeFileWithPath));

				// Check that the csproj file contains the .cs and .hbm.xml
				Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(order.Tenant, order.CodeFile));
				Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(order.Tenant, order.MappingFile));
			}

			#endregion
		}

		//[Test(Description = "Test Property Decaration")]
		//public void Entity07_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = "Property1",
		//        TypeName = "System.String",
		//        DefaultValue = "DefaultValue"
		//    });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));
		//    #endregion
		//}

		//// currently failing
		//[Test(Description = "Test Property Decaration,DefaultValue = DefaultValue")]
		//public void Entity08_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };

		//    //entityName.Properties.Add(new Property(entity) { Name = "Property1", TypeName = "System.String", DefaultValue = "DefaultValue" });
		//    entityName.Properties.Add(new Property(entity) 
		//    {
		//        Name = "Property2"
		//        , TypeName = "System.Int32"
		//        , DefaultValue = "DefaultValue" 
		//    });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));
		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration, string propDefaultValue = DefaultValue string, propDesc = Prop1 Descsription")]
		//public void Entity09_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propType = "System.String";
		//    string propDesc = "Prop1 Descsription";

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propType,
		//        Description = propDesc
		//    });
		//    //entityName.Properties.Add(new Property(entity) { Name = "Property2", TypeName = "System.Int32", DefaultValue = "DefaultValue" });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));

		//    // Check property values
		//    List<Entity> lEntities = metadataAccess.GetEntities(tenant);
		//    Assert.True(propName == lEntities[0].Properties[0].Name);
		//    Assert.True(propType == lEntities[0].Properties[0].TypeName);
		//    Assert.True(propDesc == lEntities[0].Properties[0].Description);

		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration - string propDefaultValue = 'DefaultValue' string propDesc = 'Prop1 Descsription' bool propIsBusinessKey = false")]
		//public void Entity10_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propType = "System.String";
		//    string propDefaultValue = "DefaultValue";
		//    string propDesc = "Prop1 Descsription";
		//    bool propIsBusinessKey = false;

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propType,
		//        DefaultValue = propDefaultValue,
		//        Description = propDesc,
		//        IsBusinessKey = propIsBusinessKey
		//    });
		//    //entityName.Properties.Add(new Property(entity) { Name = "Property2", TypeName = "System.Int32", DefaultValue = "DefaultValue" });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));

		//    // Check property values
		//    List<Entity> lEntities = metadataAccess.GetEntities(tenant);
		//    Assert.True(propName == lEntities[0].Properties[0].Name);
		//    Assert.True(propType == lEntities[0].Properties[0].TypeName);
		//    Assert.True(propDesc == lEntities[0].Properties[0].Description);
		//    Assert.True(propIsBusinessKey == lEntities[0].Properties[0].IsBusinessKey);

		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration - propEncrypted = false")]
		//public void Entity11_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propType = "System.String";
		//    bool propEncrypted = false;

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propType,
		//        IsEncrypted = propEncrypted
		//    });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));

		//    // Check property values
		//    List<Entity> lEntities = metadataAccess.GetEntities(tenant);
		//    Assert.True(propName == lEntities[0].Properties[0].Name);
		//    Assert.True(propType == lEntities[0].Properties[0].TypeName);
		//    Assert.True(propEncrypted == lEntities[0].Properties[0].IsEncrypted);

		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration - this used to be enum of string, but enum is now gone")]
		//public void Entity12_NegPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propTypeName = "System.String";
		//    bool propEncrypted = false;
		//    PropertyType propType = PropertyType.Basic;

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propTypeName,
		//        IsEncrypted = propEncrypted,
		//        PropertyType = propType
		//    });

		//    #region checks
		//    try
		//    {
		//        // Save
		//        metadataAccess.SaveEntity(entity);
		//    }
		//    catch
		//    { }
		//    finally
		//    {
		//        // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//        Assert.IsTrue(File.Exists(entityName.MappingFile));

		//        // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//        Assert.IsTrue(File.Exists(entityName.CodeFile));

		//        // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//        Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//        Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));
		//    }
		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration - propIsEncrypted = true")]
		//public void Entity13_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propType = "System.String";
		//    bool propIsEncrypted = true;

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propType,
		//        IsEncrypted = propIsEncrypted
		//    });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));

		//    // Check property values
		//    List<Entity> lEntities = metadataAccess.GetEntities(tenant);
		//    Assert.True(propName == lEntities[0].Properties[0].Name);
		//    Assert.True(propType == lEntities[0].Properties[0].TypeName);
		//    Assert.True(propIsEncrypted == lEntities[0].Properties[0].IsEncrypted);

		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration - propIsRequired = true")]
		//public void Entity14_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propType = "System.String";
		//    bool propIsRequired = true;

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propType,
		//        IsRequired = propIsRequired
		//    });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));

		//    // Check property values
		//    List<Entity> lEntities = metadataAccess.GetEntities(tenant);
		//    Assert.True(propName == lEntities[0].Properties[0].Name);
		//    Assert.True(propType == lEntities[0].Properties[0].TypeName);
		//    Assert.True(propIsRequired == lEntities[0].Properties[0].IsRequired);

		//    #endregion
		//}

		//[Test(Description = "Test Property Decaration - propIsUnique = true")]
		//public void Entity15_PosPropertyDecaration()
		//{
		//    SystemConfig.CleanEntityDir(tenant);
		//    SystemConfig.CreateCsProj(tenant);

		//    // Define the entity
		//    Entity entity = new Entity()
		//    {
		//        ClassName = "DemandForPayment",
		//        Namespace = tenant + ".BusinessentityName.OrderManagement",
		//        AssemblyName = tenant + ".BusinessEntity",
		//        Category = Category.ConfigDriven,
		//        Tenant = tenant
		//    };
		//    string propName = "Property1";
		//    string propType = "System.String";
		//    bool propIsUnique = true;

		//    entityName.Properties.Add(new Property(entity)
		//    {
		//        Name = propName,
		//        TypeName = propType,
		//        IsUnique = propIsUnique
		//    });

		//    #region checks
		//    // Save
		//    metadataAccess.SaveEntity(entity);

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.hbm.xml file exists
		//    Assert.IsTrue(File.Exists(entityName.MappingFile));

		//    // Check that the file MetraTech.BusinessentityName.OrderManagement.DemandForPayment.cs file exists
		//    Assert.IsTrue(File.Exists(entityName.CodeFile));

		//    // Check that the csproj file contains DemandForPayment.cs and DemandForPayment.hbm.xml
		//    Assert.IsTrue(MSBuildHelper.CSharpFileExistsInCsProj(entityName.Tenant, entityName.CodeFileWithoutPath));
		//    Assert.IsTrue(MSBuildHelper.HbmMappingFileExistsInCsProj(entityName.Tenant, entityName.MappingFileWithoutPath));

		//    // Check property values
		//    List<Entity> lEntities = metadataAccess.GetEntities(tenant);
		//    Assert.True(propName == lEntities[0].Properties[0].Name);
		//    Assert.True(propType == lEntities[0].Properties[0].TypeName);
		//    Assert.True(propIsUnique == lEntities[0].Properties[0].IsUnique);

		//    #endregion
		//}

		[Test]
		public void TestDeleteEntity()
		{
			#region Create entities

			IList<Entity> entities = new List<Entity>();

			// Order
			Entity order = new Entity()
			{
				ClassName = tenantName + "_Order",
				Namespace = tenantName + ".BusinessEntity.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Order Label",
				PluralName = "Orders",
				Description = "Order Description"
			};
			entities.Add(order);

			Property refProperty = new Property(order)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			order.Properties.Add(refProperty);

			Property descProperty = new Property(order)
			{
				Name = "Description",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Description",
				Description = "Description",
			};
			order.Properties.Add(descProperty);

			// LineItem
			Entity lineItem = new Entity()
			{
				ClassName = tenantName + "_LineItem",
				Namespace = tenantName + ".BusinessEntity.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "LineItem Label",
				PluralName = "LineItems",
				Description = "LineItem Description"
			};
			entities.Add(lineItem);

			refProperty = new Property(lineItem)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			lineItem.Properties.Add(refProperty);

			descProperty = new Property(lineItem)
			{
				Name = "Description",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Description",
				Description = "Description",
			};
			lineItem.Properties.Add(descProperty);

			// Product
			Entity product = new Entity()
			{
				ClassName = tenantName + "_Product",
				Namespace = tenantName + ".BusinessEntity.OrderManagement",
				AssemblyName = tenantName + ".BusinessEntity",
				Category = Category.ConfigDriven,
				Tenant = tenantName,
				Label = "Product Label",
				PluralName = "Products",
				Description = "Product Description"
			};
			entities.Add(product);

			refProperty = new Property(product)
			{
				Name = "ReferenceNumber",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Ref# Label",
				Description = "Ref# Description",
				DefaultValue = "abc",
				IsBusinessKey = true
			};
			product.Properties.Add(refProperty);

			descProperty = new Property(product)
			{
				Name = "Description",
				QualifiedName = new QualifiedName("System.String", tenantName),
				Label = "Description",
				Description = "Description",
			};
			product.Properties.Add(descProperty);

			#endregion

			// Create Relationships
			MetadataAccess.Instance.CreateOneToManyRelationship(ref order, ref lineItem);
			MetadataAccess.Instance.CreateOneToManyRelationship(ref lineItem, ref product);

			// Save Entities
			MetadataAccess.Instance.SaveEntities(tenantName, entities);

			// Delete LineItem
			List<ErrorObject> errors;
			List<Entity> changedEntities = MetadataAccess.Instance.DeleteEntity(lineItem, out errors);
			Assert.AreEqual(2, changedEntities.Count, "Mismatched counts");

		}

		#region Private Methods

		#endregion

		// TODO: Add tests for proper error messages
		// TODO: Add tests for invalid default values
		// TODO: Add tests for default DateTime values
		// TODO: Add tests for default Decimal values other than 0
		// TODO: Add tests for default GUID {E9378233-6B6F-44f6-B4FD-81609DCDA4A8}
		// TODO: Add tests for default Enums

		#region Data
		private string tenantName = "MetadataTestQA";
		#endregion
	}
}
