using System.Runtime.Serialization;
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
        #endregion
    }
}