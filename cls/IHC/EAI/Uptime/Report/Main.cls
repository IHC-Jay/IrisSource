Class IHC.EAI.Uptime.Report.Main Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod OnPage() As %Status
{
    &html<
    
		<!DOCTYPE html>
		<html lang="en">
		<head>
			<meta charset="utf-8">
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<meta name="description" content="">
			<meta name="author" content="">

			<title>Ensemble Uptime Report</title>

			<!-- Bootstrap Core CSS -->
			<link href="css/bootstrap.min.css" rel="stylesheet">
			
			<!-- MetisMenu CSS -->
			<link href="css/metisMenu.min.css" rel="stylesheet">

			<!-- Timeline CSS -->
			<link href="css/timeline.css" rel="stylesheet">

			<!-- Custom CSS -->
			<link href="css/startmin.css" rel="stylesheet">

			<!-- Morris Charts CSS -->
			<link href="css/morris.css" rel="stylesheet">

			<!-- Custom Fonts -->
			<link href="css/font-awesome.min.css" rel="stylesheet" type="text/css">

			<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
			<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
			<!--[if lt IE 9]>
				<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
				<script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
			<![endif]-->
		</head>
		<body>

			<div id="wrapper">

				<!-- Navigation -->
				<nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
					<div class="navbar-header">
						<a class="navbar-brand" href="#">EAI</a>
					</div>

					<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
						<span class="sr-only">Toggle navigation</span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
						<span class="icon-bar"></span>
					</button>

					<!-- Top Navigation: Left Menu -->
					<ul class="nav navbar-nav navbar-left navbar-top-links">
						<li><a href="#(..Link("/csp/sys/UtilHome.csp"))#"><i class="fa fa-home fa-fw"></i> Management Portal</a></li>
					</ul>

					<!-- Top Navigation: Right Menu -->
					<ul class="nav navbar-right navbar-top-links">
						<!--li class="dropdown navbar-inverse">
							<a class="dropdown-toggle" data-toggle="dropdown" href="#">
								<i class="fa fa-bell fa-fw"></i> <b class="caret"></b>
							</a>
							<ul class="dropdown-menu dropdown-alerts">
								<li>
									<a href="#">
										<div>
											<i class="fa fa-comment fa-fw"></i> New Comment
											<span class="pull-right text-muted small">4 minutes ago</span>
										</div>
									</a>
								</li>
								<li class="divider"></li>
								<li>
									<a class="text-center" href="#">
										<strong>See All Alerts</strong>
										<i class="fa fa-angle-right"></i>
									</a>
								</li>
							</ul>
						</li-->
						<!--li class="dropdown">
							<a class="dropdown-toggle" data-toggle="dropdown" href="#">
								<i class="fa fa-user fa-fw"></i> secondtruth <b class="caret"></b>
							</a>
							<ul class="dropdown-menu dropdown-user">
								<li><a href="#"><i class="fa fa-user fa-fw"></i> User Profile</a>
								</li>
								<li><a href="#"><i class="fa fa-gear fa-fw"></i> Settings</a>
								</li>
								<li class="divider"></li>
								<li><a href="#"><i class="fa fa-sign-out fa-fw"></i> Logout</a>
								</li>
							</ul>
						</li-->
					</ul>

					<!-- Sidebar -->
					<div class="navbar-default sidebar" role="navigation">
						<div class="sidebar-nav navbar-collapse">

							<ul class="nav" id="side-menu">
								<li class="sidebar-search">
									<div class="input-group custom-search-form">
										<input type="text" class="form-control" placeholder="Search...">
										<span class="input-group-btn">
											<button class="btn btn-primary" type="button">
												<i class="fa fa-search"></i>
											</button>
										</span>
									</div>
								</li>
								<li>
									<a href="#(..Link("/csp/healthshare/eai/IHC.EAI.Uptime.Report.Main.cls"))#" class="active"><i class="fa fa-dashboard fa-fw"></i> Ensemble Uptime</a>
								</li>
								<!--li>
									<a href="#"><i class="fa fa-sitemap fa-fw"></i> Multi-Level Dropdown<span class="fa arrow"></span></a>
									<ul class="nav nav-second-level">
										<li>
											<a href="#">Second Level Item</a>
										</li>
										<li>
											<a href="#">Third Level <span class="fa arrow"></span></a>
											<ul class="nav nav-third-level">
												<li>
													<a href="#">Third Level Item</a>
												</li>
											</ul>
										</li>
									</ul>
								</li-->
							</ul>

						</div>
					</div>
				</nav>

				<!-- Page Content -->
				<div id="page-wrapper">
					<div class="container-fluid">

						<div class="row">
							<div class="col-lg-12">
								<h1 class="page-header">Ensemble Uptime Report</h1>
							</div>
						</div>
						
						<!-- ... Your content goes here ... -->
						<div class="row">
							<div class="panel panel-default">
								<div class="panel-heading">
									<i class="fa fa-line-chart fa-fw"></i> Month To Date (#($ZSTRIP(##class(IHC.EAI.Uptime.Util).GetCurrentMonth(),"<>W"))#)
								</div>
								<div class="panel-body">
									<div id="current-month-donut" style="height: 250px;"></div>
									<div id="current-month-line" style="height: 150px;"></div>
									
									<div class="text-center">
										<a href="#mtd-details" class="btn btn-info" data-toggle="collapse">Details</a>
									</div>
									<div class="row" style="margin-top:10px;"></div>
									<div id="mtd-details" class="collapse">
										<div class="table-responsive">
											<table class="table table-bordered table-hover table-striped">
												<thead>
		                                       		<tr>
		                                       			<th>Namespace</th>
		                                       			<th>Percent Up</th>
		                                       		</tr>
		                                        </thead>
		                                        <tbody>
		                                        >
		                                        
		                                        Set tResults = ##class(IHC.EAI.Uptime.Util).GetNamespaceResults(1,.tStatus)
		                                        For i=1:1:tResults.Count() {
		                                         	Set tResultItem = tResults.GetAt(i)
		                                         	Write "<tr>"
		                                         	Write "<td>" _ $PIECE(tResultItem,"|",1) _ "</td>"
		                                         	Write "<td>" _ $PIECE(tResultItem,"|",2) _ "&#37;</td>"
		                                         	Write "</tr>", !
		                                        }
		                                        
		                                        &html<
		                                        </tbody>
		                                    </table>
		                                </div>
		                                        
		                                <div class="table-responsive">
		                                    <table class="table table-bordered table-hover table-striped">
		                                        <thead>
		                                        <tr>
		                                            <th>ConfigName</th>
		                                            <th>Namespace</th>
		                                            <th>DownStart</th>
		                                            <th>DownEnd</th>
		                                            <th>Reason</th>
		                                        </tr>
		                                        </thead>
		                                        <tbody>
		                                        >
		                                        
		                                        Set tResults = ##class(IHC.EAI.Uptime.Util).GetDetailResults(1,.tStatus)
		                                        For i=1:1:tResults.Count() {
		                                         	Set tResultItem = tResults.GetAt(i)
		                                         	Write "<tr>"
		                                         	Write "<td>" _ tResultItem.ConfigName _ "</td>"
		                                         	Write "<td>" _ tResultItem.Namespace _ "</td>"
		                                         	Write "<td>" _ tResultItem.DownStart _ "</td>"
		                                         	Write "<td>" _ tResultItem.DownEnd _ "</td>"
		                                         	Write "<td>" _ tResultItem.Reason _ "</td>"
		                                         	Write "</tr>", !
		                                        }
		                                        
		                                        &html<
		                                        </tbody>
		                                    </table>
		                                </div>
		                                <!-- /.table-responsive -->
		                                <!--div class="col-lg-8">
		                                    <div id="morris-bar-chart"></div>
		                                </div-->
		                                <!-- /.col-lg-8 (nested) -->
									</div>
								</div>
							</div>
							
							<div class="panel panel-default">
								<div class="panel-heading">
									<i class="fa fa-line-chart fa-fw"></i> Previous Month (#($ZSTRIP(##class(IHC.EAI.Uptime.Util).GetPreviousMonth(),"<>W"))#)
								</div>
								<div class="panel-body">
									<div id="previous-month-donut" style="height: 250px;"></div>
									<div id="previous-month-line" style="height: 150px;"></div>
									
									<div class="text-center">
										<a href="#pmd-details" class="btn btn-info" data-toggle="collapse">Details</a>
									</div>
									<div class="row" style="margin-top:10px;"></div>
									<div id="pmd-details" class="collapse">
		                                <div class="table-responsive">
											<table class="table table-bordered table-hover table-striped">
												<thead>
		                                       		<tr>
		                                       			<th>Namespace</th>
		                                       			<th>Percent Up</th>
		                                       		</tr>
		                                        </thead>
		                                        <tbody>
		                                        >
		                                        
		                                        Set tResults = ##class(IHC.EAI.Uptime.Util).GetNamespaceResults(2,.tStatus)
		                                        For i=1:1:tResults.Count() {
		                                         	Set tResultItem = tResults.GetAt(i)
		                                         	Write "<tr>"
		                                         	Write "<td>" _ $PIECE(tResultItem,"|",1) _ "</td>"
		                                         	Write "<td>" _ $PIECE(tResultItem,"|",2) _ "&#37;</td>"
		                                         	Write "</tr>", !
		                                        }
		                                        
		                                        &html<
		                                        </tbody>
		                                    </table>
		                                </div>
		                                
		                                <div class="table-responsive">
		                                    <table class="table table-bordered table-hover table-striped">
		                                        <thead>
		                                        <tr>
		                                            <th>ConfigName</th>
		                                            <th>Namespace</th>
		                                            <th>DownStart</th>
		                                            <th>DownEnd</th>
		                                            <th>Reason</th>
		                                        </tr>
		                                        </thead>
		                                        <tbody>
		                                        >
		                                        
		                                        Set tResults = ##class(IHC.EAI.Uptime.Util).GetDetailResults(2,.tStatus)
		                                        For i=1:1:tResults.Count() {
		                                         	Set tResultItem = tResults.GetAt(i)
		                                         	Write "<tr>"
		                                         	Write "<td>" _ tResultItem.ConfigName _ "</td>"
		                                         	Write "<td>" _ tResultItem.Namespace _ "</td>"
		                                         	Write "<td>" _ tResultItem.DownStart _ "</td>"
		                                         	Write "<td>" _ tResultItem.DownEnd _ "</td>"
		                                         	Write "<td>" _ tResultItem.Reason _ "</td>"
		                                         	Write "</tr>", !
		                                        }
		                                        
		                                        &html<
		                                        </tbody>
		                                    </table>
		                                </div>
									</div>
								</div>
							</div>
							
							<div class="panel panel-default">
								<div class="panel-heading">
									<i class="fa fa-line-chart fa-fw"></i> Year To Date (#($ZSTRIP(##class(IHC.EAI.Uptime.Util).GetYearToDate(),"<>W"))#)
								</div>
								<div class="panel-body">
									<div id="year-to-date-donut" style="height: 250px;"></div>
									<div id="year-to-date-line" style="height: 150px;"></div>
									<div class="text-center">
										<a href="#ytd-details" class="btn btn-info" data-toggle="collapse">Details</a>
									</div>
									<div class="row" style="margin-top:10px;"></div>
									<div id="ytd-details" class="collapse">
		                                <div class="table-responsive">
											<table class="table table-bordered table-hover table-striped">
												<thead>
		                                       		<tr>
		                                       			<th>Namespace</th>
		                                       			<th>Percent Up</th>
		                                       		</tr>
		                                        </thead>
		                                        <tbody>
		                                        >
		                                        
		                                        Set tResults = ##class(IHC.EAI.Uptime.Util).GetNamespaceResults(3,.tStatus)
		                                        For i=1:1:tResults.Count() {
		                                         	Set tResultItem = tResults.GetAt(i)
		                                         	Write "<tr>"
		                                         	Write "<td>" _ $PIECE(tResultItem,"|",1) _ "</td>"
		                                         	Write "<td>" _ $PIECE(tResultItem,"|",2) _ "&#37;</td>"
		                                         	Write "</tr>", !
		                                        }
		                                        
		                                        &html<
		                                        </tbody>
		                                    </table>
		                                </div>
		                                <div class="table-responsive">
		                                    <table class="table table-bordered table-hover table-striped">
		                                        <thead>
		                                        <tr>
		                                            <th>ConfigName</th>
		                                            <th>Namespace</th>
		                                            <th>DownStart</th>
		                                            <th>DownEnd</th>
		                                            <th>Reason</th>
		                                        </tr>
		                                        </thead>
		                                        <tbody>
		                                        >
		                                        
		                                        Set tResults = ##class(IHC.EAI.Uptime.Util).GetDetailResults(3,.tStatus)
		                                        For i=1:1:tResults.Count() {
		                                         	Set tResultItem = tResults.GetAt(i)
		                                         	Write "<tr>"
		                                         	Write "<td>" _ tResultItem.ConfigName _ "</td>"
		                                         	Write "<td>" _ tResultItem.Namespace _ "</td>"
		                                         	Write "<td>" _ tResultItem.DownStart _ "</td>"
		                                         	Write "<td>" _ tResultItem.DownEnd _ "</td>"
		                                         	Write "<td>" _ tResultItem.Reason _ "</td>"
		                                         	Write "</tr>", !
		                                        }
		                                        
		                                        &html<
		                                        </tbody>
		                                    </table>
		                                </div>
									</div>
								</div>
							</div>
							
						</div>
					</div>
				</div>

			</div>

			<!-- jQuery -->
			<script src="js/jquery.min.js"></script>

			<!-- Bootstrap Core JavaScript -->
			<script src="js/bootstrap.min.js"></script>

			<!-- Metis Menu Plugin JavaScript -->
			<script src="js/metisMenu.min.js"></script>

			<!-- Custom Theme JavaScript -->
			<script src="js/startmin.js"></script>
			
			<!-- raphael JavaScript -->
			<script src="js/raphael.min.js"></script>
			
			<!-- morris JavaScript -->
			<script src="js/morris.min.js"></script>
			
			<script language="JavaScript" type="text/javascript">
				Morris.Donut({
		        resize: true,
		        element: 'current-month-donut',
		        formatter: function (value, data) { return value + '%'; },
		        data: [
		         {label: "Up", value: #(##class(IHC.EAI.Uptime.Util).GetCurrentMonthResults(1))#,color: "#90c657"},
		         {label: "Down", value: #(##class(IHC.EAI.Uptime.Util).GetCurrentMonthResults(2))#,color: "#e45857"}
		        ]
			      });
			
			</script>
			
			<script language="JavaScript" type="text/javascript">
				Morris.Donut({
		        resize: true,
		        element: 'previous-month-donut',
		        formatter: function (value, data) { return value + '%'; },
		        data: [
		         {label: "Up", value: #(##class(IHC.EAI.Uptime.Util).GetPreviousMonthResults(1))#,color: "#90c657"},
		         {label: "Down", value: #(##class(IHC.EAI.Uptime.Util).GetPreviousMonthResults(2))#,color: "#e45857"}
		        ]
			      });
			
			</script>
			
			<script language="JavaScript" type="text/javascript">
				Morris.Donut({
		        resize: true,
		        element: 'year-to-date-donut',
		        formatter: function (value, data) { return value + '%'; },
		        data: [
		         {label: "Up", value: #(##class(IHC.EAI.Uptime.Util).GetYTDResults(1))#,color: "#90c657"},
		         {label: "Down", value: #(##class(IHC.EAI.Uptime.Util).GetYTDResults(2))#,color: "#e45857"}
		        ]
			      });
			
			</script>
			
			<script language="JavaScript" type="text/javascript">
				Morris.Line(#(##class(IHC.EAI.Uptime.Util).GetCurrentMonthTrends())#);
			</script>
			<script language="JavaScript" type="text/javascript">
				Morris.Line(#(##class(IHC.EAI.Uptime.Util).GetPreviousMonthTrends())#);
			</script>
			<script language="JavaScript" type="text/javascript">
				Morris.Line(#(##class(IHC.EAI.Uptime.Util).GetYTDTrends())#);
			</script>
		</body>
		</html>
   
	>
    Quit $$$OK
}

}
