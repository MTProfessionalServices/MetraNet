using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class EnforceStep : BaseStep
    {
        #region Properties
        public string PropertyName { get; set; }
        public string DefaultExpression { get; set; }
        #endregion

        #region Constructor
        public EnforceStep(BaseFlow flow)
            : base(flow, StepType.Enforce)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            AddToInputsAndOutputs(PropertyName, Direction.Output);
        }

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "Enforce {0}", PropertyName);
        }

        public override string GetTechnicalAutoLabel()
        {
            return  string.Format(CultureInfo.InvariantCulture, "Enforce({0})", PropertyName);
        }


        public override List<EventChargeMapping> GetEventChargeMappings()
        {
            var mappings = new List<EventChargeMapping>();
            var mapping = GetBaseEventChargeMapping();
            mapping.FieldName = "OBJECT." + PropertyName;
            mapping.FieldType = CdeFieldMappingType.modifier;
            mapping.Modifier = DefaultExpression;
            mapping.Filter = string.Format(CultureInfo.InvariantCulture, "{0} OBJECT.{1} eq \"\"", ConditionalExpression, PropertyName);
            mappings.Add(mapping);
            return mappings;
        }
        #endregion
    }
}
