using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel.DataAnnotations;
using MetraTech.Agreements.Properties;

namespace MetraTech.Agreements.Models
{
    /// <summary>
    /// This class defines Properties on an agreement (for use in the agreement template model).
    /// </summary>
    public class AgreementPropertiesViewModel : IValidatableObject
    {
        /// <summary>
        /// Date this agreement goes into effect
        /// </summary>
        [Display(Name = "AgreementTemplateModel_EffectiveStartDate", ResourceType = typeof (AgreementTemplateModels)
            )]
        [DataType(DataType.DateTime)]
        public DateTime? EffectiveStartDate { get; set; }

        /// <summary>
        /// Date this agreement goes out of effect
        /// </summary>
        [Display(Name = "AgreementTemplateModel_EffectiveEndDate", ResourceType = typeof (AgreementTemplateModels))]
        [DataType(DataType.DateTime)]
        public DateTime? EffectiveEndDate { get; set; }

        public AgreementPropertiesModel Model()
        {
            return new AgreementPropertiesModel
                       {EffectiveEndDate = EffectiveEndDate, EffectiveStartDate = EffectiveStartDate};
        }
        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            var retVal = new Collection<ValidationResult>();
            if ((EffectiveStartDate != null) && (EffectiveEndDate != null) && (EffectiveStartDate > EffectiveEndDate))
            {
                var resourceManager = new ResourcesManager();
                retVal.Add(
                    new ValidationResult(resourceManager.GetLocalizedResource("ERROR_START_DATE_AFTER_END_DATE")));
            }

            return retVal;
        }
    }

}