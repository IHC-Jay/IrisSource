import {CommonColumns, CommonColumnsDisplayColumns} from './CommonColumns';

export interface ClaimAcknowledgment extends CommonColumns {

  TransactionSetControlNumber: string;
  BHTRefId: string;
  loop2200DSTC1Date	: string;
  loop2200D1REF1RefId: string;
  loop2200D1REF2RefId	: string;
  loop2200D1DTPDateTimePeriod	: string;
  loop2100C2NM1NameLastorOrganizationName	: string;
  loop2100APERName: string;
  loop2200D1TRNRefId	: string;
  loop2100CNM1NameFirst: string;
  loop2100BNM1NameLastorOrganizationName	: string;
  loop2100CDMGDateTimePeriod	: string;
  loop2100CDMGGenderCode	: string;
  loop2100DNM1NameFirst: string;
  loop2100DDMGDateTimePeriod	: string;
  loop2100DDMGGenderCode: string;
  x12Data: string;
}

