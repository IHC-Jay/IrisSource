import { Component,   ViewChildren,  ElementRef,  ChangeDetectorRef,  QueryList, OnInit } from '@angular/core';
import { Router, ActivatedRoute, RouteConfigLoadEnd } from '@angular/router';
import { AbstractControlOptions, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { first } from 'rxjs/operators';
import { FormsModule, ReactiveFormsModule, FormGroupDirective } from '@angular/forms';
import { RestServiceComponent } from '../../../services/rest-service.component';
import { EventListenerFocusTrapInertStrategy } from '@angular/cdk/a11y';
import { tpLinks } from './tp-links';

export class TransTypes
{
  NAME:string;
  TransactionSetId:string;
  VERSION: string;
  Direction: string;
}

@Component(
  {  selector: 'add-edit',
     templateUrl: './add-edit.component.html',
     styleUrls: ['./add-edit.component.css'],
})


export class AddEditComponent implements OnInit {
    form!: FormGroup;
    id!: string;
    parentTpId!: string;
    sendertpIdHelp: string;
    receivertpIdHelp: string;
    isAddMode!: boolean;
    loading = false;
    batchMode: boolean = true;
    showTpIds: boolean = false;
    submitted = false;
    sendingTpIds = [];
    ackTypes:string[] = ["Always","Never","Negative"];
    modeTypes:string[] = ["Batch","RT"];
    routingTypes:string[] =["UHIN Batch","R1 Batch","UMR Batch","Loopback Batch"];
    receivingTpIds = [];
    ownerTpIds = [];
    canRender = false;

    trn: tpLinks;

    transactionTypes: TransTypes[];


    @ViewChildren("input") inputs: QueryList<ElementRef>;

    constructor(
        private formBuilder: FormBuilder,
        private route: ActivatedRoute,
        private router: Router,
        private tpService: RestServiceComponent,
        private cdRef: ChangeDetectorRef
    ) {

     }

     public initializeData()
{
  console.info("1. fetchTpIds");
  this.tpService.fetchOwnerTpIds().subscribe((res: any) => {

    res.forEach((entry) => {

     this.ownerTpIds.push(entry.TPID);

    });


  console.info("2. fetchTransactionTypes");
  this.tpService.fetchTransactionTypes().subscribe((res: any) => {

    this.transactionTypes = res;
    this.canRender = true;
  } );
 });
}

    async ngOnInit() {
      console.info("AddEditComponent ngOnInit");


      let arr =  this.route.snapshot.paramMap.keys

        this.parentTpId = this.route.snapshot.params['tpId'];
        this.id = this.route.snapshot.params['tpLink'];
        this.isAddMode = !this.id;
        console.info('Get TP for id: ' + this.id +", parent: " + this.parentTpId);
        if( this.isAddMode)
        {
          this.parentTpId = this.route.snapshot.params['tp'];
          console.info("Get parent: " + this.parentTpId);
        }
        this.form = this.formBuilder.group({
          ParentTpId: [''],
          Link: ['', Validators.required],
          TransType: ['', Validators.required],
          TransactionSetId: [''],
          Mode: ['', Validators.required],
          Ack: ['', Validators.required],
          FilePath: [''],
          FtpServer: [''],
          GsReceiverId: ['', Validators.required],
          GsSenderId: ['', Validators.required],
          IsaSenderId: ['', Validators.required],
          IsaReceiverId: ['', Validators.required],
          Routing: ['', Validators.required],
          SNIP: ['', Validators.required],
          Separators   : ['|*^:', Validators.maxLength(4)],
      });
      this.initializeData();


      let myPromise = () => new Promise((resolve, reject) => {
        setTimeout(function(){
          resolve('Count')
        }, 1000)
      })

      for (let index = 0; index < 5; index++) {
        let count = await myPromise()
        console.log('waiting for service: ' +`${count}: ${index}`);
        if(this.canRender)
          break;
      }

      let ttype ='' ;

      if (!this.isAddMode) {
        this.tpService.fetchTpLink(this.id)
            .pipe(first())
            .subscribe(x => {
              this.form.patchValue(x);

              for (let key in x) {

                if(key === 'TransType')
                {
                  ttype =x[key].toString();
                  console.info('patchValue 1: ' + key + ' :: ' + ttype );
                  this.form.controls.TransType.setValue(ttype);
                  this.setTransactionSetId();

                  break;
                }
                }
             }
            );

        this.form.controls.ParentTpId.setValue(this.parentTpId);

      }


    }

    ngAfterViewInit()
    {
      console.info('nfAfter: ' + this.form.controls['Link'].value)
    }

    // convenience getter for easy access to form fields
    get f() { return this.form.controls; }

    onCancel()
    {
      console.info('On Cancel, got back to: ' + this.parentTpId);
      for (let el in this.form.controls) {
        if (this.form.controls[el].value) {
          console.log(el +': ' + this.form.controls[el].value)
        }
      }
      this.router.navigate(["/TradingPartners/tpIds/tp-links/" + this.parentTpId ]);
    }

    onSubmit() {

        this.submitted = true;

        for (let el in this.form.controls) {
          if (this.form.controls[el].errors) {
            console.log(el +" - not initialized")
          }
     }

        // stop here if form is invalid
        if (this.form.invalid) {
          console.info('Invalid: ' + this.form.invalid);
            return;
        }

        this.loading = true;

        this.createUpdateTpLink(this.isAddMode);

    }
    setRtBatch()
    {
      console.info('setRtBatch: ' + this.form.controls['Mode'].value);
      if(this.form.controls['Mode'].value === 'RT')
      {
          this.batchMode = false;
          this.ackTypes = ["Never","Negative"];
          this.form.controls.Routing.setValue('RT');
      }
      else {
        this.batchMode = true;
        this.ackTypes = ["Always","Never","Negative"];
        this.form.controls.Routing.setValue(this.routingTypes[0]);
      }
      this.form.controls.Ack.setValue(this.ackTypes[0]);
    }

    setTransactionSetId()
    {

      console.info('setTransactionSetId: ' + this.form.controls['TransType'].value + ', ' + this.transactionTypes.length);
      var ttVal = this.form.controls['TransType'].value
       var result = this.transactionTypes.findIndex(item => item.NAME === ttVal);
       console.info(ttVal + '- result: ' + result);
      this.form.controls['TransactionSetId'].setValue(this.transactionTypes[result].Direction + ': '+ this.transactionTypes[result].TransactionSetId +' / ' +  this.transactionTypes[result].VERSION );
      console.info('TransType : ' +this.form.controls['TransactionSetId'].value);
      this.form.controls.Mode.setValue(this.modeTypes[0]);
      this.setRtBatch();
      if( this.transactionTypes[result].Direction === 'Inbound')
      {
        this.sendertpIdHelp = 'Parent TPId';
        this.receivertpIdHelp = 'TPIds for owner';
        this.sendingTpIds =[];
        this.receivingTpIds=[];
        this.sendingTpIds[0] = this.parentTpId ;
        this.receivingTpIds = this.ownerTpIds;
        this.form.controls.GsReceiverId.setValue(this.receivingTpIds[0]);
        this.form.controls.IsaReceiverId.setValue(this.receivingTpIds[0]);
        this.form.controls.GsSenderId.setValue(this.sendingTpIds[0]);
        this.form.controls.IsaSenderId.setValue(this.sendingTpIds[0]);
      }
      else {
        this.sendertpIdHelp = 'TPIds for owner';
        this.receivertpIdHelp = 'Parent TPId';
        this.receivingTpIds =[];
        this.sendingTpIds = [];
        this.receivingTpIds[0] = this.parentTpId ;
        this.sendingTpIds = this.ownerTpIds;
        this.form.controls.GsReceiverId.setValue(this.receivingTpIds[0]);
        this.form.controls.IsaReceiverId.setValue(this.receivingTpIds[0]);
        this.form.controls.GsSenderId.setValue(this.sendingTpIds[0]);
        this.form.controls.IsaSenderId.setValue(this.sendingTpIds[0]);
      }
      this.showTpIds = true;
    }

    private createUpdateTpLink(addFlg: boolean) {
      console.info('Create TPLink for name: ' + this.form.value);
      this.tpService.addUpdateTpLink(this.form.value, addFlg)
          .pipe(first())
          .subscribe((res) => {
            let retStr:String;
            if (res.errormessage !== undefined) {
             console.info('createUpdateTpLink error: ' + res.errormessage);
             retStr = res.errormessage;
            }
            else if( res.Status !== undefined) {
              console.info('createUpdateTpLink status: ' + res.Status);
              if(res.Status ='OK')
              {
                 this.router.navigate(["/TradingPartners/tpIds/tp-links/" + this.parentTpId ]);
              }
              retStr = res.Status;
            }
            else{
              console.info('createUpdateTpLink else: ' + res.Error);
              retStr = res.Error;
            }
            if(retStr !== 'OK')
            {
              alert(retStr);
            }
              //
          })
          .add(() => this.loading = false);

    }


}
