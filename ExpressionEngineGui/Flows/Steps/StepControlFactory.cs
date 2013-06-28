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
                case StepType.Container:
                    control = new ctlContainer();
                    break;
                case StepType.Else:
                    control = new ctlElse();
                    break;
                case StepType.ElseIf:
                    control = new ctlElseIf();
                    break;
                case StepType.Enforce:
                    control = new ctlEnforce();
                    break;
                case StepType.Expression:
                    control = new ctlExpression();
                    break;
                case StepType.Function:
                    control = new ctlFuctionStep();
                    break;
                case StepType.If:
                    control = new ctlIfStep();
                    break;
                case StepType.Mtsql:
                    control = new ctlMtsql();
                    break;
                case StepType.NewProperty:
                    control = new ctlNewPropertyStep();
                    break;
                case StepType.ParameterTableLookup:
                    control = new ctlParameterTableLookupStep();
                    break;
                case StepType.ProcessList:
                    control = new ctlProcessList();
                    break;
                case StepType.Query:
                    control = new ctlQueryStep();
                    break;
                case StepType.SubscriptionLookup:
                    control = new ctlSubscriptionLookup();
                    break;
                default:
                    throw new ArgumentException("Unhandled type");
            }
            control.Init(step, context);
            return control;
        }
    }
}
