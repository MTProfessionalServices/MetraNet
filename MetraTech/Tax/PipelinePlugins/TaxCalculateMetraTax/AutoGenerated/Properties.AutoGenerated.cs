#region Generated using ICE (Do not modify this region)
/// Generated using ICE
/// ICE CodeGen Version: 1.0.0
#endregion
#undef ERROR_ON_NULL_GET

//////////////////////////////////////////////////////////////////////////////
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Diagnostics;
using System.Configuration;
using System.Collections.Generic;
using System.Xml;
using MetraTech.Pipeline;
using MetraTech.Interop.MTPipelineLib;
//STANDARD_ENUM_REFERENCES
using IMTSystemContext = MetraTech.Interop.SysContext.IMTSystemContext;
using IMTConfigPropSet = MetraTech.Interop.MTPipelineLib.IMTConfigPropSet;
using MTLog = MetraTech.Interop.SysContext.MTLog;
using IMTNameID = MetraTech.Interop.SysContext.IMTNameID;
using IEnumConfig = MetraTech.Interop.SysContext.IEnumConfig;
using System.Collections.ObjectModel;
//ENUM_USING

namespace MetraTech.Tax.Plugins
{
    #region Properties class
    public class Properties
    {
        #region Variables
        private PipelineProperties m_pipeline;
        private ISession m_session;
        #endregion

        #region Construction
        internal static Properties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
			PipelineProperties pipelinePrototype = PipelineProperties.CreatePrototype(log, systemContext, xmlConfig);

            return new Properties(pipelinePrototype);
        }
        internal static Properties Create(Properties prototype, ISession session)
        {
            PipelineProperties pipeline = PipelineProperties.Create(prototype.m_pipeline, session);

            return new Properties(pipeline, session);
        }
        private Properties(PipelineProperties pipeline) : this(pipeline, null) { }
        private Properties(PipelineProperties pipeline, ISession session)
        {
            m_pipeline = pipeline;
            m_session = session;
        }
        #endregion

        #region Properties
        internal ISession Session
        {
            get { return m_session; }
        }
        internal PipelineProperties Pipeline
        {
            get { return m_pipeline; }
        }
        #endregion
    }
    #endregion

    #region GeneralConfig class
    public sealed class GeneralConfig
    {
        #region General config variables
        private bool? m_shouldtaxdetailsbestored;
		private bool? m_defaultisimpliedtax;
		private string m_defaultproductcode;
		private string m_defaultroundingalgorithm;
		private int? m_defaultroundingdigits;
		//GENERAL_CONFIG_VAR
        #endregion

        #region Construction 
		private const string GeneralConfigTag = "GeneralConfig";
        private readonly string XPathToGeneralConfig = String.Format("{0}", GeneralConfigTag);
        internal GeneralConfig(IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            XmlNode generalConfigProps = xmlConfig.DocumentElement.SelectSingleNode(XPathToGeneralConfig);

            if (generalConfigProps == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' was not found in t xpath = {1}. Can not configure Plug-in. Configuration content = '{2}'"
					, GeneralConfigTag, XPathToGeneralConfig, xmlConfig.OuterXml));
            }
			
            m_shouldtaxdetailsbestored = bool.Parse(GetValueFromParameter(generalConfigProps, "ShouldTaxDetailsBeStored"));
            m_defaultisimpliedtax = bool.Parse(GetValueFromParameter(generalConfigProps, "DefaultIsImpliedTax"));
            m_defaultproductcode = (string)GetValueFromParameter(generalConfigProps, "DefaultProductCode");
            m_defaultroundingalgorithm = (string)GetValueFromParameter(generalConfigProps, "DefaultRoundingAlgorithm");
            m_defaultroundingdigits = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultRoundingDigits"));
            //GENERAL_CONFIG_ASSIGN
        }
		
		private static string GetValueFromParameter(XmlNode node, string paramName)
        {
            XmlNode childNode = node.SelectSingleNode(paramName);
            if (childNode == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' parametr name does not set into '{1}'. Section content = '{2}'"
                    , paramName, GeneralConfigTag, node.OuterXml));
            }
            return childNode.InnerText;
        }
        #endregion

        #region General Config Properties
        /// <summary>
        /// For each transaction tax, MetraNet can stored detalied information (in the t_tax_details table).  This value determines if these details are saved or not.
        /// </summary>
        internal bool? ShouldTaxDetailsBeStored
        {
            get
            {
                return m_shouldtaxdetailsbestored;
            }
        }
        /// <summary>
        /// If true, the amount already includes the tax.
        /// </summary>
        internal bool? DefaultIsImpliedTax
        {
            get
            {
                return m_defaultisimpliedtax;
            }
        }
        /// <summary>
        /// A code identifying the product.  This same code should be used in the MetraTax parameter table define the tax rate for the product.
        /// </summary>
        internal string DefaultProductCode
        {
            get
            {
                return m_defaultproductcode;
            }
        }
        /// <summary>
        /// The rounding algorithm to use.  Acceptable values are: NONE or BANK.  NONE means no rounding will be performed. BANK means banker's rounding will be performed.
        /// </summary>
        internal string DefaultRoundingAlgorithm
        {
            get
            {
                return m_defaultroundingalgorithm;
            }
        }
        /// <summary>
        /// The number of rounding digits. 0 - no rounding, 1 round to 1 digit after decimal point, 2 for 2 digits, etc.
        /// </summary>
        internal int? DefaultRoundingDigits
        {
            get
            {
                return m_defaultroundingdigits;
            }
        }
        //GENERAL_CONFIG_PROP
        #endregion
    }
    #endregion

    #region Properties Collection class
    public sealed class PropertiesCollection : IEnumerable<Properties>
    {
        private ReadOnlyCollection<ISession> m_sessions;
        private Properties m_prototype;

        public PropertiesCollection(Properties prototype, ReadOnlyCollection<ISession> sessions)
        {
            m_sessions = sessions;
            m_prototype = prototype;
        }

        public int IndexOf(Properties item)
        {
            return m_sessions.IndexOf(item.Session);
        }

        public Properties this[int index]
        {
            get
            {
                return Properties.Create(m_prototype, m_sessions[index]);
            }
        }

        public bool Contains(Properties item)
        {
            return m_sessions.Contains(item.Session);
        }

        public void CopyTo(Properties[] array, int arrayIndex)
        {
            for (int i = 0, j = arrayIndex;
                j < array.Length && i < m_sessions.Count;
                ++i, ++j)
            {
                array[j] = Properties.Create(m_prototype, m_sessions[i]);
            }
        }

        public int Count
        {
            get { return m_sessions.Count; }
        }

        public bool IsReadOnly
        {
            get { return true; }
        }

        public IEnumerator<Properties> GetEnumerator()
        {
            return new PropertiesEnumerator(this);
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return new PropertiesEnumerator(this);
        }

        public struct PropertiesEnumerator : IEnumerator<Properties>
        {
            private PropertiesCollection m_propsCol;
            private int m_index;
            private const int START = -1;

            public PropertiesEnumerator(PropertiesCollection propsCol)
            {
                m_propsCol = propsCol;
                m_index = START;
            }
            public Properties Current
            {
                get
                {
                    return m_propsCol[m_index];
                }
            }
            public void Dispose()
            {
                m_propsCol = null;
                m_index = START;
            }
            object System.Collections.IEnumerator.Current
            {
                get { return this.Current; }
            }

            public bool MoveNext()
            {
                if ((m_index + 1) <= (m_propsCol.Count - 1))
                {
                    ++m_index;
                    return true;
                }
                else
                    return false;
            }

            public void Reset()
            {
                m_index = START;
            }
        }
    }
    #endregion

    #region PipelineProperties Class
    public sealed class PipelineProperties
    {
        #region Non-Pipeline variables
        private ISession m_session;
        private IEnumConfig m_enumConfig;
        private PlugInBase.LogDelegate Log;
        #endregion

        #region Pipeline variables
        private Binding<int> m_accountid;
        private Binding<decimal> m_amount;
        private Binding<DateTime> m_invoicedate;
        private Binding<int> m_intervalid;
        private Binding<string> m_productcode;
        private Binding<bool> m_isimpliedtax;
        private Binding<string> m_roundingalgorithm;
        private Binding<int> m_roundingdigits;
        private Binding<decimal> m_federaltaxamount;
        private Binding<decimal> m_federaltaxamountrounded;
        private Binding<string> m_federaltaxname;
        private Binding<decimal> m_statetaxamount;
        private Binding<decimal> m_statetaxamountrounded;
        private Binding<string> m_statetaxname;
        private Binding<decimal> m_countytaxamount;
        private Binding<decimal> m_countytaxamountrounded;
        private Binding<string> m_countytaxname;
        private Binding<decimal> m_localtaxamount;
        private Binding<decimal> m_localtaxamountrounded;
        private Binding<string> m_localtaxname;
        private Binding<decimal> m_othertaxamount;
       private Binding<decimal> m_othertaxamountrounded;
        private Binding<string> m_othertaxname;
        private Binding<long> m_taxchargeid;
        //BINDING_ID_VAR
        #endregion

        #region Construction
        internal static PipelineProperties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
			return new PipelineProperties(log, systemContext, xmlConfig);
        }
        internal static PipelineProperties Create(PipelineProperties prototype, ISession session)
        {
            return new PipelineProperties(prototype, session);
        }
		
		private const string PipelineBinding = "PipelineBinding";
        private readonly string XPathToPipelineBinding = String.Format("{0}", PipelineBinding);
        private PipelineProperties(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            Log = log;

            //Init the enum config
            m_enumConfig = systemContext.GetEnumConfig();

            //get the nameID
            IMTNameID nameID = systemContext.GetNameID();

            XmlNode pipelineProps = xmlConfig.DocumentElement.SelectSingleNode(XPathToPipelineBinding);

            if (pipelineProps == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' was not found in t xpath = {1}. Can not configure Plug-in. Configuration content = '{2}'"
					, PipelineBinding, XPathToPipelineBinding, xmlConfig.OuterXml));
            }
			
            m_accountid = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "AccountID")));
			m_amount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "Amount")));
			m_invoicedate = new Binding<DateTime>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "InvoiceDate")));
			m_intervalid = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "IntervalID")));

            // These values do not have to be set.
            m_productcode = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "ProductCode"));
            m_isimpliedtax = CreateOptionalBindingBool(nameID, GetValueFromParameter(pipelineProps, "IsImpliedTax"));
            m_roundingalgorithm = CreateOptionalBindingString(nameID, GetValueFromParameter(pipelineProps, "RoundingAlgorithm"));
            m_roundingdigits = CreateOptionalBindingInt(nameID, GetValueFromParameter(pipelineProps, "RoundingDigits"));
			
			m_federaltaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "FederalTaxAmount")));
			m_federaltaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "FederalTaxName")));
			m_statetaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StateTaxAmount")));
			m_statetaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StateTaxName")));
			m_countytaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountyTaxAmount")));
			m_countytaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountyTaxName")));
			m_localtaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "LocalTaxAmount")));
			m_localtaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "LocalTaxName")));
			m_othertaxamount = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "OtherTaxAmount")));
			m_othertaxname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "OtherTaxName")));
			m_taxchargeid = new Binding<long>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "TaxChargeID")));

            m_federaltaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "FederalTaxAmountRounded")));
            m_statetaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StateTaxAmountRounded")));
            m_countytaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountyTaxAmountRounded")));
            m_localtaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "LocalTaxAmountRounded")));
            m_othertaxamountrounded = new Binding<decimal>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "OtherTaxAmountRounded")));

			//BINDING_ID_ASSIGN            
        }
		

        Binding<string> CreateOptionalBindingString(IMTNameID nameID, String configuredParameter)
        {
            if (configuredParameter.Length <= 0)
            {
                Binding<string> result = new Binding<string>(-1);
                result.HasID = false;
                return result;
            }

            return new Binding<string>(nameID.GetNameID(configuredParameter));
        }


        Binding<bool> CreateOptionalBindingBool(IMTNameID nameID, String configuredParameter)
        {
            if (configuredParameter.Length <= 0)
            {
                Binding<bool> result = new Binding<bool>(-1);
                result.HasID = false;
                return result;
            }

            return new Binding<bool>(nameID.GetNameID(configuredParameter));
        }


        Binding<int> CreateOptionalBindingInt(IMTNameID nameID, String configuredParameter)
        {
            if (configuredParameter.Length <= 0)
            {
                Binding<int> result = new Binding<int>(-1);
                result.HasID = false;
                return result;
            }

            return new Binding<int>(nameID.GetNameID(configuredParameter));
        }

		 private static string GetValueFromParameter(XmlNode node, string paramName)
        {
            XmlNode childNode = node.SelectSingleNode(paramName);
            if (childNode == null)
            {
                throw new ConfigurationErrorsException(String.Format("The '{0}' parametr name does not set into '{1}'. Section content = '{2}'"
                   , paramName, PipelineBinding, node.OuterXml));
            }
            return childNode.InnerText;
        }
		
        private PipelineProperties(PipelineProperties prototype, ISession session)
        {
            m_session = session;
            m_enumConfig = prototype.m_enumConfig;
            Log = prototype.Log;

            m_accountid = new Binding<int>(prototype.m_accountid.ID);
			m_amount = new Binding<decimal>(prototype.m_amount.ID);
			m_invoicedate = new Binding<DateTime>(prototype.m_invoicedate.ID);
			m_intervalid = new Binding<int>(prototype.m_intervalid.ID);
			m_productcode = new Binding<string>(prototype.m_productcode.ID);
			m_isimpliedtax = new Binding<bool>(prototype.m_isimpliedtax.ID);
			m_roundingalgorithm = new Binding<string>(prototype.m_roundingalgorithm.ID);
			m_roundingdigits = new Binding<int>(prototype.m_roundingdigits.ID);
			m_federaltaxamount = new Binding<decimal>(prototype.m_federaltaxamount.ID);
			m_federaltaxname = new Binding<string>(prototype.m_federaltaxname.ID);
			m_statetaxamount = new Binding<decimal>(prototype.m_statetaxamount.ID);
			m_statetaxname = new Binding<string>(prototype.m_statetaxname.ID);
			m_countytaxamount = new Binding<decimal>(prototype.m_countytaxamount.ID);
			m_countytaxname = new Binding<string>(prototype.m_countytaxname.ID);
			m_localtaxamount = new Binding<decimal>(prototype.m_localtaxamount.ID);
			m_localtaxname = new Binding<string>(prototype.m_localtaxname.ID);
			m_othertaxamount = new Binding<decimal>(prototype.m_othertaxamount.ID);
			m_othertaxname = new Binding<string>(prototype.m_othertaxname.ID);

            m_federaltaxamountrounded = new Binding<decimal>(prototype.m_federaltaxamountrounded.ID);
            m_statetaxamountrounded = new Binding<decimal>(prototype.m_statetaxamountrounded.ID);
            m_countytaxamountrounded = new Binding<decimal>(prototype.m_countytaxamountrounded.ID);
            m_localtaxamountrounded = new Binding<decimal>(prototype.m_localtaxamountrounded.ID);
            m_othertaxamountrounded = new Binding<decimal>(prototype.m_othertaxamountrounded.ID);

			m_taxchargeid = new Binding<long>(prototype.m_taxchargeid.ID);
			//BINDING_ID_CLONE
        }
        #endregion
	

        #region Pipeline Properties
        /// <summary>
        /// (In) This account will be examined to determine country and country zone.  This will then be used with parameter tables containing MetraTax rates and other information to determine the tax rate.
        /// </summary>
        internal int? AccountID
        {
            get
            {
                try
                {
                    if (!m_accountid.HasValue)
                    {
                        m_accountid.HasValue = true;
                        m_accountid.Value = m_session.GetIntegerProperty(m_accountid.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_accountid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_accountid.IsNull)
                    return null;
                else
                    return m_accountid.Value;
            }
            
        }
		/// <summary>
        /// (In) The amount that should be taxed.
        /// </summary>
        internal decimal? Amount
        {
            get
            {
                try
                {
                    if (!m_amount.HasValue)
                    {
                        m_amount.HasValue = true;
                        m_amount.Value = m_session.GetDecimalProperty(m_amount.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_amount.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_amount.IsNull)
                    return null;
                else
                    return m_amount.Value;
            }
            
        }
		/// <summary>
        /// (In) This is the date of the transaction.  The date is used to select the best fitting rate from the MetraTax parameter tables.
        /// </summary>
        internal DateTime? InvoiceDate
        {
            get
            {
                try
                {
                    if (!m_invoicedate.HasValue)
                    {
                        m_invoicedate.HasValue = true;
                        m_invoicedate.Value = m_session.GetDateTimeProperty(m_invoicedate.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_invoicedate.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_invoicedate.IsNull)
                    return null;
                else
                    return m_invoicedate.Value;
            }
            
        }
		/// <summary>
        /// (In) The interval ID associated with the transaction.
        /// </summary>
        internal int? IntervalID
        {
            get
            {
                try
                {
                    if (!m_intervalid.HasValue)
                    {
                        m_intervalid.HasValue = true;
                        m_intervalid.Value = m_session.GetIntegerProperty(m_intervalid.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_intervalid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_intervalid.IsNull)
                    return null;
                else
                    return m_intervalid.Value;
            }
            
        }
		/// <summary>
        /// (In) A code identifying the product.  This same code should be used in the MetraTax parameter table define the tax rate for the product.
        /// </summary>
        internal string ProductCode
        {		
            get
            {
                try
                {
                    if (m_productcode.ID == -1)
                    {
                        m_productcode.IsNull = true;
                    }
                    else if (!m_productcode.HasValue)
                    {
                        m_productcode.HasValue = true;
                        m_productcode.Value = m_session.GetStringProperty(m_productcode.ID);
                    }
                }
				#pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_productcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_productcode.IsNull)
                    return null;
                else
                    return m_productcode.Value;
            }
            
        }
		/// <summary>
        /// (In) If true, the amount already includes the tax.
        /// </summary>
        internal bool? IsImpliedTax
        {
            get
            {
                try
                {
                    if (m_isimpliedtax.ID == -1)
                    {
                        m_isimpliedtax.IsNull = true;
                    }
                    else if (!m_isimpliedtax.HasValue)
                    {
                        m_isimpliedtax.HasValue = true;
                        m_isimpliedtax.Value = m_session.GetBooleanProperty(m_isimpliedtax.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_isimpliedtax.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(PlugInBase.LogLevel.Error, "An error occurred when trying to get the isImpliedTax value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_isimpliedtax.IsNull)
                {
                    return null;
                }
                else
                {
                    return m_isimpliedtax.Value;
                }
            }
            
        }
		/// <summary>
        /// (In) The rounding algorithm to use.  Acceptable values are: NONE or BANK.  NONE means no rounding will be performed. BANK means banker's rounding will be performed.
        /// </summary>
        internal string RoundingAlgorithm
        {		
            get
            {
                try
                {
                    if (m_roundingalgorithm.ID == -1)
                    {
                        m_roundingalgorithm.IsNull = true;
                    }
                    else if (!m_roundingalgorithm.HasValue)
                    {
                        m_roundingalgorithm.HasValue = true;
                        m_roundingalgorithm.Value = m_session.GetStringProperty(m_roundingalgorithm.ID);
                    }
                }
				#pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_roundingalgorithm.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_roundingalgorithm.IsNull)
                    return null;
                else
                    return m_roundingalgorithm.Value;
            }
            
        }
		/// <summary>
        /// (In) The number of rounding digits. 0 - no rounding, 1 round to 1 digit after decimal point, 2 for 2 digits, etc.
        /// </summary>
        internal int? RoundingDigits
        {
            get
            {
                try
                {
                    if (m_roundingdigits.ID == -1)
                    {
                        m_roundingdigits.IsNull = true;
                    } 
                    else if (!m_roundingdigits.HasValue)
                    {
                        m_roundingdigits.HasValue = true;
                        m_roundingdigits.Value = m_session.GetIntegerProperty(m_roundingdigits.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_roundingdigits.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Tax.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_roundingdigits.IsNull)
                    return null;
                else
                    return m_roundingdigits.Value;
            }
            
        }
		/// <summary>
        /// (Out) The federal tax amount.
        /// </summary>
        internal decimal? FederalTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_federaltaxamount.ID, value.Value);
                m_federaltaxamount.Value = value.Value;
            }
        }
		/// <summary>
        /// (Out) The federal tax name. This comes from the configured MetraTax parameter table defining the rate.
        /// </summary>
        internal string FederalTaxName
        {		
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_federaltaxname.ID, value);
                m_federaltaxname.Value = value;
            }
        }
		/// <summary>
        /// (Out) The state tax amount.
        /// </summary>
        internal decimal? StateTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_statetaxamount.ID, value.Value);
                m_statetaxamount.Value = value.Value;
            }
        }
		/// <summary>
        /// (Out) The state tax name.
        /// </summary>
        internal string StateTaxName
        {		
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_statetaxname.ID, value);
                m_statetaxname.Value = value;
            }
        }
		/// <summary>
        /// (Out) The county tax amount.
        /// </summary>
        internal decimal? CountyTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_countytaxamount.ID, value.Value);
                m_countytaxamount.Value = value.Value;
            }
        }
		/// <summary>
        /// (Out) The county tax name.
        /// </summary>
        internal string CountyTaxName
        {		
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_countytaxname.ID, value);
                m_countytaxname.Value = value;
            }
        }
		/// <summary>
        /// (Out) The local tax amount.
        /// </summary>
        internal decimal? LocalTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_localtaxamount.ID, value.Value);
                m_localtaxamount.Value = value.Value;
            }
        }
		/// <summary>
        /// (Out) The local tax name.
        /// </summary>
        internal string LocalTaxName
        {		
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_localtaxname.ID, value);
                m_localtaxname.Value = value;
            }
        }
		/// <summary>
        /// (Out) Other tax amount.
        /// </summary>
        internal decimal? OtherTaxAmount
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_othertaxamount.ID, value.Value);
                m_othertaxamount.Value = value.Value;
            }
        }
		/// <summary>
        /// (Out) Other tax name.
        /// </summary>
        internal string OtherTaxName
        {		
            
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_othertaxname.ID, value);
                m_othertaxname.Value = value;
            }
        }

        internal decimal? FederalTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_federaltaxamountrounded.ID, value.Value);
                m_federaltaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? StateTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_statetaxamountrounded.ID, value.Value);
                m_statetaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? CountyTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_countytaxamountrounded.ID, value.Value);
                m_countytaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? LocalTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_localtaxamountrounded.ID, value.Value);
                m_localtaxamountrounded.Value = value.Value;
            }
        }

        internal decimal? OtherTaxAmountRounded
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetDecimalProperty(m_othertaxamountrounded.ID, value.Value);
                m_othertaxamountrounded.Value = value.Value;
            }
        }


		/// <summary>
        /// (Out) An index that can be used to get detailed information about the tax if tax details were stored (based on configuration).  This value is used for the column id_tax_charge in t_tax_details.
        /// </summary>
        internal long? TaxChargeID
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Tax.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetLongProperty(m_taxchargeid.ID, value.Value);
                m_taxchargeid.Value = value.Value;
            }
        }
		//BINDING_ID_PROP
        #endregion
    }
    #endregion

    #region Binding Class
    [DebuggerStepThrough]
    internal class Binding<T>
    {
        #region Protected Variables
        protected readonly int m_id;
        protected T m_value;
        protected bool m_isNull;
	protected bool m_hasValue;
        protected bool m_hasID;
        #endregion

        internal Binding(int id)
        {
            m_id = id;
            m_value = default(T);
            m_isNull = false;
            m_hasValue = false;
            m_hasID = true;
        }

        internal bool HasValue
        {
            get { return m_hasValue; }
            set { m_hasValue = value; }
        }


        internal bool HasID
        {
            get { return m_hasID; }
            set { m_hasID = value; }
        }

        internal bool IsNull
        {
            get { return m_isNull; }
            set { m_isNull = value; }
        }
        internal T Value
        {
            get { return m_value; }
            set { m_value = value; }
        }
        internal int ID
        {
            get { return m_id; }
        }

        internal virtual void Reset()
        {
            m_hasValue = false;
            m_isNull = false;
            m_value = default(T);
        }
    }
    #endregion

#if CONTAINS_ENUMS
    #region EnumBinding Class
    internal sealed class EnumBinding<T> : Binding<T>
        where T : struct
    {
    #region Private Variables
        private readonly Dictionary<int, int> m_csToDb;
        private readonly Dictionary<int, int> m_dbToCs;
        private readonly string m_enumSpace;
        private readonly string m_enumName;
        #endregion

    #region Construction
        internal EnumBinding(int id, IEnumConfig enumConfig)
            : base(id)
        {
            m_csToDb = new Dictionary<int, int>();
            m_dbToCs = new Dictionary<int, int>();

            //build the enum id mapping
            object[] attrs = typeof(T).GetCustomAttributes(typeof(MTEnumAttribute), false);

            MTEnumAttribute info = attrs[0] as MTEnumAttribute;

            m_enumSpace = info.EnumSpace;
            m_enumName = info.EnumName;

            //get the ordinal of the value in the C# enum and save it along with the db id for the enum value
            foreach (string oldEnumStr in info.OldEnumValues)
            {
                if (!oldEnumStr.Contains(":"))
                    throw new InvalidEnumAttributeException(m_enumSpace + " " + m_enumName + " has an invalid OldEnumValues value on it's MTEnumAttribute");

                string[] set = oldEnumStr.Split(':');
                int ordinal = int.Parse(set[0]);
                string strVal = set[1];

                //trim extra quotes
                strVal = strVal.Trim('"');

                //get the id from the database
                int dbId = enumConfig.GetID(m_enumSpace, m_enumName, strVal);

                //add to both forward and reverse lookup lists
                //this will use up twice as much memory (still very little compared to everything else...)
                //but it will be just as fast for forward and reverse lookups
                m_csToDb.Add(ordinal, dbId);
                m_dbToCs.Add(dbId, ordinal);
            }
        }
        #endregion

    #region Properties and Methods
        internal int GetDatabaseIDForValue(T value)
        {
            return m_csToDb[Convert.ToInt32(value)];
        }
        internal void SetUsingDatabaseID(int dbId)
        {
            m_value = (T)Enum.ToObject(typeof(T), m_dbToCs[dbId]);
        }
        internal string EnumSpace
        {
            get { return m_enumSpace; }
        }
        internal string EnumName
        {
            get { return m_enumName; }
        }
        #endregion
    }
    #endregion
#endif
}
