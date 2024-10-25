import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';

import {TransRestServiceComponent} from '../../services/transrest-service.component';
import { MatTableDataSource } from '@angular/material/table';

import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { Router, ActivatedRoute } from '@angular/router';
import {SelectionModel} from '@angular/cdk/collections';


import {MatNativeDateModule} from '@angular/material/core';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatFormFieldModule} from '@angular/material/form-field';
import {MatCheckboxModule} from '@angular/material/checkbox';
import {MatCardModule} from '@angular/material/card';
import {x12err} from './WfDetails';
import { MatRow } from '@angular/material/table';

@Component({
  selector: 'app-workflowDetails',
  templateUrl: './workflowDetails.component.html',
  styleUrls: ['./workflowDetails.component.css']
})



export class WorkflowDetailsComponent implements OnInit {
  displayLabel: string = "Display columns:";
  statusTypes = [
    "Assigned",
    "Resolved",
    "Ignored"
  ];

  form!: FormGroup;

  @ViewChild("searchValue") searchValue: ElementRef;
  @ViewChild("searchField") searchField: ElementRef;

  @ViewChild("statusType") statusType: ElementRef;
  @ViewChild("rowCnt") rowCnt: ElementRef;
  @ViewChild("transType") transType: ElementRef;
  @ViewChild("errorType") errorType: ElementRef;

  @ViewChild("matStartDate") matStartDate: string;
  @ViewChild("matEndDate") matEndDate: string;

  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;


  statusTypeString = "";
  wfStatus: string = "";
  transTypeStr = '';
  errorTypeStr = '';
  submitted = false;
  canRenderDetails = false;
  dataSource = new MatTableDataSource<any>();
  checked = false;
  errorStr:string = "";


  dataTableLabel:string[] =  ['#', 'Segment', 'Data', 'Segment/Element', 'Error'];
  dataTableKey: string[] = ['lnNum', 'segId', 'data', 'segElem', 'error'];


  isEdit: boolean = false;
  isSelected: boolean = true;

  sub:any;
  id:string;
  selectedRow: number = -1;
  minSelRow:number = 0
  maxSelRow:number = 0;

  transaction:string;
  wfCurrentStat:string;

  x12Array: [x12err] = [{lnNum:'0', segId:'1', data:"TEST", segElem:'1/1', error:'Y'}];

  x12Data:string;
  selection = new SelectionModel<x12err>(false, []);


  constructor(private WfService: TransRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute){
      tpId: new FormControl();

  }

  ngOnInit()
  {
    console.info("ngOnInit");

    this.form = this.formBuilder.group({
      statusType: ['', Validators.required],
      rowCnt:['', Validators.required],
      transType: ['', Validators.required],
      errorType: ['', Validators.required]
    });

    this.form.controls.statusType.setValue(this.statusTypes[0]);
     this.wfStatus = this.statusTypes[0];

    this.sub = this.route
    .queryParams
    .subscribe(params => {
      // Defaults to 0 if no query param provided.
      this.id = ''+params['id'] || '0';
      this.transaction = ''+params['workflow'] || '0';

      this.statusTypeString = params['statusTypeString'];
      this.errorTypeStr = params['errorTypeString'];
      console.log('Query params id: ', this.id + ', trans: ' + this.transaction +", statusTypeString: " + this.statusTypeString);
    });
    this.getX12();

  }
  get f() { return this.form.controls; }

  statusTypeChange(evt: any)
{
  console.info("statusTypeChange: " + this.form.controls.statusType.value)
  this.wfStatus = this.form.controls.statusType.value
}


getX12()
{
  this.canRenderDetails = false;
  console.log("Call service for " +this.id +", ", this.wfStatus);
    this.WfService.fetchWorkFlowEntry("id=" + this.id ).subscribe((res: any) => {

      console.log("# of records: " + res.length)
      let x12DataLns = res[0].X12.split("~")
      this.errorStr = (String)(res[0].Error).replaceAll(";", "\n");
      this.wfCurrentStat = res[0].Status;
      this.x12Array.splice(0, this.x12Array.length)
      let segNum = 0
      let segEle = ""
      this.selectedRow = -1;


      let errFound:boolean = false;
      x12DataLns.forEach((item, index) => {
          let err = '';
          segEle ='';


          if(segNum >= 1)
            {
              segNum++;
            }

            if(item.startsWith('ST*') || item.startsWith('ST|'))
            {
              segNum = 1
            }


          for (var ind=1; (ind < res.length && segNum > 0); ind++) {

            if(segNum == res[ind].segNum)
            {
              segEle = res[ind].segNum +"/" + res[ind].eleNum
              err =  res[ind].segErrStr + "(" + res[ind].segErrCode + ") / "  + res[ind].eleErrStr +"("+ res[ind].eleErrCode +")";

              if (this.selectedRow === -1 && err !== '')
              {
                this.selectedRow = index + 1;
                this.minSelRow = this.selectedRow;
              }
              this.maxSelRow = index+1;

              break;
            }
          }


          if(item !== '')
          {
            let segStr = (segNum==0)?'-':segNum.toString();

            if (this.checked)
            {
              if(err !== '')
              {
                this.x12Array.push({lnNum:(index+1), segId:segStr, data: item, segElem:segEle, error:err});
                errFound = true;
              }
            }
            else
            {
              this.x12Array.push({lnNum:(index+1), segId:segStr, data: item, segElem:segEle, error:err});

            }
          }
          if(item.startsWith('SE*') || item.startsWith('SE|'))
            {
              segNum = 0
            }

        });

      console.log(this.checked + ", x12Array: " + this.x12Array.length +", errors:" + errFound)

      if(!errFound)
      {
        this.selectedRow = 0
        console.log(this.selectedRow +", min: " + this.minSelRow +", max: " + this.maxSelRow)
      }
      this.dataSource.data = this.x12Array;
      console.log("# of lines: " + this.dataSource.data.length  )
      this.canRenderDetails = true;

      console.log("Remove " + this.wfCurrentStat +" from " + this.statusTypes.length)

      var index = this.statusTypes.indexOf(this.wfCurrentStat); // get index if value found otherwise -1

      if (index > -1) { //if found
        this.statusTypes.splice(index, 1);
      }

    });


}


 updateWF()
 {

  console.info("Update WorkFlowItem id: " +this.id +",  status: " +  this.wfStatus)
  if (this.wfStatus !== '')
  {

    this.WfService.updateWorkFlowItem(this.id, this.wfStatus, '').subscribe((res: any) => {
      this.dataSource.data = res;
      this.canRenderDetails = true;

      console.info("WorkFlowItems array: " + this.dataSource.data.length +", " + this.dataTableKey[1] +", " + this.dataTableLabel[1]);
      if (this.wfStatus !== 'Assigned')
      {
         this.toWorkFlow();
      }
    });
  }

 }

 clickChkBox()
 {
  this.checked = !this.checked;
  this.getX12();
 }

 toWorkFlow()
  {

      console.log('To WorkFlow: ' + this.transaction );
      this.router.navigate(["/workflow/"],

      {
        queryParams: { transaction: this.transaction,
          'statusTypeString': this.statusTypeString, 'errorTypeString': this.errorTypeStr }
    }

       );
  }

  SelectNextError()
  {
   for(var ind=this.selectedRow+1; ind < this.x12Array.length; ind++){
      if(this.x12Array[ind].error != '')
      {
          this.selectedRow = ind+1;

          const ele = document.querySelectorAll("table");

          ele.forEach(element => {

            if (element.id === 'wftab'){
              console.log("scrollIntoView: " + element.nodeName +": " + element.id)
              element.scrollIntoView();
            }
          });



          break;

      }
   }
  }

  SelectPrevError()
  {
   for(var ind=this.selectedRow-2; ind > 0 ; ind--){
      if(this.x12Array[ind].error != '')
      {
          this.selectedRow = ind+1;
          break;

      }
   }

  }

  OnRowClick(evt)
  {
    this.selection.select(evt.lnNum)
   console.log(this.selection.selected)
  }

}
