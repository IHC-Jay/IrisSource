import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormControl, Validators, NgForm } from '@angular/forms';
import {EligibilityRequest} from './EligibilityRequest'
import {Claim} from './Claims';
import {ClaimStatusResp} from './ClaimStatusResp';
import {ClaimStatusReq} from './ClaimStatusReq';
import {TransRestServiceComponent} from '../services/transrest-service.component';
import { MatTableDataSource } from '@angular/material/table';
import {MatAccordion, MatExpansionModule} from '@angular/material/expansion';
import {MatRadioModule, MatRadioGroup} from '@angular/material/radio';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { Router, ActivatedRoute } from '@angular/router';
import {MatSelectModule,} from '@angular/material/select';
import {DisplayColumns, DisplayColumnsArray} from './DisplayColumns'

import {MatNativeDateModule} from '@angular/material/core';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatFormFieldModule} from '@angular/material/form-field';
import { MatMenu, MatMenuTrigger } from '@angular/material/menu';

@Component({
  selector: 'app-transaction',
  templateUrl: './transaction.component.html',
  styleUrls: ['./transaction.component.css']
})



export class TransactionComponent implements OnInit, AfterViewInit {

  contextMenuPosition = { x: '0px', y: '0px' };
  @ViewChild(MatMenuTrigger)
  contextMenu: MatMenuTrigger;


  displayLabel: string = "Display columns:";

  nowDt = new Date((new Date().getTime() - (24 * 60 * 60 * 1000)));

startDate = "2023-01-12";
endDate ="13:30";
  startTm = "13:30";
  endTm= "2023-01-12";
  paramsList: string[];

    maxCount = ["10", "25", "50", "100", "200"];
    dispositions = ["All", "Processed", "Rejected"];

  transactionTypes: string[] = ["All", "270", "271","276", "277", "277CA", "835", "837I", "837P", "837D", "999", "TA1"];

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

    this.form = this.formBuilder.group({

      rowCnt:['25', Validators.required],
      transType: ['270', Validators.required],
      btControl: ['Batch', Validators.required],
      searchField: ['ID', Validators.required],
      disposition: ['Processed'],
      mode:['RealTime', Validators.required],
      searchCndition: ['=', Validators.required],
      searchValue: ['', Validators.required],
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
    this.currentTransType = '270'

    this.sub = this.route.queryParams.subscribe(params => {

      if(params !== undefined && params.transaction !== undefined)
        {
      // Defaults to '' if no query param provided.

      this.currentTransType =  params['transaction'] || '';
      this.searchString = params['search'] || '';
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


        if (this.searchString !== '')
        {
          console.log('set search controls, ' + this.searchTransaction);
          this.form.controls.searchField.setValue(this.searchString);
          this.searchTransaction = true;
        }
        else{
        this.clearSearch();
      }
     }
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
      console.info("Init Usr Columns: " + this.usrDisplayColumns.length);

      this.TransactionService.fetchDisplayColumns().subscribe((res: any) => {
        this.usrDisplayColumns.splice(0, this.usrDisplayColumns.length)
        this.usrDisplayColumns.push(...res);
        console.info("User display columns from fetchDisplayColumns: " + this.usrDisplayColumns.length);

        if(this.currentTransType !== '')
        {

        this.transactionChange(this.currentTransType);

        console.info('Transaction search for: ' + this.currentTransType);
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
      this.paramsList = [];
      this.paramsList.push("mode::" + this.form.controls.mode.value);
      this.paramsList.push("transaction::"+this.form.controls.transType.value);
      this.paramsList.push("status::"+this.form.controls.disposition.value );

      this.paramsList.push("startDtTm::" + this.startDate +" "+ this.startTm);

      this.paramsList.push("endDtTm::" + this.endDate+" " +this.endTm );
      this.paramsList.push("count::" + this.form.controls.rowCnt.value);

      if(this.searchString !== "")
      {
        this.paramsList.push("sql::" + this.searchString);
      }

      console.info("Mode# " +  this.form.controls.mode.value + ", " + this.form.controls.transType.value + ", " + this.form.controls.disposition.value );
      console.info("Start# " +  this.startDate + ", " + this.startTm );
      console.info("End# " +  this.endDate  + ", " + this.endTm );
      console.info("onSearchTransactions count: " +this.form.controls.rowCnt.value)
      if (this.form.controls.transType.value === '' && this.currentTransType !== '')
      {
        this.form.controls.transType.setValue(this.currentTransType);
      }


      this.loading = true;

      if(this.form.controls.transType.value === '270')
      {

            this.TransactionService.fetchEligibilityRequests(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {

            this.dataSource.data = res;
            this.canRenderDetails = true;

            console.info("Data rows array: " + this.dataSource.data.length);

            this.loading = false;

            this.setControls();
            });

      }
      else if(this.form.controls.transType.value === '271'){

        this.TransactionService.fetchEligibilityBenefitResponses(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
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

        this.TransactionService.fetchClaimPayment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
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

          this.paramsList.push("addSql::" + "VersionReleaseIndustryIdenti='005010X222A1' " + staticSearchStr);

         this.TransactionService.fetchClaims(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
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
        this.paramsList.push("addSql::" + "VersionReleaseIndustryIdenti='005010X223A2' ")
        this.TransactionService.fetchClaims(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
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
        this.paramsList.push("addSql::" + "VersionReleaseIndustryIdenti='005010X224A2' ")
        this.TransactionService.fetchClaims(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claims array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === '276'){

        this.TransactionService.fetchClaimStatusReq(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Status  Req array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else if(this.form.controls.transType.value === '277'){

         this.TransactionService.fetchClaimStatusResp(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
          this.dataSource.data = res;
          this.canRenderDetails = true;
          this.loading = false;
          console.info("Claim Status Resp array: " + this.dataSource.data.length);
          this.setControls();
         });

       }
       else if(this.form.controls.transType.value === '277CA'){

        this.TransactionService.fetchClaimAcknowledgment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Claim Acknowledgment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
       else if(this.form.controls.transType.value === '999'){

        this.TransactionService.fetchImplementationAcknowledgment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
         this.dataSource.data = res;
         this.canRenderDetails = true;
         this.loading = false;
         console.info("Implementation Acknowledgment array: " + this.dataSource.data.length);
         this.setControls();
        });

      }
      else if(this.form.controls.transType.value === 'TA1'){

        this.TransactionService.fetchInterchangeAcknowledgment(this.form.controls.mode.value, this.paramsList).subscribe((res: any) => {
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
          this.searchString += " AND " + sVal +  " BETWEEN '" + this.startDate +"' AND '" + this.endDate +"'";
        }
        else
        {
          this.searchString =  sVal + " " + " BETWEEN '" + this.startDate +"' AND '" + this.endDate +"'";
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
  this.searchTypeString = "";
  this.paramsList.forEach( val => {
    this.searchTypeString += val +";";
   });

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
            ***/


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

// Handle right click

onContextMenu(event: MouseEvent, row:any, ind: number) {
  event.preventDefault();

  console.log( ind +'. Row clicked: ' + row.id );

  this.contextMenuPosition.x = event.clientX + 'px';
  this.contextMenuPosition.y = event.clientY + 'px';
  let item: Item ={id: row.id, rowId: ind};
  this.contextMenu.menuData = { 'item': item };
  this.contextMenu.menu.focusFirstItem('mouse');
  this.contextMenu.openMenu();
}

onContextMenuNew(item: Item) {
  // alert('Click on Action 1 ' + item.id);

    this.searchTypeString = "";
  this.paramsList.forEach( val => {
    this.searchTypeString += val +";";
   });
   this.searchTypeString += ";sameWindow::false";

       const url = this.router.serializeUrl(this.router.createUrlTree(["/transaction/transaction-details/"],
      {queryParams: { id:  item.id, 'transaction': this.form.controls.transType.value, 'search': this.searchString, 'searchTypeString': this.searchTypeString } }
       ));
    const newTab = window.open(url, '_blank');
    if(newTab) {
        newTab.opener = null;
    }



}

onContextMenuSame(item: Item) {
  // alert('Click on Action 2' + item.id);

  this.searchTypeString = "";
  this.paramsList.forEach( val => {
    this.searchTypeString += val +";";
   });
   this.searchTypeString += ";sameWindow::true";
      this.router.navigate(["/transaction/transaction-details/"],
      {queryParams: { id:  item.id, 'transaction': this.form.controls.transType.value, 'search': this.searchString, 'searchTypeString': this.searchTypeString } }
       );

}


}

export interface Item {
  id: number;
  rowId: number;
}

