using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using System.Globalization;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class NewPropertyStep : FlowStepBase
    {
        #region Properties
        [DataMember]
        public Property Property = new Property(null, TypeFactory.CreateString(), true, null);
        #endregion

        #region Constructor
        public NewPropertyStep(Flow flow)
            : base(flow, FlowStepType.NewProperty)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            Property.Direction = Direction.Output;
            InputsAndOutputs.Add((Property)Property.Copy());
        }

        public override string GetAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "New {0} ({1})", Property.Name, Property.Type.BaseType.ToString());
        }
        #endregion
    }
}
