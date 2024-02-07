import { Component,   ViewChildren,  ElementRef,  ChangeDetectorRef,  QueryList, OnInit } from '@angular/core';
import { Router, ActivatedRoute, RouteConfigLoadEnd } from '@angular/router';
import { AbstractControlOptions, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { first } from 'rxjs/operators';
import { FormsModule, ReactiveFormsModule, FormGroupDirective } from '@angular/forms';
import { TpRestServiceComponent } from '../../../services/tprest-service.component';
import { EventListenerFocusTrapInertStrategy } from '@angular/cdk/a11y';
import { tpLinks } from './tp-links';
import { CreateNoteComponent } from './create-note/create-note.component';
import { SingleNoteComponent } from './single-note/single-note.component';

export class TransTypes
{
  NAME:string;
  TransactionSetId:string;
  VERSION: string;
}

export class KVP {
  id: number;
  Key: string;
  Value: string;

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
    transaction835:boolean = false;

    sendingTpIds = [];
    ackTypes:string[] = ["Error","Always","Never"];
    direcTypes:string[] =["In", "Out"];
    modeTypes:string[] = ["Batch","RT"];
    routingTypes:string[];

    receivingTpIds = [];
    ownerTpIds = [];
    canRender = false;
    transaction: string;
    sub:any;
    customProp: KVP[] = [];

    trn: tpLinks;

    transactionTypes: TransTypes[];


    @ViewChildren("input") inputs: QueryList<ElementRef>;

    constructor(
        private formBuilder: FormBuilder,
        private route: ActivatedRoute,
        private router: Router,
        private tpService: TpRestServiceComponent,
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

        // From Workflow
        this.sub = this.route.queryParams
        .subscribe(params => {

          this.transaction = ''+params['transaction']
        });


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
          Direction: ['', Validators.required],
          ISAAck: ['', Validators.required],
          GSAck: ['', Validators.required],
          STAck: ['', Validators.required],
          GsReceiverId: ['', Validators.required],
          GsSenderId: ['', Validators.required],
          IsaSenderId: ['', Validators.required],
          IsaReceiverId: ['', Validators.required],
          Routing: ['', Validators.required],
          SNIP: ['', Validators.required],
          Separators   : ['|*^:', Validators.maxLength(4)],
          UniqueId: [''],
          MergeFlg: [''],
          customProp: [''],
          Active: ['']
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

                  this.form.controls.TransType.setValue(ttype);
                  this.setTransactionSetId();

                }
                if(key === 'Mode')
                {
                  this.form.controls['Mode'].setValue(x[key].toString());
                }
                else if(key === 'ISAAck')
                {
                  this.form.controls['ISAAck'].setValue(x[key].toString());
                }
                else if(key === 'GSAck')
                {
                  this.form.controls['GSAck'].setValue(x[key].toString());
                }
                else if(key === 'STAck')
                {
                  this.form.controls['STAck'].setValue(x[key].toString());
                }
                else if(key === 'Routing')
                {
                  this.form.controls['Routing'].setValue(x[key].toString());
                }
                else if(key === 'Direction')
                {
                  this.form.controls['Direction'].setValue(x[key].toString());
                }
                else if(key === 'Separators')
                {
                  this.form.controls['Separators'].setValue(x[key].toString());
                }
                else if(key === 'SNIP')
                {
                  this.form.controls['SNIP'].setValue(x[key].toString());
                }
                else if(key === 'TransType')
                {
                  this.form.controls['TransType'].setValue(x[key].toString());
                }
                else if(key === 'GsReceiverId')
                {
                this.form.controls.GsReceiverId.setValue(x[key].toString());
                }
                else if(key === 'IsaReceiverId')
                {
                  console.log("IsaReceiverId.setValue " + x[key].toString());
                    this.form.controls.IsaReceiverId.setValue(x[key].toString());
                }
                else if(key === 'GsSenderId')
                {
                 this.form.controls.GsSenderId.setValue(x[key].toString());
                }
                else if(key === 'IsaSenderId')
                {
                  console.log("IsaSenderId.setValue " + x[key].toString());
                  this.form.controls.IsaSenderId.setValue(x[key].toString());
                }

                else if(key === 'customProp')
                {

                  for(var index in x[key])
                  {
                      console.log(index +". " + x[key][index].Key + "> " + x[key][index].Value);

                      let cs = new KVP();
                      cs.id =  Number(index);
                      cs.Key = x[key][index].Key;
                      cs.Value = x[key][index].Value;

                      if(cs.Key === 'BatchingMode835')
                      {
                        if(cs.Value === 'Batched')
                        {
                          this.form.controls.MergeFlg.setValue(true);
                        }
                        else {
                          this.form.controls.MergeFlg.setValue(false);
                        }
                      }
                      else
                      {

                        this.customProp.push(cs)
                      }
                  }

                }
                else{
                  console.log(key +"-- Not mapped")
                }
              }
             }
            );

        this.form.controls.ParentTpId.setValue(this.parentTpId);

      }
      else{
        if(this.transaction !== undefined)
        {

          // Search
          console.info('setTransactionSetId search: ' + this.transaction + ', ' + this.transactionTypes.length);

          var result = this.transactionTypes.findIndex(item => (item.TransactionSetId + '(' +	item.VERSION +')') === this.transaction);
          console.info(this.transaction + '- result: ' + result +"=>" + this.transactionTypes[result].NAME);
          if( result > 0 )
          {
            this.form.controls.TransType.setValue(this.transactionTypes[result].NAME);
            console.log("Set transaction type: " + this.transactionTypes[result].NAME +' , input: ' + this.transaction)

            this.setTransactionSetId();
          }
        }
      }


    }
/*
    ngAfterViewInit()
    {
      console.info('nfAfter: ' + this.form.controls['Link'].value)
    }
*/
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
          this.ackTypes = ["Error","Never"];
          this.form.controls.Routing.setValue('RT');
          this.routingTypes = ["UhinRT","IntermountainHealthcare", "BitBucket"];
          this.form.controls.Routing.setValue(this.routingTypes[0]);
      }
      else {
        this.batchMode = true;
        this.ackTypes = ["Error","Always","Never"];
        this.routingTypes = ["UhinBatch","StLukesBatch","UMRBatch","IntermountainHealthcare", "BitBucket"];
        this.form.controls.Routing.setValue(this.routingTypes[0]);
      }
      if(this.isAddMode)
      {
        this.form.controls.ISAAck.setValue(this.ackTypes[0]);
        this.form.controls.GSAck.setValue(this.ackTypes[0]);
        this.form.controls.STAck.setValue(this.ackTypes[0]);
        this.form.controls.SNIP.setValue('1')
        // this.form.controls.Direction.setValue(this.direcTypes[0]);
      }
    }

    setTransactionSetId()
    {


      var ttVal = this.form.controls['TransType'].value
      console.info('setTransactionSetId search: ' + ttVal + ', ' + this.transactionTypes.length);
       var result = this.transactionTypes.findIndex(item => item.NAME === ttVal);
       console.info(ttVal + '- result: ' + result);
      this.form.controls['TransactionSetId'].setValue(this.transactionTypes[result].TransactionSetId +' / ' +  this.transactionTypes[result].VERSION );
      console.info('TransType : ' +this.form.controls['TransactionSetId'].value);

      if(this.transactionTypes[result].TransactionSetId === '271' ||
      this.transactionTypes[result].TransactionSetId === '277' ||
      this.transactionTypes[result].TransactionSetId === '835'
      )
      {
        this.form.controls.Direction.setValue(this.direcTypes[1]);
      }
      else
      {
        this.form.controls.Direction.setValue(this.direcTypes[0]);
      }

      if( this.transactionTypes[result].TransactionSetId.startsWith('27'))
      {
        this.modeTypes = ["Batch","RT"];
      }
      else
      {
        this.modeTypes = ["Batch"];
      }

      this.form.controls.Mode.setValue(this.modeTypes[0]);
      this.setRtBatch();

      if( this.form.controls['Direction'].value === 'In')
      {
        this.sendertpIdHelp = 'Parent TPId';
        this.receivertpIdHelp = 'TPIds for owner';
        this.sendingTpIds =[];
        this.receivingTpIds=[];
        this.sendingTpIds[0] = this.parentTpId ;
        this.receivingTpIds = this.ownerTpIds;
        if (this.isAddMode) {
          this.form.controls.GsReceiverId.setValue(this.receivingTpIds[0]);
          this.form.controls.IsaReceiverId.setValue(this.receivingTpIds[0]);
          this.form.controls.GsSenderId.setValue(this.sendingTpIds[0]);
          this.form.controls.IsaSenderId.setValue(this.sendingTpIds[0]);
        }
      }
      else {
        this.sendertpIdHelp = 'TPIds for owner';
        this.receivertpIdHelp = 'Parent TPId';
        this.receivingTpIds =[];
        this.sendingTpIds = [];
        this.receivingTpIds[0] = this.parentTpId ;
        this.sendingTpIds = this.ownerTpIds;
        if (this.isAddMode) {
          this.form.controls.GsReceiverId.setValue(this.receivingTpIds[0]);
          this.form.controls.IsaReceiverId.setValue(this.receivingTpIds[0]);
          this.form.controls.GsSenderId.setValue(this.sendingTpIds[0]);
          this.form.controls.IsaSenderId.setValue(this.sendingTpIds[0]);
          }
      }
      if(this.transactionTypes[result].TransactionSetId === '835')
      {
        this.transaction835 = true;
      }
      else
      {
        this.transaction835 = false;
      }

      this.showTpIds = true;
    }

    private createUpdateTpLink(addFlg: boolean) {
      this.form.value.customProp = this.customProp;
      console.info('Create TPLink for name: ' + this.form.value.TransactionSetId +", customProp: " + this.customProp.length);
      if ( String(this.form.value.TransactionSetId).startsWith('835'))
      {
        let kv = new KVP();
        kv.Key = "BatchingMode835"
        if(this.form.controls.MergeFlg.value == true)
        {
          console.info('Add Merge for ' + this.form.value.TransType)
          kv.Value = "Batched"
        }
        else {
          console.info('Remove Merge for ' + this.form.value.TransType)
          kv.Value = "Individual"
        }
        this.customProp.push(kv)

      }
      this.tpService.addUpdateTpLink(this.form.value, addFlg)
          .pipe(first())
          .subscribe((res) => {
            let retStr:String;
            if (res.errormessage !== undefined) {
             console.info('createUpdateTpLink error: ' + res.errormessage);
             retStr = res.errormessage;
            }
            else if( res.Status !== undefined) {
              console.error('createUpdateTpLink status: ' + res.Status);
              if(res.Status == 'OK')
              {
                 this.router.navigate(["/TradingPartners/tpIds/tp-links/" + this.parentTpId ]);
                 retStr = 'OK'
              }
              else
              {
                   retStr = this.form.value.Link + ": " + res.Status;
              }
            }
            else{
              alert('createUpdateTpLink Status: ' + res);
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

    createKV(kv: KVP) {
      if (this.customProp.length === 0) {
        const newKV = { ...kv, id: 1 };
        this.customProp = [...this.customProp, newKV];
      } else {
        const [{ id: newId }] = [...this.customProp].reverse();
        const newKV = { ...kv, id: newId + 1 };
        this.customProp = [...this.customProp, newKV];
      }
    }


}
