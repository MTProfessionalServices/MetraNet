using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

// Metratech specific.
using NUnit.Framework;
using MetraTech.Interop.RCD;
using MetraTech.DDO;

//
namespace MetraTech.DynamicDataObjects.Test
{
  /// <summary>
  ///   Unit Tests for Dynamic Data Objects framework
  ///   
  ///   To run the this test fixture:
  //    nunit-console /fixture:MetraTech.DynamicDataObjects.Test.DDOConfigurationTests /assembly:O:\debug\bin\MetraTech.DynamicDataObjects.Test.dll
  /// </summary>
  [TestFixture]
  class DDOConfigurationTests
  {
    // Data members.
    private Logger mLogger = new Logger("[DDOConfigurationTests]");
    private IMTRcd mRcd = new MTRcdClass();
    private string mDefaultExtension = "SmokeTest";
    private static Entities mEntities = new Entities();

    [TestFixtureSetUp]
    public void Setup()
    {
      // Create sample entities and save them to SmokeTest extention.
      mEntities.Add(CreateStockEntity("OTC_Stock",
                                      "This object is used to keep track of over the counter trades.",
                                      mDefaultExtension));
      mEntities.Add(CreateStockEntity("NYSE_Stock",
                                      "This object is used to keep track of New Your Stock Exchange trades.",
                                      mDefaultExtension));
      mEntities.Add(CreateStockEntity("Nasdaq_Stock",
                                      "This object is used to keep track of Nasdaq stock trades.",
                                      mDefaultExtension));
      mEntities.Add(CreateStockEntity("Delete_Test",
                                      "This object is used to keep track of Nasdaq stock trades.",
                                      mDefaultExtension));
      mEntities.Save();
    }

    [TestFixtureTearDown]
    public void TearDown()
    {
      mEntities.Remove("OTC_Stock");
      mEntities.Remove("NYSE_Stock");
      mEntities.Remove("Nasdaq_Stock");
      mEntities.Remove("Delete_Test");
    }

    /// <summary>
    /// Validate that the sample entities were added during initialization.
    /// </summary>
    [Test]
    [Category("DDO Configuration")]
    public void AddEntityTest()
    {
      // Check to see that all entities files were added.
      foreach (Entity entity in mEntities)
        Assert.IsTrue(File.Exists(entity.Path), "DDO configuration file '{0}' not created.", entity.Path);
    }

    /// <summary>
    /// Delete one of the entities added during initialization.
    /// </summary>
    [Test]
    [Category("DDO Configuration")]
    public void DeleteEntityTest()
    {
      // Get the entity object.
      Entity entity = Entity.Load("Delete_Test", mDefaultExtension);

      // Delete the entity.
      mEntities.Remove("Delete_Test");

      // Validate that the entity file is deleted.
      Assert.IsFalse(File.Exists(entity.Path), "DDO configuration file '{0}' was not deleted.", entity.Path);
    }

    /// <summary>
    /// </summary>
    [Test]
    [Category("DDO Configuration")]
    public void UpdateEntityTest()
    {
      string description = "Description modified by UpdateEntityTest";

      // Load an existing entity.
      Entity entity = Entity.Load("OTC_Stock", mDefaultExtension);

      // Remeber entity for later comparison.
      string originalEnityDescription = entity.Description;

      // Update existing entity.
      entity.Description = description;

      // Modify the first property.
      Property property = entity.Properties["Symbol"];
      string originalProperyDescription = property.Description;
      property.Description = description;
      property.DefaulValue = "Default value set to this string";
      entity.Properties["Symbol"] = property;
      
      // Save.
      entity.Save();

      // Load again to see if data is valid.
      entity = Entity.Load("OTC_Stock", mDefaultExtension);

      // Validate entity description.
      Assert.AreNotEqual(entity.Description, originalEnityDescription, "DDO description was not modified.");
      Assert.AreEqual(entity.Description, description, "DDO description was modified but not saved.");

      // Validate property.
      Property savedProperty = entity.Properties["Symbol"];
      Assert.AreNotEqual(property.Description, originalProperyDescription, "Property description was not modified.");
      Assert.AreEqual(property.Description, description, "Property description was modified but not saved.");
      Assert.AreEqual(property.DefaulValue, "Default value set to this string", "DefaultValue property not modified.");
    }

    /// <summary>
    /// </summary>
    [Test]
    [Category("DDO Configuration")]
    public void InvalidExtensionParameterTest()
    {
      //xxx TODO:
      // 1. Load an existing entity
      // 2. Set invalid extension, catch exception.
    }

    [Test]
    [Category("DDO Configuration")]
    public void ValidateEntityTypesTest()
    {
      //xxx TODO:
      // 1. Make sure only valid types can be added.
    }

    [Test]
    [Category("DDO Configuration")]
    public void AddRelationTest()
    {
      //xxx TODO:
      // 1. Add a valid Relation to entity and make sure it is added.
      // 2. Add an invalid relation to entity and make sure it fails.
      // 3. 
    }

    [Test]
    [Category("DDO Configuration")]
    public void ValidateRelationParametersTest()
    {
      //xxx TODO:
      // 1. Make sure only valid Relationships may be addedtypes can be added.
    }

    [Test]
    [Category("DDO Configuration")]
    public void UpdateEntitiesTest()
    {
      //xxx TODO: Load exisiting entities and see if they exists in the collection.

      //xxx TODO: Update more than one entity.
      try
      {
      }
      catch (Exception ex)
      {
        mLogger.LogError("xxx TODO, error: " + ex.InnerException.Message);
        throw ex;
      }

      try
      {
      }
      catch (Exception ex)
      {
        mLogger.LogError("xxx TODO, error: " + ex.InnerException.Message);
        throw ex;
      }
    }

    /// <summary>
    /// This function allows us to create  many entities. They are all the same except for type name.
    /// This will allows us to test all the option of the DDO configuration api, including the case
    /// with one or more entities.
    /// </summary>
    /// <param name="name">Name of entity to create</param>
    /// <param name="description">Desfription for the entity</param>
    /// <param name="extension">Extension to store the entity to</param>
    /// <returns></returns>
    public Entity CreateStockEntity(string name, string description, string extension)
    {
      Entity entity = new Entity();
      entity.Name = name;
      entity.Extension = extension;
      entity.Description = description;

      // Add properties

      // Stock symbol
      Property property = new Property();
      property.Name = "Symbol";
      property.Description = "Stock market trading equity symbol.";
      property.PropType = PropertyType.STRING;
      property.Size = 4;
      property.IsNullable = false;
      property.IsUnique = true;
      entity.AddProperty(property);

      // Stock company name
      property = new Property();
      property.Name = "CompanyName";
      property.Description = "Corporate name of the publicly traded company associated with symbol.";
      property.Size = 255;
      property.PropType = PropertyType.STRING;
      property.IsNullable = true;
      property.IsUnique = true;
      entity.AddProperty(property);

      // Quantity
      property = new Property();
      property.Name = "Quantity";
      property.Description = "Number of shares purchased.";
      property.PropType = PropertyType.INTEGER;
      property.IsNullable = false;
      property.IsUnique = false;
      entity.AddProperty(property);

      // Purchase Date
      property = new Property();
      property.Name = "TransactionDate";
      property.Description = "Date the shares of stock were purchased.";
      property.PropType = PropertyType.DATETIME;
      property.IsNullable = false;
      property.IsUnique = true;
      entity.AddProperty(property);

      // Price
      property = new Property();
      property.Name = "Price";
      property.Description = "Price of the stock at the time of purchase or sale.";
      property.PropType = PropertyType.DECIMAL;
      property.IsNullable = false;
      property.IsUnique = true;
      entity.AddProperty(property);

      // Transaction Type: BUY, SELL
      //xxx TODO: How to handle enums...
      // need another property to specify the fully qualified name of enum

      return entity;
    }
  }
}