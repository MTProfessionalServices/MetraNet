using System;
using System.Collections.Generic;
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
        #region Properties

        /// <summary>
        /// The parent collection to which the flow belongs
        /// </summary>
        public BaseFlow Flow { get; set; }

        public StepInfo Info { get { return StepInfo.Items[StepType]; } }

        [DataMember]
        public StepType StepType { get; private set; }
        
        /// <summary>
        /// The sequential step number; updated when UpdateFlow() is invoked
        /// </summary>
        public int Index { get; set; }

        /// <summary>
        /// Label entered by the user, shown in the tree
        /// </summary>
        [DataMember]
        public string UserLabel { get; set; }

        /// <summary>
        /// A description entered by the user, shown as a tooltip in the tree
        /// </summary>
        [DataMember]
        public string UserDescription { get; set; }

        [DataMember]
        public string ConditionalExpression { get; set; }

        /// <summary>
        /// The child steps
        /// </summary>
        public List<BaseStep> Steps = new List<BaseStep>();

        /// <summary>
        /// Indicates what properties (and their direction) the Step interacts with. Each subclass should override this method
        /// </summary>
        public PropertyCollection InputsAndOutputs = new PropertyCollection(null);

        public PropertyCollection AvailableProperties  = new PropertyCollection(null);
        #endregion

        #region Constructor
        public BaseStep(BaseFlow flow, StepType stepType)
        {
            if (flow == null)
                throw new ArgumentException("flow is null");
            Flow = flow;
            StepType = stepType;
            FixDeserilization(new StreamingContext());
        }

        [OnDeserializedAttribute]
        private void FixDeserilization(StreamingContext sc)
        {
            InputsAndOutputs = new PropertyCollection(null);
            AvailableProperties  = new PropertyCollection(null);
        }

        #endregion

        #region Flow Methods
        public BaseStep FirstStep()
        {
            if (Steps.Count == 0)
                return null;
            return Steps[0];
        }
        public BaseStep LastStep()
        {
            if (Steps.Count == 0)
                return null;
            return Steps[Steps.Count-1];
        }
        #endregion

        #region Methods

        /// <summary>
        /// Updates the InputsAndOutputs collection. Should be overriden by base class.
        /// </summary>
        public virtual void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
        }

        public virtual void Validate(ValidationMessageCollection messages, Context context)
        {
            //TODO: add validation
        }

        /// <summary>
        /// Returns an automatically generated user-friendly label. Commonly used as the text in the tree control UI.
        /// </summary>
        public virtual string GetBusinessAutoLabel()
        {
            return null;
        }

        public virtual string GetTechnicalAutoLabel()
        {
            return null;
        }

        public string GetLabel(LabelMode mode)
        {
            if (mode == LabelMode.Business)
            {
                if (!string.IsNullOrWhiteSpace(UserLabel))
                    return UserLabel;
                return GetBusinessAutoLabel();
            }
            return GetTechnicalAutoLabel();
        }

        public string GetDescription()
        {
            if (!string.IsNullOrWhiteSpace(UserDescription))
                return UserDescription;
            return Info.Description;
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
