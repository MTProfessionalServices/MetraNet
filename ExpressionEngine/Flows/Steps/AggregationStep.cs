using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.Mvm.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class AggregationStep : BaseStep
    {
        #region properties
        /// <summary>
        /// The property to which the aggregation is targeted. Must be a numeric
        /// </summary>
        [DataMember]
        public string TargetProperty { get; set; }

        /// <summary>
        /// The type of aggregation
        /// </summary>
        [DataMember]
        public AggregateAction Action { get; set; }

        /// <summary>
        /// The property which is being aggregated. Must be a numeric
        /// </summary>
        [DataMember]
        public string SourceProperty { get; set; }
        #endregion

        #region Constructor
        public AggregationStep(BaseFlow flow)
            : base(flow, StepType.Aggregate)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            AddToInputsAndOutputs(TargetProperty, Direction.Output);
            AddToInputsAndOutputs(SourceProperty, Direction.Input);
        }

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "Aggreate {0} of {1} into {2}", Action, SourceProperty, TargetProperty);
        }

        public override string GetTechnicalAutoLabel()
        {
            return  string.Format(CultureInfo.InvariantCulture, "{0} = Aggreate({1}, {2})",
                          TargetProperty, Action, SourceProperty);
        }
        #endregion
    }
}

