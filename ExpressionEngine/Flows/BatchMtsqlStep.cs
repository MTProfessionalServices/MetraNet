using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class BatchMtsqlStep : FlowStepBase
    {
        #region Properties
        [DataMember]
        public string Script { get; set; }
        #endregion

        #region Constructor
        public BatchMtsqlStep(Flow flow)
            : base(flow, FlowStepType.BatchMtsql)
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
