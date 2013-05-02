using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;
using System.Reflection;

namespace AgreementTemplate.Test
{
    
    
    /// <summary>
    ///This is a test class for AgreementTemplatePropertiesViewModelTest and is intended
    ///to contain all AgreementTemplatePropertiesViewModelTest Unit Tests
    ///</summary>
    [TestClass()]
    public class AgreementTemplatePropertiesViewModelTest
    {
        private const int MAXID = 10000;
        private readonly Random m_random = new Random();

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
        /// A test for Validate. Confirm that the combo of no available end date and no available start date does not generate validation errors.
        ///</summary>
        [TestMethod()]
        public void TpvmTest_ValidateNoAvailableDates()
        {
          string uniqueName = "TpvmTest_ValidateBadAvailableDates" + m_random.Next(MAXID);
          var target = new AgreementTemplatePropertiesViewModel()
          {
            CreatedBy = 123,
            AgreementTemplateName = uniqueName
          };
          var validationContext = new ValidationContext(target, null, null)
          {
            DisplayName = target.GetType().Name
          };

          IEnumerable<ValidationResult> result;
          result = target.Validate(validationContext);
          // We expect no results in the validation results because we have a valid available start and end date combination in the AgreementTemplatePropertiesViewModel object
          Assert.AreEqual(0, result.Count());
        }

        /// <summary>
        /// A test for Validate. Confirm that the combo of no available end date and an available start date does not generate validation errors.
        ///</summary>
        [TestMethod()]
        public void
          TpvmTest_ValidateNoAvailableEndDate()
        {
          string uniqueName = "TpvmTest_ValidateBadAvailableDates" + m_random.Next(MAXID);
          var target = new AgreementTemplatePropertiesViewModel()
          {
            CreatedBy = 123,
            AgreementTemplateName = uniqueName,
            AvailableStartDate = new DateTime(2013, 1, 1)
          };
          var validationContext = new ValidationContext(target, null, null)
          {
            DisplayName = target.GetType().Name
          };

          IEnumerable<ValidationResult> result;
          result = target.Validate(validationContext);
          // We expect no results in the validation results because we have a valid available start and end date combination in the AgreementTemplatePropertiesViewModel object
          Assert.AreEqual(0, result.Count());
        }

        /// <summary>
        /// A test for Validate. Confirm that the combo of an available end date and no available start date does not generate validation errors.
        ///</summary>
        [TestMethod()]
        public void TpvmTest_ValidateNoAvailableStartDate()
        {
          string uniqueName = "TpvmTest_ValidateBadAvailableDates" + m_random.Next(MAXID);
          var target = new AgreementTemplatePropertiesViewModel()
          {
            CreatedBy = 123,
            AgreementTemplateName = uniqueName,
            AvailableEndDate = new DateTime(2013, 1, 1)
          };
          var validationContext = new ValidationContext(target, null, null)
          {
            DisplayName = target.GetType().Name
          };

          IEnumerable<ValidationResult> result;
          result = target.Validate(validationContext);
          // We expect no results in the validation results because we have a valid available start and end date combination in the AgreementTemplatePropertiesViewModel object
          Assert.AreEqual(0, result.Count());
        }

        /// <summary>
        /// A test for Validate. Confirm that an available end date that is after the available start date does not generate validation errors.
        ///</summary>
        [TestMethod()]
        public void TpvmTest_ValidateGoodAvailableDates()
        {
          string uniqueName = "TpvmTest_ValidateBadAvailableDates" + m_random.Next(MAXID);
          var target = new AgreementTemplatePropertiesViewModel()
          {
            CreatedBy = 123,
            AgreementTemplateName = uniqueName,
            AvailableStartDate = new DateTime(2013, 1, 1),
            AvailableEndDate = new DateTime(2013, 1, 31) // Set the available end date to a valid day that is after than the available start date. This should NOT cause a validation error to be added to the validation results.
          };
          var validationContext = new ValidationContext(target, null, null)
          {
            DisplayName = target.GetType().Name
          };

          IEnumerable<ValidationResult> result;
          result = target.Validate(validationContext);
          // We expect no results in the validation results because we have a valid available start and end date combination in the AgreementTemplatePropertiesViewModel object
          Assert.AreEqual(0, result.Count());
        }

        /// <summary>
        ///A test for Validate.  Confirm that an available end date that is before the available start date generates validation errors.
        ///</summary>
        [TestMethod()]
        public void TpvmTest_ValidateBadAvailableDates()
        {
          string uniqueName = "TpvmTest_ValidateBadAvailableDates" + m_random.Next(MAXID);
          var target = new AgreementTemplatePropertiesViewModel()
          {
            CreatedBy = 123,
            AgreementTemplateName = uniqueName,
            AvailableStartDate = new DateTime(2013, 1, 31),
            AvailableEndDate = new DateTime(2013, 1, 1) // Set the available end date to a day that is earlier than the available start date. This should cause a validation error to be added to the validation results.
          };
          var validationContext = new ValidationContext(target, null, null)
          {
            DisplayName = target.GetType().Name
          };

          IEnumerable<ValidationResult> result;
          result = target.Validate(validationContext);
          // We expect results in the validation results because we have an invalid available start and end date combination in the AgreementTemplatePropertiesViewModel object
          Assert.AreNotEqual(0, result.Count());
        }
    }
}
