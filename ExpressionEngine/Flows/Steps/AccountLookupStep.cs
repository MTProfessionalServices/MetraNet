using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using PropertyGui.Flows.Enumerations;

namespace MetraTech.ExpressionEngine.Flows
{
    [DataContract(Namespace = "MetraTech")]
    public class AccountLookupStep : BaseStep
    {
        #region Properties

        [DataMember]
        public AccountLookupMode LookupMode { get; set; }

        [DataMember]
        public string Indentifer { get; set; }

        [DataMember]
        public string Namespace { get; set; }

        [DataMember]
        public string Timestamp { get; set; }

        [DataMember]
        public bool FailIfNotFound { get; set; }

        [DataMember] 
        public List<string> AccountViews { get; private set; }

        [DataMember]
        public List<string> PropertyNames { get; private set; } 

        #endregion

        #region Constructor
        public AccountLookupStep(BaseFlow flow) : base(flow, StepType.AccountLookup)
        {
            AccountViews = new List<string>();
            PropertyNames = new List<string>();
        }
        #endregion

        #region Methods
        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs.Clear();
        }

        public override string GetBusinessAutoLabel()
        {
            return string.Format(CultureInfo.InvariantCulture, "AccountLookup");
        }
        public override string GetTechnicalAutoLabel()
        {
            return GetBusinessAutoLabel();
        }

        public List<Property> GetPossibleAccountViewProperties()
        {
            var properties = new List<Property>();
           
            foreach (var avName in AccountViews)
            {
                var av = Flow.ProductView.Context.PropertyBagManager.Get(avName);
                if (avName != null)
                {
                    foreach (var property in av.Properties)
                    {
                        properties.Add((Property)property.Copy());
                    }
                }
            }
            return properties;
        }
        #endregion
    }
}
