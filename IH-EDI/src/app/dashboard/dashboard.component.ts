import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormArray, FormControl, Validators, NgForm } from '@angular/forms';


import {TransRestServiceComponent} from '../services/transrest-service.component';
import { MatTableDataSource } from '@angular/material/table';

import { Router, ActivatedRoute } from '@angular/router';

import {DisplayColumns} from '../transaction/DisplayColumns'

import { MatMenu, MatMenuTrigger } from '@angular/material/menu';

import { catchError } from 'rxjs';

import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';


@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.component.html',
    styleUrls: ['./dashboard.component.css'],
    standalone: false
})


export class DashBoardComponent implements OnInit {


  public barChartOptions:any = {
    scaleShowVerticalLines: false,
    responsive: true
  };

    public mbarChartLabels:string[] = [];

    public barChartType:string = 'bar';
    public barChartLegend:boolean = true;


  public barChartData:any[] = [];


  contextMenuPosition = { x: '0px', y: '0px' };
  @ViewChild(MatMenuTrigger)
  contextMenu: MatMenuTrigger;

  nowDt = new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));

  startDate = "2023-01-12";
  startTm = "13:30";
  endDate= "2023-01-12";
  endTm ="13:30";

  paramsList: string[];

  loading:boolean = false;
  searchDashBoard:boolean = false;


  form!: FormGroup;
  dataTableLabel: string[] = [];
  dataTableKey: string[] = [];
  canRenderDetails = false;


  dataSource = new MatTableDataSource<any>;


  additionalsearchString = "";
  searchTypeString = "";
  currentTransType = '270';
  currentMode = 'Batch';
  sub:any;

  constructor(private DashBoardService: TransRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute, public dialog: MatDialog){
      tpId: new FormControl();

  }




  ngOnInit()
  {
    console.info("ngOnInit");


    this.currentTransType = ''

    this.sub = this.route.queryParams.subscribe(params => {

      if(params !== undefined && params.dashboard !== undefined)
        {
          // Defaults to '' if no query param provided.

          this.currentTransType =  params['transaction'] || '';
          this.additionalsearchString = params['additionalSearch'] || '';
          this.searchTypeString = params['searchTypeString'];

        }

          if (this.searchTypeString === null || this.searchTypeString.length == 0)
            {
              console.info('no query params')
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
            }

    });
    this.onSearchDashBoard();

  }



  onSearchDashBoard()
    {
      this.canRenderDetails = false;
      this.paramsList = [];
      this.paramsList.push("mode::Batch");
      this.paramsList.push("transaction::"+this.currentTransType);
      this.paramsList.push("status::Processed" );

      this.paramsList.push("startDtTm::" + this.startDate +" "+ this.startTm);

      this.paramsList.push("endDtTm::" + this.endDate+" " +this.endTm );
      this.paramsList.push("count::25" );

      if(this.additionalsearchString !== "")
      {
        this.paramsList.push("sql::" + this.additionalsearchString);
      }


      this.loading = true;

      let staticSearchStr = "";


      if(this.additionalsearchString.length > 0)
        {
          console.info("additionalsearchString: " + this.additionalsearchString)
          staticSearchStr = staticSearchStr + " AND " + this.additionalsearchString

        }
      if(staticSearchStr.length > 3)
      {
          staticSearchStr = staticSearchStr.replace('AND','') // Remove first AND
          this.paramsList.push("sql::" + staticSearchStr);
      }
      this.paramsList.push("dashboard::1");

      this.searchTypeString = "";
      this.paramsList.forEach( val => {
        this.searchTypeString += val +";";
       });

      sessionStorage.setItem("searchTypeString", this.searchTypeString)

          this.DashBoardService.fetchDashboardentries(this.paramsList).subscribe((res: any) => {

            console.info("Data rows array: " + res.length);
            this.dataTableLabel = [];
            this.dataTableKey = [];

            this.dataTableLabel.push("Transaction");
            this.dataTableKey.push("Transaction");
            this.dataTableLabel.push("LastProcessed");
            this.dataTableKey.push("LastProcessed");

            let lable = "", prevLab = ""
            let lastProc = [];
            let transCount = [];



            res.forEach( (element, index) => {

              lable = element.Transaction
              lastProc.push(element.LastProcessed)

              if (lable !== prevLab)
                {

                  if(transCount.length > 0)
                  {
                    this.barChartData.push ( {data: transCount, label:  prevLab});
                  }
                  prevLab = lable;
                  transCount = [];
                }

              if(this.mbarChartLabels.indexOf(element.Days) < 0)
              {
                this.mbarChartLabels.push(element.Days)
                this.dataTableLabel.push(element.Days);
                this.dataTableKey.push(element.Days);
              }

              transCount.push(element.Count);

              if ( (index+1) == res.length)
              {
                this.barChartData.push ( {data: transCount, label:  lable});
              }

            });

            this.barChartData.forEach((chartEle, index) => {
              console.info("Barchart label: " + chartEle.label +", " + chartEle.data +", " + lastProc[index]);
              console.info(this.dataTableLabel[1] +": " + chartEle.data[0])

              this.dataSource.data.push(
                {
                  [this.dataTableLabel[0]]:[chartEle.label],
                  [this.dataTableLabel[1]]:lastProc[index],
                  [this.dataTableLabel[2]]:chartEle.data[0],
                  [this.dataTableLabel[3]]:chartEle.data[0],
                  [this.dataTableLabel[4]]:chartEle.data[1],
                  [this.dataTableLabel[5]]:chartEle.data[2],
                  [this.dataTableLabel[6]]:chartEle.data[3]
                }
                );



            });


              this.canRenderDetails = true;




            this.loading = false;

            }),

            catchError(errorRes => {

              alert('Error in fetching EligibilityBenefit Requests: ' + errorRes);
              this.dataSource.data = [];
              return errorRes;
            })


    }



// Handle right click

onContextMenu(event: MouseEvent, row:any, ind: number) {
  event.preventDefault();

  console.log( 'Row clicked: ' + row.Transaction +' Params: ' + this.paramsList.length);

  this.contextMenuPosition.x = event.clientX + 'px';
  this.contextMenuPosition.y = event.clientY + 'px';

  let item: Item ={rowId: row.Transaction, FileName: ""};


  this.currentTransType = row.Transaction.toString().toUpperCase()


  let index = 0;

  for (let index = 0; index < this.paramsList.length; index++)
    {
        let ind = this.paramsList[index].indexOf("transaction")

        if (ind >= 0)
        {
          this.paramsList = this.paramsList.splice(ind, 1, "transaction::"+this.currentTransType)
          console.log('Replace transaction in paramsList')
          break;
        }
     };
     if (index >= this.paramsList.length)
     {
      console.log('Add transaction in paramsList')
      this.paramsList.push("transaction::"+this.currentTransType)
     }

  this.contextMenu.menuData = { 'item': item };
  this.contextMenu.menu.focusFirstItem('mouse');
  this.contextMenu.openMenu();
}

onContextMenuNew(item: Item) {
  console.log("Click on Action id: " + item.rowId);
  sessionStorage.removeItem("currentTab")
  sessionStorage.setItem("currentTab", "Transactions");

    this.searchTypeString = "";
    this.paramsList.forEach( val => {
      this.searchTypeString += val +";";
      console.log(val);
     });


    if (this.searchTypeString.indexOf('transaction') < 0)
    {
      this.searchTypeString += "transaction::"+this.currentTransType + ";status::Processed;" +
      "tranStartDtTm::" + this.startDate +" "+ this.startTm +";" +
      "endDtTm::" + this.endDate+" " +this.endTm +";" +
      "count::25;"  ;
    }

    this.searchTypeString += ";sameWindow::false";
       const url = this.router.serializeUrl(this.router.createUrlTree(["/transaction/"],
      {queryParams: {  'transaction': this.currentTransType,  'searchTypeString': this.searchTypeString } }
       ));
    const newTab = window.open(url, '_blank');
    if(newTab) {
        newTab.opener = null;
    }

}

onContextMenuSame(item: Item) {

  this.searchTypeString = "";
  sessionStorage.removeItem("currentTab")
  sessionStorage.setItem("currentTab", "Transactions");

    this.paramsList.forEach( val => {
      this.searchTypeString += val +";";
      console.log(val);
     });


    if (this.searchTypeString.indexOf('transaction') < 0)
    {
      this.searchTypeString += "transaction::"+this.currentTransType + ";status::Processed;" +
      "tranStartDtTm::" + this.startDate +" "+ this.startTm +";" +
      "endDtTm::" + this.endDate+" " +this.endTm +";" +
      "count::25;"  ;
    }


   this.searchTypeString += ";sameWindow::true";
      this.router.navigate(["/transaction/"],
      {queryParams: { 'transaction': this.currentTransType, 'searchTypeString': this.searchTypeString } }
       );

}


public chartClicked(e:any):void {
  console.log(e);
}

public chartHovered(e:any):void {
  // console.log(e);
}

}

export interface Item {
  FileName: string;
  rowId: number;
}

