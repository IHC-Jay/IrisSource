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
import { bulkTpLinks } from '../tradingPartners/tpIds/tp-links/bulk-tp-links';

import { environment } from '../../environments/environment';

import {EligibilityRequest} from '../transaction/EligibilityRequest'
import {Claim} from '../transaction/Claims'
import {ClaimStatusResp} from '../transaction/ClaimStatusResp'
import {ClaimStatusReq} from '../transaction/ClaimStatusReq'
import {ClaimPayment} from '../transaction/ClaimPayment'
import {ImplementationAcknowledgment} from '../transaction/ImplementationAcknowledgment';
import {ClaimAcknowledgment} from '../transaction/ClaimAcknowledgment';
import { transition } from '@angular/animations';

import {DisplayColumns, DisplayColumnsArray} from '../transaction/DisplayColumns';
import { AuthenticationService } from '../services/authentication.service';
import { Router, ActivatedRoute} from '@angular/router';

const tpUrl = `${environment.tpUrl}`;

const transUrl = `${environment.transUrl}`;



@Injectable({ providedIn: 'root' })

@Component({
  selector: 'app-rest-service',
  templateUrl: './rest-service.component.html'
})

export class RestServiceComponent {

  currentUser:string = '';
  error = new Subject<string>();

  constructor(private authenticationService: AuthenticationService,
    private http: HttpClient, private http2: HttpClient
    , private router: Router)
   {
    console.log('**** RestServiceComponent constructor ****')
   }

   getCurrentUser()
   {
     console.log('Fetch getCurrentUser');
     if( this.currentUser === '')
     {
      this.authenticationService.logout();
      localStorage.clear();
      this.router.navigate(['/']);
     }
     return this.currentUser;
   }

  validateUser(usr: string, passw: String)
   {

    let searchParams = new HttpParams();
    // searchParams = searchParams.append('Accept', '*/*');
    //searchParams = searchParams.append('custom', 'key');
    console.log('Test User: ' + usr);
    let url = '';

    url = tpUrl + 'ping';


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
         console.info("validateUser return Response: " + responseData.ContactName)
         this.currentUser = usr;
         return responseData.ContactName;
        }),
        catchError(errorRes => {
          // Send to analytics server
          console.error('RestServiceComponent validateUser catchError: ' + errorRes);
          throw(errorRes);
        })
      );
  }


    fetchTradingPartners() {
      console.log('Fetch TradingPartners with Auth ' );

      let url = '';

      url = tpUrl + 'Tps';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,
        )
        .pipe(
          map(responseData => {
            console.info(responseData);
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                // console.info('TP key: ' + key)
                TradingPartnersArray.push({ ...responseData[key], id: responseData[key].id });
              }
            }
            console.info('return TP array: ' + TradingPartnersArray.length );
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

      url = tpUrl + 'TpIdsForTP?name='+tpName;


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

      console.log('fetchTPforTpId Class: ' + tpName);
      let url = '';

      url = tpUrl + 'TPforTPID?tpid='+tpName;


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

      let url = tpUrl + 'GetAllTpIds';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TradingPartnersArray.push({ ...responseData[key], id: key });
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

    fetchOwnerTpIds() {


      console.log('fetchOwnerTpIds');

      let url = tpUrl + 'GetOwnerTpIds';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TradingPartnersArray.push({ ...responseData[key], id: key });
              }
            }
            return TradingPartnersArray;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In GetOwnerTpIds catchError');
            return throwError(errorRes);
          })
        );
    }


    fetchTransactionTypes() : Observable < TradingPartner[] >{

      console.log('Fetch TransactionTypes');

      let url = '';

      url = tpUrl + 'GetTransactionTypes';


      return this.http
        .get<{ [key: string]: TradingPartner }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TradingPartnersArray: TradingPartner[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                TradingPartnersArray.push({ ...responseData[key], id: key });
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

      url = tpUrl + 'LinksForTPID?TPID='+ tpid;


      return this.http
        .get<{ [key: string]: tpLinks }>(
          url,

        )
        .pipe(
          map(responseData => {
            const TpLinksArray: tpLinks[] = [];
            for (const key in responseData) {
              if (responseData.hasOwnProperty(key)) {
                console.info("Key: " + responseData[key].Link);
                if(responseData[key].Link !== undefined)
                {
                  TpLinksArray.push({ ...responseData[key], id: key });
                }
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

      url = tpUrl + 'TpLink?id='+ tpLink;


      return this.http
        .get<{ [key: string]: tpLinks }>(
          url,
        )
        .pipe(
          map(responseData => {
            console.trace(responseData);
            return responseData;
          }),
          catchError(errorRes => {
            // Send to analytics server
            console.error('In getTpFromIris catchError: ' + errorRes);
            return throwError(errorRes);
          })
        );
    }


  deleteTpLink(tpLink: String) {

    console.log('deleteTpLink: ' + tpLink);

    let url = tpUrl + 'DeleteTpLink';

    console.info('Post to delete TPLink: ' + url);
    const body = { id: tpLink, User: this.getCurrentUser()};
    return this.http.post<string>(url, body);

  }


  addUpdateTpLink(link: tpLinks, add: boolean) {

    console.log('add tpLinks: ' + link.Link);

    let url = ''

    if(add)
    {
       url = tpUrl + '' + 'NewTpLink';
    }
    else{
      url = tpUrl + '' + 'UpdateTpLink';
    }

    console.info('Post to create/update TPLink: ' + url);
    link.User =  this.getCurrentUser()
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

    url = tpUrl + 'TpIdsForTP?name='+ tpId;

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

    let url = tpUrl + 'NewTp';
    tradingPartner.User =  this.getCurrentUser();

    console.info('Post to create TP: ' + url);

    return this.http.post<any>(url, tradingPartner);
  }

  deleteTradingPartner(tpName: string) : Observable<string> {


    console.log('deleteTradingPartner: ' + tpName);

    let url = tpUrl + 'DeleteTp';

    console.info('Post to delete TP: ' + url);
   const body = { Name: tpName };
    return this.http.post<string>(url, body);

  }

  updateTradingPartner(tradingPartner: TradingPartner): Observable<TradingPartner> {
    console.log('updateTradingPartner: ' + tradingPartner.Name + ", Id: " + tradingPartner.id);


    let url = tpUrl + 'UpdateTp';
    tradingPartner.User =  this.getCurrentUser();
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


    let url = tpUrl + 'NewTpId';
    newTpId.User =  this.getCurrentUser();
    console.info('Post to create TPID: ' + url);
    return this.http.post<any>(url, newTpId);

  }

  updateTPID(tpid: TpId): Observable<TpId> {
    console.log('updateTradingPartner TPIT: ' + tpid.Name + ", Id: " + tpid.id);


    let url = tpUrl + 'UpdateTpId';
    tpid.User =  this.getCurrentUser();
    console.info('Post to update TP: ' + url);
    return this.http.post<TpId>(`${url}`, tpid);
  }


  deleteTPID(tpId: string) : Observable<string> {


    let url = tpUrl + 'DeleteTpId';

    console.info('Post to delete TPID: ' + url);

    const body = { id: tpId };
    return this.http.post<string>(url, body);

  }

  addBulkTpLinks(link: bulkTpLinks) {

    console.log('add bulkTpLinks: ' + link.Link);

    let url = tpUrl + '' + 'BulkTpLinks';

    console.info('Post to create/update TPLinks: ' + url);
    link.User =  this.getCurrentUser();

    return this.http.post<any>(url, link)
    .pipe(
      map(responseData => {

        return responseData;

      }),
      catchError(errorRes => {
        // Send to analytics server
        console.error('addBulkTpLinks catchError: ' + errorRes);
        return errorRes;
      })
    );


  }
 // Transactions REST



fetchEligibilityRequests(searchStr: string) {
  console.log('Fetch EligibilityRequest with Auth for: ' + searchStr );

  let url = transUrl + 'EligibilityBenefits';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  console.log('ElgBen: ' + url)
  return this.http2
    .get<{ [key: string]: EligibilityRequest }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const EligibilityRequestArray: EligibilityRequest[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
             EligibilityRequestArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return TP array: ' + EligibilityRequestArray.length );
        return EligibilityRequestArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchEligibilityRequest catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchClaims(searchStr: string) {
  console.log('Fetch Claim with Auth ' );

  let url = transUrl + 'Claims';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  return this.http2
    .get<{ [key: string]: Claim }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimArray: Claim[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim array: ' + ClaimArray.length );
        return ClaimArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaims catchError: ' + errorRes);
        return errorRes;
      })
    );

}
fetchClaimStatusReq(searchStr: string) {
  console.log('Fetch Claim Status Response with Auth ' );

  let url = transUrl + 'ClaimStatusRequest';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  return this.http2
    .get<{ [key: string]: ClaimStatusReq }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimStatusReqArray: ClaimStatusReq[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimStatusReqArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim Status Resp array: ' + ClaimStatusReqArray.length );
        return ClaimStatusReqArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimStatusResp catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchClaimStatusResp(searchStr: string) {
  console.log('Fetch Claim Status Response with Auth ' );

  let url = transUrl + 'ClaimStatusResponse';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  return this.http2
    .get<{ [key: string]: ClaimStatusResp }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimStatusRespArray: ClaimStatusResp[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimStatusRespArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim Status Resp array: ' + ClaimStatusRespArray.length );
        return ClaimStatusRespArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimStatusResp catchError: ' + errorRes);
        return errorRes;
      })
    );

}


fetchEligibilityBenefitResponses(searchStr: string) {
  console.log('Fetch Eligibility Benefit Responses with Auth ' + searchStr);

  let url = transUrl + 'EligibilityBenefitResponses';
  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }

  return this.http2
    .get<{ [key: string]: EligibilityRequest }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const EligibilityRequestArray: EligibilityRequest[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            EligibilityRequestArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim Status Resp array: ' + EligibilityRequestArray.length );
        return EligibilityRequestArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchEligibilityBenefitResponses catchError: ' + errorRes);
        return errorRes;
      })
    );

}


fetchClaimPayment(searchStr: string) {
  console.log('Fetch Claim Status Response with Auth ' );

  let url = transUrl + 'ClaimPayment';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  return this.http2
    .get<{ [key: string]: ClaimPayment }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimPaymentArray: ClaimPayment[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimPaymentArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim Status Resp array: ' + ClaimPaymentArray.length );
        return ClaimPaymentArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimPayment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchImplementationAcknowledgment(searchStr: string) {
  console.log('Fetch Claim Status Response with Auth ' );

  let url = transUrl + 'ImplementationAcknowledgment';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  return this.http2
    .get<{ [key: string]: ImplementationAcknowledgment }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ImplementationAcknowledgmentArray: ImplementationAcknowledgment[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ImplementationAcknowledgmentArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim Status Resp array: ' + ImplementationAcknowledgmentArray.length );
        return ImplementationAcknowledgmentArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimPayment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchClaimAcknowledgment(searchStr: string) {
  console.log('Fetch Claim Status Response with Auth ' );

  let url = transUrl + 'ClaimAcknowledgment';

  if(searchStr.length > 0)
  {
    url = url + "?searchStr=" + searchStr;
  }
  return this.http2
    .get<{ [key: string]: ClaimAcknowledgment }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimAcknowledgmentArray: ClaimAcknowledgment[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimAcknowledgmentArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Claim Status Resp array: ' + ClaimAcknowledgmentArray.length );
        return ClaimAcknowledgmentArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimPayment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchTransactionFields() {
  console.log('Fetch TransactionFields with Auth ' );

  let url = transUrl + 'TransactionFields';


  return this.http2
    .get<{ [key: string]: Claim }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        return responseData;

      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchTransactionFields catchError: ' + errorRes);
        return errorRes;
      })
    );

}



fetchDisplayColumns() {


  let url = transUrl + 'DisplayColumns?userNm=' +  this.getCurrentUser();

  console.log('Fetch DisplayColumns from  ' + url);
  return this.http2
    .get<{ [key: string]: DisplayColumns }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const dispArray: DisplayColumns[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            dispArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return Display array: ' + dispArray.length );
        return dispArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchTransactionFields catchError: ' + errorRes);
        return errorRes;
      })
    );

}

saveDisplayColumns(dispCol: DisplayColumnsArray)
{
  dispCol.User =  this.getCurrentUser();
  console.log('saveDisplayColumns ' +  this.getCurrentUser());

  let url = transUrl + 'SaveDisplayColumns';

  console.info('Post to SaveDisplayColumns: ' + url +" for " + dispCol.User);

  return this.http.post<any>(url, dispCol)
  .pipe(
    map(responseData => {
      console.info(responseData);

      return responseData;

    }),
    catchError(errorRes => {
      // Send to analytics server
      console.error('saveDisplayColumns catchError: ' + errorRes);
      return errorRes;
    })
  );

}

fetchParentRecord(id: string, trans: string) {


  let url = transUrl + "GetParentX12?id=" + id +"&transType=" + trans;

  console.log('Fetch Parent X12 ' + url);
  return this.http2.get<{ [key: string]: ImplementationAcknowledgment }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info("responseData: " + responseData);

        if(responseData !== undefined && responseData[0] !== undefined)
        {

          console.info('return Parent X12 : ' + responseData[0].id );
          return responseData[0];
        }
        else
        {
          console.info('No data from service');
          return "No data";
        }

      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimPayment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

openRelated2701Model(trans:string, cRefId: string, dRefId : string,
  InterchangeSenderID : string,
  InterchangeReceiverID: string,
  InterchangeControlNumber: string)
  {

    let url = transUrl + "GetRelatedEligBenefit?transType="+trans+"&C1TRN1RefId="
    + cRefId+"&D1TRN1RefId="+dRefId+"&InterchangeSenderID="+InterchangeSenderID+"&InterchangeReceiverID="
    +InterchangeReceiverID+"&InterchangeControlNumber="+InterchangeControlNumber;

    console.log('Fetch 27x X12 ' + url);
    return this.http2
      .get<{ [key: string]: any }>(
        url
      )

      .pipe(
        map(responseData => {
          console.info(responseData);

          return responseData[0];


        }),

        catchError(errorRes => {
          // Send to analytics server
          console.error('In openRelated27xModel catchError: ' + errorRes);
          return errorRes;
        })
      );
  }


openRelated2767Model(trans:string, cRefId: string, dRefId : string,
  InterchangeSenderID : string,
  InterchangeReceiverID: string,
  InterchangeControlNumber: string)
  {

    let url = transUrl + "GetRelatedClaimStatus?transType="+trans+"&C1TRN1RefId="
    + cRefId+"&D1TRN1RefId="+dRefId+"&InterchangeSenderID="+InterchangeSenderID+"&InterchangeReceiverID="
    +InterchangeReceiverID+"&InterchangeControlNumber="+InterchangeControlNumber;

    console.log('Fetch 27x X12 ' + url);
    return this.http2
      .get<{ [key: string]: any }>(
        url
      )

      .pipe(
        map(responseData => {
          console.info(responseData);

          return responseData[0];


        }),

        catchError(errorRes => {
          // Send to analytics server
          console.error('In openRelated27xModel catchError: ' + errorRes);
          return errorRes;
        })
      );
  }

fetchGetRelatedTransaction(trans: string, grpId: string, InterchangeSenderID : string,
 InterchangeReceiverID : string,
  InterchangeControlNumber : string) {


  let url = transUrl + "GetRelatedTransaction?GroupControlNumber="
  + grpId+"&transType="+trans+"&InterchangeSenderID="+InterchangeSenderID+"&InterchangeReceiverID="
  +InterchangeReceiverID+"&InterchangeControlNumber="+InterchangeControlNumber;

  console.log('Fetch 999 X12 ' + url);
  return this.http2
    .get<{ [key: string]: EligibilityRequest }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        return responseData[0];


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchGetRelatedTransaction catchError: ' + errorRes);
        return errorRes;
      })
    );

}

openRelated83xModel(trans: string,
  ClaimSubmittersIdentifier : string, MonetaryAmount :  string)
  {


 let url = transUrl + "GetRelatedClaimInfo?transType="+trans+"&ClaimSubmittersIdentifier="+ClaimSubmittersIdentifier
 + "&MonetaryAmount="+MonetaryAmount;

 console.log('Fetch 83x X12 ' + url);
 return this.http2
   .get<{ [key: string]: Claim }>(
     url
   )

   .pipe(
     map(responseData => {
       console.info(responseData);

       return responseData[0];


     }),

     catchError(errorRes => {
       // Send to analytics server
       console.error('In openRelated83xModel catchError: ' + errorRes);
       return errorRes;
     })
   );


}
openRelatedClaimAckModel(trans: string,
  ClaimSubmittersIdentifier : string)
  {


 let url = transUrl + "GetRelatedClaimAck?transType="+trans+"&ClaimSubmittersIdentifier="+ClaimSubmittersIdentifier;

 console.log('Fetch 277CA X12 ' + url);
 return this.http2
   .get<{ [key: string]: Claim }>(
     url
   )

   .pipe(
     map(responseData => {
       console.info(responseData);

       return responseData[0];

     }),

     catchError(errorRes => {
       // Send to analytics server
       console.error('In openRelatedClaimAckModel catchError: ' + errorRes);
       return errorRes;
     })
   );


}


  }



