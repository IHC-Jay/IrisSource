import {CommonColumns, CommonColumnsDisplayColumns} from './CommonColumns';

export interface ClaimPayment extends CommonColumns {

  loop1000AN11PRName: string;
  loop1000APER1Name: string;
  loop1000BN1Name: string;

  loop1000BREF1RefId: string;

  BPRMonetaryAmount: string;

  BPRPaymentMethodCode: string;

  TRNRefId: string;

  REF1RefId: string;

  DTMDate: string;
   loop21001CLPClaimSubmittersIdentifier : string;

 loop21001CLPMonetaryAmount : string;

 loop21001CLPMonetaryAmount2 : string;

  x12Data: string;
}

