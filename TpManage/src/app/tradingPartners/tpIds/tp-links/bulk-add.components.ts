import { Component,   ViewChildren,  ElementRef,  ChangeDetectorRef,  QueryList, OnInit } from '@angular/core';
import { Router, ActivatedRoute} from '@angular/router';
import { AbstractControlOptions, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { first } from 'rxjs/operators';
import { FormsModule, ReactiveFormsModule, FormGroupDirective } from '@angular/forms';
import { RestServiceComponent } from '../../../services/rest-service.component';
import { bulkTpLinks } from './bulk-tp-links';

@Component(
  {  selector: 'bulk-add',
     templateUrl: './bulk-add.components.html',
     styleUrls: ['./bulk-add.components.css'],
})


export class BulkAddComponents implements OnInit {
    form!: FormGroup;
    parentTpId!: string;
    loading = false;

    submitted = false;

    BatchackTypes:string[] = ["Negative","Always", "Never"];
    RTackTypes = ["Never","Negative"];
    modeTypes:string[] = ["Batch","RT"];
    routingTypes:string[] =["UHIN Batch","R1 Batch","UMR Batch","Loopback Batch"];
    ownerTpIds = [];
    canRender = false;

    trn: bulkTpLinks;

    RtTransactionTypes= ["270", "271","276", "277"];
    BatchTransactionTypes= ["270", "271","276", "277", "835", "837"];

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
     this.canRender = true;
    });
    console.info("this.ownerTpIds: " + this.ownerTpIds.length)

 });
}

    async ngOnInit() {
      console.info("AddEditComponent ngOnInit");
        this.parentTpId = this.route.snapshot.params['tpId'];

        console.info('Get TP parent: ' + this.parentTpId);

          this.parentTpId = this.route.snapshot.params['tp'];
          console.info("Get parent: " + this.parentTpId);

        this.form = this.formBuilder.group({
          ParentTpId: [''],
          PayerId: ['', Validators.required],
          Link: ['', Validators.required],
          RtTransType: ['', Validators.required],
          BatchTransType: ['', Validators.required],
          RtAck: ['', Validators.required],
          BatchAck: ['', Validators.required],
          BatchRouting: ['', Validators.required],
          RtSNIP: ['1', Validators.required],
          BatchSNIP: ['1', Validators.required],
          Separators   : ['|*^:', Validators.maxLength(4)]
      });

      this.initializeData();


      let myPromise = () => new Promise((resolve, reject) => {
        setTimeout(function(){
          resolve('Count')
        }, 1000)
      })

      for (let index = 0; index < 5; index++) {
        let count = await myPromise()

        if(this.canRender){
          console.log('Received from fetchOwnerTpIds: ' +`${count}: ${index}`);

          break;
        }
      }

      let ttype ='' ;

       this.form.controls.ParentTpId.setValue(this.parentTpId);
       this.form.controls.PayerId.setValue(this.ownerTpIds[0]);

       this.form.controls.RtAck.setValue(this.RTackTypes[0]);
       this.form.controls.BatchAck.setValue(this.BatchackTypes[0]);
       this.form.controls.BatchRouting.setValue(this.routingTypes[0]);
       this.form.controls.RtSNIP.setValue(1);
       this.form.controls.BatchSNIP.setValue(1);
       this.form.controls.Separators.setValue("|*^:");

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
          console.log(el +" - " + this.form.controls[el].value);
          if (this.form.controls[el].errors) {
            console.log(el +" - not initialized");
          }
     }

        // stop here if form is invalid
        if (this.form.invalid) {
          console.info('Invalid: ' + this.form.invalid);
            return;
        }

        this.loading = true;

        this.createUpdateTpLink();

    }


    private createUpdateTpLink() {
      console.info('Create TPLink for name: ' + this.form.value);
      this.tpService.addBulkTpLinks(this.form.value)
          .pipe(first())
          .subscribe((res) => {
            let retStr:String;
            console.info(res);
            if (res.errormessage !== undefined) {
             console.info('createUpdateTpLink error: ' + res.errormessage);
             retStr = res.errormessage;
            }
            else if( res.Status !== undefined) {
              console.error('createUpdateTpLink status: ' + res.Status);
              if(res.Status ='OK')
              {
                 this.router.navigate(["/TradingPartners/tpIds/tp-links/" + this.parentTpId ]);
              }
              else
              {
                alert('createUpdateTpLink status: ' + res.Status);
              }
              retStr = res.Status;
            }
            else{
              alert('createUpdateTpLink else: ' + res.Error);
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
