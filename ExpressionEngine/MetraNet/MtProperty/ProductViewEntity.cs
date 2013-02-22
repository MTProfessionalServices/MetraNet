using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.Database;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    public class ProductViewEntity : Entity
    {
        #region Properties
        public Collection<UniqueKey> UniqueKey;
        #endregion

        #region Constructor
        public ProductViewEntity(string name, string description):base(name, ComplexType.ProductView, null, true, description)
        {
          UniqueKey = new Collection<UniqueKey>();

          //Add the core properties
          var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifiert", true);
          accountId.IsCore = true;

          var timestamp = Properties.AddDateTime("Timestamp", "The time the event is deemed to have occurred", true);
          timestamp.IsCore = true;

          var eventChargeName = UserSettings.NewSyntax ? "EventCharge" : "Amount";
          var eventCharge = Properties.AddCharge(eventChargeName, "The charge assoicated with the event which may summarize other charges within the event", true);
        }
        #endregion
    }
}
