using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Components
{
  /// <summary>
  /// Units of measure are used to identify the magnitude of a physical quantity.
  /// They help compare quantities more reliably than simply relying on pure numbers with an
  /// implied unit of measure, which can be easily misinterpreted.
  /// Examples of units of measurement:
  ///   - Meters, kilometers, miles, yards (distance)
  ///   - Bytes, Gigabytes, Bits (digital information)
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
    public class UnitOfMeasure :  EnumValue 
    {
        #region Properties
        /// <summary>
        /// The root category to which this unit belongs. Example categories are: distance,
        /// weight, digital information, fluid volume, time, etc.
        /// The root category for a given unit is the one that includes all the units that
        /// can be converted to this one.
        /// </summary>
        public EnumCategory RootCategory { get; private set; }

        /// <summary>
        /// A mnemonic code that can be used to uniquivocally identify the unit
        /// </summary>
        [DataMember]
        public string Code { get; set; }
        public string PrintSymbol { get; set; }
        public bool IsMetric { get;  set; } 
        #endregion

        #region GUI Support Properties (should be moved in future)
        public override string Image { get { return "FixedUnitOfMeasure.png"; } }
        #endregion

        #region Constructor
        public UnitOfMeasure(EnumCategory category, string name, int id, string description) : base(category, name, id, description)
        {
        }
        #endregion
    }
}
