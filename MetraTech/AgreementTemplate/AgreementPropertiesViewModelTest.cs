using System.Collections.ObjectModel;
using System.Linq;
using MetraTech;
using MetraTech.Agreements.Models;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using Microsoft.VisualStudio.TestTools.UnitTesting.Web;
using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;

namespace AgreementTemplate.Test
{


  /// <summary>
  ///This is a test class for AgreementPropertiesViewModelTest and is intended
  ///to contain all AgreementPropertiesViewModelTest Unit Tests
  ///</summary>
  [TestClass()]
  public class AgreementPropertiesViewModelTest
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

    /// <summary>
    /// A test for Validate. Confirm that the combo of no effective end date and no effective start date does not generate validation errors.
    ///</summary>
    [TestMethod()]
    public void PvmTest_ValidateNoEffectiveDates()
    {
      var target = new AgreementPropertiesViewModel();
      var validationContext = new ValidationContext(target, null, null)
      {
        DisplayName = target.GetType().Name
      };

      IEnumerable<ValidationResult> result;
      result = target.Validate(validationContext);
      // We expect no results in the validation results because we have a valid effective start and end date combination in the AgreementPropertiesViewModel object
      Assert.AreEqual(0, result.Count());
    }

    /// <summary>
    /// A test for Validate. Confirm that the combo of no effective end date and an effective start date does not generate validation errors.
    ///</summary>
    [TestMethod()]
    public void PvmTest_ValidateNoEffectiveEndDate()
    {
      var target = new AgreementPropertiesViewModel()
      {
        EffectiveStartDate = new DateTime(2013, 1, 1)
      };
      var validationContext = new ValidationContext(target, null, null)
      {
        DisplayName = target.GetType().Name
      };

      IEnumerable<ValidationResult> result;
      result = target.Validate(validationContext);
      // We expect no results in the validation results because we have a valid effective start and end date combination in the AgreementPropertiesViewModel object
      Assert.AreEqual(0, result.Count());
    }

    /// <summary>
    /// A test for Validate. Confirm that the combo of an effective end date and no effective start date does not generate validation errors.
    ///</summary>
    [TestMethod()]
    public void PvmTest_ValidateNoEffectiveStartDate()
    {
      var target = new AgreementPropertiesViewModel()
      {
        EffectiveEndDate = new DateTime(2013, 1, 1)
      };
      var validationContext = new ValidationContext(target, null, null)
      {
        DisplayName = target.GetType().Name
      };

      IEnumerable<ValidationResult> result;
      result = target.Validate(validationContext);
      // We expect no results in the validation results because we have a valid effective start and end date combination in the AgreementPropertiesViewModel object
      Assert.AreEqual(0, result.Count());
    }

    /// <summary>
    /// A test for Validate. Confirm that an effective end date that is after the effective start date does not generate validation errors.
    ///</summary>
    [TestMethod()]
    public void PvmTest_ValidateGoodEffectiveDates()
    {
      var target = new AgreementPropertiesViewModel()
      {
        EffectiveStartDate = new DateTime(2013, 1, 1),
        EffectiveEndDate = new DateTime(2013, 1, 31) // Set the effective end date to a valid day that is after than the effective start date. This should NOT cause a validation error to be added to the validation results.
      };
      var validationContext = new ValidationContext(target, null, null)
      {
        DisplayName = target.GetType().Name
      };

      IEnumerable<ValidationResult> result;
      result = target.Validate(validationContext);
      // We expect no results in the validation results because we have a valid effective start and end date combination in the AgreementPropertiesViewModel object
      Assert.AreEqual(0, result.Count());
    }

    /// <summary>
    ///A test for Validate.  Confirm that an effective end date that is before the effective start date generates validation errors.
    ///</summary>
    [TestMethod()]
    public void PvmTest_ValidateBadEffectiveDates()
    {
      var target = new AgreementPropertiesViewModel()
      {
        EffectiveStartDate = new DateTime(2013, 1, 31),
        EffectiveEndDate = new DateTime(2013, 1, 1) // Set the effective end date to a day that is earlier than the effective start date. This should cause a validation error to be added to the validation results.
      };
      var validationContext = new ValidationContext(target, null, null)
      {
        DisplayName = target.GetType().Name
      };

      IEnumerable<ValidationResult> result;
      result = target.Validate(validationContext);
      // We expect results in the validation results because we have an invalid effective start and end date combination in the AgreementPropertiesViewModel object
      Assert.AreNotEqual(0, result.Count());
    }
  }
}
