using System.Collections.Generic;
using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.Database;
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
        [DataMember]
        public bool IsMetered { get; set; }

        [DataMember]
        public Collection<UniqueKey> UniqueKey { get; private set; }

        public override string DatabaseName { get { return "t_pv_" + Name; } }

        [DataMember]
        public EventType EventType { get; set; }

        /// <summary>
        ///// The xQualificationGroup prefix
        /// </summary>
        public override string XqgPrefix { get { return UserContext.Settings.NewSyntax ? "EVENT" : "USAGE"; } }

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

        /// <summary>
        /// Appends the core values
        /// </summary>
        public void AddCoreProperties()
        {
            //AccountID
            var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifier", true);
            accountId.IsCore = true;

            //Timestamp
            var timestamp = Properties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            timestamp.IsCore = true;

            //Currency
            var currency = Properties.AddString("Currency", "The currency for the Event", true);
            currency.IsCore = true;

            //Event Amount
            var eventCharge = (ProductViewProperty)Properties.AddCharge(PropertyBagConstants.EventCharge, "The charge assoicated with the event which may summarize other charges within the event.The amount can be negative to represent a credit.", true);
            eventCharge.IsCore = true;
            eventCharge.DatabaseNameMapping = "c_Amount";
            var chargeType = (ChargeType) eventCharge.Type;
            chargeType.CurrencyMode = CurrencyMode.PropertyDriven;
            chargeType.CurrencyProperty = "Currency";

            //Presentation Page ID
            var presentationPageId = (MetraNetPropertyBase)Properties.AddInteger32("PresentationPageId", "Identifes which MetraView page will present the Event.", true);
            presentationPageId.IsCore = true;
            presentationPageId.DatabaseNameMapping = "c_ViewId";

            //Event ID
            var eventId = (MetraNetPropertyBase) Properties.AddInteger32("EventId", "Uniquely identifes the Event", true);
            eventId.IsCore = true;
            eventId.DatabaseNameMapping = "c_SessionId";

            AddTaxProperty("c_TaxAmount", PropertyBagConstants.EventTax, Properties);
            AddTaxProperty("c_FederalTaxAmount", "FederalTax", Properties);
            AddTaxProperty("c_StateTaxAmount", "StateTax", Properties);
            AddTaxProperty("c_CountyTaxAmount", "CountyTax", Properties);
            AddTaxProperty("c_LocalTaxAmount", "LocalTax", Properties);
            AddTaxProperty("c_OtherTaxAmount", "OtherTax", Properties);
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
