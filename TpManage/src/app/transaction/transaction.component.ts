import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormArray, FormControl, Validators, NgForm } from '@angular/forms';


import {TransRestServiceComponent} from '../services/transrest-service.component';
import { MatTableDataSource } from '@angular/material/table';
import {MatAccordion, MatExpansionModule} from '@angular/material/expansion';
import {MatRadioModule, MatRadioGroup} from '@angular/material/radio';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { Router, ActivatedRoute } from '@angular/router';
import {MatSelectModule,} from '@angular/material/select';
import {DisplayColumns} from './DisplayColumns'
import {SearchColumns} from './SearchColumns'

import {MatNativeDateModule} from '@angular/material/core';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatFormFieldModule} from '@angular/material/form-field';
import { MatMenu, MatMenuTrigger } from '@angular/material/menu';
import { MatSelect, MatSelectChange } from '@angular/material/select';
import { MatFormField } from '@angular/material/form-field';
import { catchError } from 'rxjs';
import { Modalx12Component } from './transaction-details/modal/modal-x12.component';
import { MatDialog } from '@angular/material/dialog';
import { DialogRef } from '@angular/cdk/dialog';

@Component({
  selector: 'app-transaction',
  templateUrl: './transaction.component.html',
  styleUrls: ['./transaction.component.css']
})



export class TransactionComponent implements OnInit, AfterViewInit {

  contextMenuPosition = { x: '0px', y: '0px' };
  @ViewChild(MatMenuTrigger)
  contextMenu: MatMenuTrigger;

  nowDt = new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));

startDate = "2023-01-12";
endDate ="13:30";
  startTm = "13:30";
  endTm= "2023-01-12";
  paramsList: string[];

    maxCount = ["10", "25", "50", "100", "200"];
    dispositions = ["All", "Processed", "Rejected"];

  transactionTypes: string[] = ["270", "271","276", "277", "277CA", "835", "837I", "837P", "837D", "999", "TA1"];


   nyiColumns = [
    {
      item_id: 'N/A',
      item_text: 'Not Implemented'
    }];

    transSearchFlds: string[] =[];
    transSearchLbls: string[] =[];


  loading:boolean = false;
  searchTransaction:boolean = false;

  public size = 5;
  public pageNumber = 0;
  form!: FormGroup;
  dataTableLabel: string[] = [];
  dataTableKey: string[] = [];
  canRenderDetails = false;
  conditionColumns: string[] = ['=', '!=', '%StartsWith', 'Contains', 'LIKE', 'NOT LIKE'];

  dataSource = new MatTableDataSource<any>();

  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatPaginator;

  transactionsFields= [
    {
      key: 'Invalid',
      type: 'text',
      label: 'Select Transaction to view the Columns',
      transactionCode: 'XXX',
    }];


  searchColumns= this.transactionsFields.slice();

  @ViewChild("rowCnt") rowCnt: ElementRef;
  @ViewChild("transType") transType: ElementRef;
  @ViewChild("displayCols") displayCols: ElementRef;
  @ViewChild("disposition") disposition: ElementRef;


  additionalsearchString = "";
  searchTypeString = "";
  currentTransType = '';
  currentMode = '';
  sub:any;

  selDropdownList = [];

  allDropdownList = [];

  selectedItems=[];

  usrSearchColumns: SearchColumns[] = [];
  usrDisplayColumns: DisplayColumns[] = [];

  constructor(private TransactionService: TransRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute, public dialog: MatDialog){
      tpId: new FormControl();

  }


  createinitForm(): FormGroup
  {
    console.info('Add new FormGroup for additional fields');
    return new FormGroup({
      'fld':new FormControl('FLD', Validators.required),
      'newFldValue':new FormControl('value', Validators.required),
    })
  }

  ngOnInit()
  {
    console.info("ngOnInit");


    this.form = this.formBuilder.group({
      rowCnt:['25', Validators.required],
      transType: ['270', Validators.required],
      disposition: ['Processed', Validators.required],
      mode:['RealTime', Validators.required],
      additional:this.formBuilder.array([this.createinitForm()])
    });


    this.currentTransType = ''

    this.sub = this.route.queryParams.subscribe(params => {

      if(params !== undefined && params.transaction !== undefined)
        {
          // Defaults to '' if no query param provided.

          this.currentTransType =  params['transaction'] || '';
          this.additionalsearchString = params['additionalSearch'] || '';
          this.searchTypeString = params['searchTypeString'];
          if (this.searchTypeString !== null && this.searchTypeString.length > 0)
          {

            let fInd = this.searchTypeString.indexOf("mode::") + 6;
            let val = this.searchTypeString.substring( fInd, this.searchTypeString.indexOf(";", fInd))
            console.log(fInd + ". MODE:" + val )
            this.form.controls.mode.setValue(val)

            fInd = this.searchTypeString.indexOf("transaction::") + "transaction::".length;
            val = this.searchTypeString.substring( fInd, this.searchTypeString.indexOf(";", fInd))
            console.log(fInd + ". transType:" + val )
            this.form.controls.transType.setValue(val)

            fInd = this.searchTypeString.indexOf("status::") + "status::".length;
            val = this.searchTypeString.substring( fInd, this.searchTypeString.indexOf(";", fInd))
            console.log(fInd + ". disposition:" + val )
            this.form.controls.disposition.setValue(val)


            fInd = this.searchTypeString.indexOf("startDtTm::") + "startDtTm::".length;
            let fInd2 = this.searchTypeString.indexOf(" ", fInd)
            val = this.searchTypeString.substring( fInd, fInd2)
            console.log(fInd + ". startDate:" + val )
            this.startDate = val

            let fInd3 = this.searchTypeString.indexOf(";", fInd2)
            val = this.searchTypeString.substring( fInd2+1, fInd3)
            console.log(fInd + ". startTm:" + val )
            this.startTm = val


            fInd = this.searchTypeString.indexOf("endDtTm::") + "endDtTm::".length;
            fInd2 = this.searchTypeString.indexOf(" ", fInd)
            val = this.searchTypeString.substring( fInd, fInd2)
            console.log(fInd + ". endDate:" + val )
            this.endDate = val

            fInd3 = this.searchTypeString.indexOf(";", fInd2)
            val = this.searchTypeString.substring( fInd2+1, fInd3)
            console.log(fInd + ". endTm:" + val )
            this.endTm = val

            fInd = this.searchTypeString.indexOf("count::") + "count::".length;
            val = this.searchTypeString.substring( fInd, this.searchTypeString.indexOf(";", fInd))
            console.log(fInd + ". rowCnt:" + val )
            this.form.controls.rowCnt.setValue(val)


            if (this.additionalsearchString !== '')
            {
              console.log('set search controls, ' + this.searchTransaction);
              this.searchTransaction = true;
            }
            else{
              this.clearSearch();
            }
          }
        }
        else
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


    this.TransactionService.fetchTransactionFields().subscribe((res: any) => {
    this.transactionsFields = [];

      for (var item of res)
      {
        // console.info("Push transactionsSearchColumns: " + item.Key)
          this.transactionsFields.push({key: item.Key, type: item.Type, label: item.Label, transactionCode: item.TransactionCode});

           // console.info(item.Key +": " + item.Label)

      }
      console.info("transactions Fields: " + this.transactionsFields.length);
      console.info("Init Usr Columns: " + this.usrDisplayColumns.length);

      this.TransactionService.fetchDisplayColumns().subscribe((res: any) => {
        this.usrDisplayColumns.splice(0, this.usrDisplayColumns.length)
        this.usrDisplayColumns.push(...res);
        console.info("User display columns from fetchDisplayColumns: " + this.usrDisplayColumns.length);
        this.TransactionService.fetchSearchColumns().subscribe((res: any) => {
          this.usrSearchColumns.splice(0, this.usrSearchColumns.length)
          this.usrSearchColumns.push(...res);
          console.info("User search columns from fetchSearchColumns: " + this.usrSearchColumns.length);

          if(this.currentTransType !== '')
            {

            this.transactionChange(this.currentTransType);

            console.info('Transaction search for: ' + this.currentTransType);
            this.onSearchTransactions();
            }
            else
            {
              this.transactionChange('270')
            }


        });


      });

    });


  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;

  }
  get f() { return this.form.controls; }

  onSearchTransactions()
    {
      this.canRenderDetails = false;
      this.paramsList = [];
      this.paramsList.push("mode::" + this.form.controls.mode.value);
      this.paramsList.push("transaction::"+this.form.controls.transType.value);
      this.paramsList.push("status::"+this.form.controls.disposition.value );

      this.paramsList.push("startDtTm::" + this.startDate +" "+ this.startTm);

      this.paramsList.push("endDtTm::" + this.endDate+" " +this.endTm );
      this.paramsList.push("count::" + this.form.controls.rowCnt.value);

      if(this.additionalsearchString !== "")
      {
        this.paramsList.push("sql::" + this.additionalsearchString);
      }
      console.info("onSearchTransactions count: " +this.form.controls.rowCnt.value)
      console.info("SearchTransactions Mode# " +  this.form.controls.mode.value + ", " + this.form.controls.transType.value + ", " + this.form.controls.disposition.value );
      console.info("SearchTransactions Start# " +  this.startDate + ", " + this.startTm );
      console.info("SearchTransactions End# " +  this.endDate  + ", " + this.endTm );

      if (this.form.controls.transType.value === '' && this.currentTransType !== '')
      {
        this.form.controls.transType.setValue(this.currentTransType);
      }


      this.loading = true;
      const formArr = this.form.get('additional') as FormArray;
      let staticSearchStr = "";

      let customFlds:string[] = this.transSearchLbls;
      let tabCol:string[] =this.transSearchFlds;

      // Get values for static search

      if (formArr.length >= 1) {
        for(let i=0;i< formArr.length;i++)
        {
          let fGrp = formArr.at(i) as FormGroup
          if (fGrp.controls.newFldValue.value === '')
          {
            console.info(fGrp.controls.fld.value +" is empty")
            continue;
          }
          else{

            console.info(fGrp.controls.fld.value +"= " + fGrp.controls.newFldValue.value)
          }

          for (let [ind, val] of customFlds.entries()) {

            if(fGrp.controls.fld.value === val)
              {
                console.info(ind + ": " + val + ", " + tabCol[ind] + " = '" + fGrp.controls.newFldValue.value + "'")
                staticSearchStr += " AND " + tabCol[ind] + " = '" + fGrp.controls.newFldValue.value + "'"
              }
          };


        }
      }
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


      if(this.form.controls.transType.value === '270')
      {

            this.TransactionService.fetchEligibilityRequests(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {

            this.dataSource.data = res;
            this.canRenderDetails = true;

            console.info("Data rows array: " + this.dataSource.data.length);

            this.loading = false;

            }),

            catchError(errorRes => {
              // Send to analytics server
              alert('Error in fetching EligibilityBenefit Requests: ' + errorRes);
              this.dataSource.data = [];
              return errorRes;
            })

      }
      else if(this.form.controls.transType.value === '271'){

        this.TransactionService.fetchEligibilityBenefitResponses(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("EligibilityBenefitResponses array: " + this.dataSource.data.length);
        });

      }

      else if(this.form.controls.transType.value === '835'){


        console.info("835 search: "+ staticSearchStr );


        this.TransactionService.fetchClaimPayment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("ClaimPayment array: " + this.dataSource.data.length);
        });

      }
      else if(this.form.controls.transType.value === '837P'){

        console.info("837P search: "+ staticSearchStr );

          this.paramsList.push("addSql::" + "VersionReleaseIndustryIdenti='005010X222A1' ");

         this.TransactionService.fetchClaims(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
          this.dataSource.data = res;
          this.canRenderDetails = true;
          this.loading = false;
          console.info("Claims array: " + this.dataSource.data.length);
         });

       }

       else if(this.form.controls.transType.value === '837I'){
        if(this.additionalsearchString.length > 0)
        {
          this.additionalsearchString = " AND " + this.additionalsearchString
        }
        this.paramsList.push("addSql::" + "VersionReleaseIndustryIdenti='005010X223A2' ")
        this.TransactionService.fetchClaims(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claims array: " + this.dataSource.data.length);
        });

      }
      else if(this.form.controls.transType.value === '837D'){
        if(this.additionalsearchString.length > 0)
        {
          this.additionalsearchString = " AND " + this.additionalsearchString
        }
        this.paramsList.push("addSql::" + "VersionReleaseIndustryIdenti='005010X224A2' ")
        this.TransactionService.fetchClaims(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claims array: " + this.dataSource.data.length);

        });

      }
      else if(this.form.controls.transType.value === '276'){

        this.TransactionService.fetchClaimStatusReq(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Status  Req array: " + this.dataSource.data.length);

        });

      }
       else if(this.form.controls.transType.value === '277'){

         this.TransactionService.fetchClaimStatusResp(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
          this.dataSource.data = res;
          this.canRenderDetails = true;
          this.loading = false;
          console.info("Claim Status Resp array: " + this.dataSource.data.length);

         });

       }
       else if(this.form.controls.transType.value === '277CA'){

        this.TransactionService.fetchClaimAcknowledgment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Acknowledgment array: " + this.dataSource.data.length);

        });

      }
       else if(this.form.controls.transType.value === '999'){

        this.TransactionService.fetchImplementationAcknowledgment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Implementation Acknowledgment array: " + this.dataSource.data.length);

        });

      }
      else if(this.form.controls.transType.value === 'TA1'){

        this.TransactionService.fetchTA1(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Interchange TA1 array: " + this.dataSource.data.length);

        });

      }
       else // Not Implemented
       {
        this.searchColumns = [];
        this.selDropdownList = this.nyiColumns;

        this.canRenderDetails = true;
        this.loading = false;
        console.info("NotImplementd array: " + this.dataSource.data.length);
       }
       this.paginator.pageSize = this.form.controls.rowCnt.value;

    }

onRowCnt()
      {
        console.info('Set paginator.pageSize: ' + this.form.controls.rowCnt.value)
        this.paginator.pageSize = this.form.controls.rowCnt.value;
        this.dataSource.paginator = this.paginator
}

clearSearch()
    {
      this.canRenderDetails = false;
      this.searchTransaction = false;
      this.additionalsearchString = "";
      console.info('clearSearch fields');
    }


private createCustomFlds(fldLbl: string): FormGroup {
  return new FormGroup({
    'fld': new FormControl(fldLbl),
    'newFldValue': new FormControl('', Validators.required)
  })
}

private clearCustomFlds() {

  const formArr = this.form.get('additional') as FormArray

  if (formArr.length >= 1) {
      formArr.clear()
  }
}

private readCustomFlds() {

  const formArr = this.form.get('additional') as FormArray

  if (formArr.length >= 1) {
    for(let i=0;i< formArr.length;i++)
    {
      let fGrp = formArr.at(i) as FormGroup
      // console.info(fGrp.controls.fld.value +"= " + fGrp.controls.newFldValue.value)
    }
  }
  console.info("Added to Additional search: " + formArr.length)

}

transactionChange(evt: any)
{

  this.dataTableLabel = [];
  this.dataTableKey = [];
  this.selectedItems = [];
  this.searchColumns =[];
  this.selDropdownList= [];

  this.allDropdownList= [];
  var allTempArr= [];
  this.dataSource.data = [];
  console.info("In transactionChange: currentTransType: " + this.currentTransType)
  if(this.form.controls.transType.value !== this.currentTransType &&
    this.form.controls.mode.value !== this.currentMode)
  {
    this.clearSearch();
  }
  this.currentTransType = this.form.controls.transType.value;
  this.currentMode = this.form.controls.mode.value;

  this.readCustomFlds();

  this.clearCustomFlds();

  var tranType:string = this.form.controls.transType.value
  console.info("Search " + tranType + " in transactionsFields " + this.transactionsFields.length)
  if (tranType.startsWith("83") || tranType === "277CA")
  {
    console.info("Change Mode to Batch for 83x, 277CA")
    this.form.controls.mode.setValue("Batch")

  }
  for (var col of this.transactionsFields)
  {

    if ( col.transactionCode === this.form.controls.transType.value)
    {
      allTempArr.push({item_id:col.key, item_text:col.label});
      this.searchColumns.push(col);
    }
  }
  console.info("searchColumns.count: " + this.searchColumns.length)

  this.allDropdownList = allTempArr;
  var tempArr = [];


  if(this.usrDisplayColumns.length > 0)
  {
    console.info("Check usrDisplayColumns: " + this.usrDisplayColumns.length +', allDropdownList #: ' + this.allDropdownList.length);
    console.info("Get Lables for transType: " + this.form.controls.transType.value + ', Mode: ' + this.form.controls.mode.value)

    for (var disp of this.usrDisplayColumns)
    {

      for (var col of this.transactionsFields)
      {

        if ( disp.TransactionCode === this.form.controls.transType.value
          && disp.key === col.key && disp.Mode === this.form.controls.mode.value)
        {
          var selInd = this.allDropdownListFind(col.label);
          console.info("Find: " + col.label + 'in allDropdownList #: ' + this.allDropdownList.length)
          if(selInd !== -1)
          {
            console.info(disp.TransactionCode + " PUSH User selected column: " + disp.key + "===" + col.key +", selInd: " + selInd)
            tempArr.push({item_id:selInd, item_text:col.label});

            break;
          }
        }
      }
    }
    this.selDropdownList =  tempArr;
  }
  if(tempArr.length === 0) // Nothing from User display columns
  {
    console.info("Nothing from User display columns for: " + this.form.controls.transType.value)
    this.searchColumns = [];
    this.allDropdownList = [];
    var tempArr2 = [];
    for (var col of this.transactionsFields)
    {


      if ( col.transactionCode === this.form.controls.transType.value)
      {
          // console.info(col.transactionCode + " PUSH " + col.key)

          tempArr.push({item_id:col.key, item_text:col.label});
          tempArr2.push({item_id:col.key, item_text:col.label});
          this.searchColumns.push(col);
      }
    }
    this.selDropdownList =  tempArr;
    this.allDropdownList = tempArr2;
  }

  for (var item of this.selDropdownList)
  {
    // console.info("selDropdownList key: " + item.item_id +", val: " +item.item_text )
      this.dataTableLabel.push(item.item_text);
      this.dataTableKey.push(item.item_id);
      this.selectedItems.push({key:item.item_id, label:item.item_text})
  }


  console.info("allDropdownList #: " + this.allDropdownList.length);
  console.info("Display columns #: " + this.selDropdownList.length);
  console.info("All search Columns #: " + this.searchColumns.length);
  console.info("User search Columns #: " + this.usrSearchColumns.length);

  console.info('Add search group')
  const formArr = this.form.get('additional') as FormArray
  this.transSearchFlds =[]
  this.transSearchLbls = []




  this.usrSearchColumns.forEach(element => {
    if(element.TransactionCode === this.form.controls.transType.value && element.Mode === this.form.controls.mode.value)
    {

        for (let tran of this.transactionsFields){
        {
          if(tran.key == element.key)
          {
            console.info(tran.label + ": " + element.key +", " + element.TransactionCode +", " + element.Mode);
            formArr.push(this.createCustomFlds(tran.label));
            this.transSearchFlds.push(element.key);
            this.transSearchLbls.push(tran.label);
            break;
          }

        }

      }
    }
  });
  this.onSearchTransactions();


}


allDropdownListFind(label:string)
{
  for(var val of this.allDropdownList)
  {
    if(val.item_text === label)
    {
      // console.info("allDropdownListFind: " + val.item_id);
      return val.item_id
    }
  }
  return -1;
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

exportData()
{
  let fileName = "DataExport-" + this.currentTransType   + "-" + this.startDate + "To" + this.endDate + ".csv"
  let data = ""

  this.dataTableLabel.forEach(element => {
    data +=element + ",";
  });
  data += "\n";

  this.dataSource.data.forEach(element => {
    this.dataTableKey.forEach(col => {
    data +=element[col] + ",";
    });
    data += "\n";
  });

  let param: string[] = [ data, fileName];
  const dialogRef = this.dialog.open(Modalx12Component, {
    width: '1700px',
    data: param
  });

}

// Handle right click

onContextMenu(event: MouseEvent, row:any, ind: number) {
  event.preventDefault();

  console.log( ind +'. Row clicked: ' + row.ID );

  this.contextMenuPosition.x = event.clientX + 'px';
  this.contextMenuPosition.y = event.clientY + 'px';
  let item: Item ={ID: row.ID, rowId: ind};
  this.contextMenu.menuData = { 'item': item };
  this.contextMenu.menu.focusFirstItem('mouse');
  this.contextMenu.openMenu();
}

onContextMenuNew(item: Item) {
  // alert('Click on Action 1 ' + item.ID);

    this.searchTypeString = "";
  this.paramsList.forEach( val => {
    this.searchTypeString += val +";";
   });
   this.searchTypeString += ";sameWindow::false";

       const url = this.router.serializeUrl(this.router.createUrlTree(["/transaction/transaction-details/"],
      {queryParams: { ID:  item.ID, 'transaction': this.form.controls.transType.value, 'additionalSearch': this.additionalsearchString, 'searchTypeString': this.searchTypeString } }
       ));
    const newTab = window.open(url, '_blank');
    if(newTab) {
        newTab.opener = null;
    }



}

onContextMenuSame(item: Item) {

  this.searchTypeString = "";
  this.paramsList.forEach( val => {
    this.searchTypeString += val +";";
   });
   this.searchTypeString += ";sameWindow::true";
      this.router.navigate(["/transaction/transaction-details/"],
      {queryParams: { ID:  item.ID, 'transaction': this.form.controls.transType.value, 'additionalSearch': this.additionalsearchString, 'searchTypeString': this.searchTypeString } }
       );

}

onContextSettings(item: Item) {

    console.log("call onContextSettings")
    this.searchTypeString = "mode::" + this.form.controls.mode.value +";" +
    "transaction::"+this.form.controls.transType.value +";" +
    "transaction::"+this.form.controls.transType.value +";" +
    "status::"+this.form.controls.disposition.value +";" +
    "startDtTm::" + this.startDate +" "+ this.startTm +";" +
    "endDtTm::" + this.endDate+" " +this.endTm +";" +
    "count::" + this.form.controls.rowCnt.value +";"  ;


   this.searchTypeString += ";sameWindow::true";
      this.router.navigate(["/transaction/transaction-settings/"],
      {queryParams: {'transaction': this.form.controls.transType.value, 'mode': this.form.controls.mode.value, 'additionalSearch': this.additionalsearchString, 'searchTypeString': this.searchTypeString  } }
       );

}

}

export interface Item {
  ID: number;
  rowId: number;
}

