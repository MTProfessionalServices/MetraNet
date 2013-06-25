using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;

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

        #endregion
    }
}
