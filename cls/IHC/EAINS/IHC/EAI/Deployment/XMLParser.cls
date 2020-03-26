Class IHC.EAI.Deployment.XMLParser extends %RegisteredObject {

Property itfExportFile As %Integer;

Property itfCompExportFile As %Integer;

Property itemsInfo As list Of IHC.EAI.Deployment.ExportItem;

Method IsConfigFile() As %Status
{
	return ..itfCompExportFile
}

Method IsItfExportFile() As %Status
{
	return ..itfExportFile
}

Method ParseFile(file As %String, compNm As %String) As %Status
{
 set lineItemNameTag= "ItemName:"
 set tagEndStr =  "</"
 set svnInfo = "<Notes>"
 set endSvnInfo = "</Notes>"
 set snvInfoFound = 0
 set svnRevTag = "Last Changed Rev:"
 set itfExportFileTag = "Deployment created by ITF team utility"
 set configTag = "<Document name"
 set configCompTag = compNm _ ".PTD"
 
 set ..itfExportFile = 0
 set ..itfCompExportFile = 0

 set itemNum = 0
 Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile(  configTag _ " " _ configCompTag)
 Do ..itemsInfo.Clear()
 
    set newSrcObj = ""
    Set fileObj=##class(%Library.File).%New(file)
	if $$$ISERR( fileObj.Open("RS")) ; Read mode and as stream
	{
		 Quit $$$ERROR($$$GeneralError, "Could not open the file")
	}
	
     	While 'fileObj.AtEnd 
        {
	        	set line = fileObj.ReadLine(,.sc,.eol)
	        	if line [ itfExportFileTag
	        	{
		        	set ..itfExportFile = 1
		        	Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile(  "File is ITF export file")
	        	}
	      		elseif (line [ configTag) && (line [ configCompTag)
	      		{
		    		set ..itfCompExportFile = 1
		    		Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile(  "File is Component export file")
	      		}
	     		if line [ svnInfo
	     		{
		 			set snvInfoFound = 1
	    		}
	    		elseif line [ endSvnInfo
	      		{
		  			set snvInfoFound = 0
	    		}
	       		elseif (snvInfoFound = 1)
	        	{
		      		set lastInd = $FIND(line, tagEndStr)
		      		
		      		if line [ lineItemNameTag
	        	    {
		        		set ind = $FIND(line, lineItemNameTag)
		        		set itemNum = itemNum + 1
		        		set newSrcObj = ##class(IHC.EAI.Deployment.ExportItem).%New()
		        		set newSrcObj.itemName = $ZSTRIP($E(line, ind, lastInd-3), "<>W")
	        		  	 Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile(  "Insert Item: " _ newSrcObj.itemName )
	        		  	Do ..itemsInfo.Insert(newSrcObj)
	        		}
	        		else
	        		{
		        		set ind = $FIND(line, ">")
		        				
		        		if line [ "Last "
		        		{
			        		set revInd = $FIND(line, svnRevTag)
			        		if (revInd > 1)
			        		{
				        		set revNum = $ZSTRIP( $E(line, revInd, lastInd-3), "<>W")
			        			 Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile(  "  Revision # " _ revNum)
			        			set ..itemsInfo.GetAt(itemNum).versionNum = revNum			        	
			        		}
			        		else
			        		{
				        		set info = $E(line, ind, lastInd-3)
			        	   		 Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile(  "   "_ info)
			        	   		if (..itemsInfo.GetAt(itemNum).itemInfo = "")
			        	   		{
				        	   		set ..itemsInfo.GetAt(itemNum).itemInfo = info
			        	   		}
			        	   		else
			        	   		{
			        	   			set ..itemsInfo.GetAt(itemNum).itemInfo =..itemsInfo.GetAt(itemNum).itemInfo _ "; " _ info
			        	   		}
			        		}
		        		}
		        				
	        		}
	        	}
        }
		Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile("# of items: " _ ..itemsInfo.Count())
       	Do fileObj.Close()
        if (..itfExportFile)
        {
	        Do ##class(IHC.ITF.ITFCOMMON.Utility).WriteToFile("Successfully parsed the File")
		    Quit $$$OK
        }
        else
        {
	        Quit $$$ERROR($$$GeneralError, "Not a valid ITF  export file")
        }
}
}