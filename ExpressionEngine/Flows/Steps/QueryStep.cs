using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class QueryStep : BaseStep
    {
        #region Properties
        [DataMember]
        public string Query { get; set; }
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
