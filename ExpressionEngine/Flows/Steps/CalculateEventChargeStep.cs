using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class CalculateEventChargeStep : BaseStep
    {
        #region Properties
        #endregion

        #region Constructor
        public CalculateEventChargeStep(BaseFlow flow)
            : base(flow, StepType.CalculateEventCharge, false)
        {
        }
        #endregion

        #region Methods

        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs = new PropertyCollection(this);
            var charges = Flow.ProductView.GetCharges(true);
            foreach (var charge in charges)
            {
                AddToInputsAndOutputs(charge.Name, Direction.Output);
                var type = (ChargeType)charge.Type;
                AddToInputsAndOutputs(type.QuantityProperty, Direction.Input);
                AddToInputsAndOutputs(type.PriceProperty, Direction.Input);
            }
        }
        public override string GetAutoLabel()
        {
            //ToDo: Need to variablize this to deal with EventPayments! 
            return string.Format(CultureInfo.InvariantCulture, "Calculate EventCharge");
        }
        #endregion
    }
}
