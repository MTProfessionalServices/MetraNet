using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class FunctionStep : BaseStep
    {
        #region Constructor
        public FunctionStep(BaseFlow flow) : base(flow, StepType.Function)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            //AddToInputsAndOutputs(PropertyName, Direction.Output);
        }

        public override string GetBusinessAutoLabel()
        {
            return GetTechnicalAutoLabel();
        }

        public override string GetTechnicalAutoLabel()
        {
            return  string.Format(CultureInfo.InvariantCulture, "fx");
        }


        public override List<EventChargeMapping> GetEventChargeMappings()
        {
            var mappings = new List<EventChargeMapping>();
            //var mapping = GetBaseEventChargeMapping();
            //mapping.FieldName = "OBJECT." + PropertyName;
            //mapping.FieldType = CdeFieldMappingType.modifier;
            //mapping.Modifier = DefaultExpression;
            //mapping.Filter = string.Format(CultureInfo.InvariantCulture, "{0} OBJECT.{1} eq \"\"", ConditionalExpression, PropertyName);
            //mappings.Add(mapping);
            return mappings;
        }
        #endregion
    }
}
