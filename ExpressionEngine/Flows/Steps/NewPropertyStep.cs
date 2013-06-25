using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using System.Globalization;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class NewPropertyStep : BaseStep
    {
        #region Properties
        [DataMember]
        public Property Property = new Property(null, TypeFactory.CreateString(), true, null);
        #endregion

        #region Constructor
        public NewPropertyStep(BaseFlow flow)
            : base(flow, StepType.NewProperty)
        {
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
            var property = (Property) Property.Copy();
            property.Direction = Direction.Output;
            InputsAndOutputs.Add(property);
        }

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "Create new property {0} ({1})", Property.Name, Property.Type.BaseType.ToString());
        }

        public override string GetTechnicalAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "new {0} ({1})", Property.Name, Property.Type.BaseType.ToString());
        }
        #endregion
    }
}
