using System;
using System.Collections.Generic;

namespace MetraTech.Agreements.Models
{
    /// <summary>
    /// Properties on agreement templates.  Also default properties for agreements; these may or may not be set.
    /// </summary>
    public class AgreementTemplateModel
    {
        /// <summary>
        /// Basic public constructor.  This ctor may seem pointless, but it's necessary to make sure each object
        /// in the model is non-null.
        /// </summary>
        public AgreementTemplateModel()
        {
            CoreAgreementProperties = new AgreementPropertiesModel();
            CoreTemplateProperties = new AgreementTemplatePropertiesModel();
            AgreementEntities = new AgreementEntitiesModel();
        }

        /// <summary>
        /// Unique ID for agreement template
        ///
        /// Note:  This property name must match the 
        /// column name (or alias) used in the __GET_AGREEMENT_TEMPLATES__
        /// database query in order for filtering and sorting to work
        /// (following the "active record" design pattern).  (Otherwise,
        /// we'd have to use some sort of FilterColumnResolver.)
        /// </summary>
        public int? AgreementTemplateId { get; set; }

        /// <summary>
        /// Properties of this template
        /// </summary>
        public AgreementTemplatePropertiesModel CoreTemplateProperties { get; set; }

        /// <summary>
        /// Properties that will be defaults for agreements made from this template
        /// </summary>
        public AgreementPropertiesModel CoreAgreementProperties { get; set; }

        /// <summary>
        /// List of agreement entities (POs, RMEs, etc) attached to this agreement template
        /// </summary>
        public AgreementEntitiesModel AgreementEntities { get; set; }

        /// <summary>
        /// Compare two sets of properties, returning a list of which ones are different.
        /// </summary>
        /// <param name="oldModel">The old model</param>
        /// <param name="newModel">The new model</param>
        /// <returns>A list of differences</returns>
        public static List<String> Compare(AgreementTemplateModel oldModel, AgreementTemplateModel newModel)
        {
            var retVal = AgreementPropertiesModel.Compare(oldModel.CoreAgreementProperties, newModel.CoreAgreementProperties);
            retVal.
                AddRange(AgreementTemplatePropertiesModel.Compare(oldModel.CoreTemplateProperties,
                                                                  newModel.CoreTemplateProperties));
            retVal.AddRange(AgreementEntitiesModel.Compare(oldModel.AgreementEntities, newModel.AgreementEntities));
            return retVal;
        }
    }

   
}