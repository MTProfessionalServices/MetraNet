using System;
using System.Collections.Generic;
using System.ComponentModel;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;
using MetraTech.DomainModel.Enums;

namespace MetraTech.Tax.Framework.DataAccess
{

    /// <summary>
    /// This singleton class reads the contents of t_tax_vendor_params
    /// and makes the contents available to clients.  The t_tax_vendor_params
    /// contains the parameters that we need to populate when passing
    /// TaxableTransactions to vendor tax packages.
    /// </summary>
    public sealed class TaxParameterDefaultManager
    {
        private static readonly Logger m_Logger = new Logger("[TaxParameterDefaultManager]");

        /// <summary>
        /// Location where queries reside
        /// </summary>
        private const string mQueryPathConst = @"Queries\Tax";

        /// <summary>
        /// Allocate ourselves.
        /// We have a private constructor, so no one else can.
        /// </summary>
        static readonly TaxParameterDefaultManager m_instance = new TaxParameterDefaultManager();

        /// This structure contains the default TaxTransaction values
        /// for each of the supported vendors.  It will be filled by reading
        /// the t_tax_vendor_params table.
        private readonly Dictionary<TaxVendor, Dictionary<string, TaxParameter>> m_VendorDefaults =
            new Dictionary<TaxVendor, Dictionary<string, TaxParameter>>();

        /// <summary>
        /// Access TaxParameterDefaultManager.Instance to get the singleton object.
        /// Then call methods on that instance.
        /// </summary>
        public static TaxParameterDefaultManager Instance
        {
            get { return m_instance; }
        }

        /// <summary>
        /// Determine if the specified vendor requires the specified parameter name
        /// </summary>
        /// <param name="parameterName">The name of the parameter</param>
        /// <param name="taxVendor">The tax vendor e.g.TaxVendor.MetraTax</param>
        /// <returns></returns>
        public bool IsParameterAvailable(string parameterName, TaxVendor taxVendor)
        {
            m_Logger.LogDebug("IsParameterAvailable: parameterName={0}, taxVendor={1}", parameterName, taxVendor);
            return m_VendorDefaults[taxVendor].ContainsKey(parameterName);
        }

        /// <summary>
        /// Retrieve the TaxParameter object associated with the specified taxVendor and parameterName.
        /// </summary>
        /// <param name="parameterName">The name of the parameter to be fetched</param>
        /// <param name="taxVendor">The vendor of the parameter</param>
        /// <returns>TaxParameter object</returns>
        public TaxParameter GetDefaultTaxParameter(string parameterName, TaxVendor taxVendor)
        {
            m_Logger.LogDebug("GetDefaultTaxParameter: parameterName={0}, taxVendor={1}", parameterName, taxVendor);
            TaxParameter taxParameter = null;
            Dictionary<string, TaxParameter> defaultsForVendor = null;
            if (m_VendorDefaults.TryGetValue(taxVendor, out defaultsForVendor))
            {
                if (defaultsForVendor.TryGetValue(parameterName, out taxParameter))
                {
                    return taxParameter;
                }
                else
                {
                    m_Logger.LogError("parameter {0} not found for taxVendor{1}", parameterName, taxVendor);
                    return null;
                }
            }
            m_Logger.LogError("taxVendor {0} not found", taxVendor);
            return null;
        }

        /// <summary>
        /// Retrieve a Dictionary containing all of the defaults for the specified vendor.
        /// </summary>
        /// <param name="taxVendor"></param>
        /// <returns></returns>
        public Dictionary<string, TaxParameter> GetDefaultsForVendor(TaxVendor taxVendor)
        {
            m_Logger.LogDebug("GetDefaultsForVendor: taxVendor={0}", taxVendor);
            Dictionary<string, TaxParameter> defaultsForVendor = null;
            if (m_VendorDefaults.TryGetValue(taxVendor, out defaultsForVendor))
            {
                return defaultsForVendor;
            }
            m_Logger.LogError("taxVendor {0} not found", taxVendor);
            return null;
        }

        /// <summary>
        /// Retrieve the default parameter value comverted to the specified "Type" as appropriate.
        /// </summary>
        /// <typeparam name="T">The desired type of the value</typeparam>
        /// <param name="parameterName">The name of the parameter</param>
        /// <param name="taxVendor"></param>
        /// <param name="isNull">True if the value being returned is null</param>
        /// <returns></returns>
        public T GetDefaultTaxParameterValue<T>(string parameterName, TaxVendor taxVendor, out bool isNull)
        {
            m_Logger.LogDebug("GetDefaultTaxParameterValue: parameterName={0}, taxVendor={1}", parameterName, taxVendor);
            TaxParameter taxParameter = GetDefaultTaxParameter(parameterName, taxVendor);
            if (taxParameter == null)
            {
                isNull = true;
                return default(T);
            }

            if (taxParameter.ParameterValue == null)
            {
                isNull = true;
                return default(T);
            }

            isNull = false;

            return (T)taxParameter.ParameterValue;

        }

        /// <summary>
        /// This is a private constructor, meaning no outsiders have access.
        /// </summary>
        private TaxParameterDefaultManager()
        {
            // Read t_tax_vendor_params table
            IMTDataReader reader = null;
            m_Logger.LogDebug("Reading t_tax_vendor_params table.");

            try
            {
                // Use a Statement and Reader to allow for incremental access.
                IMTConnection connection = ConnectionManager.CreateConnection();
                IMTAdapterStatement statement = connection.CreateAdapterStatement(mQueryPathConst, "__GET_ALL_VENDOR_PARAMS__");

                m_Logger.LogDebug("Issuing query: " + statement.Query);
                reader = statement.ExecuteReader();

                while (reader.Read())
                {
                    int taxVendorInt = reader.GetInt32("id_vendor");
                    string parameterName = reader.GetString("tx_canonical_name");
                    string parameterTypeString = reader.GetString("tx_type");
                    string description = reader.GetString("tx_description");
                    string defaultValueString = "";
                    if (!reader.IsDBNull("tx_default"))
                    {
                        defaultValueString = reader.GetString("tx_default");
                    }

                    // convert the TaxVendor "int" into an enum value
                    TaxVendor taxVendor = (TaxVendor) EnumHelper.GetCSharpEnum(taxVendorInt);
                    
                    // convert the parameterTypeString into a "real" type
                    Type parameterType = Type.GetType(parameterTypeString) ?? GetType(parameterTypeString);

                    Object defaultValue;
                    try
                    {
                        if ((defaultValueString == null) || (defaultValueString == ""))
                        {
                            defaultValue = null;
                        }
                        else
                        {
                            var tConverter = TypeDescriptor.GetConverter(parameterType);
                            defaultValue = tConverter != null
                                               ? tConverter.ConvertFromString(defaultValueString)
                                               : DBNull.Value;
                        }
                    }
                    catch (Exception e)
                    {
                        var msg = String.Format("Could not convert default field for parameter name {0}", parameterName);
                        m_Logger.LogException(msg, e);
                        throw;
                    }

                    TaxParameter taxParameter = new TaxParameter(parameterName, description,
                        parameterType, defaultValue);

                    if (m_VendorDefaults.ContainsKey(taxVendor))
                    {
                        m_VendorDefaults[taxVendor].Add(taxParameter.ParameterName, taxParameter);
                    }
                    else
                    {
                        m_VendorDefaults[taxVendor] = new Dictionary<string, TaxParameter>();
                        m_VendorDefaults[taxVendor].Add(taxParameter.ParameterName, taxParameter);
                    }
                }
            }
            catch (Exception e)
            {
                m_Logger.LogException("unable to read table t_tax_vendor_params", e);
                throw;
            }
            finally
            {
                if (reader != null && !reader.IsClosed)
                    reader.Close();
            }

            foreach (var vendorDictionaryPair in m_VendorDefaults)
            {
                m_Logger.LogDebug("Default values for {0}", vendorDictionaryPair.Key);
                Dictionary<string, TaxParameter> currentVendorDefaults = vendorDictionaryPair.Value;
                foreach (var nameTaxParamPair in currentVendorDefaults)
                {
                    m_Logger.LogDebug(nameTaxParamPair.Value.ToString());
                }
            }
        }

        /// <summary>
        /// Given a string (that was read from the t_tax_vendor_params table describing
        /// a datatype) return the corresponding type.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        private static Type GetType(string typeName)
        {
            var type = typeName.ToLower().Trim();

            if (type.Contains("str") || type.Contains("char"))
            {
                return Type.GetType("System.String");
            }
            // Place before int
            if (type.Contains("int64") || type.Contains("bigint") || type.Contains("big") || type.Contains("long"))
            {
                return Type.GetType("System.Int64");
            }
            if (type.Contains("uint64"))
            {
                return Type.GetType("System.UInt64");
            }
            if (type.Contains("int16") || type.Contains("short"))
            {
                return Type.GetType("System.Int16");
            }
            if (type.Contains("uint"))
            {
                return Type.GetType("System.UInt32");
            }
            if (type.Contains("int"))
            {
                return Type.GetType("System.Int32");
            }
            if (type.Contains("bool"))
            {
                return Type.GetType("System.Boolean");
            }
            if (type.Contains("sbyte"))
            {
                return Type.GetType("System.SByte");
            }
            if (type.Contains("byte"))
            {
                return Type.GetType("System.Byte");
            }
            if (type.Contains("dec"))
            {
                return Type.GetType("System.Decimal");
            }
            if (type.Contains("doub"))
            {
                return Type.GetType("System.Double");
            }
            if (type.Contains("sing"))
            {
                return Type.GetType("System.Single");
            }
            if (type.Contains("date") || type.Contains("time"))
            {
                return Type.GetType("System.DateTime");
            }
            if (type.Contains("float"))
            {
                return Type.GetType("System.Float");
            }

            throw new TaxException("unexpected tx_type value " + typeName + " in t_tax_vendorparams");

        }
    }
}

