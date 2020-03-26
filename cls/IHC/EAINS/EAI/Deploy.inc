ROUTINE EAI.Deploy [TYPE=INC]
#Define WORKEXPORTDIR(%insType) 				"/WORK/" _ %insType _ "/export"
#Define USEREXPORTDIR(%insType,%uname) 			"/WORK/" _ %insType _ "/export/" _ %uname
#Define WORKDEPLOYDIR(%insType) 				"/WORK/" _ %insType _ "/deploy"
#Define USERDEPLOYDIR(%insType,%uname) 			"/WORK/" _ %insType _ "/deploy/" _ %uname
#Define USERDEPLOYLOGDIR(%insType,%uname) 		"/WORK/" _ %insType _ "/deploy/" _ %uname _ "/logs"
#Define USERDEPLOYROLLBACKDIR(%insType,%uname) 	"/WORK/" _ %insType _ "/deploy/" _ %uname _ "/rollback"
#Define SVNSRCTRUNK  							"/ITF_Ensemble/trunk"
#Define SVNLIST 								"svn list --no-auth-cache --non-interactive --recursive"
#Define SVNINFO									"svn info --no-auth-cache --non-interactive"
#Define SVNLOG									"svn log --no-auth-cache --non-interactive"
#Define SVNCHECKOUT								"svn co --no-auth-cache --non-interactive"
#Define SVNUPDATE								"svn update  -N --no-auth-cache --non-interactive"
#Define SVNUPDATEALL							"svn update --no-auth-cache --non-interactive"
#Define SVNCOMMIT								"svn commit -N"
#Define SVNADD									"svn add -N --no-auth-cache --non-interactive"
#Define SVNSRCURL								"https://subversion.co.ihc.com/ITF_Ensemble/trunk" 
#Define SVNCHECKINTIME							"Last Changed Date:"
#Define SVNRELEASEURL							"https://subversion.co.ihc.com/ITF_EnsembleReleasePkgs/trunk"