using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace MetraTech.Agreements.Models
{
  /// <summary>
    /// This class represents a list of entities that contains pricing for an agreement.  Current examples might be product offerings 
    /// or rate modeling entities.
    /// 
    /// Although this class encapsulates a list, we don't expose the list, because we want to do things like checking for duplicates, 
    /// so we need to control adding and deleting from the list.
    /// </summary>
    public class AgreementEntitiesViewModel :IValidatableObject
    {
        /// <summary>
        /// Standard constructor
        /// </summary>
        public AgreementEntitiesViewModel(){AgreementEntityList = new List<AgreementEntityModel>();}
        /// <summary>
        /// This list of agreement entities attached to this agreement
        /// </summary>
        public List<AgreementEntityModel> AgreementEntityList{get; set;}
        
        /// <summary>
        /// Create a model equivalent to this view model.  It adds each entity individually, because we can't write
        /// directly to the entity list of the model
        /// </summary>
        /// <returns>model equivalent to this view model.</returns>
        public AgreementEntitiesModel Model()
        {
            var retVal = new AgreementEntitiesModel();
            foreach (var entity in AgreementEntityList)
            {
                retVal.AddEntity(entity);
            }
            return retVal;
        }

      public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
      {
          //For now, assume this object is always valid.
          return new ValidationResult[0];
      }
    }

}