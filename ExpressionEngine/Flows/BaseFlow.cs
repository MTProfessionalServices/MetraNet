using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class BaseFlow
    {
        #region Properties 
        public PropertyCollection InitialProperties = new PropertyCollection(null);

        /// <summary>
        /// The steps within the flow
        /// </summary>
        [DataMember]
        public List<BaseStep> Steps = new List<BaseStep>();

        #endregion

        #region Methods
        public void UpdateFlow(Context context)
        {
            BaseStep previousStep = null;
            for (int index = 0; index < Steps.Count; index++)
            {
                var step = Steps[index];

                #warning, why do we need this here???
                step.AvailableProperties = new PropertyCollection(this);

                step.AvailableProperties.Clear();

                //Copy what was available to previous
                if (previousStep == null)
                    step.AvailableProperties.AddRange(InitialProperties);
                else
                {
                    step.AvailableProperties.AddRange(previousStep.AvailableProperties);

                    //Append outputs from the the previous item if they aren't already in the step's available list
                    foreach (var property in previousStep.InputsAndOutputs)
                    {
                        if (property.IsOutputOrInOut && !step.AvailableProperties.Exists(property.Name))
                            step.AvailableProperties.Add(property);
                    }
                }

                step.UpdateInputsAndOutputs(context);
                previousStep = step;
            }
        }

        public void Validate(ValidationMessageCollection messages, Context context)
        {
            //UpdateFlow(context);
            //foreach (var item in this)
            //{
            //    item.Validate(messages, context);
            //}
        }
        #endregion
    }
}
