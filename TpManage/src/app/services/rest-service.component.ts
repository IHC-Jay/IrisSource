import { Component } from '@angular/core';
import { Injectable } from '@angular/core';
import {
  HttpClient,
  HttpHeaders,
  HttpParams
  } from '@angular/common/http';
import { forkJoin, Observable, pipe } from 'rxjs';
import { map, catchError, tap } from 'rxjs/operators';
import { Subject, throwError } from 'rxjs';

import { TradingPartner } from '../tradingPartners/TradingPartner';
import { TpId } from '../tradingPartners/tpIds/TpId';
import { tpLinks } from '../tradingPartners/tpIds/tp-links/tp-links';

import { environment } from '../../environments/environment';

const baseUrl = `${environment.apiUrl}`;


@Injectable({ providedIn: 'root' })

@Component({
  selector: 'app-rest-service',
  templateUrl: './rest-service.component.html'
})

export class RestServiceComponent {

  error = new Subject<string>();

  constructor(private http: HttpClient)
   {
   }

  validateUser(usr: String, passw: String)
   {

    let searchParams = new HttpParams();
    // searchParams = searchParams.append('Accept', '*/*');
    //searchParams = searchParams.append('custom', 'key');
    console.log('Test User: ' + usr);
    let url = '';

    url = baseUrl + 'ping';


    return this.http.get<{ [key: string]: string }>(
        url,
        {
          headers: new HttpHeaders({
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': "GET, PUT, POST, DELETE",
          'Access-Control-Allow-Headers' : 'Content-Type, x-requested-with',
          'Content-Type': 'application/json',
          'Access-Control-Allow-Credentials': 'true',
          Authorization: 'Basic ' + btoa(usr + ':' + passw)  } ),
          params: searchParams,
          responseType: 'json'
        }
      )
      .pipe(
        map(responseData => {
         console.info("return Response: " + responseData.ContactName)
         return responseData.ContactName;
        }),
        catchError(errorRes => {
          // Send to analytics server
          console.error('RestServiceComponent validateUser catchError');
          throw(errorRes);
        })
      );
  }

    fetchTradingPartners() {
      console.log('Fetch TradingPartners with Auth ' );

      let url = '';

      url = baseUrl + 'Tps';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,
        )
        .pipe(
          map(responseData => {
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TradingPartnersArray.push({ ...responseData[key], tpid: key });
              }
            }
            console.info('return TP array: ' + TradingPartnersArray.length )
            return TradingPartnersArray;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In fetchTradingPartners catchError');
            return errorRes;
          })
        );
    }

    fetchTPIDs(tpName: String) {
      console.log('Fetch Class: ' + tpName);

      let url = '';

      url = baseUrl + 'TpIdsForTP?name='+tpName;


      return this.http.get<{ [key: string]: TpId }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TPIDArray: TpId[] = [];
            console.info("Response")
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                console.info("Got a TP record")
                TPIDArray.push({ ...responseData[key], id: key });
              }
            }
            return TPIDArray;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In fetchTPIDs catchError');
            return throwError(errorRes);
          })
        );
    }

    fetchTPforTpId(tpName: String) {

      console.log('Fetch Class: ' + tpName);
      let url = '';

      url = baseUrl + 'TPforTPID?tpid='+tpName;


      return this.http.get<{ [key: string]: TpId }>(
          url,

        )
        .pipe(
          map(responseData => {
           console.info("Response")
           return responseData;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In fetchTPIDs catchError');
            return throwError(errorRes);
          })
        );
    }


    fetchTpIds() {


      console.log('Fetch Class');

      let url = baseUrl + 'GetAllTpIds';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TradingPartnersArray.push({ ...responseData[key], tpid: key });
              }
            }
            return TradingPartnersArray;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In fetchTpIds catchError');
            return throwError(errorRes);
          })
        );
    }


    fetchTransactionTypes() : Observable < TradingPartner[] >{

      console.log('Fetch TransactionTypes');

      let url = '';

      url = baseUrl + 'GetTransactionTypes';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TradingPartnersArray.push({ ...responseData[key], tpid: key });
              }
            }
            return TradingPartnersArray;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In fetchTransactionTypes catchError');
            return throwError(errorRes);
          })
        );
    }

    fetchTpLinks(tpid: String)
    {
      console.log('Fetch TpLinks Class: ' + tpid);

      let url = '';

      url = baseUrl + 'LinksForTPID?TPID='+ tpid;


      return this.http
        .get<{ [key: string]: tpLinks }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TpLinksArray: tpLinks[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TpLinksArray.push({ ...responseData[key], id: key });
              }
            }
            return TpLinksArray;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In fetchTradingPartners catchError');
            return throwError(errorRes);
          })
        );
    }


    fetchTpLink(tpLink: String)
    {

      console.log('Fetch TpLink Class: ' + tpLink);
      let url = '';

      url = baseUrl + 'TpLink?id='+ tpLink;


      return this.http
        .get<{ [key: string]: tpLinks }>(
          url,
        )
        .pipe(
          map(responseData => {
            return responseData;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In getTpFromIris catchError');
            return throwError(errorRes);
          })
        );
    }


  deleteTpLink(tpLink: String) {

    console.log('deleteTpLink: ' + tpLink);

    let url = baseUrl + 'DeleteTpLink';

    console.info('Post to delete TPLink: ' + url);
    const body = { id: tpLink };
    return this.http.post<string>(url, body);

  }


  addUpdateTpLink(link: tpLinks, add: boolean) {

    console.log('add tpLinks: ' + link.Link);

    let url = ''

    if(add)
    {
       url = baseUrl + '' + 'NewTpLink';
    }
    else{
      url = baseUrl + '' + 'UpdateTpLink';
    }

    console.info('Post to create/update TPLink: ' + url);

    // const body = { Name: 'Angular POST Request ', Type: 'PROVIDER' };
    return this.http.post<any>(url, link)
    .pipe(
      map(responseData => {

        return responseData;

      }),
      catchError(errorRes => {
        // Send to analytics server
        console.error('In tpLinks catchError: ');
        return errorRes;
      })
    );


  }


  getTpIds(tpId: string) : Observable<TpId[]> {

    let url = '';

    url = baseUrl + 'TpIdsForTP?name='+ tpId;

    return this.http
      .get<{ [key: string]: TpId }>(
        url,

      )
      .pipe(
        map(responseData => {
          const TpIdsArray: TpId[] = [];
          for (const key in responseData) {
            if (responseData.hasOwnProperty(key)) {
              let id = {...responseData[key]}.id;
              console.info("Push:" + key +", nm: " + id)
              TpIdsArray.push({ ...responseData[key], id: id });
            }
          }
          return TpIdsArray;
        }),
        catchError(errorRes => {
          // Send to analytics server
          console.error('In fetchTpIds catchError');
          return throwError(errorRes);
        })
      );
  }


  addTradingPartner(tradingPartner: TradingPartner):  Observable<TradingPartner> {


    console.log('addTradingPartner: ' + tradingPartner.Name);


    let url = baseUrl + 'NewTp';

    console.info('Post to create TP: ' + url);

    return this.http.post<any>(url, tradingPartner);
  }

  deleteTradingPartner(tpName: string) : Observable<string> {


    console.log('deleteTradingPartner: ' + tpName);

    let url = baseUrl + 'DeleteTp';

    console.info('Post to delete TP: ' + url);
   const body = { Name: tpName };
    return this.http.post<string>(url, body);

  }

  updateTradingPartner(tradingPartner: TradingPartner): Observable<TradingPartner> {
    console.log('updateTradingPartner: ' + tradingPartner.Name + ", Id: " + tradingPartner.tpid);


    let url = baseUrl + 'UpdateTp';
    return this.http.post<TradingPartner>(`${url}`, tradingPartner);

  }


  deleteTradingPartners(tradingPartners: TradingPartner[]) {
    return forkJoin(
      tradingPartners.map((tradingPartner) =>
      this.deleteTradingPartner(tradingPartner.Name)
      )
    );
  }


  addTPID(newTpId: TpId) : Observable<TpId> {

    console.log('addTradingPartner TPID: ' + newTpId.Name);


    let url = baseUrl + 'NewTpId';

    console.info('Post to create TPID: ' + url);
    return this.http.post<any>(url, newTpId);

  }

  updateTPID(tpid: TpId): Observable<TpId> {
    console.log('updateTradingPartner TPIT: ' + tpid.Name + ", Id: " + tpid.id);


    let url = baseUrl + 'UpdateTpId';

    console.info('Post to update TP: ' + url);
    return this.http.post<TpId>(`${url}`, tpid);
  }


  deleteTPID(tpId: string) : Observable<string> {


    let url = baseUrl + 'DeleteTpId';

    console.info('Post to delete TPID: ' + url);

    const body = { id: tpId };
    return this.http.post<string>(url, body);

  }



  }



