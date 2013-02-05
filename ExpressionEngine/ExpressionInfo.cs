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
        public List<Entity.EntityTypeEnum> SupportedEntityTypes = new List<Entity.EntityTypeEnum>();
        public bool SupportsAqgs { get; set; }
        public bool SupportsUqgs { get; set; }

        #endregion

        #region Static Constructor
        static ExpressionInfo()
        {
            //AQG
            var info = AddInfo(Expression.ExpressionTypeEnum.AQG, Entity.EntityTypeEnum.AccountType);
            info.SupportsAqgs = true;
            
            //UQG
            info = AddInfo(Expression.ExpressionTypeEnum.UQG, Entity.EntityTypeEnum.ProductView);
            info.SupportsUqgs = true;

            //Message
            info = AddInfo(Expression.ExpressionTypeEnum.Message, Entity.EntityTypeEnum.AccountView);
        }


        private static ExpressionInfo AddInfo(Expression.ExpressionTypeEnum type, params Entity.EntityTypeEnum[] entityTypes)
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
