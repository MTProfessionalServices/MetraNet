using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class ExpressionStep : BaseStep
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
        public ExpressionStep(BaseFlow flow)
            : base(flow, StepType.Expression)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            //We aren't dealing with any inputs, including if this property is used itself as an input
            AddToInputsAndOutputs(PropertyName, Direction.Output);
        }

        public Property GetProperty()
        {
             return AvailableProperties.Get(PropertyName);
        }
        public override string GetBusinessAutoLabel()
        {
            return GetTechnicalAutoLabel();
        }

        public override string GetTechnicalAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0} = {1}", PropertyName, Expression);
        }


        public override List<EventChargeMapping> GetEventChargeMappings()
        {
            var mappings = new List<EventChargeMapping>();

            var mapping = GetBaseEventChargeMapping();
            mapping.ChargeName = "???";
            mapping.FieldName = PropertyName;
            mapping.FieldType = CdeFieldMappingType.modifier;
            mapping.Modifier = Expression;

            mappings.Add(mapping);
            return mappings;
        }

        #endregion
    }
}
