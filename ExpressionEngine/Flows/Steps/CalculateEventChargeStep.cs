using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.Flows.Steps
{
    [DataContract(Namespace = "MetraTech")]
    public class CalculateEventChargeStep : BaseStep
    {
        #region Properties
        #endregion

        #region Constructor
        public CalculateEventChargeStep(BaseFlow flow)
            : base(flow, StepType.CalculateEventCharge)
        {
        }
        #endregion

        #region Methods

        public override void UpdateInputsAndOutputs(Context context)
        {
            InputsAndOutputs = new PropertyCollection(this);
            var charges = Flow.ProductView.GetCharges(true);
            foreach (var charge in charges)
            {
                AddToInputsAndOutputs(charge.Name, Direction.Output);
                var type = (ChargeType)charge.Type;
                AddToInputsAndOutputs(type.QuantityProperty, Direction.Input);
                AddToInputsAndOutputs(type.PriceProperty, Direction.Input);
            }
        }
        public override string GetBusinessAutoLabel()
        {
            return "Calculate Event Charge";
        }
        public override string GetTechnicalAutoLabel()
        {
            return "CalculateEventCharge()";
        }


        public override List<EventChargeMapping> GetEventChargeMappings()
        {
            var mappings = new List<EventChargeMapping>();

            var charges = Flow.ProductView.GetCharges(false);
            
            if (charges.Count == 0)
            {
                var eventCharge = Flow.ProductView.GetEventCharge();
                mappings.AddRange(GetEventChargeMappingsForCharge(true, eventCharge));
            }
            else
            {
                foreach (var charge in charges)
                {
                    var chargeMappings = GetEventChargeMappingsForCharge(false, charge);
                    mappings.AddRange(chargeMappings);
                } 
            }

            return mappings;
        }

        private List<EventChargeMapping> GetEventChargeMappingsForCharge(bool isEventCharge, Property chargeProperty)
        {
            var mappings = new List<EventChargeMapping>();
            var chargeType = (ChargeType)chargeProperty.Type;

            string chargeName;
            if (!string.IsNullOrWhiteSpace(chargeType.Alias))
                chargeName = chargeType.Alias;
            else
                chargeName = chargeProperty.PropertyCollection.GetPropertyDatabaseName(BasicHelper.GetNameFromFullName(chargeProperty.Name));

            //Units mapping
            if (chargeType.QuantityProperty != null)
            {
                var unitsMapping = GetBaseEventChargeMapping();
                unitsMapping.ChargeName = chargeName;
                unitsMapping.FieldName = chargeType.QuantityProperty;
                unitsMapping.FieldType = CdeFieldMappingType.units;
                mappings.Add(unitsMapping);
            }

            //Amount mapping
            var amountMapping = GetBaseEventChargeMapping();
            amountMapping.ChargeName = chargeName;
            amountMapping.FieldName = isEventCharge? "Amount" : chargeProperty.DatabaseName;
            amountMapping.FieldType = CdeFieldMappingType.amount;
            mappings.Add(amountMapping);

            //Rate mapping
            if (chargeType.PriceProperty != null)
            {
                var priceMapping = GetBaseEventChargeMapping();
                priceMapping.ChargeName = chargeName;
                priceMapping.FieldName = chargeType.PriceProperty;
                priceMapping.FieldType = CdeFieldMappingType.rate;
                mappings.Add(priceMapping);
            }

            return mappings;
        }
        #endregion
    }
}
