import { Component, OnInit,Input } from '@angular/core';
import { CommonModule } from "@angular/common";
import { CommonColumns, CommonColumnsDisplayColumns} from '../CommonColumns';
import { EligibilityRequest } from '../EligibilityRequest';
import { transition } from '@angular/animations';
import { Router, ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { TransRestServiceComponent } from '../../services/transrest-service.component';
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

  dataSource = new MatTableDataSource<any>();

  sub:any;
  id:string;
  X12DataParentId:string;
  ak1CtrlNum:string;
  ak1ver:string;
  searchStr:string;
  searchTypeString:string;
  transaction:string;
  x12Data:string;
  fileName = "TEST";

  constructor(
    private TransactionService: TransRestServiceComponent,
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
      this.searchTypeString = params['searchTypeString'];
      console.log('Query params id: ', this.id + ', trans: ' + this.transaction +", search: " + this.searchStr +", searchTypeString: " + this.searchTypeString);
    });

    this.TransactionService.fetchTransactionFields().subscribe((res: any) => {

      this.displayedColumns = [];

        for (var item of res)
        {

          if( ((Number.isNaN(item.TransactionCode) === false) && (item.TransactionCode ===  this.transaction) ) ||
          ( (Number.isNaN(item.TransactionCode) === true) && Number.parseInt(item.TransactionCode) ===  Number.parseInt(this.transaction) )
          || Number.parseInt(item.TransactionCode) == 1)
          {
            this.displayedColumns.push({key: item.Key, type: item.Type, label: item.Label, transactionCode: item.TransactionCode});
            console.log(Number.isNaN(item.TransactionCode) + ", Display: " + item.TransactionCode +" ===  " + this.transaction +" || " + item.TransactionCode +": " + item.Key)
          }

        }
        console.log(this.transaction + '- Display columns: ' + this.displayedColumns.length);
        if(this.transaction === '270')
        {

          this.TransactionService.fetchEligibilityRequests("id='" + this.id +"'", this.searchTypeString, 1).subscribe((res: any) => {

            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');

            console.log("# of records: " + res.length)
          });
        }
        if(this.transaction === '271')
        {

          this.TransactionService.fetchEligibilityBenefitResponses("id='" + this.id +"'", this.searchTypeString, 1).subscribe((res: any) => {

            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
            console.log("# of records: " + res.length + ", parent Id:" + this.dataSource.data[0].X12DataParentId)
          });
        }
        else if(this.transaction.startsWith('837')){

          this.TransactionService.fetchClaims("id='" + this.id+"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }
        else if(this.transaction === '835'){
          this.TransactionService.fetchClaimPayment("id='" + this.id+"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }
        else if(this.transaction === '276'){

          this.TransactionService.fetchClaimStatusReq("id='" + this.id +"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }
        else if(this.transaction === '277'){

          this.TransactionService.fetchClaimStatusResp("id='" + this.id +"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }
        else if(this.transaction.toString() === '277CA'){

          this.TransactionService.fetchClaimAcknowledgment("id='" + this.id+"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }
        else if(this.transaction === '999'){

          this.TransactionService.fetchImplementationAcknowledgment("id='" + this.id+"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
            this.ak1CtrlNum = this.dataSource.data[0].AK1GroupControlNumber	;
            this.ak1ver= this.dataSource.data[0].AK1VersionReleaseIndustryIdenti;
            this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }
        else if(this.transaction === 'TA1'){

          this.TransactionService.fetchInterchangeAcknowledgment("id='" + this.id+"'", this.searchTypeString, 1).subscribe((res: any) => {
            this.canRenderDetails = true;
            this.dataSource.data = res;
            this.X12DataParentId = this.dataSource.data[0].X12DataParentId;
             this.fileName = this.dataSource.data[0].FileName.replace(/^.*[\\\/]/, '');
          });

        }


  });

  }

  getSelectedValue(loopnum: number, question:string)
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
                // console.info(loopnum + ". getSelectedValue: " + question +'= ' + val);
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
                else if( question.indexOf("Date") > 0  && val.length ==8)
                {
                  val = val.substring(4,6)  + "/" +  val.substring(6,8) + "/" +val.substring(0,4)
                }
                else if (val === '')
                {
                  val = '-';
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
      // {queryParams: { trans: this.transaction, 'search':  this.searchStr } }
      {
        queryParams: { transaction: this.transaction,
          'search': this.searchStr,
          'searchTypeString': this.searchTypeString }
    }

       );
  }

  openX12Modal(): void {
    console.info("openX12Modal: " + this.X12DataParentId + ", " + this.transaction);

    this.TransactionService.fetchParentRecord(this.X12DataParentId, this.transaction, this.searchTypeString).subscribe((res: any) => {
      this.canRenderDetails = true;
      let val = ""

      if(res === "No data")
      {
        let param: string[] = [ "Not found", ""];
        const dialogRef = this.dialog.open(Modalx12Component, {
          width: '1700px',
          data: param
        });
      }


      else if (res.x12Data !== undefined && res.x12Data.length > 0 )
      {
        if (res.x12Data.length > 105)
        {
           let letter = res.x12Data.charAt(105);

           val = res.x12Data.replaceAll(letter, letter + "\n" )
            console.info("Split X12 with: " + letter);
         }
         else
         {
           val = res.x12Data
         }
      }
      else{
          val = res.x12Data.replaceAll("~", "~\n")
        }
      if(val !== "")
      {
        let param: string[] = [ val, this.fileName];
        const dialogRef = this.dialog.open(Modalx12Component, {
          width: '1700px',
          data: param
        });

        dialogRef.afterClosed().subscribe(result => {
          console.log('The dialog closed');
        });

      }
    });

  }

  openRelatedTransactionModel(): void {

    console.log(" fetchGetRelatedTransaction: " + this.transaction +", " + this.dataSource.data[0].GroupControlNumber)

    let tranType = this.transaction;
    let grpNum = this.dataSource.data[0].GroupControlNumber;
    if(this.transaction === '999')
    {
      console.log(" fetchGetRelatedTransaction: " + this.ak1CtrlNum +", " +  this.ak1ver);
      tranType = this.ak1ver;
      grpNum =  this.ak1CtrlNum ;
    }
    console.log(" fetchGetRelatedTransaction: " + this.dataSource.data[0].InterchangeControlNumber +"," +
    this.dataSource.data[0].InterchangeReceiverID + "," +
    this.dataSource.data[0].InterchangeSenderID)

    this.TransactionService.fetchGetRelatedTransaction(tranType, grpNum,
      this.dataSource.data[0].InterchangeSenderID,
      this.dataSource.data[0].InterchangeReceiverID,
      this.dataSource.data[0].InterchangeControlNumber, this.searchTypeString

      ).subscribe((res: any) => {
      this.canRenderDetails = true;
      let val = ""
      let fileName = "NA"
      if(this.transaction === '999')
      {
        if (res !== undefined && res && res.tranX12 !== undefined && res.tranX12.length > 0 )
        {
          let letter = res.tranX12.charAt(105);
          val = res.tranX12.replaceAll(letter, letter + "\n" )
          console.info("Split tranX12 with: " + letter);
          fileName =  res.FileName.replace(/^.*[\\\/]/, '')
          }
          else{
            val = 'Related item not found';
          }
      }
      else
      {
          if (res !== undefined && res && res.x12Data !== undefined && res.x12Data.length > 0 )
          {
            let letter = res.x12Data.charAt(105);
            val = res.x12Data.replaceAll(letter, letter + "\n" )
            console.info("Split X12 with: " + letter);
            fileName =  res.FileName.replace(/^.*[\\\/]/, '')
            }
            else{
              val = 'Related item not found';
            }
      }

        let param: string[] = [ val,  fileName];
    const dialogRef = this.dialog.open(Modalx12Component, {
      width: '1700px',
      data: param
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog closed');
    });


  });

  }

  openRelated27xModel(): void {

    console.log(" openRelated27xModel: " + this.transaction +", " + this.dataSource.data[0].GroupControlNumber)

    let tranType = this.transaction;
    let grpNum = this.dataSource.data[0].GroupControlNumber;

    console.log(" openRelated27xModel: " + this.dataSource.data[0].InterchangeControlNumber +"," +
    this.dataSource.data[0].InterchangeReceiverID + "," +
    this.dataSource.data[0].InterchangeSenderID);
    if (tranType == '270' || tranType == '271')
    {
        this.TransactionService.openRelated2701Model(this.transaction,
          this.dataSource.data[0].loop2000C1TRN1RefId, this.dataSource.data[0].loop2000D1TRN1RefId,
          this.dataSource.data[0].InterchangeSenderID,
          this.dataSource.data[0].InterchangeReceiverID,
          this.dataSource.data[0].InterchangeControlNumber, this.searchTypeString

          ).subscribe((res: any) => {
          this.canRenderDetails = true;
          let val = ""
          let fileName = "NA"
          if(this.transaction === '271' )
          {
            if (res !== undefined && res && res.ReqX12 !== undefined && res.ReqX12.length > 0 )
            {
              let letter = "~";
              fileName = res.ReqFileName.replace(/^.*[\\\/]/, '')
              val = res.ReqX12.replaceAll(letter, letter + "\n" )
              console.info("Split ReqX12 with: " + letter);

              }
              else{
                val = 'Related 270 not found';
              }
          }
          else
          {
              if (res !== undefined && res && res.ResX12 !== undefined && res.ResX12.length > 0 )
              {
                let letter = "~";
                fileName = res.ResFileName.replace(/^.*[\\\/]/, '')
                val = res.ResX12.replaceAll(letter, letter + "\n" )
                console.info("Split X12 with: " + letter);

                }
                else{
                  val = 'Related 271 not found';
                }
          }

            let param: string[] = [ val, fileName];
        const dialogRef = this.dialog.open(Modalx12Component, {
          width: '1700px',
          data: param
        });

        dialogRef.afterClosed().subscribe(result => {
          console.log('The dialog closed');
        });


      });
    }
    else
    {
      this.TransactionService.openRelated2767Model(this.transaction, this.dataSource.data[0].loop2200D1TRNRefId,
        this.dataSource.data[0].loop2200E1TRNRefId,
        this.dataSource.data[0].InterchangeSenderID,
        this.dataSource.data[0].InterchangeReceiverID,
        this.dataSource.data[0].InterchangeControlNumber, this.searchTypeString
        ).subscribe((res: any) => {
        this.canRenderDetails = true;
        let val = ""
        let fileName = ""
        if(this.transaction === '277')
        {
          if (res !== undefined && res && res.ReqX12 !== undefined && res.ReqX12.length > 0 )
          {
            let letter = "~";
            val = res.ReqX12.replaceAll(letter, letter + "\n" )
            fileName = res.ReqFileName.replace(/^.*[\\\/]/, '')
            console.info(res.ReqFileName + ", Split ReqX12 with: " + letter);

            }
            else{
              val = 'Related 276 not found';
            }
        }
        else
        {
            if (res !== undefined && res && res.ResX12 !== undefined && res.ResX12.length > 0 )
            {
              let letter = "~";
              fileName = res.ResFileName.replace(/^.*[\\\/]/, '')
              val = res.ResX12.replaceAll(letter, letter + "\n" )
              console.info(res.ResFileName + ", Split X12 with: " + letter);

              }
              else{
                val = 'Related 277 not found';

              }
        }

        let param: string[] = [ val,  fileName];
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
  openRelated83xModel()
  {
    console.log('openRelated83xModel');
    var amt = ""
    var clmId = ""
    if(this.transaction === '835' )
    {
      clmId = this.dataSource.data[0].loop21001CLPClaimSubmittersIdentifier
     amt = this.dataSource.data[0].loop21001CLPMonetaryAmount
    }
    else{

      clmId = this.dataSource.data[0].loop23001CLMClaimSubmittersIdentifier
      amt = this.dataSource.data[0].loop23001CLMMonetaryAmount
    }


    this.TransactionService.openRelated83xModel(this.transaction, clmId, amt).subscribe((res: any) => {
      this.canRenderDetails = true;
      let val = ""
      let fileName = "NA"
      if(this.transaction === '835' )
      {
        if (res !== undefined && res && res.ClmX12 !== undefined && res.ClmX12.length > 0 )
        {
          let letter = "~";
          fileName = res.ClmFileName.replace(/^.*[\\\/]/, '')
          val = res.ClmX12.replaceAll(letter, letter + "\n" )
          console.info("Split X12 with: " + letter);

          }
          else{
            val = 'Related 835 not found';
          }
      }
      else
      {
        if (res !== undefined && res && res.ClmRemX12 !== undefined && res.ClmRemX12.length > 0 )
        {
          let letter = "~";
          fileName = res.ClmRemFileName.replace(/^.*[\\\/]/, '')
          val = res.ClmRemX12.replaceAll(letter, letter + "\n" )
          console.info("Split ClmRemX12 with: " + letter);

          }
          else{
            val = 'Related 837 not found';
          }


      }

        let param: string[] = [ val, fileName];
    const dialogRef = this.dialog.open(Modalx12Component, {
      width: '1700px',
      data: param
    });

    dialogRef.afterClosed().subscribe(result => {
      console.log('The dialog closed');
    });


  });

  }
  openRelated277CAModel()
  {
    console.log('openRelated83xModel');

    var clmId = ""
    if(this.transaction === '277CA' )
    {
      clmId = this.dataSource.data[0].loop2200D1TRNRefId

    }
    else{

      clmId = this.dataSource.data[0].loop23001CLMClaimSubmittersIdentifier

    }


    this.TransactionService.openRelatedClaimAckModel(this.transaction, clmId).subscribe((res: any) => {
      this.canRenderDetails = true;
      let val = ""
      let fileName = "NA"
      if(this.transaction === '277CA' )
      {
        if (res !== undefined && res && res.ClmX12 !== undefined && res.ClmX12.length > 0 )
        {
          let letter = "~";
          fileName = res.ClmFileName.replace(/^.*[\\\/]/, '')
          val = res.ClmX12.replaceAll(letter, letter + "\n" )
          console.info("Split ClmX12 with: " + letter);

          }
          else{
            val = 'Related 837 not found';
          }
      }
      else
      {
        if (res !== undefined && res && res.AckX12 !== undefined && res.AckX12.length > 0 )
        {
          let letter = "~";
          fileName = res.AckFileName.replace(/^.*[\\\/]/, '')
          val = res.AckX12.replaceAll(letter, letter + "\n" )
          console.info("Split X12 with: " + letter);

          }
          else{
            val = 'Related 277CA not found';
          }
      }

        let param: string[] = [ val, fileName];
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
