import {CommonColumns, CommonColumnsDisplayColumns} from './CommonColumns';

export interface ClaimStatusReq extends CommonColumns {

  TransactionSetControlNumber: string;
  VersionReleaseIndustryIdenti: string;
  loop2100DNM1NameFirst	: string;
  loop2100DNM1NameLastorOrganizationName: string;
  loop2000C1TRN1RefId: string;
  	loop2200D1DTPDateTimePeriod	: string;
    loop2200D1REF1RefId	: string;
    loop2200D1REF2RefId	: string;
    loop2200D1TRNRefId: string;
    loop2200E1TRNRefId: string;
    X12DataParentId: string;
  x12Data: string;
}

