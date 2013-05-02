using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;

namespace AgreementTemplate.Test
{
    
    
    /// <summary>
    ///This is a test class for AgreementEntitiesViewModelTest and is intended
    ///to contain all AgreementEntitiesViewModelTest Unit Tests
    ///</summary>
    [TestClass()]
    public class AgreementEntitiesViewModelTest
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
        ///A test for AgreementEntitiesViewModel Constructor
        ///</summary>
        [TestMethod()]
        public void EvmTest_AgreementEntitiesViewModelConstructor()
        {
            AgreementEntitiesViewModel target = new AgreementEntitiesViewModel();
            Assert.IsNotNull(target.AgreementEntityList);
        }

        /// <summary>
        ///A test for Model
        ///</summary>
        [TestMethod()]
        public void EvmTest_Model()
        {
            AgreementEntitiesViewModel target = new AgreementEntitiesViewModel(); 
            target.AgreementEntityList.Add(CreateEntity());
            AgreementEntitiesModel actual = target.Model();
            Assert.IsTrue(actual.AgreementEntityList.Count == target.AgreementEntityList.Count);
            foreach (var entity in actual.AgreementEntityList)
                Assert.IsTrue(actual.AgreementEntityList.Contains(entity));
        }

        /// <summary>
        /// Test that adding the same entity twice throws an exception.
        /// </summary>
        [TestMethod]
        [ExpectedException(typeof(ArgumentException))]
        public void EvmTest_AddDuplicateEntityToViewModel()
        {
            AgreementEntitiesViewModel target = new AgreementEntitiesViewModel();
            var entity = CreateEntity();
            target.AgreementEntityList.Add(entity);
            target.AgreementEntityList.Add(entity);
            target.Model();
        }
    }
}
