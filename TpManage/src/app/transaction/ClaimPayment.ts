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
 loop21001NM11NameFirst	: string;
 loop21001NM11NameLastorOrganizationName	: string;

  x12Data: string;
}

