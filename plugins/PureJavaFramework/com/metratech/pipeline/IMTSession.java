package com.metratech.pipeline;

/**
 * COM Interface 'IMTSession'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTSession Interface</B>'
 *
 * Generator Options:
 * PromptForTypeLibraries = True
 * AttemptNonDual = True
 * ClashPrefix = zz_
 * LowerCaseMemberNames = True
 * IDispatchOnly = False
 * RetryOnReject = True
 * GenerateDeprecatedConstructors = True
 * ArraysAsObjects = False
 * DontGenerateDisp = False
 * DontRenameSameMethods = False
 * IgnoreConflictingInterfaces = True
 */
public interface IMTSession {
  /**
   * setLongProperty. method SetLongProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setLongProperty  (
              int propid,
              int propval) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getLongProperty. method GetLongProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getLongProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setBSTRProperty. method SetBSTRProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aValue The aValue (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setBSTRProperty  (
              int aPropId,
              String aValue) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getBSTRProperty. method GetBSTRProperty
   *
   * @param     aPropId The aPropId (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getBSTRProperty  (
              int aPropId) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setStringProperty. method SetStringProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aValue The aValue (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setStringProperty  (
              int aPropId,
              String aValue) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getStringProperty. method GetStringProperty
   *
   * @param     aPropId The aPropId (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getStringProperty  (
              int aPropId) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setBoolProperty. method SetBoolProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aVal The aVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setBoolProperty  (
              int aPropId,
              boolean aVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getBoolProperty. method GetBoolProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean getBoolProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setDoubleProperty. method SetDoubleProperty
   *
   * @param     aPropId The aPropId (in)
   * @param     aValue The aValue (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDoubleProperty  (
              int aPropId,
              double aValue) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getDoubleProperty. method GetDoubleProperty
   *
   * @param     aPropId The aPropId (in)
   * @return    return value.  The apValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public double getDoubleProperty  (
              int aPropId) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setOLEDateProperty. method SetOLEDateProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setOLEDateProperty  (
              int propid,
              java.util.Date propval) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getOLEDateProperty. method GetOLEDateProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Date getOLEDateProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setTimeProperty. method SetTimeProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setTimeProperty  (
              int propid,
              int propval) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getTimeProperty. method GetTimeProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getTimeProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setDateTimeProperty. method SetDateTimeProperty
   *
   * @param     propid The propid (in)
   * @param     propval The propval (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDateTimeProperty  (
              int propid,
              int propval) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getDateTimeProperty. method GetDateTimeProperty
   *
   * @param     propid The propid (in)
   * @return    return value.  The propval
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getDateTimeProperty  (
              int propid) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * get_NewEnum. property _NewEnum
   *
   * @return    return value.  An enumeration.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Enumeration get_NewEnum  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getSessionID. property SessionID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getSessionID  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addSessionChildren. method AddSessionChildren
   *
   * @param     apSet An reference to a IMTSessionSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSessionChildren  (
              IMTSessionSet apSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * sessionChildren. method SessionChildren
   *
   * @return    return value.  An reference to a IMTSessionSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTSessionSet sessionChildren  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getServiceID. property ServiceID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getServiceID  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getParentID. property ParentID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getParentID  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getDatabaseID. property DatabaseID
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getDatabaseID  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setDatabaseID. property DatabaseID
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDatabaseID  (
              int pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * increaseSharedRefCount. method IncreaseSharedRefCount
   *
   * @return    return value.  The apNewCount
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int increaseSharedRefCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * decreaseSharedRefCount. method DecreaseSharedRefCount
   *
   * @return    return value.  The apNewCount
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int decreaseSharedRefCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * deleteForcefully. method DeleteForcefully
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void deleteForcefully  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * markComplete. method MarkComplete
   *
   * @return    return value.  The apParentReady
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean markComplete  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * markCompoundAsFailed. method MarkCompoundAsFailed
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void markCompoundAsFailed  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getOutstandingChildren. property OutstandingChildren
   *
   * @return    return value.  The children
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getOutstandingChildren  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * rollback. method Rollback
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void rollback  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setStartStage. property StartStage
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setStartStage  (
              int pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getStartStage. property StartStage
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getStartStage  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setInTransitTo. method InTransitTo
   *
   * @param     rhs1 The rhs1 (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setInTransitTo  (
              int rhs1) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setInProcessBy. method InProcessBy
   *
   * @param     rhs1 The rhs1 (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setInProcessBy  (
              int rhs1) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getUID. property UID
   *
   * @param     uID An unsigned byte (out: use single element array)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void getUID  (
              byte[][] uID) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getUIDAsString. property UIDAsString
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getUIDAsString  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addSessionDescendants. method AddSessionDescendants
   *
   * @param     apSet An reference to a IMTSessionSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSessionDescendants  (
              IMTSessionSet apSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * IsParent. property IsParent
   *
   * @return    return value.  The isParent
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean IsParent  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * isCompoundMarkedAsFailed. property CompoundMarkedAsFailed
   *
   * @return    return value.  The failed
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean isCompoundMarkedAsFailed  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addEvents. method AddEvents
   *
   * @param     events The events (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addEvents  (
              int events) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEvents. method Events
   *
   * @return    return value.  The events
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getEvents  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * beginTransaction. method BeginTransaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void beginTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * joinDistributedTransaction. method Join Distributed Transaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void joinDistributedTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * commitTransaction. method Commit Transaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void commitTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * rollbackTransaction. method Rollback Transaction
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void rollbackTransaction  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IIDc8757973_20e5_11d2_a1c1_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTSessionProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "c8757973-20e5-11d2-a1c1-006008c0e24a";
  String DISPID_1610743808_NAME = "setLongProperty";
  String DISPID_1610743809_NAME = "getLongProperty";
  String DISPID_1610743810_NAME = "setBSTRProperty";
  String DISPID_1610743811_NAME = "getBSTRProperty";
  String DISPID_1610743812_NAME = "setStringProperty";
  String DISPID_1610743813_NAME = "getStringProperty";
  String DISPID_1610743814_NAME = "setBoolProperty";
  String DISPID_1610743815_NAME = "getBoolProperty";
  String DISPID_1610743816_NAME = "setDoubleProperty";
  String DISPID_1610743817_NAME = "getDoubleProperty";
  String DISPID_1610743818_NAME = "setOLEDateProperty";
  String DISPID_1610743819_NAME = "getOLEDateProperty";
  String DISPID_1610743820_NAME = "setTimeProperty";
  String DISPID_1610743821_NAME = "getTimeProperty";
  String DISPID_1610743822_NAME = "setDateTimeProperty";
  String DISPID_1610743823_NAME = "getDateTimeProperty";
  String DISPID__4_GET_NAME = "get_NewEnum";
  String DISPID_1610743825_GET_NAME = "getSessionID";
  String DISPID_1610743826_NAME = "addSessionChildren";
  String DISPID_1610743827_NAME = "sessionChildren";
  String DISPID_1610743828_GET_NAME = "getServiceID";
  String DISPID_1610743829_GET_NAME = "getParentID";
  String DISPID_1610743830_GET_NAME = "getDatabaseID";
  String DISPID_1610743830_PUT_NAME = "setDatabaseID";
  String DISPID_1610743832_NAME = "increaseSharedRefCount";
  String DISPID_1610743833_NAME = "decreaseSharedRefCount";
  String DISPID_1610743834_NAME = "deleteForcefully";
  String DISPID_1610743835_NAME = "markComplete";
  String DISPID_1610743836_NAME = "markCompoundAsFailed";
  String DISPID_1610743837_GET_NAME = "getOutstandingChildren";
  String DISPID_1610743838_NAME = "rollback";
  String DISPID_1610743839_PUT_NAME = "setStartStage";
  String DISPID_1610743839_GET_NAME = "getStartStage";
  String DISPID_1610743841_PUT_NAME = "setInTransitTo";
  String DISPID_1610743842_PUT_NAME = "setInProcessBy";
  String DISPID_1610743843_GET_NAME = "getUID";
  String DISPID_1610743844_GET_NAME = "getUIDAsString";
  String DISPID_1610743845_NAME = "addSessionDescendants";
  String DISPID_1610743846_GET_NAME = "IsParent";
  String DISPID_1610743847_GET_NAME = "isCompoundMarkedAsFailed";
  String DISPID_1610743848_NAME = "addEvents";
  String DISPID_1610743849_GET_NAME = "getEvents";
  String DISPID_1610743850_NAME = "beginTransaction";
  String DISPID_1610743851_NAME = "joinDistributedTransaction";
  String DISPID_1610743852_NAME = "commitTransaction";
  String DISPID_1610743853_NAME = "rollbackTransaction";
}
