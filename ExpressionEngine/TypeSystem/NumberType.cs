using System;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    /// <summary>
    /// General class for numbers. NOTE that the name is intentionlly not "NumericType" because
    /// "Numeric" is a BaseType which implies every typeof NumberType. This is a very important 
    /// distinction.
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class NumberType : Type
    {
        #region Properties

        /// <summary>
        /// Indicates the unit of measure mode (fixed or driven by other property)
        /// </summary>
        [DataMember]
        public UnitOfMeasureMode UnitOfMeasureMode { get; set; }

        /// <summary>
        /// Depending on the UomMode, specifies a fixed UoM, a UoM category or the name of the property that determines the UOM.
        /// </summary>
        [DataMember]
        public string UnitOfMeasureQualifier { get; set; }

        #endregion

        #region Constructor
        public NumberType(BaseType type, UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
            : base(type)
        {
            if (!TypeHelper.IsNumeric(type))
                throw new ArgumentException("Invalid type: " + type.ToString());

            UnitOfMeasureMode = unitOfMeasureMode;
            UnitOfMeasureQualifier = unitOfMeasureQualifier;
        }
        #endregion

        #region Methods
        public new NumberType Copy()
        {
            var type = (NumberType)base.Copy();
            InternalCopy(type);
            type.UnitOfMeasureMode = UnitOfMeasureMode;
            type.UnitOfMeasureQualifier = UnitOfMeasureQualifier;
            return type;
        }
        #endregion

    }
}
