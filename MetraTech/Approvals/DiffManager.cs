using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using System.Xml;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Localization;

namespace MetraTech.Approvals
{
    /// <summary>
    /// Class to manage differences and serialization for Approvals
    /// </summary>
    public class DiffManager
    {
        /// <summary>
        /// Serialize an object into XML using a DataContractSerializer
        /// </summary>
        /// <param name="t"> the object to be serialized</param>
        /// <returns>the XML as a string</returns>
        public static string MarshallToXml(object t)
        {
            if (t == null)
            {
                return string.Empty;
            }
            using (var textWriter = new StringWriter())
            {
                using (var xmlWriter = new XmlTextWriter(textWriter))
                {
                    xmlWriter.Indentation = 1;
                    var serializer = new DataContractSerializer(t.GetType());
                    serializer.WriteObject(xmlWriter, t);
                }
                return textWriter.ToString();
            }
        }

        /// <summary>
        /// Deserialize an object from XML
        /// </summary>
        /// <typeparam name="T">the type of object</typeparam>
        /// <param name="reader">where to read the xml from</param>
        /// <returns>the deserialized object</returns>
        public static T UnmarshallFromXml<T>(XmlTextReader reader)
        {
            if (reader == null)
            {
                throw new ArgumentNullException("reader");
            }
            var serializer = new DataContractSerializer(typeof (T));
            return (T) serializer.ReadObject(reader, true);
        }

        /// <summary>
        /// Converts COM TimeSpan ENUM to C# timeSpan ENUM
        /// </summary>
        /// <param name="from">the COM TimeSpan ENUM</param>
        /// <returns>The C# TimeSpan ENUM</returns>
        private static ProdCatTimeSpan.MTPCDateType Convert(MTPCDateType from)
        {
            switch (from)
            {
                case MTPCDateType.PCDATE_TYPE_ABSOLUTE:
                    return ProdCatTimeSpan.MTPCDateType.Absolute;
                case MTPCDateType.PCDATE_TYPE_NEXT_BILLING_PERIOD:
                    return ProdCatTimeSpan.MTPCDateType.NextBillingPeriod;
                case MTPCDateType.PCDATE_TYPE_NO_DATE:
                    return ProdCatTimeSpan.MTPCDateType.NoDate;
                case MTPCDateType.PCDATE_TYPE_NULL:
                    return ProdCatTimeSpan.MTPCDateType.Null;
                case MTPCDateType.PCDATE_TYPE_SUBSCRIPTION_RELATIVE:
                    return ProdCatTimeSpan.MTPCDateType.SubscriptionRelative;
                default:
                    return ProdCatTimeSpan.MTPCDateType.Null;
            }
        }

        /// <summary>
        /// This method converts a COM Product Offering object into a C# DomainModel object
        /// These objects are slightly different, mind you:
        ///  The following properties only exist in C#:  SpecificationCharacteristics, GroupSubscriptionRequiresCycle, UsageCycleType
        ///  The following properties only exist in COM: nonsharedpricelist
        /// This method only deals with the main ProductOffering properties (and extension properties).  It does not deal with Priceable Items, etc.
        /// It handles enum conversion between COM and C#, as well as TimeSpan object differences.
        /// If an extension property is unable to be copied, then an exception will be thrown
        /// </summary>
        /// <param name="from">The COM Product offering object to convert from</param>
        /// <returns>The converted c# product offering object</returns>
        public static ProductOffering Convert(MTProductOffering from)
        {
            if (from == null)
            {
                return null;
            }
            var to = new ProductOffering();
            if (from.AvailabilityDate != null)
            {
                to.AvailableTimeSpan = new ProdCatTimeSpan();
                if (!from.AvailabilityDate.IsEndDateNull())
                {
                    to.AvailableTimeSpan.EndDate = from.AvailabilityDate.EndDate;
                }
                to.AvailableTimeSpan.EndDateType = Convert(from.AvailabilityDate.EndDateType);
                to.AvailableTimeSpan.EndDateOffset = from.AvailabilityDate.EndOffset;
                if (!from.AvailabilityDate.IsStartDateNull())
                {
                    to.AvailableTimeSpan.StartDate = from.AvailabilityDate.StartDate;
                }
                to.AvailableTimeSpan.StartDateType = Convert(from.AvailabilityDate.StartDateType);
                to.AvailableTimeSpan.StartDateOffset = from.AvailabilityDate.StartOffset;
                to.AvailableTimeSpan.TimeSpanId = from.AvailabilityDate.ID;
            }
            to.CanUserSubscribe = from.SelfSubscribable;
            to.PriceableItems = null;
            to.CanUserUnsubscribe = from.SelfUnsubscribable;
            if (!string.IsNullOrEmpty(from.GetCurrencyCode()))
            {
                string key = from.GetCurrencyCode();
                object value3 = EnumHelper.GetGeneratedEnumByEntry(typeof (SystemCurrencies), key);
                if (value3 != null)
                {
                    to.Currency = (SystemCurrencies) value3;
                }
                else
                {
                    throw new Exception(string.Format("Unable to convert enum for CurrencyCode {0}", key));
                }
            }
            to.Description = from.Description;
            to.DisplayName = from.DisplayName;
            if (from.EffectiveDate != null)
            {
                to.EffectiveTimeSpan = new ProdCatTimeSpan();
                if (!from.EffectiveDate.IsEndDateNull())
                {
                    to.EffectiveTimeSpan.EndDate = from.EffectiveDate.EndDate;
                }
                to.EffectiveTimeSpan.EndDateType = Convert(from.EffectiveDate.EndDateType);
                to.EffectiveTimeSpan.EndDateOffset = from.EffectiveDate.EndOffset;
                if (!from.EffectiveDate.IsStartDateNull())
                {
                    to.EffectiveTimeSpan.StartDate = from.EffectiveDate.StartDate;
                }
                to.EffectiveTimeSpan.StartDateType = Convert(from.EffectiveDate.StartDateType);
                to.EffectiveTimeSpan.StartDateOffset = from.EffectiveDate.StartOffset;
                to.EffectiveTimeSpan.TimeSpanId = from.EffectiveDate.ID;
            }
            if (from.Properties != null)
            {
                foreach (MTProperty entry in from.Properties)
                {
                    if (entry.Extended && entry.Value != null)
                    {
                        if (entry.Value is string && string.IsNullOrEmpty((string) entry.Value))
                        {
                            continue;
                        }
                        try
                        {
                            PropertyInfo pi = to.GetType().GetProperty(entry.Name,
                                                                       BindingFlags.Public | BindingFlags.IgnoreCase |
                                                                       BindingFlags.Instance);
                            if (EnumHelper.IsEnumType(pi.PropertyType))
                            {
                                // Get the generated enum based on rowset value (t_enum_data.id_enum_data)
                              int temp = 0;
                              if (System.Int32.TryParse(entry.Value.ToString(), out temp))
                              {

                                object mtEnum = EnumHelper.GetEnumByValue(Nullable.GetUnderlyingType(pi.PropertyType) ?? pi.PropertyType, entry.Value.ToString());
                               

                                if (mtEnum == null)
                                {
                                  throw new Exception("Unable to find enum");
                                }

                                pi.SetValue(to, mtEnum, null);
                              }

                            }
                            else if (pi.PropertyType.Equals(typeof (System.Boolean)) ||
                                  pi.PropertyType.Equals(typeof (Nullable<System.Boolean>)))
                              {
                                bool tmp = false;
                                if (System.Boolean.TryParse(entry.Value.ToString(), out tmp))
                                {
                                  pi.SetValue(to, entry.Value, null);
                                }
                                else
                                {
                                  string temp = entry.Value.ToString();
                                  if (temp == "Y" || temp == "1")
                                  {
                                    pi.SetValue(to, true, null);
                                  }

                                  if (temp == "N" || temp == "0")
                                  {
                                    pi.SetValue(to, false, null);
                                  }

                                }
                              }
                              else
                              {
                                pi.SetValue(to, entry.Value, null);
                              }
                        }
                        catch (Exception ex)
                        {
                            throw new Exception(
                                string.Format("Unable to copy extension prop {0}: {1}", entry.Name, ex.Message), ex);
                        }
                    }
                }
            }

            to.IsHidden = from.Hidden;
            if (from.DisplayDescriptions != null)
            {
                to.LocalizedDescriptions = new Dictionary<LanguageCode, string>();
                var local = (LocalizedEntity) from.DisplayDescriptions;
                foreach (DictionaryEntry entry in local.LanguageMappings)
                {
                    var key = (string) entry.Key;
                    if (key.Contains("-"))
                    {
                        key = key.Substring(key.IndexOf('-') + 1);
                    }
                    object value3 = EnumHelper.GetGeneratedEnumByEntry(typeof (LanguageCode), key.ToUpper());
                    if (value3 != null)
                    {
                        to.LocalizedDescriptions.Add((LanguageCode) value3, (string) entry.Value);
                    }
                    else
                    {
                        throw new Exception(string.Format("Unable to convert enum for Descriptions language {0}",
                                                          entry.Key));
                    }
                }
            }
            if (from.DisplayNames != null)
            {
                to.LocalizedDisplayNames = new Dictionary<LanguageCode, string>();
                var local = (LocalizedEntity) from.DisplayNames;
                foreach (DictionaryEntry entry in local.LanguageMappings)
                {
                    var key = (string) entry.Key;
                    if (key.Contains("-"))
                    {
                        key = key.Substring(key.IndexOf('-') + 1);
                    }
                    object value3 = EnumHelper.GetGeneratedEnumByEntry(typeof (LanguageCode), key.ToUpper());
                    if (value3 != null)
                    {
                        to.LocalizedDisplayNames.Add((LanguageCode) value3, (string) entry.Value);
                    }
                    else
                    {
                        throw new Exception(string.Format("Unable to convert enum for DisplayNames language {0}",
                                                          entry.Key));
                    }
                }
            }
            to.Name = from.Name;
            to.ProductOfferingId = from.ID;
            if (from.SubscribableAccountTypes != null)
            {
                to.SupportedAccountTypes = new List<string>(from.SubscribableAccountTypes.Count);
                foreach (string t in from.SubscribableAccountTypes)
                {
                    to.SupportedAccountTypes.Add(t);
                }
            }
            return to;
        }

        /// <summary>
        /// Diffs two objects, creating a list of differences.
        /// Both Before and After objects should be the same type, otherwise an exception will be thrown
        /// If the objects being compared are simple primitives (or strings), then we will just use existence and equality
        /// If the objects being compared are DateTime's then we will just compare everything except MS
        /// If the objects being compared are Dictionaries or Lists then we will compare the contents recursively
        /// IF the objects being compared are objects, then we will compare the object's member properties
        /// 
        /// For nested objects (objects/dictionaries/lists) we will compare the contents, not the actual pointers
        /// If the before is null, and the after is not, then we assume that the change is an Add
        /// If the after is null, and the before is not, then we assume that the change is a Remove
        /// 
        /// Note for lists, the order of the lists is important.  Each row is compared based on the order.  It is not based on existence.
        /// </summary>
        /// <param name="before">The before object to compare</param>
        /// <param name="after">The after object to compare</param>
        /// <param name="diffsOnly">If true, then the output list will only have differences, otherwise it will have all comparisons</param>
        /// <param name="prefix">Ability to prepend a prefix onto field names</param>
        /// <returns>the list of differences</returns>
        public static List<DomainModelDiff> Diff(object before, object after, bool diffsOnly, string prefix = @"")
        {
            var list = new List<DomainModelDiff>();
            if (before == null && after == null)
            {
                if (!diffsOnly && !string.IsNullOrEmpty(prefix))
                {
                    list.Add(new DomainModelDiff {Name = prefix, Different = false});
                }
                return list;
            }
            Type type;
            if (before != null)
            {
                type = before.GetType();
                if (after != null && !type.Equals(after.GetType()))
                {
                    throw new Exception("Incompatible types");
                }
            }
            else
            {
                type = after.GetType();
            }
            Type ut = Nullable.GetUnderlyingType(type) ?? type;
            if (ut.IsPrimitive || ut.IsNotPublic || ut.Equals(typeof (string)))
            {
                if ((ut.Equals(typeof (string)) && string.IsNullOrEmpty((string) before) &&
                     string.IsNullOrEmpty((string) after)))
                {
                    if (!diffsOnly)
                    {
                        list.Add(new DomainModelDiff {Name = prefix, Different = false});
                    }
                }
                else if (before == null || (ut.Equals(typeof (string)) && string.IsNullOrEmpty((string) before)))
                {
                    list.Add(new DomainModelDiff {Name = prefix, After = after, Different = true, Comment = @"Added"});
                }
                else if (after == null || (ut.Equals(typeof (string)) && string.IsNullOrEmpty((string) after)))
                {
                    list.Add(new DomainModelDiff
                                 {Name = prefix, Before = before, Different = true, Comment = @"Removed"});
                }
                else
                {
                    if (!before.Equals(after))
                    {
                        list.Add(new DomainModelDiff
                                     {
                                         Name = prefix,
                                         Before = before,
                                         After = after,
                                         Different = true,
                                         Comment = @"Modified"
                                     });
                    }
                    else if (!diffsOnly)
                    {
                        list.Add(new DomainModelDiff {Name = prefix, Before = before, After = after, Different = false});
                    }
                }
            }
            else if (ut.Equals(typeof (DateTime)))
            {
                if (before == null && after == null)
                {
                    if (!diffsOnly)
                    {
                        list.Add(new DomainModelDiff {Name = prefix, Different = false});
                    }
                }
                else if (before == null)
                {
                    list.Add(new DomainModelDiff {Name = prefix, After = after, Different = true, Comment = @"Added"});
                }
                else if (after == null)
                {
                    list.Add(new DomainModelDiff
                                 {Name = prefix, Before = before, Different = true, Comment = @"Removed"});
                }
                else
                {
                    var ld = (DateTime) before;
                    var rd = (DateTime) after;
                    if (!ld.ToString("yyyymmddHH24miss").Equals(rd.ToString("yyyymmddHH24miss")))
                    {
                        list.Add(new DomainModelDiff
                                     {
                                         Name = prefix,
                                         Before = before,
                                         After = after,
                                         Different = true,
                                         Comment = @"Modified"
                                     });
                    }
                }
            }
            else if (ut.IsGenericType && ut.GetGenericTypeDefinition().Equals(typeof (Dictionary<,>)))
            {
                var myCopy = new Dictionary<object, object>();
                IEnumerable iel = null;
                if (before != null)
                {
                    iel = (IEnumerable) before;
                }
                IEnumerable ier = null;
                if (after != null)
                {
                    ier = (IEnumerable) after;
                }
                if (iel != null)
                {
                    foreach (object el in iel)
                    {
                        myCopy.Add(el.GetType().GetProperty("Key").GetValue(el, null),
                                   el.GetType().GetProperty("Value").GetValue(el, null));
                    }
                }
                if (ier != null)
                {
                    foreach (object er in ier)
                    {
                        object key = er.GetType().GetProperty("Key").GetValue(er, null);
                        object value = er.GetType().GetProperty("Value").GetValue(er, null);
                        if (myCopy.ContainsKey(key))
                        {
                            list.AddRange(Diff(myCopy[key], value, diffsOnly, prefix + @"/" + key));
                            myCopy.Remove(key);
                        }
                        else
                        {
                            list.Add(new DomainModelDiff
                                         {
                                             Name = prefix + "@/" + key,
                                             After = value,
                                             Different = true,
                                             Comment = @"Added"
                                         });
                        }
                    }
                }
                foreach (var entry in myCopy)
                {
                    list.Add(new DomainModelDiff
                                 {
                                     Name = prefix + @"/" + entry.Key,
                                     After = entry.Value,
                                     Different = true,
                                     Comment = @"Removed"
                                 });
                }
            }
            else if (ut.IsGenericType && ut.GetGenericTypeDefinition().Equals(typeof (List<>)))
            {
                // NOTE: for lists, we assume order is important, and not existence
                IEnumerable iel = null;
                if (before != null)
                {
                    iel = (IEnumerable) before;
                }
                IEnumerable ier = null;
                if (after != null)
                {
                    ier = (IEnumerable) after;
                }
                IEnumerator ie = null;
                if (ier != null)
                {
                    ie = ier.GetEnumerator();
                }
                int rcount = -1;
                int lcount = -1;
                if (iel != null)
                {
                    foreach (object el in iel)
                    {
                        lcount++;
                        if (ie != null && ie.MoveNext())
                        {
                            rcount++;
                            object er = ie.Current;
                            list.AddRange(Diff(el, er, diffsOnly, prefix + @"[" + lcount + @"]"));
                        }
                        else
                        {
                            list.Add(new DomainModelDiff
                                         {
                                             Name = prefix + @"[" + lcount + @"]",
                                             Before = el,
                                             Different = true,
                                             Comment = @"Removed"
                                         });
                        }
                    }
                }
                while (ie != null && ie.MoveNext())
                {
                    rcount++;
                    list.Add(new DomainModelDiff
                                 {
                                     Name = prefix + @"[" + rcount + @"]",
                                     After = ie.Current,
                                     Different = true,
                                     Comment = @"Added"
                                 });
                }
            }
            else
            {
                // TODO: cache all this stuff
                foreach (PropertyInfo p in ut.GetProperties())
                {
                    bool ignore = false;
                    foreach (object x in p.GetCustomAttributes(typeof (ScriptIgnoreAttribute), true))
                    {
                        ignore = true;
                    }
                    foreach (object x in p.GetCustomAttributes(typeof (MTPropertyLocalizationAttribute), true))
                    {
                        ignore = true;
                    }
                    if (ignore)
                    {
                        continue;
                    }
                    object l = null;
                    object r = null;
                    if (before != null)
                    {
                        l = p.GetValue(before, null);
                    }
                    if (after != null)
                    {
                        r = p.GetValue(after, null);
                    }
                    list.AddRange(Diff(l, r, diffsOnly, string.IsNullOrEmpty(prefix) ? p.Name : (prefix + @"/" + p.Name)));
                }
            }
            return list;
        }
    }

    /// <summary>
    /// DomainModelDiff holds individual differences
    /// </summary>
    [DataContract]
    [Serializable]
    public class DomainModelDiff : BaseObject
    {
        /// <summary>
        /// The name of the property (can be nested name)
        /// </summary>
        [DataMember(IsRequired = true, EmitDefaultValue = false)]
        [MTDataMember(IsRequired = true, Length = 100, Description = "The name of the property (can be nested name)",
            MsixType = "string")]
        public string Name { get; set; }

        /// <summary>
        /// The before value
        /// </summary>
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        [MTDataMember(IsRequired = false, Description = "The before value", MsixType = "object")]
            public object Before { get; set; }

        /// <summary>
        /// The after value
        /// </summary>
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        [MTDataMember(IsRequired = false, Description = "The after value", MsixType = "object")]
            public object After { get; set; }

        /// <summary>
        /// Are the values different
        /// </summary>
        [DataMember(IsRequired = true, EmitDefaultValue = false)]
        [MTDataMember(IsRequired = true, Description = "Are the values different", MsixType = "bool")]
            public bool Different { get; set; }

        /// <summary>
        /// A comment on the difference.  This will usually be empty if the values are the same, and either Added/Removed/Modified if they are different.
        /// </summary>
        [DataMember(IsRequired = false, EmitDefaultValue = false)]
        [MTDataMember(IsRequired = false, Description = "A comment on the difference", MsixType = "string", Length = 100
            )]
            public string Comment { get; set; }
    }
}