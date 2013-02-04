using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Need to rethink this class... only one property is used... move to BaseType? Big question is, do we need a class for basetypes or should it
    /// just be an enum
    /// </summary>
    public class BaseTypeInfo
    {
        #region Static Properties
        public static readonly BaseType[] LeafTypeFilters = new BaseType[] {
        BaseType.Any,
        BaseType.Numeric,
        BaseType.String,
        BaseType.Integer,
        BaseType.Integer32,
        BaseType.Integer64,
        BaseType.DateTime,
        BaseType._Enum,
        BaseType.Decimal,
        BaseType.Float,
        BaseType.Double,
        BaseType.Boolean,
        BaseType.Guid,
        BaseType.Binary,
        BaseType.UniqueIdentifier,
        BaseType.Charge
    };
        #endregion

        #region Properties
        public readonly BaseType Type;
        #endregion

        #region Constructor
        public BaseTypeInfo()
        {
            foreach (var type in Enum.GetValues(typeof(BaseType)))
            {

            }
        }
        #endregion

    }
}
