#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess;

namespace MetraTech.ActivityServices.Services.Common
{
    public class PCIdentifierResolver
    {
        private static Logger m_Logger;

        static PCIdentifierResolver()
        {
            m_Logger = new Logger("Logging\\ActivityServices", "[PCIdentifierResolver]");
        }

        public static int ResolveProductOffering(PCIdentifier pcID)
        {
            return ResolveProductOffering(pcID, false);
        }

        public static int ResolveProductOffering(PCIdentifier pcID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_PRODUCTOFFERING__", "product offering", pcID, null, takeUpdateLock);
        }

        public static int ResolvePriceableItemType(PCIdentifier pcID)
        {
            return ResolvePriceableItemType(pcID, false);
        }

        public static int ResolvePriceableItemType(PCIdentifier pcID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_PITYPE__", "priceable item type", pcID, null, takeUpdateLock);
        }

        public static int ResolvePriceableItemTemplate(PCIdentifier pcID)
        {
            return ResolvePriceableItemTemplate(pcID, false);
        }

        public static int ResolvePriceableItemTemplate(PCIdentifier pcID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_PITEMPLATE__", "priceable item template", pcID, null, takeUpdateLock);
        }

        public static int ResolvePriceableItemInstance(int productOfferingId, PCIdentifier pcID)
        {
            return ResolvePriceableItemInstance(productOfferingId, pcID, false);
        }

        public static int ResolvePriceableItemInstance(int productOfferingId, PCIdentifier pcID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_PIINSTANCE__", "Priceable item instance", pcID, productOfferingId, takeUpdateLock);
        }

        public static int ResolveCalendar(PCIdentifier calendarID)
        {
            return ResolveCalendar(calendarID, false);
        }

        public static int ResolveCalendar(PCIdentifier calendarID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_CALENDAR__", "calendar", calendarID, null, takeUpdateLock);
        }

        public static int ResolveCalendarHoliday(int calendarId, PCIdentifier holidayID)
        {
            return ResolveCalendarHoliday(calendarId, holidayID, false);
        }

        public static int ResolveCalendarHoliday(int calendarId, PCIdentifier holidayID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_CALENDAR_HOLIDAY__", "calendar holiday", holidayID, calendarId, takeUpdateLock);
        }

        public static int ResolvePriceList(PCIdentifier priceListID)
        {
            return ResolvePriceList(priceListID, false);
        }

        public static int ResolvePriceList(PCIdentifier priceListID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_PRICELIST__", "pricelist", priceListID, null, takeUpdateLock);
        }

        public static int ResolvePIInstanceBySub(int subId, PCIdentifier pcID, bool takeUpdateLock)
        {
            // TODO: Hacked the query to pass the subId as the PO, need to make decision on how to handle this.
            return InternalResolveIdentifier("__RESOLVE_PIINSTANCE_BY_SUB__", "Priceable item instance", pcID, subId, takeUpdateLock);
        }

        public static int ResolveReasonCode(PCIdentifier rcID)
        {
            return ResolveReasonCode(rcID, false);
        }

        public static int ResolveReasonCode(PCIdentifier rcID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_REASON_CODE__", "Reason Code", rcID, null, takeUpdateLock);
        }

        public static int ResolveCounterType(PCIdentifier ctID)
        {
            return ResolveCounterType(ctID, false);
        }

        public static int ResolveCounterType(PCIdentifier ctID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_COUNTER_TYPE__", "Counter type", ctID, null, takeUpdateLock);
        }

        public static int ResolveCounterPropDef(PCIdentifier cpdID)
        {
            return ResolveCounterPropDef(cpdID, false);
        }

        public static int ResolveCounterPropDef(PCIdentifier cpdID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_COUNTER_PROPERTY_DEFINITION__", "Counter property definition", cpdID, null, takeUpdateLock);
        }

        public static int ResolveProductView(PCIdentifier pvID)
        {
            return ResolveProductView(pvID, false);
        }

        public static int ResolveProductView(PCIdentifier pvID, bool takeUpdateLock)
        {
            return InternalResolveIdentifier("__RESOLVE_PRODUCT_VIEW__", "Product view", pvID, null, takeUpdateLock);
        }

        private static int InternalResolveIdentifier(string queryTag, string entityName, PCIdentifier pcID, int? po_id, bool takeUpdateLock)
        {
            int retval = -1;

            string predicate;

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                if (pcID.ID.HasValue && !string.IsNullOrEmpty(pcID.Name))
                {
                    if (conn.ConnectionInfo.IsOracle)
                    {
                        predicate = string.Format("id_prop = {0} and upper(nm_name) = upper('{1}')", pcID.ID, pcID.Name);
                    }
                    else
                    {
                        predicate = string.Format("id_prop = {0} and nm_name = '{1}'", pcID.ID, pcID.Name);
                    }
                }
                else if (pcID.ID.HasValue)
                {
                    predicate = string.Format("id_prop = {0}", pcID.ID);
                }
                else if (!string.IsNullOrEmpty(pcID.Name))
                {
                    if (conn.ConnectionInfo.IsOracle)
                    {
                        predicate = string.Format(" upper(nm_name) = upper('{0}')", pcID.Name);
                    }
                    else
                    {
                        predicate = string.Format("nm_name = '{0}'", pcID.Name);
                    }
                }
                else
                {
                    throw new MASBasicException(string.Format("Must specify either {0} internal identifier or name for resolution", entityName));
                }


                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"queries\PCWS", queryTag))
                {
                    stmt.AddParam("%%PREDICATE%%", predicate, true);
                    if (po_id.HasValue)
                    {
                        stmt.AddParamIfFound("%%ID_PO%%", po_id);
                    }

                    if (takeUpdateLock && !conn.ConnectionInfo.IsOracle)
                    {
                        stmt.AddParam("%%UPDLOCK%%", "with(updlock)");
                    }
                    else
                    {
                        stmt.AddParam("%%UPDLOCK%%", "");
                    }

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            int idxIdProp = rdr.GetOrdinal("id_prop");
                            if (!rdr.IsDBNull(idxIdProp))
                            {
                                retval = rdr.GetInt32(idxIdProp);
                            }
                        }
                    }
                }
            }

            return retval;
        }

    }
}
