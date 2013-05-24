package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfigPropSet'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigPropSet Interface</B>'
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
public interface IMTConfigPropSet {
  /**
   * next. method Next
   *
   * @return    return value.  An reference to a IMTConfigProp
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigProp next  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * previous. method Previous
   *
   * @return    return value.  An reference to a IMTConfigProp
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigProp previous  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * reset. method Reset
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void reset  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextWithName. method NextWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigProp
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigProp nextWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextLongWithName. method NextLongWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public int nextLongWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextStringWithName. method NextStringWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String nextStringWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextBoolWithName. method NextBoolWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean nextBoolWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextVariantWithName. method NextVariantWithName
   *
   * @param     aName The aName (in)
   * @param     apType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (out: use single element array)
   * @return    return value.  A Variant
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public Object nextVariantWithName  (
              String aName,
              int[] apType) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextDoubleWithName. method NextDoubleWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public double nextDoubleWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextSetWithName. method NextSetWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet nextSetWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * insertSet. method InsertSet
   *
   * @param     aName The aName (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet insertSet  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * insertProp. method InsertProp
   *
   * @param     aName The aName (in)
   * @param     aType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (in)
   * @param     aVal A Variant (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void insertProp  (
              String aName,
              int aType,
              Object aVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * addSubSet. method AddSubSet
   *
   * @param     apNewSet An reference to a IMTConfigPropSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void addSubSet  (
              IMTConfigPropSet apNewSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * write. method Write
   *
   * @param     aFilename The aFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void write  (
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeWithChecksum. method WriteWithChecksum
   *
   * @param     aFilename The aFilename (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeWithChecksum  (
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeToHost. method WriteToHost
   *
   * @param     aHostName The aHostName (in)
   * @param     aRelativePath The aRelativePath (in)
   * @param     aUsername The aUsername (in)
   * @param     aPassword The aPassword (in)
   * @param     aSecure The aSecure (in)
   * @param     aChecksum The aChecksum (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void writeToHost  (
              String aHostName,
              String aRelativePath,
              String aUsername,
              String aPassword,
              boolean aSecure,
              boolean aChecksum) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextMatches. method NextMatches
   *
   * @param     aPropName The aPropName (in)
   * @param     aType A com.metratech.pipeline.__MIDL___MIDL_itf_MTPipelineLib_0256_0001 constant (A  COM typedef)  (in)
   * @return    return value.  The apMatch
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public boolean nextMatches  (
              String aPropName,
              int aType) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * writeToBuffer. method WriteToBuffer
   *
   * @return    return value.  The apVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String writeToBuffer  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * nextDateWithName. method NextDateWithName
   *
   * @param     aName The aName (in)
   * @return    return value.  The pDate
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public java.util.Date nextDateWithName  (
              String aName) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * insertConfigProp. method InsertConfigProp
   *
   * @param     pProp An reference to a IMTConfigProp (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void insertConfigProp  (
              IMTConfigProp pProp) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getName. property Name
   *
   * @return    return value.  The bName
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getName  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getAttribSet. property AttribSet
   *
   * @return    return value.  An reference to a IMTConfigAttribSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigAttribSet getAttribSet  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setAttribSet. property AttribSet
   *
   * @param     ppSet An reference to a IMTConfigAttribSet (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setAttribSet  (
              IMTConfigAttribSet ppSet) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getDTD. property DTD
   *
   * @return    return value.  The pVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getDTD  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * setDTD. property DTD
   *
   * @param     pVal The pVal (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void setDTD  (
              String pVal) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getChecksum. property Checksum
   *
   * @return    return value.  The pChecksum
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getChecksum  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * checksumRefresh. method ChecksumRefresh
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void checksumRefresh  () throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID9adcd818_35fd_11d2_a1c4_006008c0e24a = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigPropSetProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "9adcd818-35fd-11d2-a1c4-006008c0e24a";
  String DISPID_1_NAME = "next";
  String DISPID_2_NAME = "previous";
  String DISPID_3_NAME = "reset";
  String DISPID_4_NAME = "nextWithName";
  String DISPID_5_NAME = "nextLongWithName";
  String DISPID_6_NAME = "nextStringWithName";
  String DISPID_7_NAME = "nextBoolWithName";
  String DISPID_8_NAME = "nextVariantWithName";
  String DISPID_9_NAME = "nextDoubleWithName";
  String DISPID_10_NAME = "nextSetWithName";
  String DISPID_11_NAME = "insertSet";
  String DISPID_12_NAME = "insertProp";
  String DISPID_13_NAME = "addSubSet";
  String DISPID_14_NAME = "write";
  String DISPID_15_NAME = "writeWithChecksum";
  String DISPID_16_NAME = "writeToHost";
  String DISPID_17_NAME = "nextMatches";
  String DISPID_18_NAME = "writeToBuffer";
  String DISPID_19_NAME = "nextDateWithName";
  String DISPID_20_NAME = "insertConfigProp";
  String DISPID_21_GET_NAME = "getName";
  String DISPID_22_GET_NAME = "getAttribSet";
  String DISPID_22_PUT_NAME = "setAttribSet";
  String DISPID_23_GET_NAME = "getDTD";
  String DISPID_23_PUT_NAME = "setDTD";
  String DISPID_24_GET_NAME = "getChecksum";
  String DISPID_25_NAME = "checksumRefresh";
}
