using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Components
{
    [DataContract(Namespace = "MetraTech")]
    public class UnitOfMeasure :  EnumValue 
    {
        #region Properties
        public UnitOfMeasureCategory Category { get; private set; }
        public string PrintSymbol { get; set; }
        public bool IsMetric { get;  set; } 
        #endregion

        #region GUI Support Properties (should be moved in future)
        public override string Image { get { return "FixedUnitOfMeasure.png"; } }
        #endregion

        #region Constructor
        public UnitOfMeasure(UnitOfMeasureCategory category, string value, int id, bool isMetric) : base(category, value, id)
        {
            IsMetric = isMetric;
        }
        #endregion
    }
}
