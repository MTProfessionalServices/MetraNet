using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
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

        /// <summary>
        /// An optional filter to deterine if the source property is used in the aggregation
        /// </summary>
        [DataMember]
        public string Filter { get; set; }
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
#warning why do i need this here? Should just need to clear it.
            InputsAndOutputs = new PropertyCollection(this);

        }

        public override string GetAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture,
                    "Aggreate({0}, {1}, {2}, '{3}')",
                        TargetProperty,
                        Action,
                        SourceProperty,
                        Filter);
        }

        public override string GetAutoDescription()
        {
            return "Aggregate...";
        }
        #endregion
    }
}

