using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class FlowCollection : List<FlowStepBase>
    {
        #region Methods
        public void UpdateFlow(Context context)
        {
            FlowStepBase previousItem = null;
            foreach (var item in this)
            {
                item.UpdateInputsAndOutputs(context);

                item.AvailableProperties.Clear();
                if (previousItem != null)
                {
                    //Copy what was available to previous
                    item.AvailableProperties.AddRange(previousItem.AvailableProperties);

                    //Append outputs from the the previous item if they aren't already in the list
                    foreach (var property in previousItem.InputsAndOutputs)
                    {
                        if (property.IsOutputOrInOut && !item.AvailableProperties.Exists(property.Name))
                            item.AvailableProperties.Add(property);
                    }
                }

                previousItem = item;
            }
        }

        public void Validate(ValidationMessageCollection messages, Context context)
        {
            UpdateFlow(context);
            foreach (var item in this)
            {
                item.Validate(messages, context);
            }
        }
        #endregion
    }
}
