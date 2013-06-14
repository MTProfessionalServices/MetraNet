using System.Collections.Generic;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class FlowCollection : List<FlowStepBase>
    {
        #region Methods
        public void UpdateFlow(Context context, PropertyCollection initalProperties)
        {
#warning TODO: need to reactivate this
            return;
            if (Count == 0)
                return;

            this[0].AvailableProperties.Clear();
            foreach (var property in initalProperties)
            {
                this[0].AvailableProperties.Add((Property)property.Copy());
            }

            FlowStepBase previousItem = null;
            foreach (var step in this)
            {
                step.UpdateInputsAndOutputs(context);

                if (previousItem != null)
                {
                    step.AvailableProperties.Clear();

                    //Copy what was available to previous
                    step.AvailableProperties.AddRange(previousItem.AvailableProperties);

                    //Append outputs from the the previous item if they aren't already in the list
                    foreach (var property in previousItem.InputsAndOutputs)
                    {
                        if (property.IsOutputOrInOut && !step.AvailableProperties.Exists(property.Name))
                            step.AvailableProperties.Add(property);
                    }
                }

                previousItem = step;
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
