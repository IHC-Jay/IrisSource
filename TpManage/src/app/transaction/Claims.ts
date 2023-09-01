import {CommonColumns, CommonColumnsDisplayColumns} from './CommonColumns';

export interface Claim extends CommonColumns {

  TransactionSetControlNumber: string;
  VersionReleaseIndustryIdenti: string;
  loop23001CLMClaimSubmittersIdentifier: string;

  loop23001REF1RefId: string;

  loop23001CLMMonetaryAmount: string;

  loop2010BADMGDateTimePeriod: string;

  loop2310BNM1182NameLastorOrganizationName: string;

  loop2010BANM11ILNameLastorOrganizationName: string;

  loop1000BNM1NameLastorOrganizationName: string;

  loop1000ANM1141NameLastorOrganizationName: string;
  loop1000ANM1141NameFirst: string;

  loop2010AANM1185NameLastorOrganizationName: string;

  loop2010BANM11ILIdentificationCode: string;
  loop2010BANM11ILNameFirst: string;

  loop2310BNM1182IdentificationCode: string;
  x12Data: string;
  loop2010AAREF1RefId: string;
  loop24001DTP1DateTimePeriod: string;
}

