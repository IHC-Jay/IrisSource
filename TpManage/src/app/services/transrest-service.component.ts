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
import { formatDate } from '@angular/common';
import { LOCALE_ID, NgModule } from '@angular/core';
import { environment } from '../../environments/environment';

import { Inject } from "@angular/core";


import {TransactionData} from '../transaction/TransactionData'


import {WorkFlowEntry, IrisUsers} from '../workflow/WorkFlowEntry';
import { transition } from '@angular/animations';
import { AuthenticationService } from './authentication.service';
import {TpRestServiceComponent} from './tprest-service.component';

import {DisplayColumns, DisplayColumnsArray} from '../transaction/DisplayColumns';
import {SearchColumns, SearchColumnsArray} from '../transaction/SearchColumns';
import { Router, ActivatedRoute} from '@angular/router';
import {User} from '../login/user';



@Injectable({ providedIn: 'root' })

@Component({
  selector: 'app-rest-service',
  templateUrl: './rest-service.component.html'
})

export class TransRestServiceComponent {

   rtTransUrl = `${environment.rtDevTransUrl}`;
   batchTransUrl = `${environment.batchDevTransUrl}`;
   authenticationService: AuthenticationService;

  error = new Subject<string>();
  currentUser: string = "";
  env: string = "";

  constructor(private http: HttpClient, private http2: HttpClient
    , private router: Router, @Inject(LOCALE_ID) public locale: string, private tpService: TpRestServiceComponent)
   {
    console.log('**** TransRestServiceComponent RestServiceComponent constructor ****');
   }

 // Transactions REST

setcurrentUser(currentUser : string, env: string, authService: AuthenticationService)
{
  this.currentUser = currentUser;
  this.env = env;
  this.authenticationService = authService;
  console.debug("Set User,env,auth " + authService)

  if(env == 'QA')
  {
    this.rtTransUrl = `${environment.rtQaTransUrl}`;
    this.batchTransUrl = `${environment.batchQaTransUrl}`;
  }
}


getCurrentUser()
{
  console.log('Fetch getCurrentUser from authenticationService ' + this.authenticationService)

     if( this.currentUser === '')
     {
      this.currentUser = this.authenticationService.getUserName()
     }
     if (this.currentUser == '')
      {
        console.log('** ERROR SET MY NAME **')
        this.authenticationService.logout();
        sessionStorage.clear();
        this.router.navigate(['/']);
      }
     console.log('Return getCurrentUser: ' + this.currentUser);

}

fetchEligibilityRequests(mode: string, searchArr: string[]) {
  if( this.currentUser === '')
    {
      this.getCurrentUser()
    }
  console.log( this.env + ' - Fetch EligibilityRequest with Auth ' + this.currentUser);

  let url = this.batchTransUrl + 'EligibilityBenefits?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'EligibilityBenefits?searchStr=' + searchArr;
  }

  console.log('ElgBen: ' + url)
  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const EligibilityRequestArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
             EligibilityRequestArray.push({ ...responseData[key], value: responseData[key].value });
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

fetchEligibilityBenefitResponses(mode: string, searchArr: string[]) {


  let url = this.batchTransUrl + 'EligibilityBenefitResponses?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'EligibilityBenefitResponses?searchStr=' + searchArr;
  }
  console.log('Fetch Eligibility Benefit Responses with Auth ' + url);
  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const EligibilityResponseArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            EligibilityResponseArray.push({ ...responseData[key], value: responseData[key].value });
          }
        }
        console.info('return Claim Status Resp array: ' + EligibilityResponseArray.length );
        return EligibilityResponseArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchEligibilityBenefitResponses catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchClaims(mode: string, searchArr: string[]) {
  console.log('Fetch Claim with Auth ' );

  let url = this.batchTransUrl + 'Claims?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'Claims?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimArray.push({ ...responseData[key], value: responseData[key].value });
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
fetchClaimStatusReq(mode: string, searchArr: string[]) {
  console.log('Fetch Claim Status Req with Auth ' );

  let url = this.batchTransUrl + 'ClaimStatusRequest?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'ClaimStatusRequest?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimStatusReqArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimStatusReqArray.push({ ...responseData[key], value: responseData[key].value });
          }
        }
        console.info('return Claim Status Req array: ' + ClaimStatusReqArray.length );
        return ClaimStatusReqArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimStatusReq catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchClaimStatusResp(mode: string, searchArr: string[]) {
  console.log('Fetch Claim Status Response with Auth ' );

  let url = this.batchTransUrl + 'ClaimStatusResponse?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'ClaimStatusResponse?searchStr=' + searchArr;
  }
  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimStatusRespArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimStatusRespArray.push({ ...responseData[key], value: responseData[key].value });
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




fetchClaimPayment(mode: string, searchArr: string[]) {
  console.debug('fetchClaimPayment ')

  let url = this.batchTransUrl + 'ClaimPayment?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'ClaimPayment?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    ).pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimPaymentArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimPaymentArray.push({ ...responseData[key], value: responseData[key].value });
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

fetchImplementationAcknowledgment(mode: string, searchArr: string[]) {
  console.log('Fetch Implementation Acknowledgment with Auth ' );

  let url = this.batchTransUrl + 'ImplementationAcknowledgment?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'ImplementationAcknowledgment?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData}>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ImplementationAcknowledgmentArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ImplementationAcknowledgmentArray.push({ ...responseData[key], value: responseData[key].value });
          }
        }
        console.info('return Claim Status Resp array: ' + ImplementationAcknowledgmentArray.length );
        return ImplementationAcknowledgmentArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchImplementationAcknowledgment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchTA1 (mode: string, searchArr: string[]) {
  console.log('Fetch TA1 with Auth ' );

  let url = this.batchTransUrl + 'GetTA1?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'GetTA1?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData}>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const TA1Array: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            TA1Array.push({ ...responseData[key], value: responseData[key].value });
          }
        }
        console.info('return Claim Status Resp array: ' + TA1Array.length );
        return TA1Array;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchImplementationAcknowledgment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchInterchangeAcknowledgment(mode: string, searchArr: string[]) {
  console.log('Fetch Interchange Ack with Auth ' );

  let url = this.batchTransUrl + 'InterchangeAcknowledgment?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'InterchangeAcknowledgment?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const InterchangeAcknowledgmentArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            InterchangeAcknowledgmentArray.push({ ...responseData[key], value: responseData[key].value });
          }
        }
        console.info('return Claim Status Resp array: ' + InterchangeAcknowledgmentArray.length );
        return InterchangeAcknowledgmentArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchInterchangeAcknowledgment catchError: ' + errorRes);
        return errorRes;
      })
    );

}
fetchClaimAcknowledgment(mode: string, searchArr: string[]) {
  console.log('Fetch Claim Ack with Auth ' );
  let url = this.batchTransUrl + 'ClaimAcknowledgment?searchStr=' + searchArr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'ClaimAcknowledgment?searchStr=' + searchArr;
  }

  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const ClaimAcknowledgmentArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            ClaimAcknowledgmentArray.push({ ...responseData[key], value: responseData[key].value });
          }
        }
        console.info('return Claim Status Resp array: ' + ClaimAcknowledgmentArray.length );
        return ClaimAcknowledgmentArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchClaimAcknowledgment catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchTransactionFields() {
  console.log('Fetch TransactionFields with Auth ' + this.getCurrentUser() );

  let url = this. batchTransUrl + 'TransactionFields';


  return this.http2
    .get<{ [key: string]: TransactionData }>(
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

  if(this.currentUser === '')
  {
    this.getCurrentUser()
  }

  let url = this.batchTransUrl + 'DisplayColumns?userNm=' +  this.currentUser;

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
  dispCol.User =  this.currentUser;
  console.log('saveDisplayColumns ' +  this.currentUser);

  let url = this. batchTransUrl + 'SaveDisplayColumns';

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

deleteDisplayColumns()
{
  let dispCol = [];

  dispCol[0] = {'User': this.currentUser, 'Setting': this.currentUser};

  console.log('deleteDisplayColumns ' +  this.currentUser);

  let url = this. batchTransUrl + 'DeleteDisplayColumns';

  console.info('Post to DeleteDisplayColumns: ' + url );

  return this.http.post<any>(url,  {'User': this.currentUser, 'Setting': 'Session'})
  .pipe(
    map(responseData => {
      console.info(responseData);

      return responseData;

    }),
    catchError(errorRes => {
      // Send to analytics server
      console.error('deleteDisplayColumns catchError: ' + errorRes);
      return errorRes;
    })
  );

}

fetchSearchColumns() {

  if(this.currentUser === '')
  {
    this.getCurrentUser()
  }

  let url = this.batchTransUrl + 'SearchColumns?userNm=' +  this.currentUser;

  console.log('Fetch SearchColumns from  ' + url);
  return this.http2
    .get<{ [key: string]: SearchColumns }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const dispArray: SearchColumns[] = [];
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

saveSearchColumns(dispCol: SearchColumnsArray)
{
  dispCol.User =  this.currentUser;
  console.log('saveSearchColumns ' +  this.currentUser);

  let url = this. batchTransUrl + 'SaveSearchColumns';

  console.info('Post to SaveSearchColumns: ' + url +" for " + dispCol.User);

  return this.http.post<any>(url, dispCol)
  .pipe(
    map(responseData => {
      console.info(responseData);

      return responseData;

    }),
    catchError(errorRes => {
      // Send to analytics server
      console.error('saveSearchColumns catchError: ' + errorRes);
      return errorRes;
    })
  );

}

deleteSearchColumns()
{
  let dispCol = [];

  dispCol[0] = {'User': this.currentUser, 'Setting': this.currentUser};

  console.log('deleteSearchColumns ' +  this.currentUser);

  let url = this. batchTransUrl + 'DeleteSearchColumns';

  console.info('Post to DeleteSearchColumns: ' + url );

  return this.http.post<any>(url,  {'User': this.currentUser, 'Setting': 'Session'})
  .pipe(
    map(responseData => {
      console.info(responseData);

      return responseData;

    }),
    catchError(errorRes => {
      // Send to analytics server
      console.error('deleteSearchColumns catchError: ' + errorRes);
      return errorRes;
    })
  );

}

fetchParentRecord(id: string, trans: string, searchTypeString: string) {


  let url = this. rtTransUrl + "GetParentX12?id=" + id +"&transType=" + trans;

  if(searchTypeString.indexOf("Batch") >= 0)
  {
    url = this. batchTransUrl + "GetParentX12?id=" + id +"&transType=" + trans;
  }

  console.log('Fetch Parent X12 ' + url);
  return this.http2.get<{ [key: string]: TransactionData}>(
      url
    )

    .pipe(
      map(responseData => {
        console.info("responseData: " + responseData);

        if(responseData !== undefined && responseData[0] !== undefined)
        {

          console.info('return Parent X12 : ' + responseData[0].value );
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
        console.error('In fetchParentRecord catchError: ' + errorRes);
        return errorRes;
      })
    );

}

openRelated2701Model(trans:string, TrnRefId: string, SubscriberId : string,
  InterchangeSenderID : string,
  InterchangeReceiverID: string,
  InterchangeControlNumber: string, searchTypeString: string)
  {

    let url = this. rtTransUrl
    if(searchTypeString.indexOf("Batch") >= 0)
    {
       url = this. batchTransUrl
    }

    url = url + "GetRelatedEligBenefit?transType="+trans+"&SubscriberId="
    + SubscriberId +"&TrnRefId="+TrnRefId+"&InterchangeSenderID="+InterchangeSenderID+"&InterchangeReceiverID="
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


openRelated2767Model(trans:string, SubscriberId: string, BhtId : string, TrnRefId: string,
  InterchangeSenderID : string,
  InterchangeReceiverID: string,
  InterchangeControlNumber: string, searchTypeString: string)
  {

    let url = this. rtTransUrl
    if(searchTypeString.indexOf("Batch") >= 0)
    {
       url = this. batchTransUrl
    }

    url = url + "GetRelatedClaimStatus?transType="+trans+"&SubscriberId="
    + SubscriberId+"&BhtId="+BhtId+"&TrnRefId="+TrnRefId+"&InterchangeSenderID="+InterchangeSenderID+"&InterchangeReceiverID="
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
  InterchangeControlNumber : string, searchTypeString: string) {

    let url = this. rtTransUrl
    if(searchTypeString.indexOf("Batch") >= 0)
    {
       url = this. batchTransUrl
    }

  url = url + "GetRelatedTransaction?GroupControlNumber="
  + grpId+"&transType="+trans+"&InterchangeSenderID="+InterchangeSenderID+"&InterchangeReceiverID="
  +InterchangeReceiverID+"&InterchangeControlNumber="+InterchangeControlNumber;

  console.log('Fetch 999 X12 ' + url);
  return this.http2
    .get<{ [key: string]: TransactionData }>(
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


     let url = this. batchTransUrl + "GetRelatedClaimInfo?transType="+trans+"&ClaimSubmittersIdentifier="+ClaimSubmittersIdentifier
 + "&MonetaryAmount="+MonetaryAmount;

 console.log('Fetch 83x X12 ' + url);
 return this.http2
   .get<{ [key: string]: TransactionData }>(
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

    let url = this. batchTransUrl + "GetRelatedClaimAck?transType="+trans+"&ClaimSubmittersIdentifier="+ClaimSubmittersIdentifier;

 console.log('Fetch 277CA X12 ' + url);
 return this.http2
   .get<{ [key: string]: TransactionData }>(
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

createRestUrl(tranType: string, searchStr: string, searchType: string, maxCnt : Number)
{
  let dateFormat = require('dateformat');
  let dte = new Date();

  let url = this.batchTransUrl
  let dtTm = "";

  if (searchType.startsWith('RT'))
  {
     url = this.rtTransUrl;
  }

  url = url + tranType ;

  if(searchStr.indexOf("id=") >= 0)
  {
    url = url + "?searchStr=" + searchStr +"&count=1"
  }
  else{

    if (searchType.indexOf('24 hour') > 0)
    {
      dte.setDate(dte.getDate() - 1);
    }
    else if (searchType.indexOf('7 day') > 1)
    {
      dte.setDate(dte.getDate() - 7);
    }
    else if (searchType.indexOf('30') > 1){
      dte.setMonth(dte.getMonth() - 1 );

    }
    else {
      dte.setMonth(dte.getMonth() - 3 );

    }
    dtTm = formatDate(dte, 'yyyy-MM-dd hh:mm:ss',this.locale);

    console.log('Fetch ' + tranType + ' with Auth ' + searchType + ", DtTm: " + dtTm + ", return: " + maxCnt);

    if ('WorkFlowEntries' == tranType)
    {
      if(searchStr.length > 0)
      {
        url = url + "?searchStr=TransactionType='" + searchStr + "'&count=" + maxCnt;
      }
      else
      {
        url = url + "?searchStr=&count=" + maxCnt
      }
    }
    else
    {
      if(searchStr.length > 0)
      {
        url = url + "?searchStr=" + searchStr + " and ProcessDtTm > '" + dtTm +"'&count=" + maxCnt;
      }
      else
      {
        url = url + "?searchStr= ProcessDtTm > '" + dtTm +"'&count=" + maxCnt
      }
    }
  }
  console.log('URL: ' + url);
  return url;
}

fetchWorkFlowItems(searchStr: string, statType: string, errType: string, maxCnt : Number, dtRange: string) {
  console.log('Fetch WF entries ' + "dateRange="+dtRange +", Search: " + searchStr +", " + statType + ", " + maxCnt + " for " + this.currentUser);

  let url = this.batchTransUrl + "WorkFlowEntries?searchStr=" + errType +"&TransType=" + searchStr + "&ErrorType=" + statType +"&userNm="+ this.currentUser+ "&count="+maxCnt + "&dateRange="+dtRange;

  return this.http2
    .get<{ [key: string]: WorkFlowEntry }>(
      url
    ).pipe(map(responseData => {
        console.info(responseData);

        const WorkFlowEntriesArray: WorkFlowEntry[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            WorkFlowEntriesArray.push({ ...responseData[key], id: responseData[key].id});
          }
        }
        console.info('return WF array: ' + WorkFlowEntriesArray.length );
        return WorkFlowEntriesArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchWorkFlowEntries catchError: ' + errorRes);
        return errorRes;
      })
    );

}


fetchIrisUsers() {
  console.log('Fetch Users');

  let url = this.batchTransUrl + "GetIrisUsers";

  return this.http2
    .get<{ [key: string]: IrisUsers }>(
      url
    ).pipe(map(responseData => {
        console.info(responseData);

        const UserArray: IrisUsers[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            UserArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return User array: ' + UserArray.length );
        return UserArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchWorkFlowEntries catchError: ' + errorRes);
        return errorRes;
      })
    );

}

fetchWorkFlowEntry(searchStr: string) {
  console.log('Fetch WF Entry with Auth for '+ this.currentUser );

  let url = this.batchTransUrl + 'WorkFlowEntry?' +  searchStr+"&userNm="+ this.currentUser;

  return this.http2
    .get<{ [key: string]: WorkFlowEntry }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const WorkFlowEntriesArray: WorkFlowEntry[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            WorkFlowEntriesArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return WF array: ' + WorkFlowEntriesArray.length );
        return WorkFlowEntriesArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In fetchWorkFlowEntry catchError: ' + errorRes);
        return errorRes;
      })
    );

}



updateWorkFlowItem(id: string, status: string, assignUser: string) {
  console.log('Update WF Entry with Auth as ' + this.currentUser);
  let url = this.batchTransUrl
  if (assignUser !== '')
  {
    url += 'UpdateWorkFlowEntry?id=' + id +"&status=" + status+"&userNm="+ assignUser+"&modUserNm="+ this.currentUser;
  }
  else
  {

    url += 'UpdateWorkFlowEntry?id=' + id +"&status=" + status+"&userNm="+ this.currentUser+"&modUserNm="+ this.currentUser;
  }
  console.log('Update WF Entry: ' + url)

  return this.http2
    .get<{ [key: string]: WorkFlowEntry }>(
      url
    ).pipe(
      map(responseData => {
        console.info(responseData);

        const WorkFlowEntriesArray: WorkFlowEntry[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
            WorkFlowEntriesArray.push({ ...responseData[key], id: responseData[key].id });
          }
        }
        console.info('return updated WF array: ' + WorkFlowEntriesArray.length );
        return WorkFlowEntriesArray;


      }),

      catchError(errorRes => {
        // Send to analytics server
        console.error('In updateWorkFlowEntry catchError: ' + errorRes);
        return errorRes;
      })
    );

}

passArray(mode: string, searchStr: string[]) {
  console.log( this.env + ' - passArray with Auth for: ' + searchStr );

  let url = this.batchTransUrl + 'ReadArray?searchArr=' + searchStr;

  if (mode === 'RealTime')
  {
     url = this.rtTransUrl + 'ReadArray?searchArr=' + searchStr;
  }


  console.log('search URL: ' + url)
  return this.http2
    .get<{ [key: string]: TransactionData }>(
      url
    )

    .pipe(
      map(responseData => {
        console.info(responseData);

        const EligibilityRequestArray: TransactionData[] = [];
        for (const key in responseData) {
          if (responseData.hasOwnProperty(key)) {
             EligibilityRequestArray.push({ ...responseData[key], value: responseData[key].value });
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

}



