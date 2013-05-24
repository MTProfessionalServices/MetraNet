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
    ///
    /// Note:  The property names defined in this class must match the 
    /// column names (or aliases) used in the __GET_AGREEMENT_TEMPLATES__
    /// database query in order for filtering and sorting to work
    /// (following the "active record" design pattern).  (Otherwise,
    /// we'd have to use some sort of FilterColumnResolver.)
    /// </summary>
    public class AgreementTemplatePropertiesModel : IValidatableObject
    {
        #region AgreementTemplateNameId
        /// <summary>
        /// ID for the name of the template, maps to a localizable string
        /// </summary>
        public int? AgreementTemplateNameId { get; set; }
        #endregion

        #region AgreementTemplateName
        /// <summary>
        /// A non-localized name for the template
        /// </summary>
        public string AgreementTemplateName { get; set; }
        #endregion

        #region AgreementTemplateDescId
        /// <summary>
        /// ID for a description of the template, maps to a localizable string
        /// </summary>
        public int? AgreementTemplateDescId { get; set; }
        #endregion

        #region AgreementTemplateDescription
        /// <summary>
        /// A non-localized description for the template
        /// </summary>
        public string AgreementTemplateDescription { get; set; }
        #endregion

        #region CreatedDate
        /// <summary>
        /// Date that the template was created
        /// </summary>
        public DateTime CreatedDate { get; set; }
        #endregion

        #region CreatedBy
        /// <summary>
        /// Who created this template
        /// </summary>
        public int CreatedBy { get; set; }
        #endregion

        #region UpdatedDate
        /// <summary>
        /// Last date the template was updated.  If it has been created but never updated, this will be null.
        /// </summary>
        [UIHint("ReadOnly")]
        public DateTime? UpdatedDate { get; set; }
        #endregion

        #region UpdatedBy
        /// <summary>
        /// Last preson to update this template.  If it has never been updated, will be null.
        /// </summary>
        [UIHint("ReadOnly")]
        public int? UpdatedBy { get; set; }
        #endregion

        #region AvailableStartDate
        /// <summary>
        /// Date this template goes into effect
        /// </summary>
        public DateTime? AvailableStartDate { get; set; }
        #endregion

        #region AvailableEndDate
        /// <summary>
        /// Date this template goes out of effect
        /// </summary>
        public DateTime? AvailableEndDate { get; set; }
        #endregion

        #region LocalizedDisplayNames
        /// <summary>
        /// This is a collection of localized display names for the shared property. 
        /// The collection is keyed by values from the LanguageCode enumeration.
        /// </summary>
        public Dictionary<LanguageCode, string> LocalizedDisplayNames { get; set; }
        #endregion

        #region LocalizedDescriptions
        /// <summary>
        /// This is a collection of localized descriptions for the shared property.  
        /// The collection is keyed by values from the LanguageCode enumeration.  
        /// If a value cannot be found for a specific LanguageCode, 
        /// the value from the Description property should be used as a default.
        /// </summary>
        public Dictionary<LanguageCode, string> LocalizedDescriptions { get; set; }
        #endregion

        #region ErrorDescription
        public string ErrorDescription { get; set; }
        #endregion

        public AgreementTemplatePropertiesModel()
        {
            CreatedDate = DateTime.Now;
        }
        /// <summary>
        /// Compare two sets of properties, returning a list of which ones are different.
        /// </summary>
        /// <param name="oldModel">The old model</param>
        /// <param name="newModel">The new model</param>
        /// <returns>A list of differences</returns>
        public static List<String> Compare(AgreementTemplatePropertiesModel oldModel, AgreementTemplatePropertiesModel newModel)
        {
            var retVal = new List<String>();
            var resourceManager = new ResourcesManager();

            if ((oldModel.AgreementTemplateName != null) && (!oldModel.AgreementTemplateName.Equals(newModel.AgreementTemplateName)))
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AgreementTemplateName", oldModel.AgreementTemplateName, newModel.AgreementTemplateName));
            } else if ((oldModel.AgreementTemplateName == null) && (newModel.AgreementTemplateName != null))
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AgreementTemplateName", "null", newModel.AgreementTemplateName));
            }
            if (oldModel.AgreementTemplateNameId != newModel.AgreementTemplateNameId)
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AgreementTemplateNameId", oldModel.AgreementTemplateNameId, newModel.AgreementTemplateNameId));
            }
            if ((oldModel.AgreementTemplateDescription!= null) && (!oldModel.AgreementTemplateDescription.Equals(newModel.AgreementTemplateDescription)))
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AgreementTemplateDescription", oldModel.AgreementTemplateDescription, newModel.AgreementTemplateDescription));
            }
            else if ((oldModel.AgreementTemplateDescription == null) && (newModel.AgreementTemplateDescription != null))
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AgreementTemplateDescription", "null", newModel.AgreementTemplateDescription));
            }
            if (oldModel.AgreementTemplateDescId != newModel.AgreementTemplateDescId)
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AgreementTemplateDescId", oldModel.AgreementTemplateDescId, newModel.AgreementTemplateDescId));
            }
           if (oldModel.AvailableStartDate != newModel.AvailableStartDate)
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AvailableStartDate", oldModel.AvailableStartDate, newModel.AvailableStartDate));
            }
            if (oldModel.AvailableEndDate != newModel.AvailableEndDate)
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "AvailableEndDate", oldModel.AvailableEndDate, newModel.AvailableEndDate));
            }
            //Skip Created and Updated info -- the former should never change, and the latter will always change, so we don't need to log them.
            
            return retVal;
        }
        /// <summary>
        /// Make a copy of the current object
        /// </summary>
        /// <returns>a copy of the current object</returns>
        public AgreementTemplatePropertiesModel Copy()
        {
            return MemberwiseClone() as AgreementTemplatePropertiesModel;
        }

        /// <summary>
        /// Make a view model of the current object
        /// </summary>
        /// <returns>a copy of the current object</returns>
        public AgreementTemplatePropertiesViewModel ViewModel()
        {
            return new AgreementTemplatePropertiesViewModel
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
                           UpdatedBy = UpdatedBy,
                           UpdatedDate = UpdatedDate
                       };
        }



        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            //TODO: Add useful valildation tests
            var retVal = new Collection<ValidationResult>();
            if (AvailableStartDate > AvailableEndDate)
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
