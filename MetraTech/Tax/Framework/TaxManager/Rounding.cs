using System;

namespace  MetraTech.Tax.Framework
{
    /// <summary>
    /// Rounding algorithms
    /// </summary>
    public enum RoundingAlgorithm
    {
        None,    // no rounding
        Banker   // banker's rounding
    }

    /// <summary>
    /// Implements rounding for tax.
    /// </summary>
    public class Rounding
    {
        // Logger
        private static Logger m_logger = new Logger("[MetraTax]");

        /// <summary>
        /// Given a string, returns the corresponding rounding
        /// algorithm, else throws an exception.
        /// </summary>
        /// <param name="algorithm"></param>
        /// <returns></returns>
        public static RoundingAlgorithm GetAlgorithm(String algorithm)
        {
            algorithm = algorithm.ToLower();

            if (algorithm.Equals("none"))
            {
                return RoundingAlgorithm.None;
            }
            if (algorithm.Equals("bank"))
            {
                return RoundingAlgorithm.Banker;
            }

            // Unknown algorithm
            String err = "Encounter unknown rounding algorithm '" + algorithm + "'." +
                        "Known algorithms are: 'none' and 'bank'";
            m_logger.LogError(err);
            throw new TaxException(err);
        }

        /// <summary>
        /// Round the given value to the given number of decimal places using the 
        /// given algorithm and number of decimal places desired.
        /// </summary>
        /// <param name="x"></param>
        /// <param name="algorithm"></param>
        /// <param name="numberOfDecimalPlaces"></param>
        /// <returns></returns>
        public static decimal Round(decimal x, RoundingAlgorithm algorithm, int numberOfDecimalPlaces)
        {
            // Rounding: None
            if (algorithm == RoundingAlgorithm.None)
            {
                return x;
            }

            // Check the argument numberOfDecimalPlaces.
            if (numberOfDecimalPlaces < 0)
            {
                throw new TaxException("Encountered an unexpected rounding algorithm argument for the " +
                                       "number of decimal places.  Expect this value to be >= 0, but value = " +
                                       numberOfDecimalPlaces);
            }

            // Rounding: Banker's 
            if (algorithm == RoundingAlgorithm.Banker)
            {
                return BankersRounding(x, numberOfDecimalPlaces);
            }
            
            // Unhandle algorithm enum
            throw new TaxException("Encountered unimplemented rounding algorithm: " + algorithm);
        }

        /// <summary>
        /// Banker's rounding
        /// </summary>
        /// <param name="x">number to round</param>
        /// <param name="algorithm">rounding algorithm to use</param>
        /// <param name="numberOfDecimalPlaces">the number of places to the right of the decimal point wanted</param>
        /// <returns>rounded amount</returns>
        public static decimal BankersRounding(decimal x, int numberOfDecimalPlaces)
        {
            return Math.Round(x, numberOfDecimalPlaces);
        }
    }
}
