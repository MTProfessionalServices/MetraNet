using System.Globalization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    public class ElseIfStep : BaseStep
    {
        #region Properties
        public string Expression { get; set; }
        #endregion

        #region Constructor
        public ElseIfStep(BaseFlow flow) : base(flow, StepType.ElseIf)
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
            return string.Format(CultureInfo.InvariantCulture, "else if ({0})", Expression);
        }
        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion
    }
}
