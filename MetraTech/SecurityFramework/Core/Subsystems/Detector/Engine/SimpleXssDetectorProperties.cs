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
    /// Generic class for XSS Detector patterns
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class GenericSimpleXssDetectorProperties<T>
    {
        /// <summary>
        /// Contains JavaScript array of <see>PatternWeight</see> (string (or other class) and weight of this string).
		/// </summary>
		[SerializeCollectionAttribute]
        public T[] JavaScriptElementPatterns { get; set; }

        /// <summary>
        /// Contains DOM array of <see>PatternWeight</see> (string (or other class) and weight of this string).
		/// </summary>
		[SerializeCollectionAttribute]
        public T[] DomElementPatterns { get; set; }

        /// <summary>
        /// Contains HTML array of <see>PatternWeight</see> (string (or other class) and weight of this string).
		/// </summary>
		[SerializeCollectionAttribute]
        public T[] HtmlElementPatterns { get; set; }

        /// <summary>
        /// Contains HTML Event array of <see>PatternWeight</see> (string (or other class) and weight of this string).
        /// </summary>
		/// <remarks>Contains only HTML event name.</remarks>
		[SerializeCollectionAttribute]
        public T[] HtmlEventNames { get; set; }

        /// <summary>
        /// Contains Signs array of <see>PatternWeight</see> (string (or other class) and weight of this string).
		/// </summary>
		[SerializeCollectionAttribute]
        public T[] SignsPatterns { get; set; }

        /// <summary>
        /// Contains VbScript array of <see>PatternWeight</see> (string (or other class) and weight of this string).
		/// </summary>
		[SerializeCollectionAttribute]
        public T[] VbScriptPatterns { get; set; }

        /// <summary>
        /// Contains obfuscation array of <see>PatternWeight</see> (string (or other class) and weight of this string).
		/// </summary>
		[SerializeCollectionAttribute]
        public T[] ObfuscationPatterns { get; set; }
    }
	
    /// <summary>
    /// Contains a regex compiled patterns for XSS detector
    /// </summary>
    public class SimpleXssDetectorPropertiesAdapted : GenericSimpleXssDetectorProperties<PatternWeightRegex>
    {
        /// <summary>
        /// Creates an object of class from <see>SimpleXssDetectorProperties</see>
        /// </summary>
        /// <param name="engineProps"></param>
		public SimpleXssDetectorPropertiesAdapted(GenericSimpleXssDetectorProperties<PatternWeight> detectionParams)
        {
            this.JavaScriptElementPatterns =
                CreateRegexFromStrPattern(detectionParams.JavaScriptElementPatterns);

            this.DomElementPatterns = CreateRegexFromStrPattern(detectionParams.DomElementPatterns);

            this.HtmlElementPatterns = CreateRegexFromStrPattern(detectionParams.HtmlElementPatterns);

            this.HtmlEventNames = CreateRegexFromHtmlEventNames(detectionParams.HtmlEventNames);

            this.SignsPatterns = CreateRegexFromStrPattern(detectionParams.SignsPatterns);

            this.VbScriptPatterns = CreateRegexFromStrPattern(detectionParams.VbScriptPatterns);

            this.ObfuscationPatterns = CreateRegexFromStrPattern(detectionParams.ObfuscationPatterns);
        }
        
        private static PatternWeightRegex[] CreateRegexFromStrPattern(IEnumerable<PatternWeight> strPatterns)
        {
            List<PatternWeightRegex> result = new List<PatternWeightRegex>();

            if (strPatterns != null)
                foreach (PatternWeight patternWeight in strPatterns)
                {
                    result.Add(new PatternWeightRegex 
                        { Pattern = new Regex(patternWeight.Pattern, RegexOptions.Compiled)
                            , Weight = patternWeight.Weight });
                }
            return result.ToArray();
        }

        private static PatternWeightRegex[] CreateRegexFromHtmlEventNames(IEnumerable<PatternWeight> eventNames)
        {
            List<PatternWeightRegex> result = new List<PatternWeightRegex>();

            if (eventNames != null)
                foreach (PatternWeight patternWeight in eventNames)
                {
                    result.Add(new PatternWeightRegex
                    {
                        // contain Pattern is: < any_tag {event_from_names} = " or ' any code ' or "/> or other end is < / any_tag >
                        Pattern = new Regex(String.Format(@"(?i:\<\s*(\b.+?\b).*?\b{0}\s*=\s*[\""\'].+?[\""\'].*?\s*\>)"
                            , patternWeight.Pattern), RegexOptions.Compiled), Weight = patternWeight.Weight });
                }
            return result.ToArray();
        }

    }
}
