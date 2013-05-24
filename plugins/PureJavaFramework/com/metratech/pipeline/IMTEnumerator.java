package com.metratech.pipeline;

/**
 * COM Interface 'IMTEnumerator'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTEnumerator Interface</B>'
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
public interface IMTEnumerator {
  /**
   * getName. property Name
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setName. property Name
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setName  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addValue. method AddValue
   *
   * @param     value The value (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addValue  (
              String value) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumspace. property EnumSpace
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumspace  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEnumspace. property EnumSpace
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEnumspace  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEnumType. property EnumType
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getEnumType  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setEnumType. property EnumType
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setEnumType  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

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
   * numValues. method NumValues
   *
   * @return    return value.  The __MIDL_0016
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int numValues  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * elementAt. method ElementAt
   *
   * @param     __MIDL_0017 The __MIDL_0017 (in)
   * @return    return value.  The pEnumValue
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String elementAt  (
              int __MIDL_0017) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getFQN. property FQN
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getFQN  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * clearValue. method ClearValue
   *
   * @param     value The value (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void clearValue  (
              String value) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * clearValues. method ClearValues
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void clearValues  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IIDbdf32815_027d_11d4_95a0_00b0d025b121 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTEnumeratorProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "bdf32815-027d-11d4-95a0-00b0d025b121";
  String DISPID_1_GET_NAME = "getName";
  String DISPID_1_PUT_NAME = "setName";
  String DISPID_2_NAME = "addValue";
  String DISPID_3_GET_NAME = "getEnumspace";
  String DISPID_3_PUT_NAME = "setEnumspace";
  String DISPID_4_GET_NAME = "getEnumType";
  String DISPID_4_PUT_NAME = "setEnumType";
  String DISPID_5_NAME = "writeSet";
  String DISPID_6_NAME = "numValues";
  String DISPID_7_NAME = "elementAt";
  String DISPID_8_GET_NAME = "getFQN";
  String DISPID_9_NAME = "clearValue";
  String DISPID_10_NAME = "clearValues";
}
