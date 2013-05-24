using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml.Serialization;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Core.Detector.Engine
{
    /// <summary>
    /// Used as container for pattern. 
    /// </summary>
    public class PatternWeightGeneric<T>
    {
        /// <summary>
        /// Pattern which is used for detect some expressions   
        /// </summary>
        [XmlAttribute(AttributeName = "Pattern")]
		[SerializePropertyAttribute]
        public T Pattern { get; set; }
        
        /// <summary>
        ///  Weight of pattern
        /// </summary>
		[XmlAttribute(AttributeName = "Weight")]
		[SerializePropertyAttribute]
        public int Weight { get; set; }
    }

    /// <summary>
    /// Used as container for pattern. Used in serialization.
    /// </summary>
    public class PatternWeight : PatternWeightGeneric<string>
    {}

    /// <summary>
    /// Used as container for pattern. Used internally in XSS detector.
    /// </summary>
    public class PatternWeightRegex : PatternWeightGeneric<Regex>
    { }
}
