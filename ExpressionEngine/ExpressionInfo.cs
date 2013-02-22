using System.Collections.Generic;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine
{
    public class ExpressionInfo
    {
        #region Properties
        public static readonly Dictionary<ExpressionTypeEnum, ExpressionInfo> Items = new Dictionary<ExpressionTypeEnum, ExpressionInfo>();

        public readonly ExpressionTypeEnum Type;
        public List<ComplexType> SupportedEntityTypes = new List<ComplexType>();
        public bool SupportsAqgs { get; set; }
        public bool SupportsUqgs { get; set; }

        #endregion

        #region Static Constructor
        static ExpressionInfo()
        {
            //Aqg
            var info = AddInfo(ExpressionTypeEnum.AQG, ComplexType.AccountView);
            info.SupportsAqgs = true;
            
            //UQG
            info = AddInfo(ExpressionTypeEnum.UQG, ComplexType.ProductView);
            info.SupportsUqgs = true;

            //Message
            AddInfo(ExpressionTypeEnum.Message, ComplexType.AccountView);

            //Expression
            AddInfo(ExpressionTypeEnum.Logic, ComplexType.AccountView);

            AddInfo(ExpressionTypeEnum.Email, ComplexType.AccountView);
        }


        private static ExpressionInfo AddInfo(ExpressionTypeEnum type, params ComplexType[] entityTypes)
        {
            var info = new ExpressionInfo(type);
            info.SupportedEntityTypes.AddRange(entityTypes);
            Items.Add(info.Type, info);
            return info;
        }
        #endregion

        #region Constructor
        public ExpressionInfo(ExpressionTypeEnum type)
        {
            Type = type;
        }
        #endregion
    }
}
