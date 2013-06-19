using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;

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
            //InputsAndOutputs.Clear();
        }

        public Property GetProperty()
        {
             return AvailableProperties.Get(PropertyName);
        }
        public override string GetAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0} = {1}", PropertyName, Expression);
        }

        public override string GetAutoDescription()
        {
            var property = GetProperty();
            if (property != null)
                return property.Description;
            return null;
        }
        #endregion
    }
}
