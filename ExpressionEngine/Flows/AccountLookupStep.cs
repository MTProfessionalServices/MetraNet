using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class AccountLookupStep : FlowStepBase
    {
       #region Constructor
        public AccountLookupStep(Flow flow) : base(flow, FlowStepType.AccountLookup)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
        }
        #endregion
    }
}
