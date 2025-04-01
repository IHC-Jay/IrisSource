import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';


import {WfRestServiceComponent} from '../../services/wfrest-service.component';

import { MatTableDataSource } from '@angular/material/table';


import { Router, ActivatedRoute } from '@angular/router';
import {SelectionModel} from '@angular/cdk/collections';


import {x12err} from './WfDetails';

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



  @ViewChild("statusType") statusType: ElementRef;


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
  ID:string;
  selectedRow: number = -1;
  minSelRow:number = 0
  maxSelRow:number = 0;

  wfCurrentStat:string;
  searchParams:string;

  x12Array: [x12err] = [{lnNum:'0', segId:'1', data:"TEST", segElem:'1/1', error:'Y'}];

  x12Data:string;
  selection = new SelectionModel<x12err>(false, []);


  constructor(private WfService: WfRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute){
      tpId: new FormControl();

  }

  ngOnInit()
  {
    console.info("ngOnInit");

    this.form = this.formBuilder.group({
      statusType: ['', Validators.required]
    });

    this.form.controls.statusType.setValue(this.statusTypes[0]);
     this.wfStatus = this.statusTypes[0];

    this.sub = this.route
    .queryParams
    .subscribe(searchParams => {
      // Defaults to 0 if no query param provided.
      this.ID = ''+searchParams['ID'] || '0';
      this.searchParams = searchParams['searchParams'];

      let fInd = this.searchParams.indexOf("status::") + "status::".length;
      let val = this.searchParams.substring( fInd, this.searchParams.indexOf(";", fInd))
      console.log(fInd + ". statusType:" + val )

      this.wfStatus = val

      console.log('Query params ID: ', this.ID + ', params: ' + this.searchParams );
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
  console.log("Call service for " +this.ID +", ", this.wfStatus);
    this.WfService.fetchWorkFlowEntry("ID=" + this.ID ).subscribe((res: any) => {

      console.log("# of records: " + res.length)
      let x12DataLns = res[0].X12.split("~")
      this.errorStr = "Workflow ID: " + this.ID + ", Status: " + this.wfStatus + "\n" + (String)(res[0].Error).replaceAll(";", "\n") + "\n" + "Number of errors: " + (res.length - 1);
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
              console.log("Push Row: " + segStr +", " + err)
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

  console.info("Update WorkFlowItem ID: " +this.ID +",  status: " +  this.wfStatus)
  if (this.wfStatus !== '')
  {
    let paramsList: string[]= [];

    paramsList.push("ID::" + this.ID);
    paramsList.push("Status::" +  this.wfStatus);
    paramsList.push("AssignedUser::" + "");

    this.WfService.updateWorkFlowItem(paramsList).subscribe((res: any) => {
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

      console.log('To WorkFlow: ' );
      this.router.navigate(["/workflow/"],

      {
        queryParams: {'searchParams': this.searchParams }
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
