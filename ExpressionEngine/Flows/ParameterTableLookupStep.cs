using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;

namespace MetraTech.ExpressionEngine.Flows
{
    public class ParameterTableLookupStep : FlowStepBase
    {
        #region Properties
        public string ParameterTable { get; set; }
        #endregion

        #region Constructor
        public ParameterTableLookupStep(FlowCollection flowCollection)
            : base(flowCollection, FlowStepType.ParameterTableLookup)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            var pt = (ParameterTableEntity)GetParameterTableLink().GetComponent(context);
            if (pt == null)
                return;

            foreach (var property in pt.Properties)
            {
            }
        }
        public ComponentLink GetParameterTableLink()
        {
            return new ComponentLink(ComponentType.ParameterTable, this, "ParameterTable", true, "ParameterTable");
        }
        #endregion

    }
}
