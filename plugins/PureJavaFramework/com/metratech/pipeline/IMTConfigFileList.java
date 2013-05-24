package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfigFileList'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigFileList Interface</B>'
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
public interface IMTConfigFileList {
  /**
   * getCount. Returns number of items in collection
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int getCount  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setCount. Returns number of items in collection
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setCount  (
              int pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addCFile. method AddCFile
   *
   * @param     apMainVal An reference to a IMTConfigPropSet (in)
   * @param     apVal An reference to a IMTConfigPropSet (in)
   * @param     aEffDate The aEffDate (in)
   * @param     aLingerDate The aLingerDate (in)
   * @param     aFilename The aFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addCFile  (
              IMTConfigPropSet apMainVal,
              IMTConfigPropSet apVal,
              int aEffDate,
              int aLingerDate,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * calculateEffDate. method CalculateEffDate
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void calculateEffDate  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEffectConfig. property EffectConfig
   *
   * @param     curDate The curDate (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getEffectConfig  (
              int curDate) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * removeItem. method RemoveItem
   *
   * @param     aIndex The aIndex (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void removeItem  (
              int aIndex) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getItem. property Item
   *
   * @param     aIndex The aIndex (in)
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object getItem  (
              int aIndex) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * get_NewEnum. property _NewEnum
   *
   * @return    return value.  An enumeration.
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Enumeration get_NewEnum  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID20021546_741f_11d2_80fc_006008c0e8b7 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigFileListProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "20021546-741f-11d2-80fc-006008c0e8b7";
  String DISPID_1_GET_NAME = "getCount";
  String DISPID_1_PUT_NAME = "setCount";
  String DISPID_2_NAME = "addCFile";
  String DISPID_3_NAME = "calculateEffDate";
  String DISPID_4_GET_NAME = "getEffectConfig";
  String DISPID_5_NAME = "removeItem";
  String DISPID_0_GET_NAME = "getItem";
  String DISPID__4_GET_NAME = "get_NewEnum";
}
