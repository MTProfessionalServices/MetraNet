using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    class StartStep : BaseStep
    {
        #region Constructor
        public StartStep(BaseFlow flow)
            : base(flow, StepType.Start)
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
            return "Start";
        }
        #endregion
    }
}
