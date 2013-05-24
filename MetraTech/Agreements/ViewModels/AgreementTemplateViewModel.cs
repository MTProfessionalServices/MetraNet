using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel.DataAnnotations;
using MetraTech.Agreements.Properties;


namespace MetraTech.Agreements.Models
{
    //Note: This is not a true view model, because CoreAgreementProperties, CoreTemplateProperties, AgreementEntities are not view models, but models themselves.
    //  At some point this should be fixed.
    public class AgreementTemplateViewModel : IValidatableObject
    {

        /// <summary>
        /// Default constructor
        /// </summary>
        public AgreementTemplateViewModel()
        {
        }


        /// <summary>
        /// Constructs an AgreementTemplateViewModel object from an agreement template model object.
        /// </summary>
        /// <param name="templateModel"></param>
        public AgreementTemplateViewModel(AgreementTemplateModel templateModel)
        {
            AgreementTemplateId = templateModel.AgreementTemplateId;
            CoreAgreementProperties = templateModel.CoreAgreementProperties == null ? null: templateModel.CoreAgreementProperties.ViewModel();
            CoreTemplateProperties = templateModel.CoreTemplateProperties == null
                                         ? null
                                         : templateModel.CoreTemplateProperties.ViewModel();
            AgreementEntities = templateModel.AgreementEntities == null ? null : templateModel.AgreementEntities.ViewModel();
        }


        /// <summary>
        /// Saves the view model's contents to an agreement template model object.
        /// </summary>
        /// <param name="templateModel"></param>
        public void SaveToModel(AgreementTemplateModel templateModel)
        {
            templateModel.AgreementTemplateId = AgreementTemplateId;
            templateModel.CoreTemplateProperties = CoreTemplateProperties == null ? null : CoreTemplateProperties.Model();
            templateModel.AgreementEntities = AgreementEntities == null ? null : AgreementEntities.Model();
            templateModel.CoreAgreementProperties = CoreAgreementProperties == null
                                                        ? null
                                                        : CoreAgreementProperties.Model();
        }


        /// <summary>
        /// Unique ID for agreement template
        /// </summary>
        [Display(Name = "AgreementTemplateModel_AgreementTemplateId",
            ResourceType = typeof (AgreementTemplateModels))]
        [UIHint("ReadOnly")]
        public int? AgreementTemplateId { get; set; }

        /// <summary>
        /// Core properties of this template
        /// </summary>
        public AgreementTemplatePropertiesViewModel CoreTemplateProperties { get; set; }

        /// <summary>
        /// Properties that will be defaults for agreements made from this template
        /// </summary>
        public AgreementPropertiesViewModel CoreAgreementProperties { get; set; }

        /// <summary>
        /// List of agreement entities (POs, RMEs, etc)
        /// </summary>
        public AgreementEntitiesViewModel AgreementEntities { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            var retVal = new Collection<ValidationResult>();
            if (AgreementTemplateId.HasValue && AgreementTemplateId <= 0)
            {
                var resourceManager = new ResourcesManager();
                retVal.Add(
                    new ValidationResult(resourceManager.GetLocalizedResource("TEMPLATE_ID_LESS_THAN_0")));
            }

            return retVal;
        }

       }
}