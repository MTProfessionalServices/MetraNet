using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class CalculateEventChargeStep : BaseStep
    {
        #region Properties
        public ProductViewEntity ProductViewEntity;
        #endregion

        #region Constructor
        public CalculateEventChargeStep(BaseFlow flow)
            : base(flow, StepType.CalculateEventCharge, false)
        {
        }
        #endregion

        #region Methods

        public override string GetAutoLabel()
        {
            //ToDo: Need to variablize this to deal with EventPayments! 
            return string.Format(CultureInfo.InvariantCulture, "Calculate EventCharge");
        }
        #endregion
    }
}
