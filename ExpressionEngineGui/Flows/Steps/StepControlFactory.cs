using System;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace PropertyGui.Flows.Steps
{
    public static class StepControlFactory
    {
        public static ctlBaseStep Create(Context context, BaseStep step)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (step == null)
                throw new ArgumentException("step is null");

            ctlBaseStep control;
            switch (step.StepType)
            {
                case StepType.AccountLookup:
                    control = new ctlAccountLookupStep();
                    break;
                case StepType.Aggregate:
                    control = new ctlAggregateStep();
                    break;
                case StepType.CalculateEventCharge:
                    control = new ctlCalculateCharge();
                    break;
                case StepType.Expression:
                    control = new ctlExpression();
                    break;
                case StepType.NewProperty:
                    control = new ctlNewPropertyStep();
                    break;
                case StepType.ParameterTableLookup:
                    control = new ctlParameterTableLookupStep();
                    break;
                case StepType.Query:
                    control = new ctlQueryStep();
                    break;
                default:
                    throw new ArgumentException("Unhandled type");
            }
            control.Init(step, context);
            return control;
        }
    }
}
