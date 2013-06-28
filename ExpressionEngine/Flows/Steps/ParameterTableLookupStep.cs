using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class ParameterTableLookupStep : BaseStep
    {
        #region Properties
        public string ParameterTable { get; set; }
        #endregion

        #region Constructor
        public ParameterTableLookupStep(BaseFlow flow)
            : base(flow, StepType.ParameterTableLookup)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            //var pt = (ParameterTableEntity)GetParameterTableLink().GetComponent(context);
            //if (pt == null)
            //    return;

            //foreach (var property in pt.Properties)
            //{
            //}
        }
        public ComponentLink GetParameterTableLink()
        {
            return new ComponentLink(ComponentType.ParameterTable, this, "ParameterTable", true, "ParameterTable");
        }

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "Parameter Table Lookup");
        }

        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }
        #endregion

    }
}
