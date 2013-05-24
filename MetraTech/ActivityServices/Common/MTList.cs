using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.IO;
using Microsoft.Win32;

namespace MetraTech.ActivityServices.Common
{
  #region Public Enums
  public enum SortType
  {
    Ascending,
    Descending
  }
  #endregion

  [DataContract(Name="MTListOf{0}")]
  [Serializable]
  public class MTList<T>
  {
        public MTList()
        {
        }

    #region Public Properties
    // Total number of rows returned by the query
    [DataMember(IsRequired = false, EmitDefaultValue = true)]
    public int TotalRows 
    { 
      get { return m_TotalRows; }
      set { m_TotalRows = value; }
    }

    public List<T> Items
    {
        get
        {
            if (m_Items == null)
            {
                m_Items = new List<T>();
            }
            return m_Items;
        }
    }

    // If CurrentPage or PageSize are -1 then all entries are returned without paging
    // PageSize specifies how many records, CurrentPage specifies where to start
    [DataMember(EmitDefaultValue=false, IsRequired=false)]
    public int CurrentPage
        {
            get { return m_CurrentPage; }
      set { m_CurrentPage = value; }
    }

    [DataMember(EmitDefaultValue = false, IsRequired = false)]
    public int PageSize 
    {
      get { return m_PageSize; }
      set { m_PageSize = value; }
    }

    // List of filter elements to restrict records being returned
        public List<MTBaseFilterElement> Filters
    {
      get 
      {
          if (m_FilterElements == null)
          {
              m_FilterElements = new List<MTBaseFilterElement>();
          }
          
          return m_FilterElements; 
      }

      set { m_FilterElements = value; }
    }

    // Sorting controls
        // Each SortCriteria must reference a property on the class T; setter will validate using reflection
        public List<SortCriteria> SortCriteria
        {
            get
            {
                if (m_SortCriteria == null)
                {
                    m_SortCriteria = new List<SortCriteria>();
                }

                return m_SortCriteria;
            }
            set { m_SortCriteria = value; }
        }
    #endregion

    #region Private Members
    
    private int m_TotalRows = 0;
    private int m_CurrentPage = 0;
    private int m_PageSize = 0;

    [DataMember(EmitDefaultValue = false, IsRequired = false)]
    private List<T> m_Items = new List<T>();

    [DataMember(EmitDefaultValue = false, IsRequired = false)]
        private List<MTBaseFilterElement> m_FilterElements = new List<MTBaseFilterElement>();

    [DataMember(EmitDefaultValue = false, IsRequired = false)]
    private List<SortCriteria> m_SortCriteria = new List<SortCriteria>();
    #endregion
  }

  [DataContract]
  [Serializable]
    public class SortCriteria
    {
        public SortCriteria(string sortProperty, SortType sortDirection)
        {
            SortProperty = sortProperty;
            SortDirection = sortDirection;
        }

        private SortCriteria() { SortDirection = SortType.Ascending; }

        [DataMember(EmitDefaultValue = false, IsRequired = false)]
        public string SortProperty { get; set; }
        [DataMember(EmitDefaultValue = false, IsRequired = false)]
        public SortType SortDirection { get; set; }
    }

    [DataContract]
    [Serializable]
    [KnownType(typeof(MTFilterElement))]
    [KnownType(typeof(MTBinaryFilterOperator))]
    public class MTBaseFilterElement
    {
      public MTBaseFilterElement()
      {
          
      }
    }

    [DataContract]
    [Serializable]
    public class MTBinaryFilterOperator : MTBaseFilterElement
    {
        public enum BinaryOperatorType
        {
            AND = 0,
            OR = 1
        };

        public MTBinaryFilterOperator(MTBaseFilterElement leftHandElement,
                                      BinaryOperatorType operatorType,
                                      MTBaseFilterElement rightHandElement)
        {
            m_LeftHandElement = leftHandElement;
            m_OperatorType = operatorType;
            m_RightHandElement = rightHandElement;
        }

        #region Public Properties
        public MTBaseFilterElement LeftHandElement { get { return m_LeftHandElement; } set { m_LeftHandElement = value; } }
        public BinaryOperatorType OperatorType { get { return m_OperatorType; } set { m_OperatorType = value; } }
        public MTBaseFilterElement RightHandElement { get { return m_RightHandElement; } set { m_RightHandElement = value; } }
        #endregion

        #region Private Members
        [DataMemberAttribute]
        private MTBaseFilterElement m_LeftHandElement = null;
        [DataMemberAttribute]
        private BinaryOperatorType m_OperatorType;
        [DataMemberAttribute]
        private MTBaseFilterElement m_RightHandElement = null;
        #endregion
    }

    [DataContract]
    [Serializable]
    [KnownType("GetKnownTypes")]
    public class MTFilterElement : MTBaseFilterElement
  {
    #region Public Enums
    public enum OperationType
    {
      Like = 1,
      Like_W,
      Equal,
      NotEqual,
      Greater,
      GreaterEqual,
      Less,
      LessEqual,
      In,
      IsNull,
      IsNotNull
    };
    #endregion

    static MTFilterElement()
    {
      InitKnownTypes();
    }

    public MTFilterElement(string propertyName, OperationType op, object value)
    {
      m_PropertyName = propertyName;
      m_OperationType = op;
      m_Value = value;
    }

    protected MTFilterElement()
    {
    }

    #region Public Properties
    virtual public string PropertyName { get { return m_PropertyName; } }
    virtual public OperationType Operation { get { return m_OperationType; } }
    virtual public object Value { get { return m_Value; } }
    #endregion


    public static Type[] GetKnownTypes()
    {
      return m_knownTypes.ToArray();
    }

    private static void InitKnownTypes()
    {
      m_knownTypes = new List<Type>();

      Assembly assembly = Assembly.Load("MetraTech.DomainModel.Enums.Generated");
      if (assembly == null)
      {
        throw new ApplicationException("Cannot load assembly 'MetraTech.DomainModel.Enums.Generated'");
      }

      m_knownTypes.AddRange(assembly.GetTypes());

      assembly = Assembly.Load("MetraTech.DomainModel.Enums");
      if (assembly == null)
      {
        throw new ApplicationException("Cannot load assembly 'MetraTech.DomainModel.Enums'");
      }

      m_knownTypes.AddRange(assembly.GetTypes());
    }

    private static List<Type> m_knownTypes;

    #region Private Members
    [DataMember(EmitDefaultValue = false, IsRequired = false)]
    private string m_PropertyName;
    [DataMember(EmitDefaultValue = false, IsRequired = false)]
    private OperationType m_OperationType = OperationType.Equal;
    [DataMember(EmitDefaultValue = false, IsRequired = false)]
    private object m_Value = null;

    #endregion
  }
}
