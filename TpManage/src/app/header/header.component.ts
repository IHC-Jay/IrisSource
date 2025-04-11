import { Component, OnInit, Input, Output, AfterViewInit, ViewChild, ElementRef, Injectable } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import {AuthenticationService} from '../services/authentication.service';
import {User} from '../login/user';
import {Link, tabLinks} from './Links';

import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { catchError, Observable } from 'rxjs';
import {TransRestServiceComponent} from '../services/transrest-service.component';
import {WfRestServiceComponent} from '../services/wfrest-service.component';
import { MatTabsModule, MatTabChangeEvent } from '@angular/material/tabs';
import { Title } from '@angular/platform-browser';
import {MatIconModule} from '@angular/material/icon';
import {MatButtonModule} from '@angular/material/button';
import {MatBadgeModule} from '@angular/material/badge';
import { tpLinks } from '../tradingPartners/tpIds/tp-links/tp-links';

const CHECK_INTERVAL = 5000 // in ms
const STORE_KEY =  'lastAction';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})


export class HeaderComponent implements AfterViewInit, OnInit   {

  loginForm: FormGroup;
  val: any;

  loading = false;
  submitted = false;
  returnUrl: string;
  displayHelp: string = "Username/Password will used for calling IRIS REST services";
  error = '';
  firstPage = '/dashboard';
  transaction = "";
  id = "";
  tpId = "";
  paramsObject:any;
  currentUser: User;
  searchStr:string = "";
  NumAssignedItems:number;
  public links:Link[] = tabLinks;


  isLogin:boolean;
  collapsed = true;

  @ViewChild("username") focusField: ElementRef;

  selectedMenu:string = 'tradingPartner'


  selectedLnkIndex = 3;

  background = 'white';

  constructor(private router: Router, private authenticationService: AuthenticationService,
      private formBuilder: FormBuilder,
      private route: ActivatedRoute,
      private TransactionService: TransRestServiceComponent,
      private WfService: WfRestServiceComponent
    )
    {
      console.log('**** HeaderComponent constructor ****');

      this.authenticationService.currentUser.subscribe(x => {
        this.currentUser = x
        this.isLogin = (x != null);
        console.log("HeaderComponent: " + this.currentUser.username)
        }
        );

    }

    ngOnInit() {

      this.loginForm = this.formBuilder.group({
          username: ['', Validators.required],
          password: ['', Validators.required],
          env: ['DEV', Validators.required],
          logoutTime: ['60', Validators.required]
      });


      // get return url from route parameters or default to '/'
      this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/login';


      this.route.queryParams.subscribe(params => {
        console.log(this.returnUrl + ', Header Query params: ' + params)

        this.paramsObject = { ...params.keys, ...params };

        if (this.paramsObject.searchTypeString  !== undefined && this.paramsObject.searchTypeString  !== '')
        {
          let str:string = this.paramsObject.searchTypeString.toString()
          if(str.indexOf('sameWindow::false') >= 0)
          {

            if (this.paramsObject.transaction !== undefined)
            {
              this.searchStr = "Transaction: " + this.paramsObject.transaction
              let element = document.getElementById('tabGrp') as HTMLElement;
              element.setAttribute('hidden', 'true');
              console.log("Disable: " + element);

              element = document.getElementById('logout') as HTMLElement;
              element.setAttribute('hidden', 'true');
              console.log("Disable: " + element);


            }


            if (this.paramsObject.additionalSearch  !== undefined && this.paramsObject.additionalSearch  !== '')
            {
              console.log("ADDITIONAL: " + this.paramsObject.additionalSearch)
              this.searchStr += ", " + this.paramsObject.additionalSearch
            }
            if(this.paramsObject.ID !== undefined)
            {
              this.searchStr += ", ID: " + this.paramsObject.ID

            }
            console.log("Label: " + this.searchStr + "sameWindow: " + this.paramsObject.searchTypeString)
          }
          else
          {
            this.searchStr = ""
          }
        }
        else
        {
          this.searchStr = ""
        }


        if(params !== undefined && params.page !== undefined)
        {
          console.log(params);
          this.firstPage = params.page;
          this.transaction = params.transaction;
          if (this.firstPage.includes("transaction-details") )
          {
            this.id = params.id;
          }
          else if (this.firstPage.includes("tp-add"))
          {
            this.tpId = params.tpId;
          }

          console.log("queryParams: " + this.firstPage);
          this.onLogin();
        }
      }
    );

  }

  ngAfterViewInit() {
    if(this.focusField !== undefined && this.focusField.nativeElement !== undefined)
    {
      this.focusField.nativeElement.focus();
    }
  }


     // convenience getter for easy access to form fields
     get f() { return this.loginForm.controls; }


  logout() {
    this.authenticationService.logout();
    sessionStorage.clear();
    this.isLogin = false;
    this.f.username.setValue('');
    this.f.password.setValue('');
    this.router.navigate(['/']);
    location.reload();
   }

   onLogin()
   {

    console.log("header onLogin")
      // stop here if form is invalid
      if (this.loginForm.invalid) {
        console.error("Invalid login form");
          return;
      }

      this.loading = true;
      return this.authenticationService.login(this.f.username.value, this.f.password.value, this.f.env.value)
      .subscribe({
        next: (res) =>
        {
          console.info('from  authenticationService.login : ' + this.firstPage);
          console.info(this.f.env.value + '- OK: ' + this.returnUrl);

          this.TransactionService.deleteDisplayColumns('Session','','').subscribe((res: any) => {

            console.info("Delete Display: " + res);

          });
          this.TransactionService.deleteSearchColumns().subscribe((res: any) => {

            console.info("Delete Search: " + res);

          });



          this.isLogin = true;
          this.submitted = true;



          this.TransactionService.fetchConfiguration().subscribe((res: any) => {
            console.info("Configuration array : " + res.length);
            if (res.length == 1)
            {
                console.log('Open Setting')
                this.router.navigate([this.links[0].link]);
                this.selectedLnkIndex = 0;
            }
            else
            {

              for(let ind = 0; ind < res.length; ind++)
                {
                  sessionStorage.setItem(res[ind].Key, res[ind].Value);
                  console.log('Store in sessionStorage ' + res[ind].Key +", " + res[ind].Value);

                  if(res[ind].Key === 'Page')
                    {
                      for(let tabInd = 0; tabInd < this.links.length; tabInd++)
                        {
                          if(this.links[tabInd].name === res[ind].Value)
                          {
                            this.firstPage = this.links[tabInd].link;
                            this.selectedLnkIndex = tabInd;
                            console.log('Use Config, page: ' + this.firstPage + ' # ' +  this.selectedLnkIndex)
                          }
                        }
                    }
                }



              this.getWFitems();

              if (this.firstPage.includes("transaction-details") )
              {
                console.log("navigate: /transaction/transaction-details/ -" + this.id);
                this.router.navigate(["/transaction/transaction-details/"],
                {queryParams: { id:  this.id, 'transaction': this.transaction, 'search': ''} }
                );
                this.selectedLnkIndex = 5
              }
              else if (this.firstPage.includes("tp-add"))
              {
                console.log("navigate: /TradingPartners/tpIds/tp-links/tp-add -" + this.id);
                this.router.navigate(["/TradingPartners/tpIds/tp-links/tp-add/"+this.tpId ],
                {queryParams: { 'transaction': this.transaction} }
                );
                this.selectedLnkIndex = 1
              }
              else{
                console.log('Navigate: ' + this.firstPage + ' # ' +  this.selectedLnkIndex)
                this.router.navigate([this.firstPage]);
              }

            }

            // Auto logout

            this.check();
            this.initListener();
            this.initInterval();
            console.log('Store in sessionStorage')
            sessionStorage.setItem(STORE_KEY,Date.now().toString());

          });


          return;


        },
        error: (e) => {
          console.error('onLogin catchError: ' +e);
          this.router.navigate(['/']);
          this.error = 'Login failed for ' + this.f.username.value + ". Exception in calling the REST service "
          alert(this.error)
          this.displayHelp = "Login failed";
          this.loading = false;
          return;
        }
      })


   }

   onTabChanged(event: MatTabChangeEvent): void {

    console.log("header onTabChanged: " + event.index)
    this.selectedLnkIndex = event.index;
    console.info(this.links[event.index].link)

    if (event.index == 6)
    {

        let numItems = this.NumAssignedItems

          this.NumAssignedItems = 0;

          this.router.navigate([this.links[event.index].link], {queryParams: { 'WFitems':  numItems}} );

      }
      else{

        this.getWFitems()
        this.router.navigate([this.links[event.index].link]);

      }

   }

   getWFitems()
   {
    let paramsList: string[]= [];

    paramsList.push('TransactionType::All')
    paramsList.push('StatusTypes::Assigned To Me')
    paramsList.push('ErrorType::All')

    this.WfService.fetchWorkFlowItems(paramsList).subscribe((res: any) => {
      this.NumAssignedItems = res.length;

    });
   }

   onHome()
   {
    console.log("header onHome")
    this.selectedLnkIndex = 3;

    this.getWFitems()
    this.router.navigate([this.links[this.selectedLnkIndex].link]);



   }

   // Auto logout

   public getLastAction() {
    return parseInt(sessionStorage.getItem(STORE_KEY));
  }

 public setLastAction(lastAction: number) {
  sessionStorage.setItem(STORE_KEY, lastAction.toString());
  }

   initListener() {
    document.body.addEventListener('click', () => this.reset());
    document.body.addEventListener('mouseover',()=> this.reset());
    document.body.addEventListener('mouseout',() => this.reset());
    document.body.addEventListener('keydown',() => this.reset());
    document.body.addEventListener('keyup',() => this.reset());
    document.body.addEventListener('keypress',() => this.reset());
     window.addEventListener("storage",() => this.storageEvt());

  }

  reset() {

    this.setLastAction(Date.now());
    // console.log('store key',sessionStorage.getItem(STORE_KEY));

  }

  initInterval() {
    setInterval(() => {
      this.check();
    }, CHECK_INTERVAL);
  }

  onContextSettings()
  {
    this.selectedLnkIndex = 0
    this.router.navigate(["/transaction/transaction-settings/"],
     );
  }

  check() {
    const now = Date.now();
    var tm = this.f.logoutTime.value
    const timeleft = this.getLastAction() + tm * 60 * 1000;
    const diff = timeleft - now;
    // console.log('Max time:' + tm + ', difference',diff)
    const isTimeout = diff < 0;

    if (isTimeout)  {
      this.logout();
    }
  }

  storageEvt(){
	console.log("storage");
	this.val = sessionStorage.getItem(STORE_KEY);
  }

}




