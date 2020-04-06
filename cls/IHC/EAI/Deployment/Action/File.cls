Class IHC.EAI.Deployment.Action.File extends IHC.EAI.Deployment.Action {

	Property Filename As %String;

	Property ComponentName As %String;
	
	Property Revision As %String;

	Property TargetProduction As %String;
	
	Property CreateRollback As %Integer [ InitialExpression = 1 ];

	Property RollbackFilename As %String;

	Property WhereToLog As %String [ InitialExpression = "L" ];

	Property LogFile As %String;

	Property AllowDeployToSource As %Boolean [ InitialExpression = 1 ];

	Property AutoRevert As %Boolean [ InitialExpression = 0 ];

}