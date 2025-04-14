import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';

import { FormBuilder, FormGroup, FormArray, FormControl, Validators, NgForm } from '@angular/forms';


import {TransRestServiceComponent} from '../../services/transrest-service.component';
import { MatTableDataSource } from '@angular/material/table';
import {MatAccordion, MatExpansionModule} from '@angular/material/expansion';
import {MatRadioModule, MatRadioGroup} from '@angular/material/radio';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { Router, ActivatedRoute } from '@angular/router';
import {MatSelectModule,} from '@angular/material/select';
import {DisplayColumns, DisplayColumnsArray} from '../DisplayColumns'
import {SearchColumns, SearchColumnsArray} from '../SearchColumns'
import {ConfirationArray, ConfigColumns} from '../Configuration';

import {MatNativeDateModule} from '@angular/material/core';
import {MatDatepickerModule} from '@angular/material/datepicker';
import {MatFormFieldModule} from '@angular/material/form-field';
import { MatMenu, MatMenuTrigger } from '@angular/material/menu';
import { MatSelect, MatSelectChange } from '@angular/material/select';
import { MatFormField } from '@angular/material/form-field';
import {Link, tabLinks} from '../../header/Links';


@Component({
  selector: 'app-transaction-settings',
  templateUrl: './transaction-settings.component.html',
  styleUrls: ['./transaction-settings.component.css']
})



export class TransactionSettingsComponent implements OnInit, AfterViewInit {


  paramsList: string[];

  maxCount = ["10", "25", "50", "100", "200"];

  logoutTime = ["15", "30", "60", "120"]

  searchTime = ["Last 1 day", "Last 7 days", "Last 30 days"];

  landingPage = ["Trading Partners", "Dashboard", "Batches", "Transactions", "Work Flow"];

  transactionTypes: string[] = ["270", "271","276", "277", "277CA", "835", "837I", "837P", "837D", "999", "TA1"];

  modes: string[] = ["Batch", "RealTime"];

  form!: FormGroup;

// All transaction fields from the service

additionalSearchStr :string;
searchTypeString:string = "";

  allTransactionsFields= [
    {
      key: 'Invalid',
      type: 'text',
      label: 'Select Transaction to view the Columns',
      transactionCode: '270',
      order: 1,
      checked: 'false'
    }];

    // Display columns for a user from the service
    usrDisplayColumns: DisplayColumns[] = [];

    // Search columns for a user from the service
    usrSearchColumns: SearchColumns[] = [];

  displayCheckBoxValues= this.allTransactionsFields.slice();
  searchCheckBoxValues= this.allTransactionsFields.slice();

  @ViewChild("cngfDispCnt") cngfDispCnt: ElementRef;
  @ViewChild("dispTransType") dispTransType: ElementRef;
  @ViewChild("dispMode") dispMode: ElementRef;

  modeString = "Batch";
  currentTransType = '270';
  sub:any;
  value = 'Clear me';
  showMode = 1
  showCngfMode = 1
  usrSelectedDisplayFields = [];

  cngfTranType = "835"
  cngfMode = "Batch";

  usrSelectedSearchFields = [];

  constructor(private TransactionService: TransRestServiceComponent,
    private formBuilder: FormBuilder, private router: Router, private route: ActivatedRoute){
      tpId: new FormControl();

  }

  ngOnInit()
  {

    this.searchTypeString =  sessionStorage.getItem("searchTypeString");


    this.form = this.formBuilder.group({
      cngfPage:['Batches', Validators.required],
      cngfTranType:['270', Validators.required],
      cngfMode:['Batch', Validators.required],
      cngfBthTime:['Last 1 day', Validators.required],
      cngfTranTime:['Last 1 day', Validators.required],
      cngfWfTime:['Last 7 days', Validators.required],
      cngfLogoff:['30', Validators.required],
      cngfDispCnt:['25', Validators.required],
      dispTransType: ['270', Validators.required],
      dispMode:['Batch', Validators.required]
    });

    if (this.searchTypeString !== null)
    {
      let fInd = this.searchTypeString.indexOf("transaction::") + "transaction::".length;
            let val = this.searchTypeString.substring( fInd, this.searchTypeString.indexOf(";", fInd))
            console.log(fInd + ". transType:" + val )
            this.form.controls.dispTransType.setValue(val)
            this.currentTransType = val;

             fInd = this.searchTypeString.indexOf("mode::") + 6;
             val = this.searchTypeString.substring( fInd, this.searchTypeString.indexOf(";", fInd))
            console.log(fInd + ". MODE:" + val )
            this.form.controls.dispMode.setValue(val);
    }

    this.TransactionService.fetchConfiguration().subscribe((res: any) => {
      console.info("Configuration array : " + res.length);
      if (res.length == 1)
      {
          console.log('No Setting')
      }
      else
      {
        for(let ind = 0; ind < res.length; ind++)
          {

            if('Page' === res[ind].Key)
            {

              this.form.controls.cngfPage.setValue(res[ind].Value)

            }
            else if('TranType' === res[ind].Key)
              {

                this.form.controls.cngfTranType.setValue(res[ind].Value)

              }
              else if('Mode' === res[ind].Key)
                {

                  this.form.controls.cngfMode.setValue(res[ind].Value)

                }
                else if('BthTime' === res[ind].Key)
                  {

                    this.form.controls.cngfBthTime.setValue(res[ind].Value)

                  }
                  else if('TranTime' === res[ind].Key)
                    {

                      this.form.controls.cngfTranTime.setValue(res[ind].Value)

                    }
                    else if('WfTime' === res[ind].Key)
                      {

                        this.form.controls.cngfWfTime.setValue(res[ind].Value)

                      }
                      else if('Logoff' === res[ind].Key)
                        {

                          this.form.controls.cngfLogoff.setValue(res[ind].Value)

                        }
                        else if('DispCnt' === res[ind].Key)
                          {

                            this.form.controls.cngfDispCnt.setValue(res[ind].Value)

                          }

          }
      }

    });


    this.sub = this.route.queryParams.subscribe(params => {

      if(params !== undefined && params.transaction !== undefined)
        {
      // Defaults to '' if no query param provided.

      this.currentTransType =  params['transaction'] || '';
      this.modeString = params['mode'];
      this.form.controls.dispTransType.setValue(this.currentTransType);
      this.form.controls.dispMode.setValue(this.modeString)

      this.additionalSearchStr = params['additionalSearch'];
      this.searchTypeString = params['searchTypeString'];
      console.log('Query params trans: ' + this.currentTransType + ", additionalSearch: " + this.additionalSearchStr +", searchTypeString: " + this.searchTypeString);


      }
    });
    if (this.currentTransType == '')
      {
        this.currentTransType = '270'

        this.form.controls.dispTransType.setValue(this.currentTransType);
      }



    this.TransactionService.fetchTransactionFields().subscribe((res: any) => {
    this.allTransactionsFields = [];

      for (var item of res)
      {
        // console.info("Push transactionsSearchColumns: " + item.Key)
          this.allTransactionsFields.push({key: item.Key,
            type: item.Type, label: item.Label, transactionCode: item.TransactionCode, order: item.Order,
          checked:'false'});
      }
      console.info("transactionsSearchColumns: " + this.allTransactionsFields.length);
      console.info("Init Usr Columns: " + this.usrDisplayColumns.length);

      this.TransactionService.fetchDisplayColumns("Default" , "Transactions").subscribe((res: any) => {
        this.usrDisplayColumns.splice(0, this.usrDisplayColumns.length)
        this.usrDisplayColumns.push(...res);
        console.info("User display columns from fetchDisplayColumns: " + this.usrDisplayColumns.length);

      });

      this.TransactionService.fetchSearchColumns().subscribe((res: any) => {
        this.usrSearchColumns.splice(0, this.usrSearchColumns.length)
        this.usrSearchColumns.push(...res);
        console.info("User search columns from fetchSearchColumns: " + this.usrSearchColumns.length);

        if(this.currentTransType !== '')
        {

        this.transactionChange(this.currentTransType);

        }
      });

    });

  }


  get f() { return this.form.controls; }

  modeChange(evt: any)
  {
    console.info("Mode: " + this.form.controls.dispMode.value)
    this.modeString = this.form.controls.dispMode.value

  }

  cngfTranTypeChange(evt: any)
  {
    this.cngfTranType = this.form.controls.cngfTranType.value
    if (this.cngfTranType === "835" || this.cngfTranType.indexOf("837") == 0 || this.cngfTranType === "277CA")
    {
        this.cngfMode = "Batch";
        this.showCngfMode = 0

        this.form.controls.cngfMode.setValue(this.cngfMode)
    }
    else
    {
      this.showCngfMode = 1
    }
  }

transactionChange(evt: any)
{

  this.displayCheckBoxValues =[];
  this.searchCheckBoxValues = [];

  this.usrSelectedDisplayFields= [];
  this.usrSelectedSearchFields=[];

  this.currentTransType = this.form.controls.dispTransType.value;

  if (this.currentTransType === "835" || this.currentTransType.indexOf("837") == 0 || this.currentTransType === "277CA")
  {
      this.modeString = "Batch";
      this.showMode = 0

      this.form.controls.dispMode.setValue(this.modeString)
  }
  else
  {
    this.showMode = 1
  }


  for (var col of this.allTransactionsFields)
    {
      // console.info("searchColumns push? = " + col.key + ", " + col.transactionCode);
      if ( (Number.parseInt(col.transactionCode) == 1 || col.transactionCode === this.form.controls.dispTransType.value)
          )

      {
          // this.searchColumns.push(col);
          this.displayCheckBoxValues.push({key: col.key, type:'', label:col.label, transactionCode:col.transactionCode,
            order:col.order,checked:'false'
          });
          this.searchCheckBoxValues.push({key: col.key, type:'', label:col.label, transactionCode:col.transactionCode,
           order:col.order,checked:'false'
          });
          // console.info("searchColumns pushed: " + col.key);
      }
    }

  if(this.usrDisplayColumns.length > 0)
  {
    console.info("Check usrDisplayColumns: " + this.usrDisplayColumns.length +', allDropdownList #: ' + this.displayCheckBoxValues.length);

    for (var disp of this.usrDisplayColumns)
    {
      // console.info(disp.TransactionCode + ", # " + this.transactionsSearchColumns.length +', allDropdownList #: ' + this.allDropdownList.length)
      for (var col of this.allTransactionsFields)
      {

        if ( disp.TransactionCode === this.form.controls.dispTransType.value
          && disp.key === col.key && disp.Mode === this.form.controls.dispMode.value)
        {
          var selInd = this.allDropdownListFindDisplay(col.label);
          if(selInd !== -1)
          {
            // console.info(disp.TransactionCode + " PUSH User selected column: " + disp.key + "===" + col.key +", selInd: " + selInd)
            this.usrSelectedDisplayFields.push({item_id:selInd, item_text:col.label, item_order:disp.Order});
            break;
          }
        }
      }
    }

  }

  for (var item of this.usrSelectedDisplayFields)
  {
    // console.info("selDropdownList key: " + item.item_id +", val: " +item.item_text )

      for (var srcCol of this.displayCheckBoxValues)
      {
        if (srcCol.label === item.item_text)
        {

          srcCol.checked = 'true';
          srcCol.order = item.item_order
          console.info(item.item_text + " - Display fld checked, order: " + srcCol.order);
          break;
        }

      }



  }
  for (var srcCol of this.displayCheckBoxValues)
    {
        if (srcCol.checked !== 'true')
        {
          srcCol.order = 99
        }
    }

  this.displayCheckBoxValues.sort((a,b) => a.order > b.order ? 1:-1)

  for (var srcCol of this.displayCheckBoxValues)
    {
        if (srcCol.checked !== 'true')
        {
          srcCol.order = 0

        }
    }

  if(this.usrSearchColumns.length > 0)
    {
      console.info("Check usrSearchColumns: " + this.usrSearchColumns.length +', allDropdownList #: ' + this.displayCheckBoxValues.length);

      for (var srch of this.usrSearchColumns)
      {
        for (var col of this.allTransactionsFields)
        {

          if ( srch.TransactionCode === this.form.controls.dispTransType.value
            && srch.key === col.key && srch.Mode === this.form.controls.dispMode.value)
          {
            var selInd = this.allDropdownListFindSearch(col.label);
            if(selInd !== -1)
            {
              // console.info(disp.TransactionCode + " PUSH User selected column: " + disp.key + "===" + col.key +", selInd: " + selInd)
              this.usrSelectedSearchFields.push({item_id:selInd, item_text:col.label});

              break;
            }
          }
        }
      }

    }

    for (var item of this.usrSelectedSearchFields)
    {
      // console.info("selDropdownList key: " + item.item_id +", val: " +item.item_text )

        for (var srcCol of this.searchCheckBoxValues)
        {
          if (srcCol.label === item.item_text)
          {
            console.info(item.item_text + " - Search fld checked")
            srcCol.checked = 'true';

          }
        }

    }

  console.info("DisplayFields #: " + this.displayCheckBoxValues.length);
  console.info("Usr DisplayFields #: " + this.usrSelectedDisplayFields.length);

  console.info("SearchColumns #: " + this.searchCheckBoxValues.length);
  console.info("Usr SearchFields #: " + this.usrSelectedSearchFields.length);

}



allDropdownListFindDisplay(label:string)
{
  for(var val of this.displayCheckBoxValues)
  {
    if(val.label === label)
    {
      // console.info("allDropdownListFind: " + val.item_id);
      return val.key
    }
  }
  return -1;
}

allDropdownListFindSearch(label:string)
{
  for(var val of this.searchCheckBoxValues)
  {
    if(val.label === label)
    {
      // console.info("allDropdownListFind: " + val.item_id);
      return val.key
    }
  }
  return -1;
}

ngAfterViewInit()
{
 console.info("ngAfterViewInit");


}

checkOrNotSearch(event: any)
{
  let val = (event.target as HTMLInputElement).value;
  console.info("checkOrNot Search: " + val)

  for (var srcCol of this.searchCheckBoxValues)
    {
      if (srcCol.label === val)
      {

        srcCol.checked = (srcCol.checked==='true')?'false':'true';
        console.info(val + " changed to: " + srcCol.checked )
        break;
      }
    }

}

checkOrNotDisplay(event: any)
{
  let val = (event.target as HTMLInputElement).value;
  console.info("checkOrNot Display: " + val)
  for (var index in this.displayCheckBoxValues)
    {
      var srcCol = this.displayCheckBoxValues[index]
      if (srcCol.label === val)
      {

        srcCol.checked = (srcCol.checked==='true')?'false':'true';
        srcCol.key
        console.info(val + " changed to: " + srcCol.checked  + 'OrdId' + index +': ' +  (<HTMLInputElement>document.getElementById('OrdId'+index)).value )
        break;
      }
    }
}

resetSettings()
{
  this.TransactionService.deleteDisplayColumns('Default',  this.form.controls.dispMode.value,  this.form.controls.dispTransType.value).subscribe((res: any) => {

    console.info("Delete Display: " + res);

  });
}

saveSettings(setting: string)
{


  var dispCol = <DisplayColumnsArray>{};
  dispCol.displayColumns = [];

  var srchCol = <SearchColumnsArray>{};
  srchCol.SearchColumns = [];

  var ind = 0;

  console.info('Save: ' + this.form.controls.dispTransType.value + ", Display #: " + this.displayCheckBoxValues.length);

  for (var item of this.displayCheckBoxValues)
  {
    if (item.checked === 'true')
    {
       var dispOrd = Number((<HTMLInputElement>document.getElementById('OrdId'+ind)).value)
       console.log('Save: ' + item.label +", order: " + dispOrd);
       dispCol.displayColumns.push({  id: '1',
        TransactionCode: this.form.controls.dispTransType.value,
        key:  item.key,
        Order: dispOrd,
        Setting: setting,
        DispType: 'Transactions',
        Mode:this.form.controls.dispMode.value});

    }
    ind++;
  }
  console.log('Save Display: ' + dispCol.displayColumns.length);

  for (var item of this.searchCheckBoxValues)
  {
    if (item.checked === 'true')
    {
       console.log('Save: ' + item.label);
       srchCol.SearchColumns.push({  id: '1',
        TransactionCode: this.form.controls.dispTransType.value,
        key:  item.key,
        Setting: setting,
        Mode:this.form.controls.dispMode.value});

    }
  }
  console.log('Save Search: ' + srchCol.SearchColumns.length);


      this.TransactionService.saveDisplayColumns(dispCol).subscribe((res: any) => {

          console.info("Display TransactionService: " + res);

        });
        this.TransactionService.saveSearchColumns(srchCol).subscribe((res: any) => {

          console.info("Search TransactionService: " + res);

        });



}

saveConfig()
{
  let paramsList=<ConfirationArray>{};


  paramsList.configColumns = [];

   paramsList.configColumns.push({key:'Page', value: this.form.controls.cngfPage.value });
   paramsList.configColumns.push({key:'TranType', value: this.form.controls.cngfTranType.value})
   paramsList.configColumns.push({key:'Mode', value: this.form.controls.cngfMode.value})
   paramsList.configColumns.push({key:'BthTime', value:this.form.controls.cngfBthTime.value})
   paramsList.configColumns.push({key:'TranTime', value:this.form.controls.cngfTranTime.value})
   paramsList.configColumns.push({key:'WfTime', value: this.form.controls.cngfWfTime.value})
   paramsList.configColumns.push({key:'Logoff', value: this.form.controls.cngfLogoff.value})
   paramsList.configColumns.push({key:'DispCnt', value: this.form.controls.cngfDispCnt.value})


   this.TransactionService.saveConfiguration(paramsList).subscribe((res: any) => {

    console.info("saved Configuration, navigate: " + this.form.controls.cngfPage.value);
    let ind = 0;
    for(; ind < tabLinks.length; ind++)
      {
        console.info( tabLinks[ind].name +" === " + this.form.controls.cngfPage.value)
        if(tabLinks[ind].name === this.form.controls.cngfPage.value)
        {
          console.log("Navigate to : " + tabLinks[ind].link);
          break;
        }

      }
      paramsList.configColumns.forEach(element => {
        sessionStorage.removeItem(element.key)
        sessionStorage.setItem(element.key, element.value);
      });

      sessionStorage.removeItem("currentTab");
      sessionStorage.setItem("currentTab", tabLinks[ind].name)


      if (ind >= tabLinks.length)
      {
        ind = 3
      }
      this.router.navigate([tabLinks[ind].link],
          {
          queryParams: { transaction: this.currentTransType,
          'additionalSearch': this.additionalSearchStr,
          'searchTypeString': this.searchTypeString }
          }
        );




  });


}

toTransactions()
  {

      console.log('To Transactions: ' + this.currentTransType + "= " + this.searchTypeString + "/" + this.additionalSearchStr);
      this.router.navigate(["/transaction/"],
      {
        queryParams: { transaction: this.currentTransType,
          'additionalSearch': this.additionalSearchStr,
          'searchTypeString': this.searchTypeString }
    }

       );
  }

}



