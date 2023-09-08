import { Injectable } from "@angular/core";

import { BehaviorSubject, Observable } from "rxjs";
import { map } from "rxjs/operators";

import { User } from "../login/user";
import {RestServiceComponent} from './rest-service.component';


@Injectable({ providedIn: "root" })

export class AuthenticationService {
 private currentUserSubject: BehaviorSubject<User>;
  public currentUser: Observable<User>;

  constructor(private usrService: RestServiceComponent) {

    this.currentUserSubject = new BehaviorSubject<User>(
      JSON.parse(sessionStorage.getItem("currentUser"))
    );
    this.currentUser = this.currentUserSubject.asObservable();

    console.info('AuthenticationService constructor');

  }

  public get currentUserValue(): User {

    return this.currentUserSubject.value;
  }

  login(username: string, password: string) {

      return this.usrService.validateUser(username, password).pipe(map(res => {
        console.info(' AuthenticationService login validateUser: ' + res);
        let user = new User();
        user.authdata = window.btoa(username + ":" + password);
        user.id = 1
        user.firstName = res
        user.username = username
        user.password = password
        sessionStorage.setItem("currentUser", JSON.stringify(user));
        this.currentUserSubject.next(user);
        console.info('login currentUserValue: ' + (this.currentUserSubject.value!== null) );
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
