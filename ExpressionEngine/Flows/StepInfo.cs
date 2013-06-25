using System.Collections.Generic;
using MetraTech.ExpressionEngine.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    public class StepInfo
    {
        public static Dictionary<StepType, StepInfo> Items = new Dictionary<StepType, StepInfo>();

        #region Properties
        public StepType Type { get; private set; }
        public bool SupportsChildren { get; private set; }
        public string Description { get; private set; }
        #endregion

        #region Static Constructor
        static StepInfo()
        {
            Add(StepType.AccountLookup, false, "Looks up an Account");
            Add(StepType.Aggregate, false, "Aggregates a child property into a parent property.");
            Add(StepType.CalculateEventCharge, false, "Calculates all charges and accumulates them into the EventCharge");
            Add(StepType.Container, true, "A container which simplifies the flow");
            Add(StepType.Enforce, false, "Enforces default values.");
            Add(StepType.Expression, false, "Assigns an expression to to a property");
            Add(StepType.Mtsql, false, "Provides an MTSQL script");
            Add(StepType.NewProperty, false, "Creates a new property");
            Add(StepType.ParameterTableLookup, false, "Looks up Parameter Table");
            Add(StepType.Query, false, "Runs a Query");
            Add(StepType.Start, true, "Starts a flow");
            Add(StepType.Function, false, "Exectues the specified function");
        }
        private static void Add(StepType type, bool supportsChildren, string description)
        {
            Items.Add(type, new StepInfo(type, supportsChildren, description));
        }
        #endregion

        #region Constructor
        public StepInfo(StepType type, bool supportsChildren, string description)
        {
            Type = type;
            SupportsChildren = supportsChildren;
            Description = description;
        }
        #endregion
    }
}
