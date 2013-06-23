using System;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.Flows.Steps;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Flows
{
    /// <summary>
    /// Simple prototype for transaction flows to replace pipelines
    /// </summary>
    [DataContract(Namespace = "MetraTech")]
    [KnownType(typeof(AggregationStep))]
    [KnownType(typeof(CalculateEventChargeStep))]
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

        /// <summary>
        /// Indicates what properties (and their direction) the Step interacts with. Each subclass should override this method
        /// </summary>
        public PropertyCollection InputsAndOutputs = new PropertyCollection(null);

        public PropertyCollection AvailableProperties  = new PropertyCollection(null);
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
        /// Updates the InputsAndOutputs collection. Should be overriden by base class.
        /// </summary>
        public virtual void UpdateInputsAndOutputs(Context context)
        {
#warning why do i need this here?
            InputsAndOutputs = new PropertyCollection(this);
            InputsAndOutputs.Clear();
        }

        public virtual void Validate(ValidationMessageCollection messages, Context context)
        {
            //TODO: add validation
        }

        /// <summary>
        /// Returns an automatically generated user-friendly label. Commonly used as the text in the tree control UI.
        /// </summary>
        public virtual string GetAutoLabel()
        {
            return null;
        }

        /// <summary>
        /// Returns an automatically generated description. Commonly used for a tool tip in the tree control UI.
        /// </summary>
        public virtual string GetAutoDescription()
        {
            return null;
        }

        public Property AddToInputsAndOutputs(string propertyName, Direction direction)
        {
            var property = AvailableProperties.Get(propertyName);
            if (property == null)
                return null;

            var ioProperty = (Property) property.Copy();
            ioProperty.Direction = direction;
            InputsAndOutputs.Add(ioProperty);
            return ioProperty;
        }
        #endregion
    }
}
