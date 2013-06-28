using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    public class IfStep : BaseStep
    {
        #region Properties
        public string Expression { get; set; }
        #endregion

        #region Constructor
        public IfStep(BaseFlow flow) : base(flow, StepType.If)
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
            return string.Format(CultureInfo.InvariantCulture, "if ({0})", Expression);
        }
        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion
    }
}
