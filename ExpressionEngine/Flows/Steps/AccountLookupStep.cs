using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class AccountLookupStep : BaseStep
    {
       #region Constructor
        public AccountLookupStep(BaseFlow flow) : base(flow, StepType.AccountLookup)
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
