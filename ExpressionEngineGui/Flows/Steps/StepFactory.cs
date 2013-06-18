using System;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace PropertyGui.Flows.Steps
{
    public static class StepFactory
    {
        public static ctlBaseStep Create(Context context, BaseStep step)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (step == null)
                throw new ArgumentException("step is null");

            ctlBaseStep control;
            switch (step.FlowStepType)
            {
                case StepType.NewProperty:
                    control = new ctlNewPropertyStep();
                    break;
                case StepType.Expression:
                    control = new ctlExpression();
                    break;
                case StepType.CalculateEventCharge:
                    control = new ctlCalculateCharge();
                    break;
                default:
                    throw new ArgumentException("Unhandled type");
            }
            control.Init(step, context);
            return control;
        }
    }
}
