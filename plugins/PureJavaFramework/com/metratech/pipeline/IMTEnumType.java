package com.metratech.pipeline;

/**
 * COM Interface 'IMTEnumType'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTEnumType Interface</B>'
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
public interface IMTEnumType {
  /**
   * getEnumspace. property Enumspace
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumspace  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEnumspace. property Enumspace
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEnumspace  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumTypeName. property EnumTypeName
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumTypeName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEnumTypeName. property EnumTypeName
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEnumTypeName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * add. method Add
   *
   * @param     pEnum An reference to a IMTEnumerator (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void add  (
              IMTEnumerator pEnum) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeSet. method WriteSet
   *
   * @param     pSet An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeSet  (
              IMTConfigPropSet pSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumTypeDescription. property EnumTypeDescription
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumTypeDescription  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEnumTypeDescription. property EnumTypeDescription
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEnumTypeDescription  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumSpaceDescription. property EnumSpaceDescription
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumSpaceDescription  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEnumSpaceDescription. property EnumSpaceDescription
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEnumSpaceDescription  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumerators. method GetEnumerators
   *
   * @return    return value.  An reference to a IMTEnumeratorCollection
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTEnumeratorCollection getEnumerators  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getStatus. property Status
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getStatus  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setStatus. property Status
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setStatus  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID3ada859f_01c6_11d4_95a0_00b0d025b121 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTEnumTypeProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "3ada859f-01c6-11d4-95a0-00b0d025b121";
  String DISPID_1_GET_NAME = "getEnumspace";
  String DISPID_1_PUT_NAME = "setEnumspace";
  String DISPID_2_GET_NAME = "getEnumTypeName";
  String DISPID_2_PUT_NAME = "setEnumTypeName";
  String DISPID_3_NAME = "add";
  String DISPID_4_NAME = "writeSet";
  String DISPID_5_GET_NAME = "getEnumTypeDescription";
  String DISPID_5_PUT_NAME = "setEnumTypeDescription";
  String DISPID_6_GET_NAME = "getEnumSpaceDescription";
  String DISPID_6_PUT_NAME = "setEnumSpaceDescription";
  String DISPID_7_NAME = "getEnumerators";
  String DISPID_9_GET_NAME = "getStatus";
  String DISPID_9_PUT_NAME = "setStatus";
}
