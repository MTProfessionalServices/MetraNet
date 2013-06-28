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
    public class ProductViewEntity : PropertyBag
    {
        #region Properties
       
        /// <summary>
        /// Multipoint parent, optional, if not null, must be a ProductView
        /// </summary>
        [DataMember]
        public string Parent { get; set; }

        [DataMember]
        public Collection<UniqueKey> UniqueKey { get; private set; }

        public override string DatabaseTableNamePrefix
        {
            get { return "t_pv_"; }
        }

        [DataMember]
        public EventType EventType { get; set; }

        [DataMember]
        public BaseFlow Flow = new BaseFlow();

        [DataMember]
        public bool UsesCommerceDecisionEngine { get; set; }

        /// <summary>
        ///// The xQualificationGroup prefix
        /// </summary>
        public override string XqgPrefix { get { return UserContext.Settings.NewSyntax ? "EVENT" : "USAGE"; } }

        public static PropertyCollection CoreProperties;

        #endregion

        #region Constructor
        static ProductViewEntity()
        {
            LoadStaticCoreProperties();
        }
        public ProductViewEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.ProductView, PropertyBagMode.ExtensibleEntity, description)
        {
            EventType = EventType.Unknown;
            FixDeserilization();
        }
        [OnDeserializedAttribute]
        private void FixDeserilization(StreamingContext sc)
        {
            FixDeserilization();
        }
        private void FixDeserilization()
        {
            DatabaseReservedPropertyTableName = PropertyBagConstants.UsageTableName;
            UniqueKey = new Collection<UniqueKey>();
        }
        #endregion

        #region Methods

        public override IEnumerable<Property> GetCoreProperties()
        {
            return CoreProperties;
        }

        public override void AddCoreProperties()
        {
            foreach (var property in CoreProperties)
            {
                if (property.Name == "EventCharge" && Properties.Get("EventCharge") != null)
                    continue;
                Properties.Add(property);
            }
        }

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
           
                //var parent = new ProductViewEntity(null, PropertyBagConstants.ParentPropertyBag, parentPv.Description);
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
        private static void LoadStaticCoreProperties()
        {
            CoreProperties = new PropertyCollection(null);

            //AccountID
            var accountId = CoreProperties.AddInteger32("AccountId", "The internal MetraNet account identifier", true);
            accountId.DatabaseColumnNameMapping = "account_id";
            accountId.IsCore = true;

            //Timestamp
            var timestamp = CoreProperties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            timestamp.DatabaseColumnNameMapping = "timestamp";
            timestamp.IsCore = true;

            //Currency
            var currency = CoreProperties.AddCurrency("Currency", "The currency for the Event", true);
            currency.DatabaseColumnNameMapping = "am_currency";
            currency.IsCore = true;
 
            //Event Amount
            var eventCharge = CoreProperties.AddCharge(PropertyBagConstants.EventCharge, "The charge assoicated with the event which may summarize other charges within the event.The amount can be negative to represent a credit.", true);
            eventCharge.IsCore = true;
            eventCharge.DatabaseColumnNameMapping = "Amount";
            var chargeType = (ChargeType) eventCharge.Type;
            chargeType.CurrencyMode = CurrencyMode.PropertyDriven;
            chargeType.CurrencyProperty = "Currency";

            //Presentation Page ID
            var presentationPageId = CoreProperties.AddInteger32("PresentationPageId", "Identifes which MetraView page will present the Event.", true);
            presentationPageId.IsCore = true;
            presentationPageId.DatabaseColumnNameMapping = "view_id";

            //Event ID
            var eventId = CoreProperties.AddInteger32("EventId", "Uniquely identifes the Event", true);
            eventId.IsCore = true;
            eventId.DatabaseColumnNameMapping = "session_id";

            AddCoreTaxProperty("c_TaxAmount", PropertyBagConstants.EventTax, CoreProperties);
            AddCoreTaxProperty("c_FederalTaxAmount", "FederalTax", CoreProperties);
            AddCoreTaxProperty("c_StateTaxAmount", "StateTax", CoreProperties);
            AddCoreTaxProperty("c_CountyTaxAmount", "CountyTax", CoreProperties);
            AddCoreTaxProperty("c_LocalTaxAmount", "LocalTax", CoreProperties);
            AddCoreTaxProperty("c_OtherTaxAmount", "OtherTax", CoreProperties);
        }

        public static Property AddCoreTaxProperty(string realName, string newName, PropertyCollection properties)
        {
            var description = string.Format(CultureInfo.InvariantCulture, "The {0} tax for the Event.", newName);
            var tax = CoreProperties.AddTax(newName, description, true, null);
            tax.DatabaseColumnNameMapping = realName;
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
            //compute.AddCoreProperties();

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
