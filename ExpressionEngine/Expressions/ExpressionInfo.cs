using System.Collections.Generic;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace MetraTech.ExpressionEngine.Expressions
{
    public class ExpressionInfo
    {
        #region Properties
        public static readonly Dictionary<ExpressionType, ExpressionInfo> Items = new Dictionary<ExpressionType, ExpressionInfo>();

        public ExpressionType Type { get { return _type; } }
        private readonly ExpressionType _type;
        public List<string> SupportedEntityTypes { get; private set; }
        public bool SupportsAqgs { get; set; }
        public bool SupportsUqgs { get; set; }
        public bool SupportsProperties { get; set; }
        public bool SupportsAvailableProperties { get; set; }

        #endregion

        #region Static Constructor
        static ExpressionInfo()
        {
            //Aqg
            var info = AddInfo(ExpressionType.Aqg, PropertyBagConstants.AccountView);
            info.SupportsAqgs = true;
            
            //Uqg
            info = AddInfo(ExpressionType.Uqg, PropertyBagConstants.ProductView);
            info.SupportsUqgs = true;

            //Message
            AddInfo(ExpressionType.Message, PropertyBagConstants.AccountView);

            //Expression
            AddInfo(ExpressionType.Logic, PropertyBagConstants.AccountView);

            AddInfo(ExpressionType.Email, PropertyBagConstants.AccountView);
        }


        private static ExpressionInfo AddInfo(ExpressionType type, params string[] entityTypes)
        {
            var info = new ExpressionInfo(type);
            info.SupportedEntityTypes.AddRange(entityTypes);
            Items.Add(info.Type, info);
            return info;
        }
        #endregion

        #region Constructor
        public ExpressionInfo(ExpressionType type)
        {
            _type = type;
            SupportedEntityTypes = new List<string>();
        }
        #endregion
    }
}
