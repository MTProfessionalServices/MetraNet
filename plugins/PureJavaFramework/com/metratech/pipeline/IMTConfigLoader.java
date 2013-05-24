package com.metratech.pipeline;

/**
 * COM Interface 'IMTConfigLoader'. Generated 7/24/00 5:03:12 PM
 * from 'D:|Builds|debug|include|MTPipelineLib.tlb'<P>
 * Generated using version 1.3.4  SB002 of <B>J-Integra[tm]</B> -- pure Java/COM integration technology from Linar Ltd.
 * See  <A HREF="http://www.linar.com/">http://www.linar.com/</A><P>
 * Description: '<B>IMTConfigLoader Interface</B>'
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
public interface IMTConfigLoader {
  /**
   * init. method Init
   *
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void init  () throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * initWithPath. method InitWithPath
   *
   * @param     aRootPath The aRootPath (in)
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public void initWithPath  (
              String aRootPath) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getAllFiles. method GetAllFiles
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @return    return value.  An reference to a IMTConfigFileList
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigFileList getAllFiles  (
              String aCompName,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getActiveFiles. method GetActiveFiles
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @return    return value.  An reference to a IMTConfigFileList
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigFileList getActiveFiles  (
              String aCompName,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEffectiveFile. method GetEffectFile
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getEffectiveFile  (
              String aCompName,
              String aFilename) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getEffectiveFileWithDate. method GetEffectFileWithDate
   *
   * @param     aCompName The aCompName (in)
   * @param     aFilename The aFilename (in)
   * @param     aDate A Variant (in)
   * @return    return value.  An reference to a IMTConfigPropSet
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public IMTConfigPropSet getEffectiveFileWithDate  (
              String aCompName,
              String aFilename,
              Object aDate) throws java.io.IOException, com.linar.jintegra.AutomationException;

  /**
   * getPath. method GetPath
   *
   * @param     aCompName The aCompName (in)
   * @return    return value.  The apRetVal
   * @exception java.io.IOException If there are communications problems.
   * @exception com.linar.jintegra.AutomationException If the remote server throws an exception.
   */
  public String getPath  (
              String aCompName) throws java.io.IOException, com.linar.jintegra.AutomationException;


  // Constants to help J-Integra dynamically map DCOM invocations to
  // interface members.  Don't worry, you will never need to explicitly use these constants.
  int IID20021541_741f_11d2_80fc_006008c0e8b7 = 1;
  /** Dummy reference to interface proxy to make sure it gets compiled */
  int xxDummy = IMTConfigLoaderProxy.xxDummy;
  /** Used internally by J-Integra, please ignore */
  String IID = "20021541-741f-11d2-80fc-006008c0e8b7";
  String DISPID_1_NAME = "init";
  String DISPID_2_NAME = "initWithPath";
  String DISPID_3_NAME = "getAllFiles";
  String DISPID_4_NAME = "getActiveFiles";
  String DISPID_5_NAME = "getEffectiveFile";
  String DISPID_6_NAME = "getEffectiveFileWithDate";
  String DISPID_7_NAME = "getPath";
}
