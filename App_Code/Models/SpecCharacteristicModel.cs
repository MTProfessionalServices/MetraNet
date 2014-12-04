using System;
using System.Activities.Validation;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Security.AccessControl;
using System.Web.Mvc;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraNet.Models
{

    #region Models

    public class SpecCharacteristicModel
    {
      [Required]
      [Display(Name = "SpecCharacteristicModel_SpecId", ResourceType = typeof(Resources.Models))]
      public int? SpecId { get; set; }

      [Required]
      [Display(Name = "SpecCharacteristicModel_EntityId", ResourceType = typeof(Resources.Models))]
      public int? EntityId { get; set; }

      [Required]
      [Display(Name = "SpecCharacteristicModel_DisplayOrder", ResourceType = typeof(Resources.Models))]
      public int? DisplayOrder { get; set; }

      [Required]
      [StringLength(20, ErrorMessageResourceName = "ErrorrMessage_SpecCharacteristicValueModel_Value", ErrorMessageResourceType = typeof(Resources.Models))]
      [Display(Name = "SpecCharacteristicModel_Name", ResourceType = typeof(Resources.Models))]
      public string Name { get; set; }

      [Required]
      [Display(Name = "SpecCharacteristicModel_SpecType", ResourceType = typeof(Resources.Models))]
      public PropertyType SpecType { get; set; }

      [Required]
      [Display(Name = "SpecCharacteristicModel_DefaultValue", ResourceType = typeof(Resources.Models))]
      public string DefaultValue { get; set; }

      [StringLength(20, ErrorMessageResourceName = "ErrorrMessage_SpecCharacteristicValueModel_Value", ErrorMessageResourceType = typeof(Resources.Models))]
      [Display(Name = "SpecCharacteristicModel_Category", ResourceType = typeof(Resources.Models))]
      public string Category { get; set; }

      [Display(Name = "SpecCharacteristicModel_UserVisible", ResourceType = typeof(Resources.Models))]
      public bool IsUserVisible { get; set; }

      [Display(Name = "SpecCharacteristicModel_UserEditable", ResourceType = typeof(Resources.Models))]
      public bool IsUserEditable { get; set; }

      [Display(Name = "SpecCharacteristicModel_Required", ResourceType = typeof(Resources.Models))]
      public bool IsRequired { get; set; }

      [StringLength(255, ErrorMessageResourceName = "ErrorMessage_SpecCharacteristicModel_Description", ErrorMessageResourceType = typeof(Resources.Models))]
      [DataType(DataType.MultilineText)]
      [Display(Name = "SpecCharacteristicModel_Description", ResourceType = typeof(Resources.Models))]
      public string Description { get; set; }
    }

    public sealed class SpecCharacteristicValueModel
    {
      public SpecCharacteristicValueModel()
      {
        // initialize localization dictionaries with language codes in the system
        NameDisplayNames = new Dictionary<LanguageCode, string>();
        foreach(LanguageCode langCode in Enum.GetValues(typeof(LanguageCode)))
        {
          NameDisplayNames.Add(langCode, "");
        }

        DescriptionDisplayNames = new Dictionary<LanguageCode, string>();
        foreach (LanguageCode langCode in Enum.GetValues(typeof(LanguageCode)))
        {
          DescriptionDisplayNames.Add(langCode, "");
        }

        CategoryDisplayNames = new Dictionary<LanguageCode, string>();
        foreach (LanguageCode langCode in Enum.GetValues(typeof(LanguageCode)))
        {
          CategoryDisplayNames.Add(langCode, "");
        }

        ChoicesDisplayNames = new Dictionary<LanguageCode, string>();
        foreach (LanguageCode langCode in Enum.GetValues(typeof(LanguageCode)))
        {
          ChoicesDisplayNames.Add(langCode, "");
        }
      }

      [HiddenInput(DisplayValue = false)]
      [Display(Name = "SpecCharacteristicValueModel_ValueId", ResourceType = typeof(Resources.Models))]
      public int? ValueId { get; set; }

      [HiddenInput(DisplayValue = false)]
      [Display(Name = "SpecCharacteristicValueModel_SpecId", ResourceType = typeof(Resources.Models))]
      public int? SpecId { get; set; }

      [StringLength(20, ErrorMessageResourceName = "ErrorrMessage_SpecCharacteristicValueModel_Value", ErrorMessageResourceType = typeof(Resources.Models))]
      [Display(Name = "SpecCharacteristicValueModel_Category", ResourceType = typeof(Resources.Models))]
      public string Category { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_CategoryDisplayNames", ResourceType = typeof(Resources.Models))]
      public Dictionary<LanguageCode, string> CategoryDisplayNames { get; set; }

      [Required]
      [StringLength(20, ErrorMessageResourceName = "ErrorrMessage_SpecCharacteristicValueModel_Value", ErrorMessageResourceType = typeof(Resources.Models))]
      [Display(Name = "SpecCharacteristicValueModel_Name", ResourceType = typeof(Resources.Models))]
      public string Name { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_NameDisplayNames", ResourceType = typeof(Resources.Models))]
      public Dictionary<LanguageCode, string> NameDisplayNames { get; set; }
      
      [StringLength(255, ErrorMessageResourceName="ErrorrMessage_SpecCharacteristicValueModel_Description", ErrorMessageResourceType= typeof(Resources.Models))]
      [DataType(DataType.MultilineText)]
      [Display(Name = "SpecCharacteristicValueModel_Description", ResourceType = typeof(Resources.Models))]
      public string Description { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_DescriptionDisplayNames", ResourceType = typeof(Resources.Models))]
      public Dictionary<LanguageCode, string> DescriptionDisplayNames { get; set; }

      [Required]
      [Display(Name = "SpecCharacteristicValueModel_SpecType", ResourceType = typeof(Resources.Models))]
      public PropertyType SpecType { get; set; }

      [StringLength(20, ErrorMessageResourceName = "ErrorrMessage_SpecCharacteristicValueModel_Value", ErrorMessageResourceType = typeof(Resources.Models))]
      [Display(Name = "SpecCharacteristicValueModel_StringValue", ResourceType = typeof(Resources.Models))]
      public string StringValue { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_Choices", ResourceType = typeof(Resources.Models))]
      public string Choices { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_ChoicesDisplayNames", ResourceType = typeof(Resources.Models))]
      public Dictionary<LanguageCode, string> ChoicesDisplayNames { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_DefaultChoice", ResourceType = typeof(Resources.Models))]
      public string DefaultChoice { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_IntValue", ResourceType = typeof(Resources.Models))]
      public int IntValue { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_DecimalValue", ResourceType = typeof(Resources.Models))]
      public decimal DecimalValue { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_BooleanValue", ResourceType = typeof(Resources.Models))]
      public bool BooleanValue { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_DatetimeValue", ResourceType = typeof(Resources.Models))]
      public DateTime DatetimeValue { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_Values", ResourceType = typeof(Resources.Models))]
      public List<string> ValueIds { get; set; }

      // Restrictions
      /////////////////////////////////////////////
      [Display(Name = "SpecCharacteristicValueModel_UserVisible", ResourceType = typeof(Resources.Models))]
      public bool IsUserVisible { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_UserEditable", ResourceType = typeof(Resources.Models))]
      public bool IsUserEditable { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_Required", ResourceType = typeof(Resources.Models))]
      public bool IsRequired { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_Min", ResourceType = typeof(Resources.Models))]
      public int? Min { get; set; }
      
      [Display(Name = "SpecCharacteristicValueModel_Max", ResourceType = typeof(Resources.Models))]
      public int? Max { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_MixDecimal", ResourceType = typeof(Resources.Models))]
      public decimal? MinDecimal { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_MaxDecimal", ResourceType = typeof(Resources.Models))]
      public decimal? MaxDecimal { get; set; }
      
      [Display(Name = "SpecCharacteristicValueModel_Length", ResourceType = typeof(Resources.Models))]
      public int? Length { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_Between_Start", ResourceType = typeof(Resources.Models))]
      public DateTime? BetweenStartDate { get; set; }

      [Display(Name = "SpecCharacteristicValueModel_Between_End", ResourceType = typeof(Resources.Models))]
      public DateTime? BetweenEndDate { get; set; }

      }

    #endregion

}
