using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    public class ContainerStep : BaseStep
    {
        #region Constructor
        public ContainerStep(BaseFlow flow)
            : base(flow, StepType.Container)
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
            return "Container";
        }
        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion
    }
}
