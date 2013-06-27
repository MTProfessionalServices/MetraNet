using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    [DataContract (Namespace = "MetraTech")]
    public class AccountViewEntity : PropertyBag
    {
        #region Properties
        private static PropertyCollection CoreProperties;
        public override string DatabaseColumnName { get { return "t_av_" + Name; } }
        public override string XqgPrefix { get { return "ACCOUNT"; } }

        #endregion

        #region Constructor
        static AccountViewEntity()
        {
            AddCoreProperties();
        }
        public AccountViewEntity(string _namespace, string name, string description)
            : base(_namespace, name, PropertyBagConstants.AccountView, PropertyBagMode.ExtensibleEntity, description)
        {
        }
        #endregion

        #region Methods
        public override IEnumerable<Property> GetCoreProperties()
        {
            return CoreProperties;
        }
        private static void AddCoreProperties()
        {
            CoreProperties = new PropertyCollection(null);

            //AccountID
            var accountId = CoreProperties.AddInteger32("AccountId", "The internal MetraNet account identifier", true);
            accountId.IsCore = true;
            CoreProperties.Add(accountId);
        }
        #endregion
    }
}
