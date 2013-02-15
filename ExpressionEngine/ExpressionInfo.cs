using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    public class ExpressionInfo
    {
        #region Properties
        public static readonly Dictionary<Expression.ExpressionTypeEnum, ExpressionInfo> Items = new Dictionary<Expression.ExpressionTypeEnum, ExpressionInfo>();

        public readonly Expression.ExpressionTypeEnum Type;
        public List<ComplexType.ComplexTypeEnum> SupportedEntityTypes = new List<ComplexType.ComplexTypeEnum>();
        public bool SupportsAqgs { get; set; }
        public bool SupportsUqgs { get; set; }

        #endregion

        #region Static Constructor
        static ExpressionInfo()
        {
            //AQG
            var info = AddInfo(Expression.ExpressionTypeEnum.AQG, ComplexType.ComplexTypeEnum.AccountView);
            info.SupportsAqgs = true;
            
            //UQG
            info = AddInfo(Expression.ExpressionTypeEnum.UQG, ComplexType.ComplexTypeEnum.ProductView);
            info.SupportsUqgs = true;

            //Message
            info = AddInfo(Expression.ExpressionTypeEnum.Message, ComplexType.ComplexTypeEnum.AccountView);

            //Expression
            info = AddInfo(Expression.ExpressionTypeEnum.Logic, ComplexType.ComplexTypeEnum.AccountView);

            info = AddInfo(Expression.ExpressionTypeEnum.Email, ComplexType.ComplexTypeEnum.AccountView);
        }


        private static ExpressionInfo AddInfo(Expression.ExpressionTypeEnum type, params ComplexType.ComplexTypeEnum[] entityTypes)
        {
            var info = new ExpressionInfo(type);
            info.SupportedEntityTypes.AddRange(entityTypes);
            Items.Add(info.Type, info);
            return info;
        }
        #endregion

        #region Constructor
        public ExpressionInfo(Expression.ExpressionTypeEnum type)
        {
            Type = type;
        }
        #endregion

    }
}
