
import { SelectionModel } from "@angular/cdk/collections";
import { Component, OnInit } from "@angular/core";
import { MatTableDataSource } from "@angular/material/table";

import { Router, ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';

import {TransRestServiceComponent} from '../services/transrest-service.component';
import {WorkFlowEntry} from './WorkFlowEntry';



@Component({
  selector: 'app-workflow',
  templateUrl: './workflow.component.html',
  styleUrls: ['./workflow.component.css']
})
export class WorkflowComponent implements OnInit {

  form!: FormGroup;

  displayedColumns: string[] = [
    'Select',
    'InterchangeSenderID',
    'InterchangeReceiverID',
    'TransactionType',
    'CreateDtTm',
    'ErrorType',
    'WorkStatus',
    'WorkUser',
    'Details'];

    displayLabel: string = "Display columns:";
    statusTypes = [
      "New",
      "Assigned",
      "Resolved",
      "Ignored"
    ];

    updStatusTypes = [
      "Resolved",
      "Ignored"
    ];

    maxCount = ["10", "25", "50", "100", "200"];

    transactionTypes: string[] = ["All", "270", "271","276", "277", "277CA", "835", "837", "837I", "837P", "837D"];
    errorTypes: string[] =['All','Data', 'TP']

  statusTypeString = 'New';
  transTypeStr = '835';
  errorTypeStr = 'All';
  submitted = false;
  canRenderDetails = false;
  rowSelected : number = 0;
  sub:any;
  updStatus: string ='';

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
      updStatusType: ['', Validators.required]
    });

    this.sub = this.route.queryParams.subscribe(params => {
		  // Defaults to '' if no query param provided.

		  this.transTypeStr =  params['transaction'] || '';
		  this.errorTypeStr =  params['errorTypeString'] || '';
		  this.statusTypeString = params['statusTypeString'];

		  console.log('ngOnInit - Query params ' + this.statusTypeString +", transType: " + this.transTypeStr);


		  if (this.transTypeStr !== '')
		  {
        this.form.controls.statusType.setValue(this.statusTypeString);
        this.statusTypeChange(null);
        this.form.controls.transType.setValue(this.transTypeStr);
        this.form.controls.errorType.setValue(this.errorTypeStr);
        this.form.controls.rowCnt.setValue("25");

			if (this.transTypeStr !== '')
			{
			  this.searchTransaction = true;
			}
			console.log('set search controls, ' + this.searchTransaction);
		  }


    });
    if (this.searchTransaction == false)
    {
		  this.form.controls.rowCnt.setValue(this.maxCount[1]);
		  this.form.controls.statusType.setValue(this.statusTypes[0]);
		  this.form.controls.transType.setValue(this.transactionTypes[0])
		  this.form.controls.errorType.setValue(this.errorTypes[0])
      this.form.controls.updStatusType.setValue(this.updStatusTypes[0])

		  this.statusTypeString = this.statusTypes[0];
		  this.transTypeStr = this.transactionTypes[0];
		  this.errorTypeStr = this.errorTypes[0];
    }
    else{
      this.GetWFs()
    }

  }


GetWFs()
{

  console.info("fetchWorkFlowItems statusTypes: " +this.statusTypeString +",  TransType: " +  this.transTypeStr)

  if (this.form.controls.transType.value === '' && this.transTypeStr !== '')
  {
    this.form.controls.transType.setValue(this.transTypeStr);
  }

  this.WfService.fetchWorkFlowItems(this.transTypeStr, this.statusTypeString, this.errorTypeStr, this.form.controls.rowCnt.value).subscribe((res: any) => {
    this.dataSource.data = res;
    this.canRenderDetails = true;

    console.info("WorkFlowItems array: " + this.dataSource.data.length  );

   });

 }

 statusTypeChange(evt: any)
 {
   this.statusTypeString = this.form.controls.statusType.value
 }

 updStatusTypeChange (evt: any)
 {
   this.updStatus = this.form.controls.updStatusType.value
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
  console.log('Row clicked, id: ' + row.id + ", Transaction: " + this.transTypeStr + ', statusTypeString: '+ this.statusTypeString );
 this.router.navigate(["/workflow/workflowDetails/"],
  {queryParams: { id:  row.id, 'workflow': this.form.controls.transType.value, 'statusTypeString': this.statusTypeString, 'errorTypeString': this.errorTypeStr } }
   );

}
/** Whether the number of selected elements matches the total number of rows. */
isAllSelected() {
  this.rowSelected = this.selection.selected.length;
  const numRows = this.dataSource.data.length;
  return this.rowSelected === numRows;
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

   if(this.updStatus !== '')
   {
      console.info("Update WorkFlowItem to " + this.updStatus)
      this.selection.selected.forEach(row => {
          console.info("ID: " + row.id +"-> " + this.updStatus)

          this.WfService.updateWorkFlowItem(row.id, this.updStatus).subscribe((res: any) => {
            this.dataSource.data = res;
            this.canRenderDetails = true;

          });

        });

      this.selection.clear();
      this.rowSelected  = 0;
      this.GetWFs();
   }

  }

}



