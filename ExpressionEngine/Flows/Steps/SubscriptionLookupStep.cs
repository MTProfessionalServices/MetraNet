using System.Collections.Generic;
using System.Globalization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    public class SubscriptionLookupStep : BaseStep
    {
        #region properties
        #endregion

        #region Constructor
        public SubscriptionLookupStep(BaseFlow flow): base(flow, StepType.SubscriptionLookup)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
        }

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "Subscription Lookup");
        }

        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion
    }
}
