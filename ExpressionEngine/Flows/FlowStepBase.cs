using System;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Flows
{
    /// <summary>
    /// Simple prototype for transaction flows to replace pipelines
    /// </summary>
    [DataContract(Namespace = "MetraTech")]
    [KnownType(typeof(ExpressionStep))]
    [KnownType(typeof(NewPropertyStep))]
    public class FlowStepBase
    {
        #region properties

        /// <summary>
        /// The parent collection to which the flow belongs
        /// </summary>
        public Flow Flow { get; private set; }

        [DataMember]
        public FlowStepType FlowStepType { get; private set; }

        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public string Description { get; set; }

        public PropertyCollection InputsAndOutputs = new PropertyCollection(null);

        public PropertyCollection AvailableProperties { get { return _availableProperties; } }
        private PropertyCollection _availableProperties = new PropertyCollection(null);
        #endregion

        #region Constructor
        public FlowStepBase(Flow flow, FlowStepType flowItemType)
        {
            if (flow == null)
                throw new ArgumentException("flow is null");
            Flow = flow;
            FlowStepType = flowItemType;
        }
        #endregion

        #region Methods

        /// <summary>
        /// Updates the InputsAndOutputs property. This must be overridden in every FlowItem
        /// </summary>
        public virtual void UpdateInputsAndOutputs(Context context)
        {
            
        }

        public void Validate(ValidationMessageCollection messages, Context context)
        {
            //TODO: add validation
        }

        public virtual string GetAutoLabel()
        {
            return null;
        }
        #endregion
    }
}
