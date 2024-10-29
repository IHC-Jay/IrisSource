
import { SelectionModel } from "@angular/cdk/collections";
import { Component, OnInit, ViewChild } from "@angular/core";
import { MatTableDataSource } from "@angular/material/table";

import { Router, ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';

import {TransRestServiceComponent} from '../services/transrest-service.component';
import {WorkFlowEntry, IrisUsers} from './WorkFlowEntry';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';

@Component({
  selector: 'app-workflow',
  templateUrl: './workflow.component.html',
  styleUrls: ['./workflow.component.css']
})
export class WorkflowComponent implements OnInit {

  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;

  form!: FormGroup;

  nowDt = new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));

  startDate = "2023-01-12";
  endDate ="13:30";
  startTm = "13:30";
  endTm= "2023-01-12";

  displayedColumns: string[] = [
    'Select',
    'InterchangeSenderID',
    'InterchangeReceiverID',
    'TransactionType',
    'CreateDtTm',
    'ErrorType',
    'WorkStatus',
    'WorkUser',
    'LastmodDtTM',
    'LastmodID',
    'Details'
];

    displayLabel: string = "Display columns:";
    statusTypes = [
      "New",
      "Assigned",
      "Resolved",
      "Ignored"
    ];

    updStatusTypes = [
      "Assigned",
      "Resolved",
      "Ignored"
    ];

    maxCount = ["10", "25", "50", "100", "200"];

    transactionTypes: string[] = ["All", "270", "271","276", "277", "277CA", "835", "837", "837I", "837P", "837D"];
    errorTypes: string[] =['All','Data', 'TP','Connection','Ack','Duplicate']

  statusTypeString = 'New';
  transTypeStr = '835';
  errorTypeStr = 'All';

  canRenderDetails = false;
  rowSelected : number = 0;
  sub:any;
  updStatus: string = this.updStatusTypes[0];

  irisUsers: IrisUsers[] = [];

  dataSource = new MatTableDataSource<WorkFlowEntry>();
  selection = new SelectionModel<WorkFlowEntry>(true, []);
  displayType = 1;
  searchTransaction = false;

  constructor(private WfService: TransRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute){
      tpId: new FormControl();

  }
  get f() { return this.form.controls; }

  ngOnInit() {

    this.form = this.formBuilder.group({
      statusType: ['', Validators.required],
      rowCnt:['', Validators.required],
      transType: ['', Validators.required],
      errorType: ['', Validators.required],
      rowSelected: [''],
      updStatusType: ['', Validators.required],
      assignee:['']
    });
    this.canRenderDetails = false;
    this.irisUsers = [];

    this.sub = this.route.queryParams.subscribe(params => {

      if(params !== undefined && params.searchParams !== undefined)
        {
          let searchParams =  params['searchParams'];

          let fInd = searchParams.indexOf("transaction::") + "transaction::".length;
          let val = searchParams.substring( fInd, searchParams.indexOf(";", fInd))
          this.transTypeStr =  val;
          this.form.controls.transType.setValue(this.transTypeStr);

          fInd = searchParams.indexOf("errorType::") + "errorType::".length;
          val = searchParams.substring( fInd, searchParams.indexOf(";", fInd))
          this.errorTypeStr =  val;
          this.form.controls.errorType.setValue(this.errorTypeStr);
          console.log("ngOnInit - errorType: " + this.errorTypeStr);

          fInd = searchParams.indexOf("status::") + "status::".length;
          val = searchParams.substring( fInd, searchParams.indexOf(";", fInd))
          this.statusTypeString = val;
          this.form.controls.statusType.setValue(this.statusTypeString);

          fInd = searchParams.indexOf("count::") + "count::".length;
          val = searchParams.substring( fInd, searchParams.indexOf(";", fInd))
          this.form.controls.rowCnt.setValue(val)
          console.log("rowCnt: " + val)

          fInd = searchParams.indexOf("startDtTm::") + "startDtTm::".length;
          let fInd2 = searchParams.indexOf(" ", fInd)
          val = searchParams.substring( fInd, fInd2)
          console.log(fInd + ". startDate:" + val )
          this.startDate = val

          let fInd3 = searchParams.indexOf(";", fInd2)
          val = searchParams.substring( fInd2+1, fInd3)
          console.log(fInd + ". startTm:" + val )
          this.startTm = val

          fInd = searchParams.indexOf("endDtTm::") + "endDtTm::".length;
          fInd2 = searchParams.indexOf(" ", fInd)
          val = searchParams.substring( fInd, fInd2)
          console.log(fInd + ". endDate:" + val )
          this.endDate = val

          fInd3 = searchParams.indexOf(";", fInd2)
          val = searchParams.substring( fInd2+1, fInd3)
          console.log(fInd + ". endTm:" + val )
          this.endTm = val

          console.log('ngOnInit - Query params ' + this.statusTypeString +", transType: " + this.transTypeStr);
          this.form.controls.updStatusType.setValue(this.updStatusTypes[0])

          this.onSubmit()

        }
        else
        {
          console.log('ngOnInit - No Query params ')

          this.nowDt = new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));
          let mm= (this.nowDt.getMonth() < 9)? "0"+(this.nowDt.getMonth() + 1): this.nowDt.getMonth() + 1;
          let dt= (this.nowDt.getDate() < 10)? "0"+this.nowDt.getDate(): this.nowDt.getDate();
          this.startDate = this.nowDt.getFullYear() +"-" + mm +"-" + dt; //  "2023-01-12"; // new Date();
          let tmVal = ((this.nowDt.getHours()< 10)? "0"+ this.nowDt.getHours() : "" + this.nowDt.getHours()) + ":" ;

          tmVal += (this.nowDt.getMinutes() < 10)? "0"+ this.nowDt.getMinutes(): "" + this.nowDt.getMinutes(); // "13:30";
          this.startTm = tmVal
          this.endTm= tmVal
          console.info("Time: " + tmVal)
          this.nowDt = new Date(new Date().getTime());
          mm= (this.nowDt.getMonth() < 9)? "0"+(this.nowDt.getMonth() + 1): this.nowDt.getMonth() + 1;
          dt= (this.nowDt.getDate() < 10)? "0" + this.nowDt.getDate(): this.nowDt.getDate();
          this.endDate =this.nowDt.getFullYear() +"-" + mm +"-" + dt;

          this.form.controls.rowCnt.setValue(this.maxCount[1]);
          this.form.controls.statusType.setValue(this.statusTypes[0]);
          this.form.controls.transType.setValue(this.transactionTypes[0])
          this.form.controls.errorType.setValue(this.errorTypes[0])
          this.form.controls.updStatusType.setValue(this.updStatusTypes[0])

          this.statusTypeString = this.statusTypes[0];
          this.transTypeStr = this.transactionTypes[0];
          this.errorTypeStr = this.errorTypes[0];
        }

    });


  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;

  }

onSubmit()
{

  console.info("fetchWorkFlowItems statusTypes: " +this.statusTypeString +",  TransType: " +  this.transTypeStr +", count: " + this.form.controls.rowCnt.value)

  if (this.form.controls.transType.value === '' && this.transTypeStr !== '')
  {
    this.form.controls.transType.setValue(this.transTypeStr);
  }

  console.debug("startDtTm::" + this.startDate +" "+ this.startTm);

  console.debug("endDtTm::" + this.endDate+" " +this.endTm );


  this.WfService.fetchWorkFlowItems(this.transTypeStr, this.statusTypeString, this.errorTypeStr, this.form.controls.rowCnt.value,
    "BETWEEN '" + this.startDate +" "+ this.startTm +"' AND '" + this.endDate+" " +this.endTm +"'"
  ).subscribe((res: any) => {
    this.dataSource.data = res;
    this.canRenderDetails = true;

    console.info("WorkFlowItems array: " + this.dataSource.data.length  );
    this.paginator.pageSize = this.form.controls.rowCnt.value;

   });

 }

 onRowCnt()
      {
        console.info('Set paginator.pageSize: ' + this.form.controls.rowCnt.value)
        this.paginator.pageSize = this.form.controls.rowCnt.value;
        this.dataSource.paginator = this.paginator
}

 statusTypeChange(evt: any)
 {
   this.statusTypeString = this.form.controls.statusType.value
 }

 updStatusTypeChange (evt: any)
 {
   this.updStatus = this.form.controls.updStatusType.value
   console.log("updStatusTypeChange: " + this.updStatus)
 }


transTypeChange(evt: any)
{
  console.info("transTypeChange: " + this.form.controls.transType.value)
  this.transTypeStr = this.form.controls.transType.value
}

errorTypeChange(evt: any)
{
  console.info("errorTypeChange: " + this.form.controls.errorType.value)
  this.errorTypeStr = this.form.controls.errorType.value
}

onRowClicked(row) {

  let searchParamsString = "errorType::" + this.form.controls.errorType.value +";" +
          "transaction::"+this.form.controls.transType.value +";" +
          "status::"+this.form.controls.statusType.value +";" +
          "startDtTm::" + this.startDate +" "+ this.startTm +";" +
          "endDtTm::" + this.endDate+" " +this.endTm +";" +
          "count::" + this.form.controls.rowCnt.value +";"  ;

  console.log('Row clicked, id: ' + row.id + ", Transaction: " + searchParamsString);

 this.router.navigate(["/workflow/workflowDetails/"],
  {queryParams: { id:  row.id,  searchParams:  searchParamsString } }
   );

}
/** Whether the number of selected elements matches the total number of rows. */
isAllSelected() {
  this.rowSelected = this.selection.selected.length;
  const numRows = this.dataSource.data.length;
  // console.log("isAllSelected: " + this.rowSelected +"===" + numRows)
  return this.rowSelected === numRows;
  this.getUsers();
}

singleToggle(row)
{
  console.log('# of rows checked: ' + this.selection.selected.length)
  console.log('Row Find: ' + row.id + ": " + this.selection.isSelected(row));

  if (this.selection.isSelected(row))
  {
    this.selection.deselect(row)
  }
  else
  {
    this.selection.select(row);
    this.getUsers();
  }
  this.rowSelected = this.selection.selected.length;
  // this.dataSource.data.forEach(row => this.selection.select(row));
  console.log('Row count:' + this.selection.selected.length)

}

getUsers()
{
  if ( this.irisUsers.length <= 0)
  {
    this.WfService.fetchIrisUsers().subscribe((res: any) => {
      this.irisUsers = res;

      console.info("Users array: " + this.irisUsers.length  );


    });
  }
}

updUserChange(event: any)
{

}

/** Selects all rows if they are not all selected; otherwise clear selection. */
masterToggle() {
  if(this.isAllSelected())
  {
      this.selection.clear()
      this.rowSelected = 0
  }
  else{
      this.dataSource.data.forEach(row => this.selection.select(row));
      this.rowSelected = this.selection.selected.length;
  }
}

updateWF()
 {
  let assignUsr = this.form.controls.assignee.value
  let assignee = '';


   for (let usr of this.irisUsers){

    if (usr.FullName === assignUsr)
    {
      assignee = usr.UserName;
      break;
    }

  };
  console.info("Update WorkFlow: " + this.selection.selected.length + " to " + this.updStatus +", user: " + assignUsr + ", " + assignee);

  if(this.updStatus !== '')
   {
      console.info("Update WorkFlowItem to " + this.updStatus)


      if (this.updStatus === 'Assigned' && assignUsr === '')
        {
          alert("Assignee is required")
        }
        else
        {
          this.selection.selected.forEach(row => {
              console.info("ID: " + row.id +"-> " + this.updStatus)

              this.WfService.updateWorkFlowItem(row.id, this.updStatus, (this.updStatus === 'Assigned')? assignee : '').subscribe((res:any) => {
                console.info("updateWorkFlowItem complete")
                this.selection.clear();
                this.rowSelected  = 0;
                this.onSubmit();
                this.canRenderDetails = true;


              });

            });


        }
   }


  }

 assignWF()
 {
  console.info("Assign WorkFlow: " + this.selection.selected.length );

      this.selection.selected.forEach(row => {
          console.info("ID: " + row.id +"-> 'Assigned'")

          this.WfService.updateWorkFlowItem(row.id, 'Assigned', '').subscribe((res: any) => {
            this.dataSource.data = res;
            error: err => console.error("Error in updateWorkFlowItem: " + err)
            complete: () =>
              {
                console.info("updateWorkFlowItem complete")
                this.selection.clear();
                this.rowSelected  = 0;
                this.onSubmit();
                this.canRenderDetails = true;
              }
          });


        });




  }

  onStDateChange(event: Event)
{

  // Get the new input value
  const newValue = (event.target as HTMLInputElement).value;
  // Perform actions based on the new value
  this.startDate = newValue;
  console.log('Input value changed:', newValue +", " + this.startDate);
}

onStTimeChange(event: Event)
{

  // Get the new input value
  const newValue = (event.target as HTMLInputElement).value;
  // Perform actions based on the new value
  this.startTm = newValue;
  console.log('Input value changed:', newValue +", " + this.startTm);
}
onEndDateChange(event: Event)
{

  // Get the new input value
  const newValue = (event.target as HTMLInputElement).value;
  // Perform actions based on the new value
  this.endDate = newValue;
  console.log('Input value changed:', newValue +", " + this.endDate);
}
onEndTimeChange(event: Event)
{

  // Get the new input value
  const newValue = (event.target as HTMLInputElement).value;
  // Perform actions based on the new value
  this.endTm = newValue;
  console.log('Input value changed:', newValue +", " + this.endTm);
}

}



