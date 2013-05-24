This folder contains visualization utilities that use GraphViz
(http://www.research.att.com/sw/tools/graphviz/).

Prerequisites:

 The following software must be installed on your machine:

 GraphViz
   -- \\thames\freeware\software\GraphViz

 perl 5.6.1 or later
   -- \\thames\software\Freeware\Perl


Tools:

viewPluginDeps.pl

This perl script parses the plugin dependencies from a stage.xml file,
creates a file in GraphViz DOT format, and displays it.

Usage:

  perl viewPluginDeps.pl <path to stage.xml>

e.g. 

  perl viewPluginDeps.pl C:\MetraTech\RMP\extensions\audioconf\config\pipeline\AudioConfCall\stage.xml


viewAssemblyDeps.pl

This perl script parses assembly dependencies from all make.inc files found in a directory subtree,
creates a file in GraphViz DOT format, and displays it.

Usage:

  perl viewAssemblyDeps.pl [<directory>]
	(default is S:\MetraTech)

