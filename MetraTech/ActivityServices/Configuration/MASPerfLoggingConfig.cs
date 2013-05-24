using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;

namespace MetraTech.ActivityServices.Configuration
{
    public sealed class MASPerfLoggingConfig : ConfigurationSection
    {
        [ConfigurationProperty("Services")]
        [ConfigurationCollection(typeof(MASPerfLoggingServiceCollection), AddItemName = "Service")]
        public MASPerfLoggingServiceCollection Services
        {
            get { return (MASPerfLoggingServiceCollection)this["Services"]; }
        }
    }

    #region ELements
    public sealed class MASPerfLoggingServiceCollection : ConfigurationElementCollection
    {
        public MASPerfLoggingServiceCollection()
        {
            
        }

        protected override string ElementName
        {
            get
            {
                return "Service";
            }
        }

        public override ConfigurationElementCollectionType CollectionType
        {
            get
            {
                return ConfigurationElementCollectionType.BasicMap;
            }
        }

        protected override ConfigurationElement CreateNewElement()
        {
            return new MASPerfLoggingService();
        }

        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((MASPerfLoggingService)element).Name;
        }

        public MASPerfLoggingService this[int index]
        {
            get
            {
                return (MASPerfLoggingService)BaseGet(index);
            }
            set
            {
                if (BaseGet(index) != null)
                {
                    BaseRemoveAt(index);
                }
                BaseAdd(index, value);
            }
        }

        new public MASPerfLoggingService this[string Name]
        {
            get
            {
                return (MASPerfLoggingService)BaseGet(Name);
            }
        }

        public int IndexOf(MASPerfLoggingService url)
        {
            return BaseIndexOf(url);
        }

        public void Add(MASPerfLoggingService url)
        {
            BaseAdd(url);
        }
        protected override void BaseAdd(ConfigurationElement element)
        {
            BaseAdd(element, false);
        }

        public void Remove(MASPerfLoggingService url)
        {
            if (BaseIndexOf(url) >= 0)
                BaseRemove(url.Name);
        }

        public void RemoveAt(int index)
        {
            BaseRemoveAt(index);
        }

        public void Remove(string name)
        {
            BaseRemove(name);
        }

        public void Clear()
        {
            BaseClear();
        }

    }

    public sealed class MASPerfLoggingService : ConfigurationElement
    {
        [ConfigurationProperty("name")]
        public string Name
        {
            get { return (string)base["name"]; }
            set { base["name"] = value; }
        }

        [ConfigurationProperty("enabled")]
        public bool Enabled
        {
            get { return (bool)base["enabled"]; }
            set { base["enabled"] = value; }
        }

        [ConfigurationProperty("Operations")]
        [ConfigurationCollection(typeof(MASPerfLoggingServiceCollection), AddItemName = "Operation")]
        public MASPerfLoggingOperationCollection Operations
        {
            get { return (MASPerfLoggingOperationCollection)this["Operations"]; }
        }
    }

    public sealed class MASPerfLoggingOperationCollection : ConfigurationElementCollection
    {
        protected override string ElementName
        {
            get
            {
                return "Operation";
            }
        }
        public override ConfigurationElementCollectionType CollectionType
        {
            get
            {
                return ConfigurationElementCollectionType.BasicMap;
            }
        }

        protected override ConfigurationElement CreateNewElement()
        {
            return new MASPerfLoggingOperation();
        }

        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((MASPerfLoggingOperation)element).Name;
        }

        public MASPerfLoggingOperation this[int index]
        {
            get
            {
                return (MASPerfLoggingOperation)BaseGet(index);
            }
            set
            {
                if (BaseGet(index) != null)
                {
                    BaseRemoveAt(index);
                }
                BaseAdd(index, value);
            }
        }

        new public MASPerfLoggingOperation this[string Name]
        {
            get
            {
                return (MASPerfLoggingOperation)BaseGet(Name);
            }
        }

        public int IndexOf(MASPerfLoggingOperation url)
        {
            return BaseIndexOf(url);
        }

        public void Add(MASPerfLoggingOperation url)
        {
            BaseAdd(url);
        }
        protected override void BaseAdd(ConfigurationElement element)
        {
            BaseAdd(element, false);
        }

        public void Remove(MASPerfLoggingOperation url)
        {
            if (BaseIndexOf(url) >= 0)
                BaseRemove(url.Name);
        }

        public void RemoveAt(int index)
        {
            BaseRemoveAt(index);
        }

        public void Remove(string name)
        {
            BaseRemove(name);
        }

        public void Clear()
        {
            BaseClear();
        }

    }

    public sealed class MASPerfLoggingOperation : ConfigurationElement
    {
        [ConfigurationProperty("name")]
        public string Name
        {
            get { return (string)base["name"]; }
            set { base["name"] = value; }
        }

        [ConfigurationProperty("enabled")]
        public bool Enabled
        {
            get { return (bool)base["enabled"]; }
            set { base["enabled"] = value; }
        }
    }
    #endregion
}
