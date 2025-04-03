import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';


import {WfRestServiceComponent} from '../../services/wfrest-service.component';

import { MatTable,  MatTableDataSource } from '@angular/material/table';


import { Router, ActivatedRoute } from '@angular/router';
import {SelectionModel} from '@angular/cdk/collections';
import { BrowserModule } from '@angular/platform-browser';
import { MatPaginator } from '@angular/material/paginator';

import { BrowserAnimationsModule } from '@angular/platform-browser/animations';


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
  @ViewChild('dataPaginator') dataPaginator: MatPaginator;
  @ViewChild('errPaginator') errPaginator: MatPaginator;
  @ViewChild(MatTable) table!: MatTable<any>;

  ngAfterViewInit() {
    this.dataSource.paginator = this.dataPaginator;
    this.errorDataSource.paginator = this.errPaginator;
  }

  statusTypeString = "";
  wfStatus: string = "";
  transTypeStr = '';
  errorTypeStr = '';
  submitted = false;
  rowClicked:number;

  pageLength= 25;
  pageIndex = 1;
  pageSize = 25;

  errPageSize = 5
  errPageLength = 5;
  errPageIndex = 1;

  canRenderDetails = false;
  dataSource = new MatTableDataSource<any>();
  errorDataSource = new MatTableDataSource<any>();
  checked = false;
  errorStr:string = "";


  dataTableLabel:string[] =  ['#', 'Segment', 'X12 Data', 'Segment/Element']; // , 'Error'];
  dataTableKey: string[] = ['lnNum', 'segId', 'data', 'segElem']; //, 'error'];

  displayedColumns: string[] = [
    'Num', 'Segment', 'Error'
  ]

  isEdit: boolean = false;
  isSelected: boolean = true;

  sub:any;
  ID:string;
  selectedRow: number = -1;

  wfCurrentStat:string;
  searchParams:string;

  x12Array: [x12err] = [{lnNum:'0', segId:'1', data:"TEST", segElem:'1/1', error:'Y'}];
  errArray:any[] = [];

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


        // First record - WF entry
        let x12DataLns = res[0].X12.split("~")
        let sep = res[0].X12.substr(3, 1)
        console.log("Sep: " + sep)
        this.errorStr = "Workflow ID: " + this.ID + ", Filename:" + res[0].Filename + ", Status: " + this.wfStatus + "\n" + (String)(res[0].Error).replaceAll(";", "\n") + "\n" ;
        this.wfCurrentStat = res[0].Status;
        this.x12Array.splice(0, this.x12Array.length)
        let segNum = 0
        let segEle = ""
        this.selectedRow = -1;


        let errFound:boolean = false;
        let transCtrlNum =0

        x12DataLns.forEach((item, index) => {
          let err = '';
          segEle ='';



          if(segNum >= 1)
            {
              segNum++;
            }

            if(item.startsWith('ST' + sep))
            {
              segNum = 1
              const words = item.split(sep);
              transCtrlNum = words[2]
              // console.log("ST: " + transCtrlNum + ", " + segNum)
            }

            // Error details

            for (var ind=1; (ind < res.length && segNum > 0); ind++) {


              if(segNum == res[ind].segNum && transCtrlNum  == res[ind].stNum)
              {
                segEle = res[ind].segNum +"/" + res[ind].eleNum
                err =  res[ind].segErrStr + "(" + res[ind].segErrCode + ") / "  + res[ind].eleErrStr +"("+ res[ind].eleErrCode +")" +" Element: " +
                res[ind].eleNum;

                if (this.selectedRow === -1 && err !== '')
                {
                  this.selectedRow = index + 1;

                }

                console.log(transCtrlNum +" == " + res[ind].stNum +": " + err)
                break;
              }
            }


            if(item !== '')
            {
              let segStr = (segNum==0)?'-':segNum.toString();

              if(err !== '')
                {
                  this.errArray.push({'Num': ind, 'Segment':(index+1), 'Error' : err})
              }
              if (this.checked) // Show errors only
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
                // console.log("SE: " + transCtrlNum + ", " + segNum)
                segNum = 0
                transCtrlNum =0
              }


        });


      console.log(this.checked + ", x12Array: " + this.x12Array.length +", errors:" + this.errArray.length)
      if (this.errArray.length > 0)
      {
        this.errorStr += "Number of errors: " +this.errArray.length;
      }

      if(!errFound)
      {
        this.selectedRow = 0
      }
      this.dataSource.data = this.x12Array;
      this.errorDataSource.data = this.errArray;
      console.log("# of lines: "  + ", " + this.errorDataSource.data.length  )
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

  SelectNextError(lnNum:string)
  {
   for(var ind=this.selectedRow+1; ind < this.x12Array.length; ind++){
      if(this.x12Array[ind].error != '' && this.x12Array[ind].lnNum == lnNum )
      {
          this.selectedRow = ind+1;

          this.dataPaginator.pageIndex = Math.floor(this.selectedRow / this.dataPaginator.pageSize)

          console.log("Next Found row " + this.selectedRow +", pageIndex: " + this.dataPaginator.pageIndex)

          this.pageIndex =  this.dataPaginator.pageIndex;


          break;

      }
   }
  }

  SelectPrevError(lnNum:string)
  {
   for(var ind=this.selectedRow-2; ind > 0 ; ind--){
      if(this.x12Array[ind].error != ''  && this.x12Array[ind].lnNum == lnNum )
      {
          this.selectedRow = ind+1;

          this.dataPaginator.pageIndex =  Math.floor(this.selectedRow / this.dataPaginator.pageSize)
          this.pageIndex =  this.dataPaginator.pageIndex;

          console.log("Prev Found row " + this.selectedRow +", pageIndex: " + this.dataPaginator.pageIndex)
          break;

      }
   }

  }

  onErrPaginateChange(event: any)
  {
    console.log("onErrPaginateChange: " + event.pageIndex);
  }
  onPaginateChange(event: any)
  {
    console.log("onPaginateChange: " + event.pageIndex);


    this.dataPaginator.pageIndex =  event.pageIndex
    this.selectedRow  = (this.pageIndex * this.dataPaginator.pageSize) + 1
    this.pageIndex =  this.dataPaginator.pageIndex;

    this.dataSource.data = this.x12Array;
    this.table.renderRows();

  }

  OnErrorRowClick(evt:any, idx)
  {
     this.selection.select(evt.Segment)
     console.log(evt.Segment +", "  + this.selectedRow +", page Size: " + this.dataPaginator.pageSize)


      if(this.rowClicked === idx) this.rowClicked = -1;
      else this.rowClicked = idx;

      if (evt.Segment == this.selectedRow)
      {
        this.selectedRow = 1
      }
     else if (evt.Segment > this.selectedRow)
     {
      this.SelectNextError(evt.Segment)
     }
      else{
        this.SelectPrevError(evt.Segment)
      }

      const ele = document.querySelectorAll("table");
      ele.forEach(element => {

        if (element.id === 'wftab'){
          console.log("scrollIntoView: " + element.nodeName +": " + element.id)
          element.scrollIntoView();

        }
      });
      this.dataSource.data = this.x12Array;
      this.table.renderRows();

     console.log(evt)
  }
  OnRowClick(evt:any)
  {
    this.selectedRow = evt.lnNum
    console.log("Selected row: "  + evt.lnNum)
  }

}
