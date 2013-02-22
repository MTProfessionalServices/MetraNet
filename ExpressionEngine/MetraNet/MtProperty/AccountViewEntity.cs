using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.MetraNet.MtProperty
{
    [DataContract]
    public class AccountViewEntity : Entity
    {
        #region Constructor
        public AccountViewEntity(string name, string description) : base(name, ComplexType.ProductView, null, true, description)
        {
          //Add the core properties
          var accountId = Properties.AddInteger32("AccountId", "The internal MetraNet account identifiert", true);
          accountId.IsCore = true;
        }
        #endregion
    }
}
