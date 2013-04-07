using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract (Namespace = "MetraTech")]
    public class TaxType : Type
    {
        #region Properties

        #endregion

        #region Constructor
        public TaxType():base(BaseType.Tax)
        {}
        #endregion

        #region Methods
        public override List<PropertyReference> GetPropertyReferences()
        {
            var references = new List<PropertyReference>();
            //Put stuff in here
            return references;
        }
        #endregion
    }
}