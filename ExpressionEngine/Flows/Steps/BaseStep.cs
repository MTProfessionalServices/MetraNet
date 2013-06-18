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
    public class BaseStep
    {
        #region properties

        /// <summary>
        /// The parent collection to which the flow belongs
        /// </summary>
        public BaseFlow Flow { get; private set; }

        [DataMember]
        public StepType FlowStepType { get; private set; }

        [DataMember]
        public string Name { get; set; }

        public bool IsUserEditable { get; private set; }

        [DataMember]
        public string Description { get; set; }

        public PropertyCollection InputsAndOutputs = new PropertyCollection(null);

        public PropertyCollection AvailableProperties { get { return _availableProperties; } }
        private PropertyCollection _availableProperties = new PropertyCollection(null);
        #endregion

        #region Constructor
        public BaseStep(BaseFlow flow, StepType flowItemType, bool isUserEditable=true)
        {
            if (flow == null)
                throw new ArgumentException("flow is null");
            Flow = flow;
            FlowStepType = flowItemType;

            IsUserEditable = isUserEditable;
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

        public virtual string GetAutoDescription()
        {
            return null;
        }
        #endregion
    }
}
