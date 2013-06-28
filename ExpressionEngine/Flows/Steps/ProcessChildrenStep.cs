using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class ProcessChildrenStep : BaseStep
    {
        #region Properties

        #endregion

        #region Constructor
        public ProcessChildrenStep(BaseFlow flow) : base(flow, StepType.ProcessList)
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
            return string.Format(CultureInfo.InvariantCulture, string.Format("ProcessChildren({0})", ""));
        }
        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }

        #endregion
    }
}
