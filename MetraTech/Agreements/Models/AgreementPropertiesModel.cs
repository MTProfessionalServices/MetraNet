using System;
using System.Collections.Generic;

namespace MetraTech.Agreements.Models
{
    /// <summary>
    /// This class defines Properties on an agreement (for use in the agreement template model).
    /// </summary>
    public class AgreementPropertiesModel
    {
        #region EffectiveStartDate
        /// <summary>
        /// Date this agreement goes into effect
        /// </summary>
        public DateTime? EffectiveStartDate { get; set; }
        #endregion

        #region EffectiveEndDate
        /// <summary>
        /// Date this agreement goes out of effect
        /// </summary>
        public DateTime? EffectiveEndDate { get; set; }
        #endregion

        /// <summary>
        /// Make a copy of the current object
        /// </summary>
        /// <returns>a copy of the current object</returns>
        public AgreementPropertiesModel Copy()
        {
            return this.MemberwiseClone() as AgreementPropertiesModel;
        }

        /// <summary>
        /// Compare two sets of properties, returning a list of which ones are different.
        /// </summary>
        /// <param name="oldModel">The old model</param>
        /// <param name="newModel">The new model</param>
        /// <returns>A list of differences</returns>
        public static List<String> Compare(AgreementPropertiesModel oldModel, AgreementPropertiesModel newModel)
        {
            var retVal = new List<String>();
            var resourceManager = new ResourcesManager();

            if (oldModel.EffectiveEndDate != newModel.EffectiveEndDate)
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "EffectiveEndDate", oldModel.EffectiveEndDate, newModel.EffectiveEndDate));
            }
            if (oldModel.EffectiveStartDate != newModel.EffectiveStartDate)
            {
                retVal.Add(String.Format(resourceManager.GetLocalizedResource("VALUE_CHANGED"), "EffectiveStartDate", oldModel.EffectiveStartDate, newModel.EffectiveStartDate));
            }
            return retVal;
        }
        /// <summary>
        /// Make a view model equivalent of the current object
        /// </summary>
        /// <returns>a model of the current object</returns>
        public AgreementPropertiesViewModel ViewModel()
        {
            return new AgreementPropertiesViewModel
                       {EffectiveEndDate = EffectiveEndDate, EffectiveStartDate = EffectiveStartDate};
        }
    }

}