import { Component, EventEmitter, OnInit, Output, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import {AuthenticationService} from '../services/authentication.service';
import {User} from '../login/user';
import {RestServiceComponent} from '../services/rest-service.component';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { catchError } from 'rxjs';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.css']
})

export class HeaderComponent implements AfterViewInit, OnInit   {
  loginForm: FormGroup;

  loading = false;
  submitted = false;
  returnUrl: string;
  displayHelp: string = "Username/Password will used for calling IRIS REST services";
  error = '';

  currentUser: User;
  isLogin:boolean;
  collapsed = true;
  @Output() selectedFeature = new EventEmitter<string>();
  @ViewChild("username") focusField: ElementRef;

  selectedMenu:string = 'tradingPartner'
  links = [
    {name:'Trading Partners', link:"/TradingPartners"},
    {name:'Search TPID', link:"/search"},
    {name:'Search Transactions', link:"/transaction"}
  ];

  activeLink = this.links[0].link;
  background = 'white';

  constructor(private router: Router, private authenticationService: AuthenticationService,
    private TradingPartnerService: RestServiceComponent,
      private formBuilder: FormBuilder,
      private route: ActivatedRoute
    )
    {
      this.authenticationService.currentUser.subscribe(x => {
        this.currentUser = x
        this.isLogin = (x != null);
        }
        );
    }

    ngOnInit() {

      this.loginForm = this.formBuilder.group({
          username: ['', Validators.required],
          password: ['', Validators.required]
      });


      // get return url from route parameters or default to '/'
      this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/login';
  }

  ngAfterViewInit() {
    this.focusField.nativeElement.focus();
  }


     // convenience getter for easy access to form fields
     get f() { return this.loginForm.controls; }


  routeLnk(lnk: string): void{
    console.info('route: ' + lnk);

    this.router.navigate([lnk] );
    this.background = (this.background =='white') ? 'beige' : 'white';
    this.activeLink = lnk
    console.info(lnk +": " + this.background);
  }

  logout() {
    this.authenticationService.logout();
    localStorage.clear();
    this.isLogin = false;
    this.f.username.setValue('');
    this.f.password.setValue('');
    this.router.navigate(['/']);
    location.reload();
   }

   onLogin()
   {


      // stop here if form is invalid
      if (this.loginForm.invalid) {
          return;
      }

      this.loading = true;
      return this.authenticationService.login(this.f.username.value, this.f.password.value)
      .subscribe({
        next: (res) =>
        {
          console.info('from  authenticationService.login');
          console.info('OK: ' + this.returnUrl);
          this.router.navigate(['/TradingPartners']);
          this.isLogin = true;
          this.submitted = true;
          return;
        },
        error: (e) => {
          console.error('onLogin catchError: ' +e);
          this.router.navigate(['/']);
          this.displayHelp = "Login failed";
          this.loading = false;
          return;
        }
      })


   }

}




