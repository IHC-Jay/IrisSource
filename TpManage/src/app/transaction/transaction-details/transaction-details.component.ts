import { Component, OnInit,Input } from '@angular/core';
import { CommonModule } from "@angular/common";
import { CommonColumns, CommonColumnsDisplayColumns} from '../CommonColumns';
import { EligibilityRequest } from '../EligibilityRequest';
import { transition } from '@angular/animations';
import { Router, ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { RestServiceComponent } from '../../services/rest-service.component';
import { MatTableDataSource } from '@angular/material/table';
import { MatDialog } from '@angular/material/dialog';
import { Modalx12Component } from './modal/modal-x12.component';
import { DialogRef } from '@angular/cdk/dialog';

@Component({
  selector: 'app-transaction-details',
  templateUrl: './transaction-details.component.html',
  styleUrls: ['./transaction-details.component.css']
})
export class TransactionDetailComponent {

  canRenderDetails: boolean = false;
  displayedColumns = [];

  dataSource = new MatTableDataSource<EligibilityRequest>();

  sub:any;
  id:string;
  X12DataParentId:string;
  searchStr:string;
  transaction:string;
  x12Data:string;
  fileName = "TEST";

  constructor(
    private TransactionService: RestServiceComponent,
    private formBuilder: FormBuilder,
    private route: ActivatedRoute,
    private router: Router,
    public dialog: MatDialog
  )
  {

    this.displayedColumns.push(...CommonColumnsDisplayColumns);

  }

  ngOnInit() {

    this.sub = this.route
    .queryParams
    .subscribe(params => {
      // Defaults to 0 if no query param provided.
      this.id = ''+params['id'] || '0';
      this.transaction = ''+params['transaction'] || '0';
      this.searchStr = params['search'];
      console.log('Query params id: ', this.id + ', trans: ' + this.transaction +", search: " + this.searchStr);
    });

    this.TransactionService.fetchTransactionFields().subscribe((res: any) => {

      this.displayedColumns = [];

        for (var item of res)
        {
          if(item.TransactionCode === ''+ this.transaction || item.TransactionCode == '1')
          {
            this.displayedColumns.push({key: item.Key, type: item.Type, label: item.Label, transactionCode: item.TransactionCode});
          }

        }
        console.log(this.transaction + '- Display columns: ' + this.displayedColumns.length);
        if(this.transaction === '270')
        {

          this.TransactionService.fetchEligibilityRequests("id='" + this.id +"'").subscribe((res: any) => {

            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');

            console.log("# of records: " + res.length)
          });
        }
        if(this.transaction === '271')
        {

          this.TransactionService.fetchEligibilityBenefitResponses("id='" + this.id +"'").subscribe((res: any) => {

            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
            console.log("# of records: " + res.length + ", parent Id:" + this.dataSource.data[0].X12DataParentId)
          });
        }
        else if(this.transaction.startsWith('837')){

          this.TransactionService.fetchClaims("id='" + this.id+"'").subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
          });

        }
        else if(this.transaction === '835'){

          this.TransactionService.fetchClaimPayment("id='" + this.id+"'").subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
          });

        }
        else if(this.transaction === '276'){

          this.TransactionService.fetchClaimStatusReq("id='" + this.id +"'").subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
          });

        }
        else if(this.transaction === '277'){

          this.TransactionService.fetchClaimStatusResp("id='" + this.id +"'").subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
          });

        }
        else if(this.transaction.toString() === '277CA'){

          this.TransactionService.fetchClaimAcknowledgment("id='" + this.id+"'").subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
          });

        }
        else if(this.transaction === '999'){

          this.TransactionService.fetchImplementationAcknowledgment("id='" + this.id+"'").subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
          });

        }

  });

  }

  getSelectedValue(question:string)
  {

    if (this.dataSource.data[0] !== undefined )
    {
      let jsonStr = JSON.stringify(this.dataSource.data[0]);

            const jsonData = JSON.parse(jsonStr)

            for(var i in jsonData)
            {
              if(i === question)
              {
                var val = jsonData[i];
                console.info("getSelectedValue: " + question +'= ' + val);
                if(question === "x12Data" )
                {
                  if (val.startsWith("ISA"))
                  {
                  let letter = val.charAt(105);
                  val = val.replaceAll(letter, letter + "\n")
                  console.info("Split X12 with: " + letter);
                  }
                  else{
                    val = val.replaceAll("~", "~\n")
                  }
                  this.x12Data = val;
                }
                else if(question === "loopCHLHierarchicalChildCode")
                {
                  // console.info(question + ": " + val)
                  if(val === 1)
                  {
                  val ="Dependent"
                  }
                  else
                  {
                  val = "Subscriber"
                  }
                }
                else if( question.indexOf("DMGDateTimePeriod") > 0 || question.indexOf("DateTimePeriod") > 0)
                {
                  val = val.substring(0,4) + "-" + val.substring(4,6) + "-" + val.substring(6,8)
                }

                // console.info("getSelectedValue: " + question +"= " + val);
                return val;
            }
          }
        }
  }
  toTransactions()
  {

      console.log('To Transactions: ' + this.transaction + "/" + this.searchStr);
      this.router.navigate(["/transaction/"],
      {queryParams: { trans: this.transaction, 'search':  this.searchStr } }
       );
  }

  openX12Modal(): void {

    this.TransactionService.fetchParentRecord(this.X12DataParentId, this.transaction).subscribe((res: any) => {
      this.canRenderDetails = true;
      let val = ""


      if (res.x12Data.length > 0 )
      {
        let letter = res.x12Data.charAt(105);
        val = res.x12Data.replaceAll(letter, letter + "\n" )
        console.info("Split X12 with: " + letter);
        }
        else{
          val = res.x12Data.replaceAll("~", "~\n")
        }

        let param: string[] = [ val, this.fileName];
    const dialogRef = this.dialog.open(Modalx12Component, {
      width: '1700px',
      data: param
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog closed');
    });


  });

  }

}
