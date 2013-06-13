using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;

namespace MetraTech.ExpressionEngine.Flows
{
    public class MeterStep : FlowStepBase
    {
        #region Properties
        [DataMember]
        public string ServiceDefinition { get; set; }
        public string Timestamp { get; set; }
        #endregion

        #region Constructor
        public MeterStep(FlowCollection flowCollection)
            : base(flowCollection, FlowStepType.Meter)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            var sdLink = GetServiceDefinitionLink();
            var sd = sdLink.GetComponent(context);
            if (sd == null)
                return;

            foreach (var property in ((ServiceDefinitionEntity)sd).Properties)
            {
                var newProperty = (Property)property.Copy();
                newProperty.Direction = Direction.Output;
            }
        }

        public ComponentLink GetServiceDefinitionLink()
        {
            return new ComponentLink(ComponentType.ServiceDefinition, this, "ServiceDefinition", true, "Service Definition");
        }
        #endregion
    }
}
