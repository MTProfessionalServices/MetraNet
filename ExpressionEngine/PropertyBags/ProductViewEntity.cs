using System.Collections.Generic;
using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Database;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class ProductViewEntity : MetraNetEntityBase
    {
        #region Properties

        /// <summary>
        /// Multipoint parent, optional, if not null, must be a ProductView
        /// </summary>
        [DataMember]
        public string Parent { get; set; }

        [DataMember]
        public Collection<UniqueKey> UniqueKey { get; private set; }

        public override string DatabaseName { get { return "t_pv_" + Name; } }

        [DataMember]
        public EventType EventType { get; set; }

        [DataMember]
        public BaseFlow Flow = new BaseFlow();

        /// <summary>
        ///// The xQualificationGroup prefix
        /// </summary>
        public override string XqgPrefix { get { return UserContext.Settings.NewSyntax ? "EVENT" : "USAGE"; } }

        public static PropertyCollection InternalCoreProperties = new PropertyCollection(null);

        #endregion

        #region Constructor
        public ProductViewEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.ProductView, description)
        {
            EventType = EventType.Unknown;
            UniqueKey = new Collection<UniqueKey>();
        }
        #endregion

        #region Methods

        public void UpdateFlow(Context context)
        {
#warning Why  do I need to do this here???
            if (Flow == null)
                Flow = new BaseFlow();
            Flow.InitialProperties = new PropertyCollection(null);

            //Append the Parent and it's properties
            var parentPv = (ProductViewEntity)context.GetComponent(ComponentType.PropertyBag, Parent);
            if (parentPv != null)
            {
                var parent = new PropertyBag(null, PropertyBagConstants.ParentPropertyBag, null, PropertyBagMode.PropertyBag, parentPv.Description);
                Flow.InitialProperties.Add(parent);
                foreach (var property in parentPv.Properties)
                {
                    parent.Properties.Add((Property)property.Copy());
                }
            }

            //Append the PV properties
            foreach (var property in Properties)
            {
                Flow.InitialProperties.Add((Property)property.Copy());
            }
            Flow.ProductView = this;
            Flow.UpdateFlow(context);
        }

        /// <summary>
        /// Appends the core values
        /// </summary>
        public void AddCoreProperties()
        {
            //EventID (id_sess) - joins to PV (with id_usage_interval)
            var eventId = (MetraNetPropertyBase)Properties.AddInteger32("EventId", "Uniquely identifes the processed Event", true);
            eventId.IsCore = true;
            eventId.DatabaseNameMapping = "id_sess";

            //EventSourceID (tx_uid) - joins to SVC
            // NOTE: this is an encoded GUID, not a pure freeform string
            var eventSourceId = (MetraNetPropertyBase)Properties.AddString("EventSourceId", "Uniquely identifes the raw unprocessed Event", true);
            eventId.IsCore = true;
            eventId.DatabaseNameMapping = "tx_uid";
            
            //PayerID (id_acc) - joins to paying account
            // TODO: do we want to use Payer or Account
            var accountId = (MetraNetPropertyBase)Properties.AddInteger32("AccountId", "The internal MetraNet account identifier", true);
            accountId.IsCore = true;
            accountId.DatabaseNameMapping = "id_acc";
            
            //PayeeID (id_payee) - joins to guiding account
            var payeeId = (MetraNetPropertyBase)Properties.AddInteger32("PayeeId", "The internal MetraNet account identifier of the payee", true);
            payeeId.IsCore = true;
            payeeId.DatabaseNameMapping = "id_payee";
            
            //ProductViewID (id_view) - joins to type of PV
            // TODO: not sure the description is accurate
            var presentationPageId = (MetraNetPropertyBase)Properties.AddInteger32("PresentationPageId", "Identifes which MetraView page will present the Event.", true);
            presentationPageId.IsCore = true;
            presentationPageId.DatabaseNameMapping = "id_view";
            
            //UsageIntervalID (id_usage_interval) - joins to PV (with id_sess), and sometimes joins to t_acc_usage (with id_parent_sess)
            var intervalId = (MetraNetPropertyBase)Properties.AddInteger32("UsageIntervalId", "The billing interval where the event is billed", true);
            intervalId.IsCore = true;
            intervalId.DatabaseNameMapping = "id_usage_interval";
            
            //ParentEventID (id_parent_sess) - optional, joins to parent t_acc_usage row (with id_usage_interval)
            // TODO: not sure we want Parent on there

            //ProductOfferingID (id_prod) - optional, joins to id_po
            var productOfferingId = (MetraNetPropertyBase)Properties.AddInteger32("ProductOfferingId", "Identifes the product offering associated with this event.", true);
            productOfferingId.IsCore = true;
            productOfferingId.DatabaseNameMapping = "id_prod";
            
            //ServiceDefinitionID (id_svc) - joins to type of SVC
            var serviceDefinitionId = (MetraNetPropertyBase)Properties.AddInteger32("PresentationPageId", "Identifies the service definition that was used to ingest the Event.", true);
            serviceDefinitionId.IsCore = true;
            serviceDefinitionId.DatabaseNameMapping = "id_svc";

            //Timestamp (dt_session)
            var timestamp = (MetraNetPropertyBase)Properties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            timestamp.IsCore = true;
            timestamp.DatabaseNameMapping = "dt_session";

            //EventCurrency (am_currency)
            // TODO: do we want to use EventCurrency or Currency
            var currency = Properties.AddCurrency("Currency", "The currency for the Event", true);
            ((MetraNetPropertyBase)currency).DatabaseNameMapping = "am_currency";
            currency.IsCore = true;

            //EventCharge (amount)
            var eventCharge = (ProductViewProperty)Properties.AddCharge(PropertyBagConstants.EventCharge, "The charge associated with the event which may summarize other charges within the event.The amount can be negative to represent a credit.", true);
            eventCharge.IsCore = true;
            eventCharge.DatabaseNameMapping = "amount";
            var chargeType = (ChargeType)eventCharge.Type;
            chargeType.CurrencyMode = CurrencyMode.PropertyDriven;
            chargeType.CurrencyProperty = "Currency";
            
            //CreateDate (dt_crt)
            var createDt = (MetraNetPropertyBase)Properties.AddDateTime("CreationDate", "The time the event was originally processed", true);
            createDt.IsCore = true;
            createDt.DatabaseNameMapping = "dt_crt";
            
            //BatchID (tx_batch) - optional
            // NOTE: this is an encoded GUID, not a pure freeform string
            var batchId = (MetraNetPropertyBase)Properties.AddString("BatchId", "The batch that this event was entered with", true);
            batchId.IsCore = true;
            batchId.DatabaseNameMapping = "tx_batch";
            
            //FederalTax (tax_federal) - optional
            AddTaxProperty("tax_federal", "FederalTax", Properties);
            
            //StateTax (tax_state) - optional
            AddTaxProperty("tax_state", "StateTax", Properties);
            
            //CountyTax (tax_county) - optional
            AddTaxProperty("tax_county", "CountyTax", Properties);
            
            //LocalTax (tax_local) - optional
            AddTaxProperty("tax_local", "LocalTax", Properties);
            
            //OtherTax (tax_other) - optional
            AddTaxProperty("tax_other", "OtherTax", Properties);
            
            //PriceableItemInstanceID (id_pi_instance) - optional, links to t_base_props to identify priceable item instance
            var priceableItemInstanceId = (MetraNetPropertyBase)Properties.AddInteger32("PriceableItemInstanceId", "Identifies the priceable item instance used for this event.", true);
            priceableItemInstanceId.IsCore = true;
            priceableItemInstanceId.DatabaseNameMapping = "id_pi_instance";

            //PriceableItemTemplateID (id_pi_template) - optional, links to t_base_props to identify priceable item template
            var priceableItemTemplateId = (MetraNetPropertyBase)Properties.AddInteger32("PriceableItemTemplateId", "Identifies the priceable item template used for this event.", true);
            priceableItemTemplateId.IsCore = true;
            priceableItemTemplateId.DatabaseNameMapping = "id_pi_template";
            
            //(id_se) - need to verify what this holds, looks to be same as account
            // TODO: verify contents here
            
            //DivisionCurrency (div_currency) - optional
            // TODO: do we want to use EventCurrency or Currency
            var divisionCurrency = Properties.AddCurrency("DivisionCurrency", "The division currency for the Event", true);
            ((MetraNetPropertyBase)divisionCurrency).DatabaseNameMapping = "div_currency";
            divisionCurrency.IsCore = true;
            
            //DivisionAmount (div_amount) - optional
            // TODO: or DivisionEventCharge?
            // TODO: do we event carry about division currency/amount?  I don't know anyone using this, and think it was probably a hasty solution to a non-existent problem
            var divisionCharge = (ProductViewProperty)Properties.AddCurrency("DivisionCharge", "The EventCharge in the Division Currency.", true);
            divisionCharge.IsCore = true;
            divisionCharge.DatabaseNameMapping = "div_amount";
            var divisionChargeType = (ChargeType)divisionCharge.Type;
            divisionChargeType.CurrencyMode = CurrencyMode.PropertyDriven;
            divisionChargeType.CurrencyProperty = "DivisionCurrency";
            
            //TaxInclusive (tax_inclusive) - optional, whether amount has taxes included
            // TODO: need to double check data type here
            
            //TaxCalculated (tax_calculated) - optional, defaults to 0, whether taxes have been calculated on this event yet, regardless of whether still up-to-date
            // TODO: need to double check data type here
            
            //TaxInformational (tax_informational) - optional, whether amount has taxes that are calculated, but not part of balance due
            // TODO: need to double check data type here

            // FIXME: we do not have a total tax amount
            AddTaxProperty("c_TaxAmount", PropertyBagConstants.EventTax, Properties);
        }

        public MetraNetPropertyBase AddTaxProperty(string realName, string newName, PropertyCollection properties)
        {
            var description = string.Format(CultureInfo.InvariantCulture, "The {0} tax for the Event.", newName);
            var tax = (MetraNetPropertyBase) Properties.AddTax(newName, description, true, null);
            tax.DatabaseNameMapping = realName;
            tax.IsCore = true;
            return tax;
        }

        public Property GetEventCharge()
        {
            return Properties.Get(PropertyBagConstants.EventCharge);
        }

        public List<Property> GetCharges(bool includeEventCharge)
        {
            var charges = new List<Property>();
            foreach (var property in Properties)
            {
                if (property.Type.IsCharge)
                {
                    if (property.Name == PropertyBagConstants.EventCharge && !includeEventCharge)
                        continue;
                    charges.Add(property);
                }
            }
            return charges;
        }

        protected override void ValidateProperties(ValidationMessageCollection messages, Context context)
        {
            var hasCharges = GetCharges(false).Count > 0;
            foreach (var property in Properties)
            {
                //Skip the top-level charge if there are sub charges
                if (property.IsCore && property.Type.IsCharge && hasCharges)
                    continue;
                property.Validate(messages, context);
            }

            UpdateFlow(context);
        }
        #endregion

        #region Prototype Methods

        /// <summary>
        /// Createa a sample Cloud Compute ProductView. Useful for development and testing purposes
        /// </summary>
        /// <returns></returns>
        public static ProductViewEntity CreateCompute()
        {
            var compute = new ProductViewEntity("MetraTech.Cloud", "Compute", "Models an IaaS compute service");
            compute.AddCoreProperties();

            //Hours
            var hoursType = TypeFactory.CreateDecimal(UnitOfMeasureMode.FixedUnitOfMeasure);
            hoursType.FixedUnitOfMeasure = "MetraTech.TimeDayBased.Hour";
            var hours = PropertyFactory.Create("ProductView","Hours", hoursType, true, "Duration in hours");
            compute.Properties.Add(hours);

            //Compute Charge
            var computeChargeType = new ChargeType("Hours");
            var computeCharge = PropertyFactory.Create("ProductView", "ComputeCharge", computeChargeType, true, "The charge associated with computaitonal processing");
            compute.Properties.Add(computeCharge);

            //Snapshots
            var snapshotType = TypeFactory.CreateDecimal(UnitOfMeasureMode.Count);
            var snapshot = PropertyFactory.Create("ProductView", "Snapshots", snapshotType, true, "The number of snapshots");
            compute.Properties.Add(snapshot);

            //Snapshot Charge
            var snapshotChargeType = new ChargeType("Snapshots");
            var snapshotCharge = PropertyFactory.Create("SnapshotCharge", snapshotChargeType, true, "The charge associated with the snapshots.");
            compute.Properties.Add(snapshotCharge);

            //Data Center
            var dataCenter = PropertyFactory.Create("ProductView", "DataCenter", TypeFactory.CreateString(), true, "The data center");
            compute.Properties.Add(dataCenter);

            return compute;
        }
        #endregion
    }
}
