using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class QueryStep : BaseStep
    {
        #region Properties
        [DataMember]
        public string Script { get; set; }
        #endregion

        #region Constructor
        public QueryStep(BaseFlow flow)
            : base(flow, StepType.Query)
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
