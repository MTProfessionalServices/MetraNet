using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class ExpressionStep : FlowStepBase
    {
        #region Properties

        /// <summary>
        /// The name of the property being assigned
        /// </summary>
        [DataMember]
        public string PropertyName { get; set; }

        /// <summary>
        /// The expression
        /// </summary>
        [DataMember]
        public string Expression { get; set; }
        #endregion

        #region Constructor
        public ExpressionStep(Flow flow)
            : base(flow, FlowStepType.Expression)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
        }

        public override string GetAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0} = {1}", PropertyName, Expression);
        }
        #endregion
    }
}
