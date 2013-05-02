using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;

namespace AgreementTemplate.Test
{
    
    
    /// <summary>
    ///This is a test class for AgreementEntitiesModelTest and is intended
    ///to contain all AgreementEntitiesModelTest Unit Tests
    ///</summary>
    [TestClass()]
    public class AgreementEntitiesModelTest
    {

        private readonly Random m_random = new Random();
        private AgreementEntityModel CreateEntity()
        {
            int num = m_random.Next();
                
            return new AgreementEntityModel
            {
                EntityId = num,
                EntityName = "MyName" + num,
                EntityType = EntityTypeEnum.ProductOffering
            };
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
        // 
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
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
        ///A test for AddEntity
        ///</summary>
        [TestMethod()]
        public void EmTest_AddEntity()
        {
            AgreementEntitiesModel target = new AgreementEntitiesModel();
            AgreementEntityModel entity = CreateEntity();
            target.AddEntity(entity);
            var agreementEntities = target.AgreementEntityList;
            Assert.IsTrue(agreementEntities.Contains(entity));
        }

        /// <summary>
        ///A test for AddEntity.  Check that if we alter an entity after adding it to the list,
        /// the original is not changed.
        ///</summary>
        [TestMethod()]
        public void EmTest_AddChangeEntity()
        {
            AgreementEntitiesModel target = new AgreementEntitiesModel();
            AgreementEntityModel entity = CreateEntity();
            target.AddEntity(entity);
            //Since secondEntity is a copy of entity, we can check that the agreementEntities
            //  contains secondEntity.
            var secondEntity = entity.Copy();
            entity.EntityName = "Foo";
            var agreementEntities = target.AgreementEntityList;
            Assert.IsTrue(agreementEntities.Contains(secondEntity));
        }

        /// <summary>
        /// Test that adding the same entity twice throws an exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void EmTest_AddDuplicateEntity()
        {
            AgreementEntitiesModel target = new AgreementEntitiesModel(); 
            var entity = CreateEntity();
            target.AddEntity(entity);
            target.AddEntity(entity);
        }
        /// <summary>
        ///A test for DeleteEntity
        ///</summary>
        [TestMethod()]
        public void EmTest_DeleteEntity()
        {
            var target = new AgreementEntitiesModel();
            var entity = new AgreementEntityModel
                                               {
                                                   EntityId = 1,
                                                   EntityName = "MyName",
                                                   EntityType = EntityTypeEnum.ProductOffering
                                               };
            target.AddEntity(entity);
            Assert.IsTrue(target.AgreementEntityList.Contains(entity));
            target.DeleteEntity(entity.EntityId,entity.EntityType);
            Assert.IsFalse(target.AgreementEntityList.Contains(entity));
        }

        /// <summary>
        /// Test that deleting a non-existent entity throws an exception
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void EmTest_DeleteNonexistentEntity()
        {
            AgreementEntitiesModel target = new AgreementEntitiesModel(); // TODO: Initialize to an appropriate value
            var entity = CreateEntity();
            target.AddEntity(entity);

            var entity2 = CreateEntity();
            target.DeleteEntity(entity2.EntityId, entity2.EntityType);
        }
    }
}
