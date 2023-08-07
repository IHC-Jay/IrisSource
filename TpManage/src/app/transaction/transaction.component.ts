import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import {EligibilityRequest} from './EligibilityRequest'
import {Claim} from './Claims';
import {ClaimStatusResp} from './ClaimStatusResp';
import {ClaimStatusReq} from './ClaimStatusReq';
import {RestServiceComponent} from '../services/rest-service.component';
import { MatTableDataSource } from '@angular/material/table';
import {MatAccordion, MatExpansionModule} from '@angular/material/expansion';

import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { Router, ActivatedRoute } from '@angular/router';
import { IDropdownSettings } from 'ng-multiselect-dropdown';
import {DisplayColumns, DisplayColumnsArray} from './DisplayColumns'

@Component({
  selector: 'app-transaction',
  templateUrl: './transaction.component.html',
  styleUrls: ['./transaction.component.css']
})



export class TransactionComponent implements OnInit, AfterViewInit {
  displayLabel: string = "Display columns:";
  TransactionTypes= ["270", "271","276", "277", "277CA", "835", "837I", "837P", "837D", "999"];
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

  dataSource = new MatTableDataSource<any>();

  usrDisplayColumns= [

    {
      key: 'usrK',
      Order: '0',
      TransactionCode: 'usrL'
    }];

  transactionsSearchColumns= [
    {
      key: 'ApplicationSendersCode',
      type: 'text',
      label: 'Application SendersCode',
      transactionCode: '270',
      detail: '1'
    }];


  searchColumns= this.transactionsSearchColumns.slice();

  @ViewChild("searchValue") searchValue: ElementRef;
  @ViewChild("searchField") searchField: ElementRef;
  @ViewChild("searchCndition") searchCndition: ElementRef;
  @ViewChild("transType") transType: ElementRef;

  searchString = "";
  currentTransType = '';
  sub:any;
  isTableExpanded = false;

  selDropdownList = [];

  allDropdownList = [];


  @ViewChild(MatPaginator) paginator: MatPaginator;
  @ViewChild(MatSort) sort: MatSort;


  dropdownSettings={};

  selectedItems=[];

  constructor(private TransactionService: RestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute){
      tpId: new FormControl();
  }


  ngOnInit()
  {
    console.info("ngOnInit");

    this.form = this.formBuilder.group({
      transType: ['', Validators.required],
      searchField: ['', Validators.required],
      searchCndition: ['', Validators.required],
      searchValue: ['', Validators.required]
    });

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
      this.currentTransType =  params['trans'] || '';
      this.searchString = params['search'] || '';

      console.log('ngOnInit - Query params ' + this.searchString +", transType: " + this.currentTransType);
      if (this.currentTransType !== '')
      {
        this.form.controls.transType.setValue(this.currentTransType);
        this.form.controls.searchValue.setValue(this.searchString);
        if (this.searchString !== '')
        {
          this.searchTransaction = true;
        }
        console.log('set search controls, ' + this.searchTransaction);
      }
      else{
        this.clearSearch();
      }
    });


    this.TransactionService.fetchTransactionFields().subscribe((res: any) => {
    this.transactionsSearchColumns = [];

      for (var item of res)
      {
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

    // this.clearSearch();


  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;

  }
  get f() { return this.form.controls; }

  onSearchTransactions()
    {

      if (this.form.controls.transType.value === '' && this.currentTransType !== '')
      {
        this.form.controls.transType.setValue(this.currentTransType);
      }
      console.info("TransType: " +this.form.controls.transType.value)

      this.loading = true;

      if(this.form.controls.transType.value === '270')
      {

            console.info('Transaction search with: ' + this.searchString);
            this.TransactionService.fetchEligibilityRequests(this.searchString).subscribe((res: any) => {
            this.dataSource.data = res;
            this.canRenderDetails = true;

            console.info("Data rows array: " + this.dataSource.data.length);

            this.loading = false;

            if(this.dataSource.data.length === 0)
            {
              alert("No rows found for " + this.searchString);
            }
            this.clearSearch();
            this.setControls();
            });

      }
      else if(this.form.controls.transType.value === '271'){

        this.TransactionService.fetchEligibilityBenefitResponses(this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("EligibilityBenefitResponses array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '835'){

        this.TransactionService.fetchClaimPayment(this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("ClaimPayment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '837P'){

        if(this.searchString.length > 0)
        {
          this.searchString = " AND " + this.searchString
        }
         this.TransactionService.fetchClaims("VersionReleaseIndustryIdenti='005010X222A1' " + this.searchString).subscribe((res: any) => {
          this.dataSource.data = res;
          this.canRenderDetails = true;
          this.loading = false;
          console.info("Claims array: " + this.dataSource.data.length);
          this.setControls();
         });

       }
       else if(this.form.controls.transType.value === '837I'){
        if(this.searchString.length > 0)
        {
          this.searchString = " AND " + this.searchString
        }
        this.TransactionService.fetchClaims("VersionReleaseIndustryIdenti='005010X223A2' " + this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claims array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '837D'){
        if(this.searchString.length > 0)
        {
          this.searchString = " AND " + this.searchString
        }
        this.TransactionService.fetchClaims("VersionReleaseIndustryIdenti='005010X224A2' " + this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claims array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '276'){

        this.TransactionService.fetchClaimStatusReq(this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Status  Req array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else if(this.form.controls.transType.value === '277'){

         this.TransactionService.fetchClaimStatusResp(this.searchString).subscribe((res: any) => {
          this.dataSource.data = res;
          this.canRenderDetails = true;
          this.loading = false;
          console.info("Claim Status Resp array: " + this.dataSource.data.length);
          this.setControls();
         });

       }
       else if(this.form.controls.transType.value === '277CA'){

        this.TransactionService.fetchClaimAcknowledgment(this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Acknowledgment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else if(this.form.controls.transType.value === '999'){

        this.TransactionService.fetchImplementationAcknowledgment(this.searchString).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Implementation Acknowledgment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else // Not Implemented
       {
        this.searchColumns = [];
        this.selDropdownList = this.nyiColumns;
        var elig:EligibilityRequest = <EligibilityRequest>{};

        this.dataSource.data.push(elig);
        this.canRenderDetails = true;
        this.loading = false;
        console.info("NotImplementd array: " + this.dataSource.data.length);
       }

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

addRow() {

      if (this.form.invalid) {
        console.info('Invalid: ' + this.form.invalid);
        alert("Search Value is required");
          return;
      }


    this.searchTransaction = true;
    this.submitted = true;

    let  sVal = ""
    for (var item of this.searchColumns)
      {
        if(item.label === this.form.controls.searchField.value)
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
      console.log('Row clicked: ' + row + ", Search: " + this.searchString);
      this.router.navigate(["/transaction/transaction-details/"],
      {queryParams: { id:  row.id, 'transaction': this.form.controls.transType.value, 'search': this.searchString } }
       );
  }


onItemSelect(inp: any) {
    console.log('onItem Select: ' + inp.item_id + ", #: " + this.dataTableLabel.length);
    this.dataTableLabel.push(inp.item_text);
    this.dataTableKey.push(inp.item_id);

}

onItemDeSelect(inp: any)
{
  console.log('onItem DeSelect: ' + inp.item_id + ", #: " + this.dataTableLabel.length);
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
saveDisplayColumns()
{
  var dispCol = <DisplayColumnsArray>{};
  dispCol.displayColumns = [];
  var ind = 0;
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

        });
}

expandCollapse(index: boolean) {
  this.panelExpand = index;
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
  for (var col of this.transactionsSearchColumns)
  {

    if ( ( col.transactionCode == '1') || (col.transactionCode === this.form.controls.transType.value && col.detail != '1'))
    {
      allTempArr.push({item_id:col.key, item_text:col.label});
    }
  }
  this.allDropdownList = allTempArr;
  var tempArr = [];

  for (var col of this.transactionsSearchColumns)
    {
      if ( (col.transactionCode === '1') || (col.transactionCode === this.form.controls.transType.value && col.detail != '1'))
      {
          this.searchColumns.push(col);
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
            console.info(disp.TransactionCode + " PUSH " + disp.key + "===" + col.key +", selInd: " + selInd)
            tempArr.push({item_id:selInd, item_text:col.label});

            break;
          }
        }
      }
    }
    this.selDropdownList =  tempArr;
  }
  if(tempArr.length === 0)
  {
    this.searchColumns = [];
    this.allDropdownList = [];
    for (var col of this.transactionsSearchColumns)
    {
      if ( (col.transactionCode === '1') || (col.transactionCode === this.form.controls.transType.value && col.detail != '1') )
      {
          console.info(col.transactionCode + " PUSH " + col.key)

          tempArr.push({item_id:col.key, item_text:col.label});
          this.searchColumns.push(col);
      }
    }
    this.selDropdownList =  tempArr;
    this.allDropdownList = tempArr;
  }
  for (var item of this.selDropdownList)
  {
    console.info("selDropdownList key: " + item.item_id +", val: " +item.item_text )
      this.dataTableLabel.push(item.item_text);
      this.dataTableKey.push(item.item_id);
      this.selectedItems.push({key:item.item_id, label:item.item_text})
  }


  console.info("allDropdownList #: " + this.allDropdownList.length);
  console.info("selDropdownList #: " + this.selDropdownList.length);
  console.info("searchColumns #: " + this.searchColumns.length);

  this.butSaveDisplay = false;
}

allDropdownListFind(label:string)
{
  for(var val of this.allDropdownList)
  {
    if(val.item_text === label)
    {
      console.info("allDropdownListFind: " + val.item_id);
      return val.item_id
    }
  }
  return -1;
}

}



