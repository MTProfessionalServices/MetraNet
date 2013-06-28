using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;


namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
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

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "Query");
        }

        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion
    }
}
