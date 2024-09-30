import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import {ERPRequest} from './ERPRequest'

import {TransRestServiceComponent} from '../services/transrest-service.component';
import { MatTableDataSource } from '@angular/material/table';
import {MatAccordion, MatExpansionModule} from '@angular/material/expansion';

import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { Router, ActivatedRoute } from '@angular/router';
import {MatSelectModule} from '@angular/material/select';
import {DisplayColumns, DisplayColumnsArray} from './DisplayColumns'

import {MatNativeDateModule} from '@angular/material/core';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatFormFieldModule} from '@angular/material/form-field';

@Component({
  selector: 'app-transaction',
  templateUrl: './transaction.component.html',
  styleUrls: ['./transaction.component.css']
})



export class TransactionComponent implements OnInit, AfterViewInit {
  displayLabel: string = "Display columns:";

  startDate =  new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));

  endDate = "";
  maxCount = ["10", "25", "50", "100", "200"];

  transactionTypes: string[] = [] ;

  butSaveDisplay: boolean = false;

   nyiColumns = [
    {
      item_id: 'N/A',
      item_text: 'Not Implemented'
    }];

  panelExpand: boolean = true;
  loading:boolean = false;
  searchTransaction:boolean = false;
  submitted = false;
  public size = 5;
  public pageNumber = 0;
  form!: FormGroup;
  dataTableLabel: string[] = [];
  dataTableKey: string[] = [];
  canRenderDetails = false;
  conditionColumns: string[] = ['=', '!=', '%StartsWith', 'Contains', 'LIKE', 'NOT LIKE'];
  searchFieldVal:string = "";
  dataSource = new MatTableDataSource<any>();

  usrDisplayColumns= [

    {
      key: 'usrK',
      Order: '0',
      TransactionCode: 'usrL'
    }];

  transactionsSearchColumns= [
    {
      key: 'Invalid',
      type: 'text',
      label: 'Select Transaction to view the Columns',
      transactionCode: 'XXX',
      detail: '1'
    }];


  searchColumns= this.transactionsSearchColumns.slice();

  @ViewChild("searchValue") searchValue: ElementRef;
  @ViewChild("searchField") searchField: ElementRef;
  @ViewChild("searchCndition") searchCndition: ElementRef;

  @ViewChild("rowCnt") rowCnt: ElementRef;
  @ViewChild("transType") transType: ElementRef;
  @ViewChild("displayCols") displayCols: ElementRef;


  searchString = "";
  searchTypeString = "";
  currentTransType = "";
  sub:any;
  isTableExpanded = false;

  selDropdownList = [];

  allDropdownList = [];


  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;


  dropdownSettings={};

  selectedItems=[];



  constructor(private TransactionService: TransRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute){

      tpId: new FormControl();

  }


  ngOnInit()
  {

    this.startDate =  new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));
    console.info("ngOnInit " + this.startDate);
    let queryParams = 0

    this.form = this.formBuilder.group({
      rowCnt:['', Validators.required],
      transType: ['', Validators.required],
      searchField: ['', Validators.required],
      searchCndition: [''],
      searchValue: [''],
      matStartDate: [''],
      matEndDate:[''],
      Sender:[''],
      Receiver:[''],
      TradingPartner:[''],
      InterchangeReceiverID:[''],
      InterchangeControlNumber:[''],
      GroupControlNumber:[''],
      InterchangeDate:[''],
      ProcessDtTm:[''],
      ProductTransfer:[''],
      PurchaseOrder:[''],
      InvoiceNumber:[''],
      FileName:['']
    });

    this.form.controls.matStartDate.setValue(this.startDate);

    this.dropdownSettings = {
      singleSelection: false,
      idField: "item_id",
      textField: "item_text",
      allowSearchFilter: true,
      enableCheckAll: false,
      maxHeight: 250
    };

    this.sub = this.route.queryParams.subscribe(params => {
      // Defaults to '' if no query param provided.

      this.currentTransType =  params['transaction'] || '';
      if (this.currentTransType !== "")
      {
        queryParams = 1
        this.searchString = params['search'] || '';
        if(this.searchString==="-")
        {
          this.searchString=""
        }
        this.searchTypeString = params['searchTypeString'];
        this.startDate =  new Date(this.searchTypeString);
        this.form.controls.transType.setValue(this.currentTransType);

        console.log('ngOnInit - Query params ' + this.searchTypeString +", transType: " + this.currentTransType +", " + this.searchString);
      }
    });
    console.info("TransactionType: " + this.currentTransType)
    this.transactionTypes.push('All')
    this.TransactionService.fetchTransactionTypes().subscribe((res: any) => {


      for (var item of res)
      {

              this.transactionTypes.push(item.TransactionType);

      }
      console.info("TransactionTypes #: " + this.transactionTypes.length);
      if(queryParams === 0)
        {
          this.form.controls.transType.setValue(this.transactionTypes[0]);
          this.currentTransType = this.transactionTypes[0];
          console.info("New search Default Date: " + this.startDate)
          this.form.controls.matStartDate.setValue(this.startDate)
          this.clearSearch();
          console.info("New search Set TransactionType: " + this.currentTransType +", Date: " + this.form.controls.matStartDate.value)
        }

    });

    this.TransactionService.fetchTransactionFields(0).subscribe((res: any) => {
    this.transactionsSearchColumns = [];


      for (var item of res)
      {
        // console.info("Push transactionsSearchColumns: " + item.Key)
        if (item.TransactionCode === "All")

          {
          this.transactionsSearchColumns.push({key: item.Key, type: item.Type, label: item.Label, transactionCode: item.TransactionCode, detail: item.Detail});


          }

      }

      console.info("transactionsSearchColumns: " + this.transactionsSearchColumns.length);
      console.info("Usr Columns: " + this.usrDisplayColumns.length);

      this.form.controls.rowCnt.setValue(this.maxCount[1]);


      this.TransactionService.fetchDisplayColumns().subscribe((res: any) => {
        this.usrDisplayColumns.splice(0, this.usrDisplayColumns.length)
        this.usrDisplayColumns.push(...res);


        if (this.currentTransType !== '')
          {
            // this.searchTypeChange(null);
            this.form.controls.transType.setValue(this.currentTransType);
            // this.form.controls.searchValue.setValue(this.searchString);
            this.form.controls.matStartDate.setValue(this.startDate)

            // this.startDate = this.searchString;

            this.form.controls.rowCnt.setValue("25");

            if (this.searchString !== '')
            {
              this.searchTransaction = true;
            }
            console.log('set search controls, ' + this.searchTransaction);

            console.info("User display columns: " + this.usrDisplayColumns.length);
            this.transactionChange(this.currentTransType);

            console.info('Transaction search for: ' + this.currentTransType);
            this.onSearchTransactions();
            this.form.controls.searchValue.setValue("");
            this.form.controls.searchField.setValue(this.dataTableLabel[0]);
            this.form.controls.searchCndition.setValue(this.conditionColumns[0]);

          }
          else{
            this.clearSearch();
          }

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
      let staticSearchStr =  "";
      console.info("SearchTransactions for TradingPartner: " + this.form.controls.TradingPartner.value)
      if (this.form.controls.matEndDate.value !== null && this.form.controls.matEndDate.value !== "")
      {

        let endDt = new Date( Date.parse(this.form.controls.matEndDate.value))
        let stDt = new Date( Date.parse(this.form.controls.matStartDate.value))
        console.info(this.form.controls.matStartDate.value + ", " + this.form.controls.matEndDate.value )

        this.searchTypeString  = "ProcessDtTm between '" + stDt.getFullYear() + "-" + (stDt.getMonth() + 1) + "-" + stDt.getDate() +"' AND '" + + endDt.getFullYear() + "-" + (endDt.getMonth() + 1) + "-" + endDt.getDate() +"'"
      }
      else
      {
          this.searchTypeString =  "" + this.form.controls.matStartDate.value
      }
      this.canRenderDetails = false;
      console.info("onSearchTransactions TransType: " +this.form.controls.transType.value +",  currentTransType: " +  this.currentTransType +", " + this.searchTypeString)
      if (this.form.controls.transType.value === '' && this.currentTransType !== '')
      {
        this.form.controls.transType.setValue(this.currentTransType);
      }


      this.loading = true;



        if(this.form.controls.transType.value !== 'All')
        {
          staticSearchStr =  "TransactionType = '"+ this.form.controls.transType.value + "'";
        }


        if(this.searchString.length > 0)
        {
          if(staticSearchStr.length > 0)
          {
            staticSearchStr = staticSearchStr + " AND " + this.searchString
          }
          else
          {
            staticSearchStr = this.searchString
          }

        }
        // staticSearchStr = staticSearchStr.replace('AND','') // Remove first AND

        console.info("X12 search: "+ staticSearchStr + ", SearchType: " +  this.searchTypeString)

        console.info('Transaction search with: ' + staticSearchStr);
        this.TransactionService.fetchERPtransactions(staticSearchStr, this.searchTypeString, this.form.controls.rowCnt.value, this.form.controls.TradingPartner.value).subscribe((res: any) => {

        this.dataSource.data = res;
        this.canRenderDetails = true;

        console.info("Data rows array: " + this.dataSource.data.length);

        this.loading = false;

        this.setControls();
        });


      }



setControls()
{
          // this.selectedItems.splice(0, this.selectedItems.length)
          console.info('Populate dataTables with ' + this.selDropdownList.length);
          console.info("Dropdown: " + this.selDropdownList.length);
          this.form.controls.searchValue.setValue('');


            console.info("allDropdownList.length: " + this.allDropdownList.length);
            console.info("selDropdownList.length: " + this.selDropdownList.length);

            this.panelExpand = false;
            this.butSaveDisplay = true;
}

clearSearch()
    {
      this.canRenderDetails = false;
      this.searchTransaction = false;
      this.searchString = "";
      this.form.controls.searchValue.setValue("");
      this.form.controls.searchField.setValue(this.dataTableLabel[0]);
      this.form.controls.searchCndition.setValue(this.conditionColumns[0]);
      console.info('clearSearch fields');
    }

addSearch() {

    this.searchTransaction = true;
    this.submitted = true;
    this.setSearchField();

      if(this.searchFieldVal === "")
      {
        alert("Search column is NULL");
      }
      let  sVal = ""
      for (var item of this.searchColumns)
        {
          if(item.label === this.searchFieldVal)
          {
            sVal = item.key
            break;
          }
        }
        if(sVal === "")
        {
          alert("Value is NULL");
        }


          let srchStr = this.form.controls.searchCndition.value
          if (srchStr === 'Contains')
          {
            srchStr = '['
          }

          if(this.searchString !== "")
          {
            this.searchString += " AND " + sVal + srchStr  + " '" + this.searchValue +"'";
          }
          else
          {
            this.searchString =  sVal + " " + srchStr + " '" + this.searchValue +"'";
          }

    }


onRowClicked(row) {
      console.log('Row clicked: ' + row.id + ", " + row.TransactionType + ", Search: " + this.searchString + ', searchTypeString: '+ this.searchTypeString );
      this.router.navigate(["/transaction/transaction-details/"],
      {queryParams: { id:  row.id, 'transaction': this.form.controls.transType.value, 'search': (this.searchString==="")?'-':this.searchString, 'searchTypeString': this.searchTypeString, 'TransactionType':row.TransactionType } }
       );
  }


onItemSelect(inp: any) {
    console.log('onItem Select: '  + inp +", " + inp.item_id + ", #: " + this.dataTableLabel.length);
    if (inp.item_id === undefined)
  {
    this.dataTableLabel.push(inp);
    console.log('onItem Select objIndex ' + inp)
  }
  else{
    this.dataTableLabel.push(inp.item_text);
    this.dataTableKey.push(inp.item_id);
  }
  this.saveDisplayColumns();
}

onItemDeSelect(inp: any)
{
  console.log('onItem DeSelect: ' + inp +", " + inp.item_id + ", #: " + this.dataTableLabel.length);
  if (inp.item_id === undefined)
  {
    var objIndex = this.dataTableLabel.findIndex(obj => obj === inp);
    console.log('onItem DeSelect objIndex ' + objIndex)
  }
  else{
    var objIndex = this.dataTableLabel.findIndex(obj => obj === inp.item_text);
    console.log('onItem DeSelect objIndex ' + objIndex)
    if (objIndex > -1) {
      this.dataTableLabel.splice(objIndex, 1);
    }
    objIndex = this.dataTableKey.findIndex(obj => obj === inp.item_id);
    console.log('onItem DeSelect objIndex ' + objIndex)
    if (objIndex > -1) {
      this.dataTableKey.splice(objIndex, 1);
    }
  }
  this.saveDisplayColumns();

}
saveDisplayColumns()
{
  var dispCol = <DisplayColumnsArray>{};
  dispCol.displayColumns = [];
  var ind = 0;
  console.info("selDropdownList #: " + this.selDropdownList.length);
  console.log('Save: ' + this.form.controls.transType.value);
  for (var item of this.selDropdownList)
  {
       console.log('Save: ' + item.item_id);
       dispCol.displayColumns.push({  id: '1',
        TransactionCode: this.form.controls.transType.value,
        key:  item.item_id,
        Order: ind});
        ind++;
  }
  console.log('Save: ' + dispCol.displayColumns.length);

      this.TransactionService.saveDisplayColumns(dispCol).subscribe((res: any) => {

          console.info("TransactionService: " + res);
          /***

          this.TransactionService.fetchTransactionFields(0).subscribe((res: any) => {
            this.transactionsSearchColumns = [];

              for (var item of res)
              {
                // console.info("Push transactionsSearchColumns: " + item.Key)
                  this.transactionsSearchColumns.push({key: item.Key, type: item.Type, label: item.Label, transactionCode: item.TransactionCode, detail: item.Detail});
              }
              console.info("transactionsSearchColumns: " + this.transactionsSearchColumns.length);
              console.info("Usr Columns: " + this.usrDisplayColumns.length);
              this.TransactionService.fetchDisplayColumns().subscribe((res: any) => {
                this.usrDisplayColumns.splice(0, this.usrDisplayColumns.length)
                this.usrDisplayColumns.push(...res);

                if(this.currentTransType !== '')
                {

                console.info("User display columns: " + this.usrDisplayColumns.length);
                this.transactionChange(this.currentTransType);

                console.info('Transaction search with: ' + this.searchString);
                this.onSearchTransactions();
                }
              });

            });
            ***/

        });
}

expandCollapse(index: boolean) {
  this.panelExpand = index;
}

searchTypeChange(evt: any)
{
  this.displayLabel = "Display columns for: "+this.form.controls.searchType.value;
  this.searchTypeString = this.form.controls.searchType.value

  this.form.controls.rowCnt.setValue(this.maxCount[1]);

}

transactionChange(evt: any)
{
  this.displayLabel = "Display columns for: "+this.form.controls.transType.value;
  this.dataTableLabel = [];
  this.dataTableKey = [];
  this.selectedItems = [];
  this.searchColumns =[];
  this.selDropdownList= [];

  this.allDropdownList= [];
  var allTempArr= [];
  this.dataSource.data = [];
  console.info(this.displayLabel +", this.currentTransType: " + this.currentTransType)

  // Bryan does not want search to clear
  /**
  if(this.form.controls.transType.value !== this.currentTransType)
  {
    this.clearSearch();
  }
  **/
  this.currentTransType = this.form.controls.transType.value;
  for (var col of this.transactionsSearchColumns)
  {

    if ( (col.transactionCode == 'All') || (col.transactionCode === this.form.controls.transType.value && col.detail != '1'))
    {
      allTempArr.push({item_id:col.key, item_text:col.label});
    }
  }
  this.allDropdownList = allTempArr;
  var tempArr = [];

  for (var col of this.transactionsSearchColumns)
    {
      // console.info("searchColumns push? = " + col.key + ", " + col.transactionCode);
      if ( (col.transactionCode == 'All') || (col.transactionCode === this.form.controls.transType.value && col.detail != '1'))
      {
          this.searchColumns.push(col);
          // console.info("searchColumns pushed: " + col.key);
      }
    }

  if(this.usrDisplayColumns.length > 0)
  {
    console.info("Check usrDisplayColumns: " + this.usrDisplayColumns.length +', allDropdownList #: ' + this.allDropdownList.length);

    for (var disp of this.usrDisplayColumns)
    {
      // console.info(disp.TransactionCode + ", # " + this.transactionsSearchColumns.length +', allDropdownList #: ' + this.allDropdownList.length)
      for (var col of this.transactionsSearchColumns)
      {

        if ( disp.TransactionCode === this.form.controls.transType.value && disp.key === col.key)
        {
          var selInd = this.allDropdownListFind(col.label);
          if(selInd !== -1)
          {
            // console.info(disp.TransactionCode + " PUSH User selected column: " + disp.key + "===" + col.key +", selInd: " + selInd)
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
    this.searchColumns = [];
    this.allDropdownList = [];
    var tempArr2 = [];
    for (var col of this.transactionsSearchColumns)
    {

    if ( (col.transactionCode == 'All') || (col.transactionCode === this.form.controls.transType.value && col.detail != '1') )
      {
          // console.info(col.transactionCode + " PUSH " + col.key)

          tempArr.push({item_id:col.key, item_text:col.label});
          tempArr2.push({item_id:col.key, item_text:col.label});

          //  console.info('searchColumns.push: ' + col.label)
          this.searchColumns.push(col);

      }
    }
    this.selDropdownList =  tempArr;
    this.allDropdownList = tempArr2;
  }
  else{
    console.info("Nothing from User display columns")
  }

  // Two fields that are not part of ERP data table
  this.dataTableLabel.push('Sender');
  this.dataTableKey.push('Sender');
  this.dataTableLabel.push('Receiver');
  this.dataTableKey.push('Receiver');

  for (var item of this.selDropdownList)
  {
      this.dataTableLabel.push(item.item_text);
      this.dataTableKey.push(item.item_id);

      //  console.info("selDropdownList key: " + item.item_id +", val: " +item.item_text )
      this.selectedItems.push({key:item.item_id, label:item.item_text})

  }


  console.info("allDropdownList #: " + this.allDropdownList.length);
  console.info("selDropdownList #: " + this.selDropdownList.length);
  console.info("searchColumns #: " + this.searchColumns.length);

  this.butSaveDisplay = false;
}

setSearchField()
{
  console.log("In setSearchField: " +this.form.controls.searchField.value)
  this.searchFieldVal = this.form.controls.searchField.value;
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



}


