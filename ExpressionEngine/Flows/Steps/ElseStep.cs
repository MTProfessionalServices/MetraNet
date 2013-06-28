using System.Globalization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    public class ElseStep : BaseStep
    {
        #region Properties
        public string Expression { get; set; }
        #endregion

        #region Constructor
        public ElseStep(BaseFlow flow)
            : base(flow, StepType.Else)
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
            return string.Format(CultureInfo.InvariantCulture, "else");
        }
        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion
    }
}