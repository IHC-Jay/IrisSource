import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import {EligibilityRequest} from './EligibilityRequest'
import {Claim} from './Claims';
import {ClaimStatusResp} from './ClaimStatusResp';
import {ClaimStatusReq} from './ClaimStatusReq';
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

  searchTypes = [
      "Batch, Last 24 hours ",
      "Batch, Last 7 days ",
      "Batch, Last 30 days ",
      "Batch, Last 90 days ",
      "RT, Last 24 hours ",
      "RT, Last 7 days ",
      "RT, Last 30 days "
    ];

    maxCount = ["10", "25", "50", "100", "200"];

  transactionTypes: string[] = [];
  rtTransactionTypes= ["270", "271","276", "277", "999", "TA1"];
  batchTransactionTypes= ["270", "271","276", "277", "277CA", "835", "837I", "837P", "837D", "999", "TA1"];

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
  @ViewChild("searchType") searchType: ElementRef;
  @ViewChild("rowCnt") rowCnt: ElementRef;
  @ViewChild("transType") transType: ElementRef;
  @ViewChild("displayCols") displayCols: ElementRef;
  @ViewChild("matStartDate") matStartDate: string;
  @ViewChild("matEndDate") matEndDate: string;

  searchString = "";
  searchTypeString = "";
  currentTransType = '';
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
    console.info("ngOnInit");

    this.form = this.formBuilder.group({
      searchType: ['', Validators.required],
      rowCnt:['', Validators.required],
      transType: ['', Validators.required],
      searchField: ['', Validators.required],
      searchCndition: [''],
      searchValue: [''],
      matStartDate: [''],
      matEndDate:[''],
      InterchangeSenderID:[''],
      InterchangeReceiverID:[''],
      InterchangeDate:[''],
      TRNRefId:[''],
      loop1000AN11PRName:[''],
      loop21001NM11NameFirst:[''],
      loop21001NM11NameLastorOrganizationName:[''],
      loop23001CLMClaimSubmittersIdentifier:[''],
      loop2010AAREF1RefId:[''],
      loop2010BANM11ILIdentificationCode:[''],
      loop24001DTP1DateTimePeriod:[''],
      FileName:['']
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

      this.currentTransType =  params['transaction'] || '';
      this.searchString = params['search'] || '';
      this.searchTypeString = params['searchTypeString'];

      console.log('ngOnInit - Query params ' + this.searchTypeString +", transType: " + this.currentTransType);


      if (this.currentTransType !== '')
      {
        this.form.controls.searchType.setValue(this.searchTypeString);
        this.searchTypeChange(null);
        this.form.controls.transType.setValue(this.currentTransType);
        this.form.controls.searchValue.setValue(this.searchString);
        this.form.controls.rowCnt.setValue("25");

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

    // this.clearSearch();


  }

  ngAfterViewInit() {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;

  }
  get f() { return this.form.controls; }

  onSearchTransactions()
    {
      this.canRenderDetails = false;
      console.info("onSearchTransactions TransType: " +this.form.controls.transType.value +",  currentTransType: " +  this.currentTransType)
      if (this.form.controls.transType.value === '' && this.currentTransType !== '')
      {
        this.form.controls.transType.setValue(this.currentTransType);
      }


      this.loading = true;

      if(this.form.controls.transType.value === '270')
      {

            console.info('Transaction search with: ' + this.searchString);
            this.TransactionService.fetchEligibilityRequests(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {

            this.dataSource.data = res;
            this.canRenderDetails = true;

            console.info("Data rows array: " + this.dataSource.data.length);

            this.loading = false;

            this.setControls();
            });

      }
      else if(this.form.controls.transType.value === '271'){

        this.TransactionService.fetchEligibilityBenefitResponses(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("EligibilityBenefitResponses array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '835'){

        let staticSearchStr = "";
        if(this.form.controls.InterchangeReceiverID.value !== '')
        {
          staticSearchStr = " AND InterchangeReceiverID = '" + this.form.controls.InterchangeReceiverID.value + "'"
        }
        if(this.form.controls.TRNRefId.value !== '')
        {
          staticSearchStr = staticSearchStr +  " AND TRNRefId = '" + this.form.controls.TRNRefId.value + "'"
        }
        if(this.form.controls.loop1000AN11PRName.value !== '')
        {
          staticSearchStr = staticSearchStr +  " AND loop1000AN11PRName = '" + this.form.controls.loop1000AN11PRName.value + "'"
        }


        if(this.form.controls.loop21001NM11NameFirst.value !== '')
        {
          staticSearchStr = " AND loop2010AAREF1RefId = '" + this.form.controls.loop21001NM11NameFirst.value + "'"
        }
        if(this.form.controls.loop21001NM11NameLastorOrganizationName.value !== '')
          {
            staticSearchStr = " AND loop21001NM11NameLastorOrganizationName = '" + this.form.controls.loop21001NM11NameLastorOrganizationName.value + "'"
          }
        if(this.form.controls.InterchangeDate.value !== '')
            {
              staticSearchStr = " AND InterchangeDate = '" + this.form.controls.InterchangeDate.value + "'"
            }

        {

        }
        if(this.searchString.length > 0)
        {
          staticSearchStr = staticSearchStr + " AND " + this.searchString

        }
        staticSearchStr = staticSearchStr.replace('AND','') // Remove first AND

        console.info("835 search: "+ staticSearchStr + ", " + this.searchString + ", " +  this.searchTypeString)

        this.TransactionService.fetchClaimPayment(staticSearchStr, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("ClaimPayment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '837P'){
        let staticSearchStr = "";
        if(this.form.controls.InterchangeSenderID.value !== '')
        {
          staticSearchStr = " AND InterchangeSenderID = '" + this.form.controls.InterchangeSenderID.value + "'"
        }
        if(this.form.controls.loop23001CLMClaimSubmittersIdentifier.value !== '')
        {
          staticSearchStr = staticSearchStr +  " AND loop23001CLMClaimSubmittersIdentifier = '" + this.form.controls.loop23001CLMClaimSubmittersIdentifier.value + "'"
        }

        if(this.form.controls.loop2010AAREF1RefId.value !== '')
        {
          staticSearchStr = " AND loop2010AAREF1RefId = '" + this.form.controls.loop2010AAREF1RefId.value + "'"
        }
        if(this.form.controls.loop2010BANM11ILIdentificationCode.value !== '')
          {
            staticSearchStr = " AND loop2010BANM11ILIdentificationCode = '" + this.form.controls.loop2010BANM11ILIdentificationCode.value + "'"
          }
        if(this.form.controls.loop24001DTP1DateTimePeriod.value !== '')
            {
              staticSearchStr = " AND loop24001DTP1DateTimePeriod = '" + this.form.controls.loop24001DTP1DateTimePeriod.value + "'"
            }
        if(this.form.controls.FileName.value !== '')
        {
                staticSearchStr = " AND FileName = '" + this.form.controls.FileName.value + "'"
        }


        if(this.searchString.length > 0)
        {
          staticSearchStr = staticSearchStr + " AND " + this.searchString
        }
         this.TransactionService.fetchClaims("VersionReleaseIndustryIdenti='005010X222A1' " + staticSearchStr, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
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
        this.TransactionService.fetchClaims("VersionReleaseIndustryIdenti='005010X223A2' " + this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
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
        this.TransactionService.fetchClaims("VersionReleaseIndustryIdenti='005010X224A2' " + this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claims array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '276'){

        this.TransactionService.fetchClaimStatusReq(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Status  Req array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else if(this.form.controls.transType.value === '277'){

         this.TransactionService.fetchClaimStatusResp(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
          this.dataSource.data = res;
          this.canRenderDetails = true;
          this.loading = false;
          console.info("Claim Status Resp array: " + this.dataSource.data.length);
          this.setControls();
         });

       }
       else if(this.form.controls.transType.value === '277CA'){

        this.TransactionService.fetchClaimAcknowledgment(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Acknowledgment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else if(this.form.controls.transType.value === '999'){

        this.TransactionService.fetchImplementationAcknowledgment(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Implementation Acknowledgment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === 'TA1'){

        this.TransactionService.fetchInterchangeAcknowledgment(this.searchString, this.searchTypeString, this.form.controls.rowCnt.value).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Interchange Acknowledgment array: " + this.dataSource.data.length);
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

      if(this.searchFieldVal === 'Process Time')
      {
        if(this.searchString !== "")
        {
          this.searchString += " AND " + sVal +  " BETWEEN '" + this.matStartDate +"' AND '" + this.matEndDate +"'";
        }
        else
        {
          this.searchString =  sVal + " " + " BETWEEN '" + this.matStartDate +"' AND '" + this.matEndDate +"'";
        }
      }
      else
      {
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
    }


onRowClicked(row) {


      console.log('Row clicked: ' + row.id + ", Search: " + this.searchString + ', searchTypeString: '+ this.searchTypeString );

      const url = this.router.serializeUrl(this.router.createUrlTree(["/transaction/transaction-details/"],
      {queryParams: { id:  row.id, 'transaction': this.form.controls.transType.value, 'search': this.searchString, 'searchTypeString': this.searchTypeString } }
       ));
    const newTab = window.open(url, '_blank');
    if(newTab) {
        newTab.opener = null;
    }
    /*
      this.router.navigate(["/transaction/transaction-details/"],
      {queryParams: { id:  row.id, 'transaction': this.form.controls.transType.value, 'search': this.searchString, 'searchTypeString': this.searchTypeString } }
       );
       */
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

          this.TransactionService.fetchTransactionFields().subscribe((res: any) => {
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


        });
}

expandCollapse(index: boolean) {
  this.panelExpand = index;
}

searchTypeChange(evt: any)
{
  this.displayLabel = "Display columns for: "+this.form.controls.searchType.value;
  this.searchTypeString = this.form.controls.searchType.value
  if ( String(this.form.controls.searchType.value).startsWith('RT'))
  {
      this.transactionTypes = [...this.rtTransactionTypes];
  }
  else{
    this.transactionTypes = [...this.batchTransactionTypes];
  }
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
  if(this.form.controls.transType.value !== this.currentTransType)
  {
    this.clearSearch();
  }
  this.currentTransType = this.form.controls.transType.value;
  for (var col of this.transactionsSearchColumns)
  {

    if ( (Number.parseInt(col.transactionCode) == 1) || (col.transactionCode === this.form.controls.transType.value && col.detail != '1'))
    {
      allTempArr.push({item_id:col.key, item_text:col.label});
    }
  }
  this.allDropdownList = allTempArr;
  var tempArr = [];

  for (var col of this.transactionsSearchColumns)
    {
      // console.info("searchColumns push? = " + col.key + ", " + col.transactionCode);
      if ( (Number.parseInt(col.transactionCode) == 1) || (col.transactionCode === this.form.controls.transType.value && col.detail != '1'))
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

      if (this.form.controls.transType.value === '837P')
      {
        if ( col.key === 'loop23001CLMClaimSubmittersIdentifier' ||
        col.key === 'loop2010AAREF1RefId' ||
        col.key === 'loop2010BANM11ILIdentificationCode' ||
        col.key === 'loop24001DTP1DateTimePeriod' ||
        col.key === 'FileName' ||
        col.key === 'InterchangeSenderID'
        )
        {
          console.log("In 837P static list , Add to Display column;");
          tempArr.push({item_id:col.key, item_text:col.label});
          tempArr2.push({item_id:col.key, item_text:col.label});
        }
      }
      else if (this.form.controls.transType.value === '835')
        {
          if ( col.key === 'loop1000AN11PRName' || col.key === 'TRNRefId' ||
          col.key === 'loop21001NM11NameFirst' ||
          col.key === 'loop21001NM11NameLastorOrganizationName' ||
          col.key === 'InterchangeReceiverID' ||
          col.key === 'InterchangeDate'
          )
          {
            console.log("In static list for 835, Add to Display column;");
            tempArr.push({item_id:col.key, item_text:col.label});
            tempArr2.push({item_id:col.key, item_text:col.label});
          }
        }

      else if ( (Number.parseInt(col.transactionCode) == 1) || (col.transactionCode === this.form.controls.transType.value && col.detail != '1') ){

          this.searchColumns.push(col);
          tempArr2.push({item_id:col.key, item_text:col.label});
          console.log('Search dropdown PUSH: ' + this.form.controls.transType.value +" / " +  col.key);
      }

      else if ( (Number.parseInt(col.transactionCode) == 1) || (col.transactionCode === this.form.controls.transType.value && col.detail != '1') )
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

onDateChange(type: any, event: any)
{
  var myDate = new Date(event.value);
  var sqlDt = myDate.getFullYear() + '-' + (myDate.getMonth() + 1) + '-' + myDate.getDate()
  console.log("In onDateChange " + myDate +" - " + sqlDt)
  if(type === 'start')
  {
    this.matStartDate = sqlDt ;
  }
  else
  {
    this.matEndDate =   sqlDt;
  }


}

}


