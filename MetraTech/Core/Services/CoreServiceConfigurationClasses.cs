using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.ServiceModel.Configuration;

namespace MetraTech.Core.Services
{
    #region Service Configuration Sections
    public sealed class EPSConfig : ConfigurationSection
    {
        public string HostName
        {
            get { return MetraPayHost.HostName; }
        }

        public int Port
        {
            get { return MetraPayHost.Port; }
        }

        public string ServerDNSIdentity
        {
            get { return MetraPayHost.ServerDNSIdentity; }
        }

        public string MTAccountRequired
        {
            get { return MetraNetAccount.Required; }
        }

        public string LogRecord
        {
            get { return MetraPayLog.LogRecord; }
        }


        public string ArPmtImplType
        {
            get { return ArPayImplementation.Type; }
        }
    
        public int MaxOpenTransactions
        {
            get { return OpenTransactions.MaxOpenTransactions; }
        }

        public int RecheckDatabaseInterval
        {
            get { return OpenTransactions.RecheckDatabaseInterval; }
        }

        public double DefaultTransactionTimeOut
        {
            get { return OpenTransactions.DefaultTransactionTimeout; }
        }

        public float TimeOutStepDown
        {
            get { return OpenTransactions.TimeoutStepDown; }
        }

        [ConfigurationProperty("MetraPayHost")]
        public MetraPayHostConfigElement MetraPayHost
        {
            get { return ((MetraPayHostConfigElement)this["MetraPayHost"]); }
        }

        [ConfigurationProperty("ServiceCertificate")]
        public CertificateReferenceElement ServiceCertificate
        {
            get { return (CertificateReferenceElement)this["ServiceCertificate"]; }
        }

        [ConfigurationProperty("MetraNetAccount")]
        public MetraNetAccountConfigElement MetraNetAccount
        {
            get { return (MetraNetAccountConfigElement)this["MetraNetAccount"]; }
        }

        [ConfigurationProperty("MetraPayLog")]
        public MetraPayLogConfigElement MetraPayLog
        {
            get { return (MetraPayLogConfigElement)this["MetraPayLog"]; }
        }

        [ConfigurationProperty("ArPayImplementation")]
        public ArPayImplementationConfigElement ArPayImplementation
        {
            get { return (ArPayImplementationConfigElement)this["ArPayImplementation"]; }
        }

        [ConfigurationProperty("OpenTransactions")]
        public OpenTransactionsConfigElement OpenTransactions
        {
            get { return (OpenTransactionsConfigElement)this["OpenTransactions"]; }
        }
    }

    public sealed class AccountTemplateServiceConfigSection : ConfigurationSection
    {
        [ConfigurationProperty("ThreadPoolSize")]
        public int ThreadPoolSize { get { return ((int)this["ThreadPoolSize"]); } }

        [ConfigurationProperty("MaxConcurrentUpdatesPerThread")]
        public int MaxConcurrentUpdatesPerThread { get { return ((int)this["MaxConcurrentUpdatesPerThread"]); } }

        [ConfigurationProperty("ClientTimoutMinutes")]
        public int ClientTimoutMinutes { get { return ((int)this["ClientTimoutMinutes"]); } }

        [ConfigurationProperty("AllTypesAccountTypeName")]
        public string AllTypesAccountTypeName { get { return ((string)this["AllTypesAccountTypeName"]); } }
    }

    public sealed class AccountServiceConfigSection : ConfigurationSection
    {
        [ConfigurationProperty("GetAccountListMaxPages")]
        public int GetAccountListMaxPages { get { return ((int)this["GetAccountListMaxPages"]); } }

        //ESR-5877 add GetAccountListTimeOut configuration
        [ConfigurationProperty("GetAccountListTimeOut")]
        public int GetAccountListTimeOut { get { return ((int)this["GetAccountListTimeOut"]); } }

    }
    #endregion

    #region Supporting Configuration Elements
    public sealed class OpenTransactionsConfigElement : ConfigurationElement
    {
        [ConfigurationProperty("MaxOpenTransactions", IsRequired = true)]
        public int MaxOpenTransactions
        {
            get { return Convert.ToInt16(this["MaxOpenTransactions"]); }
            set { this["MaxOpenTransactions"] = value; }
        }

        [ConfigurationProperty("RecheckDatabaseInterval", IsRequired = true)]
        public int RecheckDatabaseInterval
        {
            get { return Convert.ToInt16(this["RecheckDatabaseInterval"]); }
            set { this["RecheckDatabaseInterval"] = value; }
        }

        [ConfigurationProperty("DefaultTransactionTimeout", IsRequired = true)]
        public double DefaultTransactionTimeout
        {
            get { return Convert.ToInt64(this["DefaultTransactionTimeout"]); }
            set { this["DefaultTransactionTimeout"] = value; }
        }

        [ConfigurationProperty("TimeoutStepDown", IsRequired = true)]
        public float TimeoutStepDown
        {
            get { return Convert.ToInt32(this["TimeoutStepDown"]); }
            set { this["TimeoutStepDown"] = value; }
        }
    }
    public sealed class ArPayImplementationConfigElement : ConfigurationElement
    {

        [ConfigurationProperty("Type", IsRequired = true)]
        public string Type
        {
            get { return (string)this["Type"]; }
            set { this["Type"] = value; }
        }

        [ConfigurationProperty("RaiseError", IsRequired = true)]
        public bool RaiseError
        {
            get { return Convert.ToBoolean(this["RaiseError"]); }
            set { this["RaiseError"] = value; }
        }

    }

    public sealed class MetraPayLogConfigElement : ConfigurationElement
    {
        [ConfigurationProperty("LogRecord", IsRequired = true)]
        public string LogRecord
        {
            get { return (string)this["LogRecord"]; }
            set { this["LogRecord"] = value; }
        }
    }

    public sealed class MetraPayHostConfigElement : ConfigurationElement
    {
        [ConfigurationProperty("HostName", IsRequired = true)]
        public string HostName
        {
            get { return (string)this["HostName"]; }
            set { this["HostName"] = value; }
        }

        [ConfigurationProperty("Port", IsRequired = true)]
        public int Port
        {
            get { return (int)this["Port"]; }
            set { this["Port"] = value; }
        }

        [ConfigurationProperty("ServerDNSIdentity", IsRequired = true)]
        public string ServerDNSIdentity
        {
            get { return (string)this["ServerDNSIdentity"]; }
            set { this["ServerDNSIdentity"] = value; }
        }

    }

    public sealed class MetraNetAccountConfigElement : ConfigurationElement
    {
        [ConfigurationProperty("Required", IsRequired = true)]
        public string Required
        {
            get { return (string)this["Required"]; }
            set { this["Required"] = value; }
        }

    }
    #endregion
}
