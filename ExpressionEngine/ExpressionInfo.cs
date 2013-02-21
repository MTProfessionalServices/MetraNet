using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine
{
    public class ExpressionInfo
    {
        #region Properties
        public static readonly Dictionary<Expression.ExpressionTypeEnum, ExpressionInfo> Items = new Dictionary<Expression.ExpressionTypeEnum, ExpressionInfo>();

        public readonly Expression.ExpressionTypeEnum Type;
        public List<VectorType.ComplexTypeEnum> SupportedEntityTypes = new List<VectorType.ComplexTypeEnum>();
        public bool SupportsAqgs { get; set; }
        public bool SupportsUqgs { get; set; }

        #endregion

        #region Static Constructor
        static ExpressionInfo()
        {
            //AQG
            var info = AddInfo(Expression.ExpressionTypeEnum.AQG, VectorType.ComplexTypeEnum.AccountView);
            info.SupportsAqgs = true;
            
            //UQG
            info = AddInfo(Expression.ExpressionTypeEnum.UQG, VectorType.ComplexTypeEnum.ProductView);
            info.SupportsUqgs = true;

            //Message
            info = AddInfo(Expression.ExpressionTypeEnum.Message, VectorType.ComplexTypeEnum.AccountView);

            //Expression
            info = AddInfo(Expression.ExpressionTypeEnum.Logic, VectorType.ComplexTypeEnum.AccountView);

            info = AddInfo(Expression.ExpressionTypeEnum.Email, VectorType.ComplexTypeEnum.AccountView);
        }


        private static ExpressionInfo AddInfo(Expression.ExpressionTypeEnum type, params VectorType.ComplexTypeEnum[] entityTypes)
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
