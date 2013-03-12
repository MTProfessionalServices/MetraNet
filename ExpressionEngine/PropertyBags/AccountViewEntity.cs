using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract (Namespace = "MetraTech")]
    public class AccountViewEntity : MetraNetEntityBase
    {
        #region Properties
        public override string DatabaseName { get { return "t_av_" + Name; } }

        public override string XqgPrefix { get { return "ACCOUNT"; } }

        #endregion

        #region Constructor
        public AccountViewEntity(string _namespace, string name, string description)
            : base(_namespace,name, PropertyBagConstants.AccountView, description)
        {
          //Add the core properties
          var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifiert", true);
          accountId.IsCore = true;
        }
        #endregion
    }
}
