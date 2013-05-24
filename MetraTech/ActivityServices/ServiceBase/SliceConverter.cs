#pragma warning disable 1591  // Disable XML Doc warning for now.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BILL = MetraTech.DomainModel.Billing;
using HR = MetraTech.Interop.MTHierarchyReports;
using System.Reflection;
using MetraTech.DomainModel.Billing;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Common;

namespace MetraTech.ActivityServices.Services.Common
{
    public static class SliceConverter
    {
        public static HR.IViewSlice ConvertSlice(BaseSlice slice)
        {

             if (slice.GetType() == typeof(BILL.DateRangeSlice))
            {
                BILL.DateRangeSlice pSlice = slice as BILL.DateRangeSlice;
                HR.DateRangeSlice drSlice = new HR.DateRangeSlice();
                drSlice.Begin = pSlice.Begin;
                drSlice.End = pSlice.End;
                return drSlice;
            }
            else if (slice.GetType() == typeof(BILL.IntersectionSlice))
            {
                BILL.IntersectionSlice pSlice = slice as BILL.IntersectionSlice;
                HR.IntersectionTimeSlice iSlice = new HR.IntersectionTimeSlice();
                iSlice.LHS = SliceConverter.ConvertSlice(pSlice.LeftHandSide) as HR.ITimeSlice;
                iSlice.RHS =  SliceConverter.ConvertSlice(pSlice.RighHandSide) as HR.ITimeSlice;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.UsageIntervalSlice))
            {
                BILL.UsageIntervalSlice pSlice = slice as BILL.UsageIntervalSlice;
                HR.UsageIntervalSlice iSlice = new HR.UsageIntervalSlice();
                iSlice.IntervalID = pSlice.UsageInterval;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.CurrentAccountIntervalSlice))
            {
                BILL.CurrentAccountIntervalSlice pSlice = slice as BILL.CurrentAccountIntervalSlice;

                int id_acc = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.AccountId);

                if (id_acc == -1)
                {
                    throw new MASBasicException("Invalid account specified in CurrentAccountIntervalSlice");
                }

                HR.UsageIntervalSlice iSlice = new HR.UsageIntervalSlice();
                iSlice.IntervalID = GetCurrentAccountInterval(id_acc);
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.PriceableItemInstanceSlice))
            {
                BILL.PriceableItemInstanceSlice pSlice = slice as BILL.PriceableItemInstanceSlice;
                HR.PriceableItemInstanceSlice iSlice = new HR.PriceableItemInstanceSlice();
                
                int poid = PCIdentifierResolver.ResolveProductOffering(pSlice.POInstanceID);
                if (poid == -1)
                {
                    throw new MASBasicException("Invalid Product Offering specified in PriceableItemInstanceSlice");
                }

                int piid = PCIdentifierResolver.ResolvePriceableItemInstance(poid, pSlice.PIInstanceID);

                if (piid == -1)
                {
                    throw new MASBasicException("Invalid Priceable Item Instance specified in PriceableItemInstanceSlice");
                }

                int viewid = PCIdentifierResolver.ResolveProductView(pSlice.ViewID);
                if (viewid == -1)
                {
                    throw new MASBasicException("Invalid Product View specified in PriceableItemInstanceSlice");
                } 
                
                iSlice.InstanceID = piid;
                iSlice.ViewID = viewid;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.PriceableItemTemplateSlice))
            {
                BILL.PriceableItemTemplateSlice pSlice = slice as BILL.PriceableItemTemplateSlice;
                HR.PriceableItemTemplateSlice iSlice = new HR.PriceableItemTemplateSlice();

                int ptid = PCIdentifierResolver.ResolvePriceableItemTemplate(pSlice.PITemplateID);
                if (ptid == -1)
                {
                    throw new MASBasicException("Invalid Priceable Item Template specified in PriceableItemTemplateSlice");
                }

                int viewid = PCIdentifierResolver.ResolveProductView(pSlice.ViewID);
                if (viewid == -1)
                {
                    throw new MASBasicException("Invalid Product View specified in PriceableItemTemplateSlice");
                }
                
                iSlice.TemplateID = ptid;
                iSlice.ViewID = viewid;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.ProductViewSlice))
            {
                BILL.ProductViewSlice pSlice = slice as BILL.ProductViewSlice;
                HR.ProductViewSlice iSlice = new HR.ProductViewSlice();
                int viewid = PCIdentifierResolver.ResolveProductView(pSlice.ViewID);
                if (viewid == -1)
                {
                    throw new MASBasicException("Invalid Product View specified in ProductViewSlice");
                }
                
                iSlice.ViewID = viewid;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.ProductViewAllUsageSlice))
            {
                BILL.ProductViewAllUsageSlice pSlice = slice as BILL.ProductViewAllUsageSlice;
                HR.ProductViewAllUsageSlice iSlice = new HR.ProductViewAllUsageSlice();
                int viewid = PCIdentifierResolver.ResolveProductView(pSlice.ViewID);
                if (viewid == -1)
                {
                    throw new MASBasicException("Invalid Product View specified in ProductViewAllUsageSlice");
                }
                
                iSlice.ViewID = viewid;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.PayerAccountSlice))
            {
                BILL.PayerAccountSlice pSlice = slice as BILL.PayerAccountSlice;
                HR.PayerSlice iSlice = new HR.PayerSlice();
                int payerId = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.PayerID);
                if (payerId == -1)
                {
                    throw new MASBasicException("Invalid payer account specified in PayerAccountSlice");
                }
                iSlice.PayerID = payerId; 
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.PayeeAccountSlice))
            {
                BILL.PayeeAccountSlice pSlice = slice as BILL.PayeeAccountSlice;
                HR.PayeeSlice iSlice = new HR.PayeeSlice();
                int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.PayeeID);
                if (payeeId == -1)
                {
                    throw new MASBasicException("Invalid payee account specified in PayeeAccountSlice");
                }
                iSlice.PayeeID = payeeId;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.PayerAndPayeeSlice))
            {
                BILL.PayerAndPayeeSlice pSlice = slice as BILL.PayerAndPayeeSlice;
                HR.PayerAndPayeeSlice iSlice = new HR.PayerAndPayeeSlice();
                int payerId = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.PayerAccountId);
                if (payerId == -1)
                {
                    throw new MASBasicException("Invalid payer account specified in PayerAndPayeeAccountSlice");
                }
                
                int payeeId = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.PayeeAccountId);
                if (payeeId == -1)
                {
                    throw new MASBasicException("Invalid payee account specified in PayerAndPayeeAccountSlice");
                }
                
                iSlice.PayeeID = payeeId;
                iSlice.PayerID = payerId;
                return iSlice;
            }
            else if (slice.GetType() == typeof(BILL.DescendentPayeeSlice))
            {
                BILL.DescendentPayeeSlice pSlice = slice as BILL.DescendentPayeeSlice;
                HR.DescendentPayeeSlice iSlice = new HR.DescendentPayeeSlice();
                int acctId = AccountIdentifierResolver.ResolveAccountIdentifier(pSlice.AncestorAccountId);
                if (acctId == -1)
                {
                    throw new MASBasicException("Invalid account specified in DescendentPayeeSlice");
                }
                
                iSlice.AncestorID = acctId;
                iSlice.Begin = pSlice.StartDate;
                iSlice.End = pSlice.EndDate;
                return iSlice;
            }
            else
            {
                throw new NotImplementedException();
            }

        }

        public static BaseSlice ConvertSlice(HR.IViewSlice slice)
        {

            HR.DateRangeSlice hrDRSlice = slice as HR.DateRangeSlice;
            if (hrDRSlice != null)
            {
                BILL.DateRangeSlice drSlice = new BILL.DateRangeSlice();
                drSlice.Begin = hrDRSlice.Begin;
                drSlice.End = hrDRSlice.End;
                return drSlice;
            }

            HR.IntersectionTimeSlice hrITSlice = slice as HR.IntersectionTimeSlice;
            if (hrITSlice != null)
            {
                BILL.IntersectionSlice iSlice = new BILL.IntersectionSlice();
                iSlice.LeftHandSide = SliceConverter.ConvertSlice(hrITSlice.LHS) as BILL.IntersectionSlice;
                iSlice.RighHandSide = SliceConverter.ConvertSlice(hrITSlice.RHS) as BILL.IntersectionSlice;
                return iSlice;
            }

            HR.UsageIntervalSlice hrUISlice = slice as HR.UsageIntervalSlice;
            if (hrUISlice != null)
            {
                BILL.UsageIntervalSlice iSlice = new BILL.UsageIntervalSlice();
                iSlice.UsageInterval = hrUISlice.IntervalID;
                return iSlice;
            }

            HR.PriceableItemInstanceSlice hrPIISlice = slice as HR.PriceableItemInstanceSlice;
            if (hrPIISlice != null)
            {
                BILL.PriceableItemInstanceSlice iSlice = new BILL.PriceableItemInstanceSlice();

                iSlice.PIInstanceID = new PCIdentifier(hrPIISlice.InstanceID);
                iSlice.ViewID = new PCIdentifier(hrPIISlice.ViewID, hrPIISlice.ProductView.Name);

                using (IMTConnection conn = ConnectionManager.CreateConnection())
                {
                    using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement("select distinct id_po from t_pl_map where id_pi_instance = ? and id_paramtable is null"))
                    {
                        prepStmt.AddParam(MTParameterType.Integer, hrPIISlice.InstanceID);

                        using (IMTDataReader rdr = prepStmt.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                iSlice.POInstanceID = new PCIdentifier(rdr.GetInt32(0));
                            }
                            else
                            {
                                throw new MASBasicException("Unable to locate Product Offering for Priceable Item Instance");
                            }
                        }
                    }
                }

                return iSlice;
            }

            HR.PriceableItemTemplateSlice hrPITSlice = slice as HR.PriceableItemTemplateSlice;
            if (hrPITSlice != null)
            {
                BILL.PriceableItemTemplateSlice iSlice = new BILL.PriceableItemTemplateSlice();

                iSlice.PITemplateID = new PCIdentifier(hrPITSlice.TemplateID);
                iSlice.ViewID = new PCIdentifier(hrPITSlice.ViewID, hrPITSlice.ProductView.Name);

                return iSlice;
            }
            
            HR.ProductViewSlice hrPVSlice = slice as HR.ProductViewSlice;
            if (hrPVSlice != null)
            {
                BILL.ProductViewSlice iSlice = new BILL.ProductViewSlice();
                iSlice.ViewID = new PCIdentifier(hrPVSlice.ViewID, hrPVSlice.ProductView.Name);
                return iSlice;
            }
            
            HR.ProductViewAllUsageSlice hrPVAUSlice = slice as HR.ProductViewAllUsageSlice;
            if (hrPVAUSlice != null)
            {
                BILL.ProductViewAllUsageSlice iSlice = new BILL.ProductViewAllUsageSlice();
                iSlice.ViewID = new PCIdentifier(hrPVAUSlice.ViewID, hrPVAUSlice.ProductView.Name);
                return iSlice;
            }
            
            HR.PayerSlice hrPayerSlice = slice as HR.PayerSlice;
            if (hrPayerSlice != null)
            {
                BILL.PayerAccountSlice iSlice = new BILL.PayerAccountSlice();
                iSlice.PayerID = new AccountIdentifier(hrPayerSlice.PayerID);
                return iSlice;
            }
            
            HR.PayeeSlice hrPayeeSlice = slice as HR.PayeeSlice;
            if (hrPayeeSlice != null)
            {
                BILL.PayeeAccountSlice iSlice = new BILL.PayeeAccountSlice();
                iSlice.PayeeID = new AccountIdentifier(hrPayeeSlice.PayeeID);
                return iSlice;
            }
            
            HR.PayerAndPayeeSlice hrPPSlice = slice as HR.PayerAndPayeeSlice;
            if (hrPPSlice != null)
            {
                BILL.PayerAndPayeeSlice iSlice = new BILL.PayerAndPayeeSlice();
                iSlice.PayeeAccountId = new AccountIdentifier(hrPPSlice.PayeeID);
                iSlice.PayerAccountId = new AccountIdentifier(hrPPSlice.PayerID);
                return iSlice;
            }
            
            HR.DescendentPayeeSlice hrDPSlice = slice as HR.DescendentPayeeSlice;
            if (hrDPSlice != null)
            {
                BILL.DescendentPayeeSlice iSlice = new BILL.DescendentPayeeSlice();
                iSlice.AncestorAccountId = new AccountIdentifier(hrDPSlice.AncestorID);
                iSlice.StartDate = hrDPSlice.Begin;
                iSlice.EndDate = hrDPSlice.End;
                return iSlice;
            }

            throw new NotImplementedException();
        }

        public static int GetCurrentAccountInterval(int id_acc)
        {
            int actualInterval = -1;

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTPreparedStatement prepStmt = conn.CreatePreparedStatement("select id_usage_interval from t_acc_usage_interval aui inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval where  id_acc = ? and ? between dt_start and dt_end"))
                {
                    prepStmt.AddParam(MTParameterType.Integer, id_acc);
                    prepStmt.AddParam(MTParameterType.DateTime, MetraTime.Now);

                    using (IMTDataReader rdr = prepStmt.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            actualInterval = rdr.GetInt32(0);
    }
}
                }
            }

            return actualInterval;
        }

        public static string ToString(BaseSlice slice)
        {
            string retval = string.Empty;

            HR.IViewSlice viewSlice = ConvertSlice(slice);

            retval = viewSlice.ToStringUnencrypted();

            return retval;
        }

        public static T FromString<T>(string sliceString) where T : BaseSlice
        {
            T retval = default(T);

            HR.ISliceFactory sliceFactory = new HR.SliceFactoryClass();
            HR.SliceLexer sliceLexer = new HR.SliceLexerClass();
            sliceLexer.Init(sliceString);

            HR.IViewSlice viewSlice = sliceFactory.GetSlice(sliceLexer);

            retval = ConvertSlice(viewSlice) as T;

            if (retval == null)
            {
                throw new MASBasicException("Slice string doesn't match specified slice type");
            }

            return retval;
        }
    }
}
