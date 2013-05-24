using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using MetraTech.Agreements.Properties;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraTech.Agreements.Models
{
    /// <summary>
    /// This class specifies properties that affect agreement templates.
    /// </summary>
    public class AgreementTemplatePropertiesViewModel : IValidatableObject
    {
        #region AgreementTemplateNameId
        /// <summary>
        /// ID for the name of the template, maps to a localizable string
        /// </summary>
        [Display(Name = "AgreementTemplateModel_AgreementTemplateNameId",
            ResourceType = typeof (AgreementTemplateModels))]
        [UIHint("ReadOnly")]
        public int? AgreementTemplateNameId { get; set; }
        #endregion

        #region AgreementTemplateName
        /// <summary>
        /// A non-localized name for the template
        /// </summary>
        [Required(ErrorMessage = "Template Name is required")]
        [Display(Name = "AgreementTemplateModel_AgreementTemplateName", ResourceType = typeof (AgreementTemplateModels))
        ]
        public string AgreementTemplateName { get; set; }
        #endregion

        #region AgreementTemplateDescId
        /// <summary>
        /// ID for a description of the template, maps to a localizable string
        /// </summary>
        [Display(Name = "AgreementTemplateModel_AgreementTemplateDescId",
            ResourceType = typeof (AgreementTemplateModels))]
        public int? AgreementTemplateDescId { get; set; }
        #endregion

        #region AgreementTemplateDescription
        /// <summary>
        /// A non-localized description for the template
        /// </summary>
        [Display(Name = "AgreementTemplateModel_AgreementTemplateDescription",
            ResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.MultilineText)]
        public string AgreementTemplateDescription { get; set; }
        #endregion

        #region CreatedDate
        /// <summary>
        /// Date that the template was created
        /// </summary>
        [Display(Name = "AgreementTemplateModel_CreatedDate", ResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.DateTime)]
        [UIHint("ReadOnly")]
        public DateTime CreatedDate { get; set; }
        #endregion

        #region CreatedBy
        /// <summary>
        /// Who created this template
        /// </summary>
        [Display(Name = "AgreementTemplateModel_CreatedBy", ResourceType = typeof (AgreementTemplateModels))]
        [UIHint("ReadOnly")]
        public int CreatedBy { get; set; }
        #endregion

        #region UpdatedDate
        /// <summary>
        /// Last date the template was updated.  If it has been created but never updated, this will be null.
        /// </summary>
        [Display(Name = "AgreementTemplateModel_UpdatedDate", ResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.DateTime)]
        public DateTime? UpdatedDate { get; set; }
        #endregion

        #region UpdatedBy
        /// <summary>
        /// Last preson to update this template.  If it has never been updated, will be null.
        /// </summary>
        [Display(Name = "AgreementTemplateModel_UpdatedBy", ResourceType = typeof (AgreementTemplateModels))]
        public int? UpdatedBy { get; set; }
        #endregion

        #region AvailableStartDate
        /// <summary>
        /// Date this template goes into effect
        /// </summary>
        [Display(Name = "AgreementTemplateModel_AvailableStartDate", ResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.DateTime)]
        public DateTime? AvailableStartDate { get; set; }
        #endregion

        #region AvailableEndDate
        /// <summary>
        /// Date this template goes out of effect
        /// </summary>
        [Display(Name = "AgreementTemplateModel_AvailableEndDate", ResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.DateTime)]
        public DateTime? AvailableEndDate { get; set; }
        #endregion

        #region ErrorDescription
        [StringLength(256, ErrorMessageResourceName = "AgreementTemplateModel_ErrorDescription",
            ErrorMessageResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.MultilineText)]
        [Display(Name = "AgreementTemplateModel_ErrorDescription", ResourceType = typeof (AgreementTemplateModels))]
        public string ErrorDescription { get; set; }
        #endregion

        
        /// <summary>
        /// Make a copy of the current object
        /// </summary>
        /// <returns>a copy of the current object</returns>
        public AgreementTemplatePropertiesViewModel Copy()
        {
            return MemberwiseClone() as AgreementTemplatePropertiesViewModel;
        }


        /// <summary>
        /// Make a model out of the current object
        /// </summary>
        /// 
        public AgreementTemplatePropertiesModel Model()
        {
            return new AgreementTemplatePropertiesModel
                       {
                           AgreementTemplateDescId = AgreementTemplateDescId,
                           AgreementTemplateDescription = AgreementTemplateDescription,
                           AgreementTemplateName = AgreementTemplateName,
                           AgreementTemplateNameId = AgreementTemplateNameId,
                           AvailableEndDate = AvailableEndDate,
                           AvailableStartDate = AvailableStartDate,
                           CreatedBy = CreatedBy,
                           CreatedDate = CreatedDate,
                           ErrorDescription = ErrorDescription == null ? null : ErrorDescription.Clone() as string,
                           LocalizedDescriptions = new Dictionary<LanguageCode, string>(),
                           LocalizedDisplayNames = new Dictionary<LanguageCode, string>()
                       };
        }
        #region AgreementTemplateDescriptionModel

        public sealed class AgreementTemplateDescriptionModel
        {
            public AgreementTemplateDescriptionModel()
            {
                // initialize localization dictionaries with language codes in the system
                AgreementTemplateNameDisplayNames = new Dictionary<LanguageCode, string>();
                foreach (LanguageCode langCode in Enum.GetValues(typeof (LanguageCode)))
                {
                    AgreementTemplateNameDisplayNames.Add(langCode, "");
                }

                AgreementTemplateDescriptionDisplayNames = new Dictionary<LanguageCode, string>();
                foreach (LanguageCode langCode in Enum.GetValues(typeof (LanguageCode)))
                {
                    AgreementTemplateDescriptionDisplayNames.Add(langCode, "");
                }

            }

            [Display(Name = "AgreementTemplateDescriptionModel_AgreementTemplateNameDisplayNames",
                ResourceType = typeof (AgreementTemplateModels))]
            public Dictionary<LanguageCode, string> AgreementTemplateNameDisplayNames { get; set; }

            [Display(Name = "AgreementTemplateDescriptionModel_AgreementTemplateDescriptionDisplayNames",
                ResourceType = typeof (AgreementTemplateModels))]
            public Dictionary<LanguageCode, string> AgreementTemplateDescriptionDisplayNames { get; set; }


            [StringLength(256,
                ErrorMessageResourceName = "ErrorMessage_AgreementTemplateDescriptionModel_ErrorDescription",
                ErrorMessageResourceType = typeof (AgreementTemplateModels))]
            [DataType(DataType.MultilineText)]
            [Display(Name = "AgreementTemplateDescriptionModel_ErrorDescription",
                ResourceType = typeof (AgreementTemplateModels))]
            public string DErrorDescription { get; set; }

        }
        #endregion

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            //TODO: Add useful valildation tests
            var retVal = new Collection<ValidationResult>();
            if ((AvailableStartDate != null) && (AvailableEndDate != null) && (AvailableStartDate > AvailableEndDate))
            {
                // TODO: Localize this!
                retVal.Add(
                    new ValidationResult("The Available End Date cannot be earlier than the Available Start Date."));
            }
            if (String.IsNullOrEmpty(AgreementTemplateName))
            {
                retVal.Add(new ValidationResult("Template name is null or empty"));
            }
            if (CreatedBy < 0)
            {
                retVal.Add(new ValidationResult("Create by is set to an invalid user"));
            }
            return retVal;
        }

    }

}
