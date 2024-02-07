import { Injectable } from "@angular/core";

import { BehaviorSubject, Observable } from "rxjs";
import { map } from "rxjs/operators";

import { User } from "../login/user";
import {TpRestServiceComponent} from './tprest-service.component';
import {TransRestServiceComponent} from './transrest-service.component';


@Injectable({ providedIn: "root" })

export class AuthenticationService {
 private currentUserSubject: BehaviorSubject<User>;
  public currentUser: Observable<User>;

  constructor(private tpService: TpRestServiceComponent, private tpTransService: TransRestServiceComponent,
              private usrTransService: TransRestServiceComponent
    ) {

    this.currentUserSubject = new BehaviorSubject<User>(
      JSON.parse(sessionStorage.getItem("currentUser"))
    );
    this.currentUser = this.currentUserSubject.asObservable();

    console.info('In AuthenticationService constructor ' );
    this.currentUser.forEach(user =>
    {
      console.info('AuthenticationService constructor ' + user);
    });

  }

  public get currentUserValue(): User {

    return this.currentUserSubject.value;
  }

  login(username: string, password: string) {

      return this.tpService.validateUser(username, password, this).pipe(map(res => {
        console.info(' AuthenticationService login validateUser: ' + res);
        let user = new User();
        user.authdata = window.btoa(username + ":" + password);
        user.id = 1
        user.firstName = res
        user.username = username
        user.password = password
        sessionStorage.setItem("currentUser", JSON.stringify(user));
        this.currentUserSubject.next(user);
        if (this.currentUserSubject.value!== null)
        {
          console.info('login currentUserValue: ' + this.currentUser );
          this.tpTransService.setcurrentUser(username);

        }
        return user;
      }));

  }

  logout() {
    // remove user from local storage to log user out
    console.info('logout currentUserValue: ' + (this.currentUserSubject.value.firstName));
    sessionStorage.removeItem("currentUser");
    this.currentUserSubject.next(null);
  }

}
