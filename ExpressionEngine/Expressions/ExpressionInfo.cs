using System.Collections.Generic;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.Expressions
{
    public class ExpressionInfo
    {
        #region Properties
        public static readonly Dictionary<ExpressionType, ExpressionInfo> Items = new Dictionary<ExpressionType, ExpressionInfo>();

        public ExpressionType Type { get { return _type; } }
        private readonly ExpressionType _type;
        public List<ComplexType> SupportedEntityTypes { get; private set; }
        public bool SupportsAqgs { get; set; }
        public bool SupportsUqgs { get; set; }

        #endregion

        #region Static Constructor
        static ExpressionInfo()
        {
            //Aqg
            var info = AddInfo(ExpressionType.Aqg, ComplexType.AccountView);
            info.SupportsAqgs = true;
            
            //Uqg
            info = AddInfo(ExpressionType.Uqg, ComplexType.ProductView);
            info.SupportsUqgs = true;

            //Message
            AddInfo(ExpressionType.Message, ComplexType.AccountView);

            //Expression
            AddInfo(ExpressionType.Logic, ComplexType.AccountView);

            AddInfo(ExpressionType.Email, ComplexType.AccountView);
        }


        private static ExpressionInfo AddInfo(ExpressionType type, params ComplexType[] entityTypes)
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
            SupportedEntityTypes = new List<ComplexType>();
        }
        #endregion
    }
}
