using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class UnitOfMeasureCategory : EnumCategory, IExpressionEngineTreeNode
    {
        #region Properties
        public override string ToExpressionSnippet { get { return string.Format(CultureInfo.InvariantCulture, "UoM.{0}", Name); } }              
        #endregion

        #region GUI Helper Properties (Remove in future)
        public override string Image { get { return "UnitOfMeasureCategory.png"; } }
        #endregion

        #region Constructor
        public UnitOfMeasureCategory(EnumNamespace parent, string name, int id, string description) : base(parent, name, id, description)
        {
            IsUnitOfMeasure = true;
        }
        #endregion

        #region Methods
        public UnitOfMeasure AddUnitOfMeasure(string name, int id, bool isMetric)
        {
            var uom = new UnitOfMeasure(this, name, id, isMetric);
            Values.Add(uom);
            return uom;
        }

        public override void Validate(bool prefixMsg, ValidationMessageCollection messages, Context context)
        {
            if (EnumNamespace.Name != PropertyBagConstants.MetraTechNamespace)
                messages.Error(string.Format(Localization.UnitOfMeasureNamespaceMustBeMetraTech, EnumNamespace));
        }

        #endregion

    }
}
