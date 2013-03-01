using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.Database;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using System.Runtime.Serialization;
using System.Globalization;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract(Namespace = "MetraTech")]
    public class ProductViewEntity : MetraNetEntityBase
    {
        #region Properties
        [DataMember]
        public Collection<UniqueKey> UniqueKey { get; private set; }

        public override string DatabaseName { get { return "t_pv_" + Name; } }

        public override string XqgPrefix { get { return UserContext.Settings.NewSyntax ? "EVENT" : "USAGE"; } }

        #endregion

        #region Constructor
        public ProductViewEntity(string name, string description) : base(name, PropertyBagConstants.ProductView, description)
        {
            UniqueKey = new Collection<UniqueKey>();

            //Add the core properties
            var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifiert", true);
            accountId.IsCore = true;

            var timestamp = Properties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
            timestamp.IsCore = true;

            var currency = Properties.AddDateTime("Currency", "The currency for the Event", true);
            currency.IsCore = true;

            var eventChargeName = UserContext.Settings.NewSyntax ? "EventCharge" : "Amount";
            var eventCharge = (MetraNetPropertyBase)Properties.AddCharge(eventChargeName, "The charge assoicated with the event which may summarize other charges within the event.The amount can be negative to represent a credit.", true);
            eventCharge.IsCore = true;
            eventCharge.DatabaseNameMapping = "c_Amount";

            var presentationPageId = (MetraNetPropertyBase)Properties.AddInteger32("PresentationPageId", "Identifes which MetraView page will present the Event.", true);
            presentationPageId.IsCore = true;
            presentationPageId.DatabaseNameMapping = "c_ViewId";

            var eventId = (MetraNetPropertyBase) Properties.AddInteger32("EventId", "Uniquely identifes the Event", true);
            eventId.IsCore = true;
            eventId.DatabaseNameMapping = "c_SessionId";

            AddTaxProperty("TaxAmount", "Total", Properties);
            AddTaxProperty("FederalTaxAmount", "Federal", Properties);
            AddTaxProperty("StateTaxAmount", "Federal", Properties);
            AddTaxProperty("CountyTaxAmount", "County", Properties);
            AddTaxProperty("LocalTaxAmount", "Local", Properties);
            AddTaxProperty("OtherTaxAmount", "Other", Properties);
        }

        public MetraNetPropertyBase AddTaxProperty(string realName, string newName, PropertyCollection properties)
        {
            var description = string.Format(CultureInfo.InvariantCulture, "The {0} tax for the Event.", newName);
            var tax = (MetraNetPropertyBase) Properties.AddCharge(realName, description, true, "0");
            tax.IsCore = true;
            return tax;
        }
        #endregion
    }
}
