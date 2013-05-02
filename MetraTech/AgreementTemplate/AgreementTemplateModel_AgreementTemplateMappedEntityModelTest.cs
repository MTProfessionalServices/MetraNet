using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace AgreementTemplate.Test
{
    
    
    /// <summary>
    ///This is a test class for AgreementTemplateModel_AgreementTemplateMappedEntityModelTest and is intended
    ///to contain all AgreementTemplateModel_AgreementTemplateMappedEntityModelTest Unit Tests
    ///</summary>
    [TestClass()]
    public class AgreementTemplateModel_AgreementTemplateMappedEntityModelTest
    {


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
        internal AgreementTemplateModel.AgreementTemplateMappedEntityModel CreateEntity()
        {
            Random random = new Random();
            var entity = new AgreementTemplateModel.AgreementTemplateMappedEntityModel();
            entity.EntityId = random.Next();
            entity.EntityName = "MyEntity" + random.Next();
            entity.EntityType = AgreementTemplateModel.EntityTypeEnum.ProductOffering;

            return entity;
        }

        /// <summary>
        ///A test for Clone
        ///</summary>
        [TestMethod()]
        public void CloneTest()
        {
            AgreementTemplateModel.AgreementTemplateMappedEntityModel target = CreateEntity();
            var actual = target.Clone();
            Assert.AreEqual(target, actual);
        }

        /// <summary>
        ///A test for Equals, check that equal items succeed
        ///</summary>
        [TestMethod()]
        public void EqualsTest()
        {
            AgreementTemplateModel.AgreementTemplateMappedEntityModel target = CreateEntity();
            var newObj = new AgreementTemplateModel.AgreementTemplateMappedEntityModel();
            newObj.EntityId = target.EntityId;
            newObj.EntityName = target.EntityName;
            newObj.EntityType = target.EntityType;

            bool expected = true; 
            bool actual = target.Equals(newObj);
            Assert.AreEqual(expected, actual);
        }

        /// <summary>
        ///A test for Equals, check that unequal items fail
        ///</summary>
        [TestMethod()]
        public void EqualsFailsTest()
        {
            AgreementTemplateModel.AgreementTemplateMappedEntityModel target = CreateEntity(); 
            var newObj = target.Clone();
            newObj.EntityId = target.EntityId + 1;
            newObj.EntityName = target.EntityName;
            newObj.EntityType = target.EntityType;

            bool expected = false;
            bool actual = target.Equals(newObj);
            Assert.AreEqual(expected, actual);
        }
    }
}
