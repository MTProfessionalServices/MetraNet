using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class AggregationStep : BaseStep
    {
        #region Properties
        public List<AggregateItem> Items = new List<AggregateItem>();
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
            return string.Format(CultureInfo.InvariantCulture, "Aggreate");
        }

        public override string GetAutoDescription()
        {
            return "Aggregate...";
        }
        #endregion
    }
}

