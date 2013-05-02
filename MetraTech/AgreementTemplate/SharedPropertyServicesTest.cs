using System.Data;
using System.Linq;
using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;
using MetraTech.DataAccess;
using System.Collections.Generic;
using MetraTech.DomainModel.Enums.Core.Global;

namespace AgreementTemplate.Test
{
    
    
    /// <summary>
    ///This is a test class for SharedPropertyServicesTest and is intended
    ///to contain all SharedPropertyServicesTest Unit Tests
    ///</summary>
    [TestClass()]
    public class SharedPropertyServicesTest
    {
         private readonly Random m_random = new Random();
         private AgreementTemplateModel SetUpTemplateCoreProperties(IAgreementTemplateServices svc)
         {

             AgreementTemplateModel target = new AgreementTemplateModel();
             Random random = new Random();
             int randomNum = random.Next(1000);

             target.CoreTemplateProperties.AgreementTemplateDescId = randomNum;
             target.CoreTemplateProperties.AgreementTemplateName = "dummy" + randomNum;
             target.CoreTemplateProperties.AgreementTemplateNameId = randomNum;
             target.CoreTemplateProperties.AgreementTemplateDescription = "";
             target.CoreTemplateProperties.CreatedBy = 123;
             target.CoreTemplateProperties.CreatedDate = DateTime.Now;
             return target;
         }
        private int createTemplateModel()
        {
            var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();
            var target = SetUpTemplateCoreProperties(svc);
            var actual = svc.Save(target);
            return actual.AgreementTemplateId == null ? -1 : (int)actual.AgreementTemplateId;
        }

        private SharedPropertyValueModel createPropVal()
        {
            var propVals = new SharedPropertyValueModel();
            //propVals.ID = null;
            propVals.IsDefault = false;
            //propVals.LocalizedDisplayValues = new Dictionary<LanguageCode, string>();
            //propVals.LocalizedDisplayValues.Add(LanguageCode.US, "LocalVal" + propVals.ID);
            propVals.Value = "Val" + propVals.ID;
            //propVals.ValueID = null; // m_random.Next();
            return propVals;
        }
        private Dictionary<LanguageCode, string> SetLocalizedData(string name, bool popDesc)
        {
            Dictionary<LanguageCode, string> dict = new Dictionary<LanguageCode, string>();
            if (popDesc)
            {
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, String.Format("{0} English Description", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, String.Format("{0} Japanese Description", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, String.Format("{0} Italian Description", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, String.Format("{0} French Description", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, String.Format("{0} German Description", name));
            }
            else
            {
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.US, String.Format("{0} English names", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.JP, String.Format("{0} Japanese Names", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.IT, String.Format("{0} Italian Names", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.FR, String.Format("{0} French Names", name));
                dict.Add(MetraTech.DomainModel.Enums.Core.Global.LanguageCode.DE, String.Format("{0} German Names", name));
            }
            return dict;
        }

        private SharedPropertyModel createSharedProperty()
        {
            int num = m_random.Next();
            var svc = new SharedPropertyServices();
            var sharedProperty = new SharedPropertyModel();
            sharedProperty.ID = null;
            string name = "SharedProp" + num;
            sharedProperty.Name = name;
            sharedProperty.Category = "Category" + num;
            sharedProperty.Description = "Description";
            sharedProperty.DisplayName = "DisplayName" + num;
            sharedProperty.LocalizedCategories = SetLocalizedData("mycategory", false);
            sharedProperty.LocalizedDisplayNames = SetLocalizedData(name, true);
            sharedProperty.LocalizedDescriptions = SetLocalizedData(name, true); 
            sharedProperty.SharedPropertyValues = new List<SharedPropertyValueModel>();
            sharedProperty.SharedPropertyValues.Add(createPropVal());
            sharedProperty.PropType = PropertyType.String;
            sharedProperty.UserEditable = false;
            sharedProperty.UserVisible = false;
            
            svc.SaveSharedProperty(ref sharedProperty);
            return sharedProperty;
        }

        private bool areBasicPropsEqual(SharedPropertyModel prop1, SharedPropertyModel prop2)
        {
            //Decided not to use one long if statement here to make it easier to step through in the debugger to see which line failed;
            if  (prop1.PropType != prop2.PropType) return false;
            if (!prop1.Category.Equals(prop2.Category)) return false;
            if (prop1.IsRequired != prop2.IsRequired) return false;
            if (!prop1.Description.Equals(prop2.Description)) return false;
            if (!prop1.Name.Equals(prop2.Name)) return false;
            if (prop1.UserVisible != prop2.UserVisible) return false;
            if (prop1.UserEditable != prop2.UserEditable) return false;
            if (!checkMinMaxVals(prop1.MinValue, prop2.MinValue)) return false;
            if (!checkMinMaxVals(prop1.MaxValue, prop2.MaxValue)) return false;
            return prop1.DisplayOrder == prop2.DisplayOrder;
        }

        private bool checkMinMaxVals(String s1, String s2)
        {
            if (s1 == null) return (s2 == null || s2.Equals("NULL"));
            if (s2 == null) return (s1.Equals("NULL"));
            return s1.Equals(s2);
        }

        //Despite the name, this doesn't check that the lists are equal, because that turns out to be
        // too stringent a standard, depending on the state of the DB.
        //  Instead, check that everything in l1 is in l2.
        private bool arePropListsEqual(List<SharedPropertyModel> l1, List<SharedPropertyModel> l2 )
        {
            foreach (var p1 in l1)
            {
                var dummy = false;
                foreach (var p2 in l2)
                {
                    if (areBasicPropsEqual(p1, p2))
                    {
                        dummy = true;
                        break; }
                }
                if (!dummy) return false;
            }
            return true;
        }
        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region Additional test attributes

        // You can use the following additional attributes as you write your tests:

        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            TestUtilities.CleanDatabase();
        }

        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion


        /// <summary>
        ///A test for GetSharedPropertiesForEntity
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_GetSharedPropertiesForEntity()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            List<FilterElement> filterpropertiesList = null;
            List<SortCriteria> sortCriteria = null;
            List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
            int entityId = createTemplateModel();
            target.SaveSharedPropertyForEntity(entityId, EntityType.ProductOffering, property);
            List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> {property};
            target.GetSharedPropertiesForEntity(entityId, filterpropertiesList, sortCriteria, ref sharedProperties);
            Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
            target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId);
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for GetSharedPropertiesForEntity with entityType parameter
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_GetSharedPropertiesForEntity_with_entityType()
        {
          SharedPropertyServices target = new SharedPropertyServices();
          var property = createSharedProperty();
          List<FilterElement> filterpropertiesList = null;
          List<SortCriteria> sortCriteria = null;
          List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
          int entityId = createTemplateModel();
          var entityType = EntityType.AgreementTemplate;
          target.SaveSharedPropertyForEntity(entityId, entityType, property);
          List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> { property };
          target.GetSharedPropertiesForEntity(entityId, entityType, filterpropertiesList, sortCriteria, ref sharedProperties);
          Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
          target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId);
          target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for GetSharedPropertiesForEntity with wrong entityType parameter
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_GetSharedPropertiesForEntity_with_wrong_entityType()
        {
          SharedPropertyServices target = new SharedPropertyServices();
          var property = createSharedProperty();
          List<FilterElement> filterpropertiesList = null;
          List<SortCriteria> sortCriteria = null;
          List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
          int entityId = createTemplateModel();
          var entityType = EntityType.AgreementTemplate;
          var wrongEntityType = EntityType.ProductOffering;
          target.SaveSharedPropertyForEntity(entityId, entityType, property);
          List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> { property };
          target.GetSharedPropertiesForEntity(entityId, wrongEntityType, filterpropertiesList, sortCriteria, ref sharedProperties);
          Assert.IsFalse(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
          target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId);
          target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for GetSharedProperties
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_GetSharedProperties()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            target.SaveSharedProperty(ref property);
            var returnedProps = new List<SharedPropertyModel>();
            target.GetSharedProperties(null, null, ref returnedProps);
            Assert.IsTrue(arePropListsEqual(new List<SharedPropertyModel> { property }, returnedProps));
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for DeleteSharedProperty
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_DeleteSharedProperty()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            target.SaveSharedProperty(ref property);
            var returnedProps = new List<SharedPropertyModel>();
            target.GetSharedProperties(null, null, ref returnedProps);
            int countBeforeDelete = returnedProps.Count;
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
            returnedProps.Clear();
            target.GetSharedProperties(null, null, ref returnedProps);
            int countAfterDelete = returnedProps.Count;
            Assert.AreEqual(countBeforeDelete, countAfterDelete + 1);
        }

        /// <summary>
        ///A test for DeleteSharedProperty. Verify that you cannot delete a shared property that is in use by an agreement template.
        ///</summary>
        [TestMethod()]
        [ExpectedException(typeof(DataException), "Cannot remove shared property because it is in use.")]
        public void SpsvcTest_DeleteSharedProperty_in_use()
        {
          SharedPropertyServices target = new SharedPropertyServices();
          var property = createSharedProperty();
          target.SaveSharedProperty(ref property);
          var returnedProps = new List<SharedPropertyModel>();
          target.GetSharedProperties(null, null, ref returnedProps);
          int countBeforeDelete = returnedProps.Count;

          // Add the shared property to an agreement template
          int entityId = createTemplateModel();
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property);

          // Try to delete the shared property now
          try
          {
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
          }
          catch (DataException e)
          {
            returnedProps.Clear();
            target.GetSharedProperties(null, null, ref returnedProps);
            int countAfterDelete = returnedProps.Count;
            // Both before and after counts should be equal
            Assert.AreEqual(countBeforeDelete, countAfterDelete);
            // Count after delete should be = 1
            Assert.AreEqual(1, countAfterDelete);

            // Finally clean up
            var vals = new List<SharedPropertyValueModel>();
            target.GetSharedPropertyValuesForSharedProperty(property.ID.GetValueOrDefault(), null, null, ref vals);

            var valIds = vals.Select(v => v.ID.Value).ToList();

            target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId, EntityType.AgreementTemplate);
            target.RemoveSharedPropertyValuesFromSharedProperty(property.ID.GetValueOrDefault(), valIds, null); 
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
            throw e;
          }
        }

        /// <summary>
        ///A test for GetSharedProperty
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_GetSharedProperty()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            target.SaveSharedProperty(ref property);
            SharedPropertyModel returnedProp;
            target.GetSharedProperty(property.ID.GetValueOrDefault(), out returnedProp);
            Assert.IsTrue(areBasicPropsEqual(property, returnedProp));
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for RemoveSharedPropertyFromEntity
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_RemoveSharedPropertyFromEntity()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            var property2 = createSharedProperty();
            List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
            int entityId = createTemplateModel();

            //Add two properties to entity, then check that both made it in.
            target.SaveSharedPropertyForEntity(entityId, EntityType.ProductOffering, property);
            target.SaveSharedPropertyForEntity(entityId, EntityType.ProductOffering, property2);
            List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> { property, property2 };
            target.GetSharedPropertiesForEntity(entityId, null, null, ref sharedProperties);
            Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));

            //Remove a property from the entity and from the expected list; check that both new lists are the same.
            sharedPropertiesExpected = new List<SharedPropertyModel> {property};
            target.RemoveSharedPropertyFromEntity(property2.ID.GetValueOrDefault(), entityId);
            sharedProperties.Clear();
            target.GetSharedPropertiesForEntity(entityId, null, null, ref sharedProperties);
            Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
            target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId);
            

            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
            target.DeleteSharedProperty(property2.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for RemoveSharedPropertyFromEntity with entity type
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_RemoveSharedPropertyFromEntity_with_entityType()
        {
          SharedPropertyServices target = new SharedPropertyServices();
          var property = createSharedProperty();
          var property2 = createSharedProperty();
          List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
          int entityId = createTemplateModel();

          //Add two properties to entity, then check that both made it in.
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property);
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property2);
          List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> { property, property2 };
          target.GetSharedPropertiesForEntity(entityId, EntityType.AgreementTemplate, null, null, ref sharedProperties);
          Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));

          //Remove a property from the entity and from the expected list; check that both new lists are the same.
          sharedPropertiesExpected = new List<SharedPropertyModel> { property };
          target.RemoveSharedPropertyFromEntity(property2.ID.GetValueOrDefault(), entityId, EntityType.AgreementTemplate);
          sharedProperties.Clear();
          target.GetSharedPropertiesForEntity(entityId, EntityType.AgreementTemplate, null, null, ref sharedProperties);
          Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
          target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId, EntityType.AgreementTemplate);


          target.DeleteSharedProperty(property.ID.GetValueOrDefault());
          target.DeleteSharedProperty(property2.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for RemoveSharedPropertyFromEntity with wrong entity type
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_RemoveSharedPropertyFromEntity_with_wrong_entityType()
        {
          SharedPropertyServices target = new SharedPropertyServices();
          var property = createSharedProperty();
          var property2 = createSharedProperty();
          List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
          int entityId = createTemplateModel();

          //Add two properties to entity, then check that both made it in.
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property);
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property2);
          List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> { property, property2 };
          target.GetSharedPropertiesForEntity(entityId, EntityType.AgreementTemplate, null, null, ref sharedProperties);
          Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));

          // Remove a property from the entity using the wrong entity type from the expected list; No properties are expected to be removed from the entity because
          // the wrong entity type was passed to the RemoveSharedPropertyFromEntity() method;
          // Check that both new lists are the same.
          sharedPropertiesExpected = new List<SharedPropertyModel> { property2, property };
          target.RemoveSharedPropertyFromEntity(property2.ID.GetValueOrDefault(), entityId, EntityType.ProductOffering);
          sharedProperties.Clear();
          target.GetSharedPropertiesForEntity(entityId, EntityType.AgreementTemplate, null, null, ref sharedProperties);
          Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
          target.RemoveSharedPropertyFromEntity(property2.ID.GetValueOrDefault(), entityId, EntityType.AgreementTemplate);
          target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId, EntityType.AgreementTemplate);


          target.DeleteSharedProperty(property.ID.GetValueOrDefault());
          target.DeleteSharedProperty(property2.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for SaveSharedProperty.  This is currently the same as the test for GetSharedProperty, until we think of a better way
        /// to confirm whether the property actually saved.
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_SaveSharedProperty()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            target.SaveSharedProperty(ref property);
            SharedPropertyModel returnedProp;
            target.GetSharedProperty(property.ID.GetValueOrDefault(), out returnedProp);
            Assert.IsTrue(areBasicPropsEqual(property, returnedProp));
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        ///A test for SaveSharedPropertyForEntity.  Currently, this is the same as the Get test.
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_SaveSharedPropertyForEntity()
        {
            SharedPropertyServices target = new SharedPropertyServices();
            var property = createSharedProperty();
            List<FilterElement> filterpropertiesList = null;
            List<SortCriteria> sortCriteria = null;
            List<SharedPropertyModel> sharedProperties = new List<SharedPropertyModel>();
            int entityId = createTemplateModel();
            target.SaveSharedPropertyForEntity(entityId, EntityType.ProductOffering, property);
            List<SharedPropertyModel> sharedPropertiesExpected = new List<SharedPropertyModel> {property};
            target.GetSharedPropertiesForEntity(entityId, filterpropertiesList, sortCriteria, ref sharedProperties);
            Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));
            target.RemoveSharedPropertyFromEntity(property.ID.GetValueOrDefault(), entityId);
            target.DeleteSharedProperty(property.ID.GetValueOrDefault());
        }

        /// <summary>
        /// A test for SaveSharedPropertyForEntity. Add multiple shared properties to the same agreement template with no display orders set on the shared properties.
        /// Next, update the display order for all shared properties that are attached to the agreement template.
        ///</summary>
        [TestMethod()]
        public void SpsvcTest_SaveSharedPropertyForEntity_with_updated_display_order()
        {
          SharedPropertyServices target = new SharedPropertyServices();
          var property_one = createSharedProperty();
          var property_two = createSharedProperty();
          List<FilterElement> filterpropertiesList = null;
          List<SortCriteria> sortCriteria = null;
          var sharedProperties = new List<SharedPropertyModel>();
          int entityId = createTemplateModel();
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property_one);
          target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, property_two);
          var sharedPropertiesExpected = new List<SharedPropertyModel> { property_one, property_two };
          target.GetSharedPropertiesForEntity(entityId, filterpropertiesList, sortCriteria, ref sharedProperties);
          Assert.IsTrue(arePropListsEqual(sharedPropertiesExpected, sharedProperties));

          // Loop through the list of sharedProperties, update the display order for each shared property and save the changes to db. Also save a map of display orders to shared property id so we can verify the save to database works
          var displayOrderMap = new Dictionary<int, int>();
          int displayOrder = 0;
          foreach (var prop in sharedProperties)
          {
            displayOrder++;
            prop.DisplayOrder = displayOrder;
            if (prop.ID.HasValue)
            {
              displayOrderMap.Add(prop.ID.Value, prop.DisplayOrder.Value);
            }
            target.SaveSharedPropertyForEntity(entityId, EntityType.AgreementTemplate, prop);
          }

          // Get the updates properties back from the databse
          var sharedPropertiesWithDisplayOrderSet = new List<SharedPropertyModel>();
          target.GetSharedPropertiesForEntity(entityId, filterpropertiesList, sortCriteria, ref sharedPropertiesWithDisplayOrderSet);

          // Loop through the properties and make sure that the DisplayOrders are set to values we set earlier
          foreach (var prop in sharedPropertiesWithDisplayOrderSet)
          {
            // find the prop in displayOrderMap
            if (prop.ID.HasValue)
            {
              int expectedDisplayOrder;
              if (displayOrderMap.TryGetValue(prop.ID.Value, out expectedDisplayOrder))
              {
                Assert.AreEqual(expectedDisplayOrder,prop.DisplayOrder);
              }
            }
          }

          // Clean up
          target.RemoveSharedPropertyFromEntity(property_one.ID.GetValueOrDefault(), entityId);
          target.RemoveSharedPropertyFromEntity(property_two.ID.GetValueOrDefault(), entityId);
          target.DeleteSharedProperty(property_one.ID.GetValueOrDefault());
          target.DeleteSharedProperty(property_two.ID.GetValueOrDefault());
        }
    }
}
