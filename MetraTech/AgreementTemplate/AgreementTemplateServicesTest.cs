using System.Collections.Generic;
using System.Data;
using System.Linq;
using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;
using MetraTech.DataAccess;


namespace AgreementTemplate.Test
{


    /// <summary>
    ///This is a test class for AgreementTemplateServicesTest and is intended
    ///to contain all AgreementTemplateServicesTest Unit Tests
    ///</summary>
    [TestClass()]
    public class AgreementTemplateServicesTest
    {


        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get { return testContextInstance; }
            set { testContextInstance = value; }
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

        #region Helper Methods

        private static void TestEntityEquality(AgreementEntitiesModel actual, AgreementEntitiesModel target)
        {
            foreach (var entity1 in actual.AgreementEntityList)
            {
                Assert.IsTrue(Enumerable.Contains(target.AgreementEntityList, entity1));
            }
        }

        private static AgreementTemplateModel SetUpTemplateCoreProperties(IAgreementTemplateServices svc)
        {

            AgreementTemplateModel target = new AgreementTemplateModel();
            Random random = new Random();
            int randomNum = random.Next(10000);

            target.CoreTemplateProperties.AgreementTemplateDescId = randomNum;
            target.CoreTemplateProperties.AgreementTemplateName = "dummy" + randomNum;
            target.CoreTemplateProperties.AgreementTemplateNameId = randomNum;
            target.CoreTemplateProperties.AgreementTemplateDescription = "";
            target.CoreTemplateProperties.CreatedBy = 123;
            target.CoreTemplateProperties.CreatedDate = DateTime.Now;
           return target;
        }

        private static AgreementTemplateModel AddEntities(ref AgreementTemplateModel template)
        {
            var entity1 = new AgreementEntityModel
                              {
                                  EntityId = GetOnePOID(),
                                  EntityName = "entity1",
                                  EntityType = EntityTypeEnum.ProductOffering
                              };

            var entity2 = new AgreementEntityModel
                              {
                                  EntityId = GetOnePOID() + 1,
                                  EntityType = EntityTypeEnum.ProductOffering,
                                  EntityName = "entity2"
                              };

            template.AgreementEntities.AddEntity(entity1);
            template.AgreementEntities.AddEntity(entity2);

            return template;
        }

        private static int GetRecentlyAddedTemplateID()
        {
            int ratid = 0;

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
                {
                    using (
                        IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement("SELECT max(id_agr_template) tempid FROM t_agr_template"))
                    {
                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                ratid = rdr.IsDBNull(0) ? 0 : rdr.GetInt32(0);
                            }
                        }

                    }
                }
                return ratid;
            }
            catch (Exception e)
            {
                throw new DataException("Could not get agreement template count..", e);
            }
        }

        private static int GetOnePOID()
        {
            int poid = 0;

            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
                {
                    using (IMTPreparedStatement stmt = conn.CreatePreparedStatement("SELECT max(id_po) poid FROM t_po"))
                    {
                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                poid = rdr.IsDBNull(0) ? 0 : rdr.GetInt32(0);
                            }
                        }

                    }
                }
                return poid;
            }
            catch (Exception e)
            {
                throw new DataException("Could not get agreement template count..", e);
            }
        }


        // This DB query must match the filters in SetUpFilterProperties().
        private static int GetDummyTemplateCountByDbQuery()
        {
            int atc = 0;
            try
            {
                using (IMTConnection conn = ConnectionManager.CreateConnection("Queries\\ProductCatalog"))
                {
                    using (
                        IMTPreparedStatement stmt =
                            conn.CreatePreparedStatement(
                            "SELECT Count(*) templatecount FROM t_agr_template where nm_template_name like 'Dummy%' and nm_template_description like '%S%' and created_by = 123"))
                    {
                        using (IMTDataReader rdr = stmt.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                atc = rdr.IsDBNull(0) ? 0 : rdr.GetInt32(0);
                            }
                        }
                    }
                }
                return atc;
            }
            catch (Exception e)
            {
                throw new DataException("Could not get agreement template count..", e);
            }
        }


        // These filter properties must match the DB query in GetDummyTemplateCountByDbQuery().
        private static List<FilterElement> SetUpFilterProperties()
        {
          //Add Filter Properties which will be sent as parameter to Get Agreement Templates
          List<FilterElement> filterpropertiesfromView = new List<FilterElement>();

          FilterElement property1 = new FilterElement("AgreementTemplateName", FilterElement.OperationType.Like, "Dummy%");
          filterpropertiesfromView.Add(property1);

          FilterElement property2 = new FilterElement("AgreementTemplateDescription", FilterElement.OperationType.Like, "%S%");
          filterpropertiesfromView.Add(property2);

          FilterElement property3 = new FilterElement("CreatedBy", FilterElement.OperationType.Like, 123);
          filterpropertiesfromView.Add(property3);

          return filterpropertiesfromView;
        }


        private static List<SortCriteria> SetUpSortingProperties()
        {
          //Create Sorting Criteria
          List<SortCriteria> scmain = new List<SortCriteria>();

          SortCriteria mysortcriteria1 = new SortCriteria("AgreementTemplateDescription", SortDirection.Ascending);
          scmain.Add(mysortcriteria1);

          SortCriteria mysortcriteria2 = new SortCriteria("CreatedBy", SortDirection.Ascending);
          scmain.Add(mysortcriteria2);

          SortCriteria mysortcriteria3 = new SortCriteria("AgreementTemplateName", SortDirection.Descending);
          scmain.Add(mysortcriteria3);

          return scmain;
        }

        #endregion


        /// <summary>
        ///A test for Save, just core properties set
        ///</summary>
        [TestMethod()]
        public void TsvcTest_CreateCoreTemplate()
        {
            var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();
            var target = SetUpTemplateCoreProperties(svc);
            var actual = svc.Save(target);
            Assert.IsNotNull(actual.AgreementTemplateId);
            var expected = svc.GetAgreementTemplate((int) actual.AgreementTemplateId);
            Assert.AreEqual(expected.CoreTemplateProperties.AgreementTemplateName, actual.CoreTemplateProperties.AgreementTemplateName);
            Assert.AreEqual(expected.CoreTemplateProperties.AgreementTemplateNameId, actual.CoreTemplateProperties.AgreementTemplateNameId);
            Assert.AreEqual(expected.CoreTemplateProperties.CreatedBy, actual.CoreTemplateProperties.CreatedBy);
            Assert.IsNotNull(actual.AgreementTemplateId);
        }

        /// <summary>
        ///A test for Save
        ///</summary>
        [TestMethod()]
        public void TsvcTest_CreateWithEntities()
        {
            var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();
            var target = SetUpTemplateCoreProperties(svc);

            AddEntities(ref target);
            var actual = svc.Save(target);
            Assert.IsNotNull(actual.AgreementTemplateId);
            var expected = svc.GetAgreementTemplate((int) actual.AgreementTemplateId);
            TestEntityEquality(target.AgreementEntities, actual.AgreementEntities);
        }



        /// <summary>
        ///A test for Copy
        ///</summary>
        /* [TestMethod()]
         public void TsvcTest_Copy()
         {
             var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();
             IAgreementTemplateModel target = SetUpTemplateCoreProperties(svc);
             target.AgreementTemplateId = 3;
             AddEntities(ref target);

             var actual = svc.Copy(target);
             Assert.AreEqual(target.AgreementTemplateDescId, actual.AgreementTemplateDescId);
             Assert.AreEqual(target.AgreementTemplateDescription, actual.AgreementTemplateDescription);
             Assert.AreEqual(actual.CreatedBy, target.CreatedBy);
             Assert.AreEqual(actual.AvailableEndDate, target.AvailableEndDate);
             Assert.AreEqual(actual.AvailableStartDate, target.AvailableStartDate);
             Assert.IsNull(actual.AgreementTemplateId);
             Assert.IsNull(actual.AgreementTemplateName);
             Assert.IsNull(actual.UpdatedBy);
             Assert.IsNull(actual.UpdatedDate);

             TestEntityEquality(actual, target);
         }
         */


        /// <summary>
        ///A test for Update
        ///</summary>
        [TestMethod()]
        public void TsvcTest_UpdateWithNoPOs()
        {
            var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();
            var target = SetUpTemplateCoreProperties(svc);
            svc.Save(target);
            target.CoreTemplateProperties.UpdatedBy = 234;
            target.CoreTemplateProperties.AgreementTemplateDescription = "New description";
            var actual = svc.Save(target);
            Assert.IsNotNull(actual.AgreementTemplateId);
            var expected = svc.GetAgreementTemplate((int) actual.AgreementTemplateId);
            Assert.AreEqual(expected.CoreTemplateProperties.AgreementTemplateDescription, actual.CoreTemplateProperties.AgreementTemplateDescription);
            Assert.AreEqual(expected.CoreTemplateProperties.AgreementTemplateDescId, actual.CoreTemplateProperties.AgreementTemplateDescId);
            Assert.AreEqual(expected.CoreTemplateProperties.CreatedBy, actual.CoreTemplateProperties.CreatedBy);

        }

        /// <summary>
        ///A test for updating with POs
        ///</summary>
        [TestMethod()]
        public void TsvcTest_UpdateWithPOs()
        {
            var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();
            var target = SetUpTemplateCoreProperties(svc);
            AddEntities(ref target);
            svc.Save(target);
            target.CoreTemplateProperties.UpdatedBy = 234;
            target.CoreTemplateProperties.AgreementTemplateDescription = "New description";
            var actual = svc.Save(target);

        }


        /// <summary>
        /// A test for GetAgreementTemplates
        /// </summary>
        [TestMethod()]
        public void TsvcTest_GetAgreementTemplates()
        {
          var target = AgreementTemplateServicesFactory.GetAgreementTemplateService();

          int dbTemplateCount = GetDummyTemplateCountByDbQuery();
          int pagesize = 1 + dbTemplateCount;  // so that all templates are included in page 1
          int pagecount = 1;

          List<FilterElement> fe = SetUpFilterProperties();
          List<SortCriteria> sc = SetUpSortingProperties();

          List<AgreementTemplateModel> svcAgreementTemplateList;
          target.GetAgreementTemplates(fe, sc, pagesize, pagecount, out svcAgreementTemplateList);
          int svcTemplateCount = svcAgreementTemplateList.Count;

          TestContext.WriteLine("pagesize={0}", pagesize);
          TestContext.WriteLine("dbTemplateCount={0}", dbTemplateCount);
          TestContext.WriteLine("svcTemplateCount={0}", svcTemplateCount);
          TestContext.WriteLine("Test will fail if dbTemplateCount exceeds pagesize!");

          Assert.AreEqual(dbTemplateCount, svcTemplateCount, "Expected and actual template count do not match.");
        }


        /// <summary>
        ///A test for GetAgreementTemplate
        ///</summary>
        [TestMethod()]
        public void TsvcTest_GetAgreementTemplate()
        {
            var target = AgreementTemplateServicesFactory.GetAgreementTemplateService();

            var newtemplate = SetUpTemplateCoreProperties(target);
            var actualt = target.Save(newtemplate);

            int templid = GetRecentlyAddedTemplateID();
            templid = (int) actualt.AgreementTemplateId;

            var expectedt = target.GetAgreementTemplate(templid);
                //target.GetAgreementTemplate(templid);

            Assert.AreEqual(expectedt.AgreementTemplateId, templid, "Expected and Actual Template Ids should match..");

        }

        /// <summary>
        ///A test for GetAgreementTemplateEntities
        ///</summary>
        [TestMethod()]
        public void TsvcTest_GetAgreementTemplateEntities()
        {
            var target = AgreementTemplateServicesFactory.GetAgreementTemplateService(1);
            var template = new AgreementTemplateModel();
            
            // Get the stubbed version of the service for now so we can verify data is populated in the List

            var entitieslistExpected = target.GetAgreementTemplateEntities(template.AgreementEntities);
            Assert.IsNotNull(entitieslistExpected, "Returned Agreement Template List");
            Assert.IsTrue(entitieslistExpected.Count > 0);
        }

        /// <summary>
        ///A test for GetAgreementTemplateMappedEntities
        ///</summary>
        [TestMethod()]
        public void TsvcTest_GetAgreementTemplateMappedEntities()
        {
            var svc = AgreementTemplateServicesFactory.GetAgreementTemplateService();

            var newtemplate = SetUpTemplateCoreProperties(svc);
            AddEntities(ref newtemplate);
            TestContext.WriteLine("Template name = '{0}'", newtemplate.CoreTemplateProperties.AgreementTemplateName);
            var actualt = svc.Save(newtemplate);
            int templid = GetRecentlyAddedTemplateID();

            // List<AgreementEntityModel> entitieslistExpected = svc.GetAgreementTemplateMappedEntities(templid);
            //Assert.IsNotNull(entitieslistExpected, "Returned Agreement Template mapped entities list");
        }


    }
}
