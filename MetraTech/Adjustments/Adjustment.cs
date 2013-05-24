using System;
using MetraTech;
using MetraTech.Interop.GenericCollection;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Localization;
using System.Runtime.InteropServices;
using System.Diagnostics;

[assembly: GuidAttribute("659478e9-3a7f-4de4-b7c1-b04b4920069e")]

namespace MetraTech.Adjustments 
{
	/// <summary>
	/// Summary description for Adjustment.
	/// </summary>
	/// 

  [Guid("1a6a694f-0f9a-4990-b2c9-af1f3bdd9eff")]
  [InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIDispatch)]
  public interface IAdjustment : IMTPCBase
  {

      MetraTech.Interop.MTProductCatalog.IMTPriceableItem PriceableItem
      {
          get;
          set;
      }

    IAdjustmentType  AdjustmentType
    {
      set; get;
    }

    bool IsTemplate
    {
      get;
    }
    
    IReasonCode CreateReasonCode();
    void RemoveReasonCode(int aID);
    void AddExistingReasonCode(IReasonCode aReasonCode);
    MetraTech.Interop.GenericCollection.IMTCollection GetApplicableReasonCodes();
    void SetApplicableReasonCodes(MetraTech.Interop.GenericCollection.IMTCollection aReasonCodes);
    int Save();

    //INamedBaseProperty
    [DispId(0)]
    int ID
    {
      set; get;
    }
    string GUID
    {
      set; get;
    }
    string Name
    {
      set; get;
    }
    string Description
    {
      set; get;
    }
    string DisplayName
    {
      set; get;
    }
    ILocalizedEntity DisplayNames
    {
      get;
    }
    
    //TODO: figure out attributes magic 
    //to  allow not to do it
    //IMTPCBase
    new void SetSessionContext(IMTSessionContext aCtx);
    new IMTSessionContext GetSessionContext();

    //IMTProperties
    IMTProperties Properties
    {
      get;
    }
    
  }
  [Guid("bd58ba8b-6ee4-4458-aa09-3dd99f4119ed")]
  [ClassInterface(ClassInterfaceType.None)]
  public class Adjustment : NamedBaseProperty, IAdjustment, IMTPCBase
  {
      public Adjustment()
          : base(MetraTech.Interop.MTProductCatalog.MTPCEntityType.PCENTITY_TYPE_ADJUSTMENT)
      {
          mReasonCodes = new MTCollectionClass();

          //Create and store an object to store localized display names
          PutObjectProperty("DisplayNames", new LocalizedEntity());
      }


      //Properties

      public MetraTech.Interop.MTProductCatalog.IMTPriceableItem PriceableItem
      {
          get
          {
              MetraTech.Interop.MTProductCatalog.IMTProductCatalog prodCatalog = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();

              return prodCatalog.GetPriceableItem(PriceableItemID);
          }
          set 
          {
              m_PriceableItemID = value.ID;
              m_IsTemplate = value.IsTemplate();
          }

      }

      public IAdjustmentType AdjustmentType
      {
          get
          {
              return (IAdjustmentType)GetPropertyValue("AdjustmentType");
          }
          set { PutPropertyValue("AdjustmentType", value); }
      }

      public bool IsTemplate
      {
          get
          {
              if (m_IsTemplate.HasValue)
              {
                  return m_IsTemplate.Value;
              }
              else
              {
                  throw new AdjustmentException("Priceable Item not set on Adjustment instance");
              }
          }
      }

      public int PriceableItemID
      {
          get
          {
              if (m_PriceableItemID.HasValue)
              {
                  return m_PriceableItemID.Value;
              }
              else
              {
                  throw new AdjustmentException("Priceable Item not set on Adjustment instance");
              }
          }
      }

      //Method
      public IReasonCode CreateReasonCode()
      {
          if (IsTemplate)
              throw new AdjustmentException("Adjustment not a template");
          IReasonCode code = new ReasonCode();
          code.SetSessionContext(GetSessionContext());
          mReasonCodes.Add(code);
          return code;
      }
      public void RemoveReasonCode(int aID)
      {
          int idx = 1;
          foreach (IReasonCode code in mReasonCodes)
          {
              if (code.ID == aID)
              {
                  mReasonCodes.Remove(idx);
                  return;
              }
              idx++;
          }
          return;
      }
      public void AddExistingReasonCode(IReasonCode aReasonCode)
      {
          if (!IsTemplate)
              throw new AdjustmentException("Adjustment not a template");
          IReasonCodeReader rcreader = new ReasonCodeReader();

          //if (rcreader.FindReasonCodeByName((IMTSessionContext)GetSessionContext(), aReasonCode.Name) == null)
          foreach (IReasonCode cd in mReasonCodes)
          {
              if (cd.Name == aReasonCode.Name)
                  return;
          }
          mReasonCodes.Add(aReasonCode);
      }
      public MetraTech.Interop.GenericCollection.IMTCollection GetApplicableReasonCodes()
      {
          //if(PriceableItem == null)
          //  throw new NullReferenceException("Priceable Item property is NULL");
          //if(PriceableItem != null && !PriceableItem.IsTemplate())
          //  throw new AdjustmentException("Adjustment not a template");
          return mReasonCodes;
      }
      public int Save()
      {
          AdjustmentWriter writer = new AdjustmentWriter();
          if (HasID())
              return writer.Create((IMTSessionContext)GetSessionContext(), this);
          else
          {
              writer.Update((IMTSessionContext)GetSessionContext(), this);
              return GetID();
          }
      }

      public void SetApplicableReasonCodes(MetraTech.Interop.GenericCollection.IMTCollection aColl)
      {
          mReasonCodes = aColl;
      }

      //data members
      private MetraTech.Interop.GenericCollection.IMTCollection mReasonCodes;

      private int? m_PriceableItemID = null;
      private bool? m_IsTemplate = null;
  }
}
