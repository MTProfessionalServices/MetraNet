using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class MtsqlStep : BaseStep
    {
        #region Properties
        public string Script { get; set; }
        #endregion

        #region Constructor
        public MtsqlStep(BaseFlow flow) : base(flow, StepType.Mtsql)
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
