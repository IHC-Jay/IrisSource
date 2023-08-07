import {CommonColumns, CommonColumnsDisplayColumns} from './CommonColumns';

export interface ImplementationAcknowledgment extends CommonColumns {

  TransactionSetControlNumber: string;
  AK1FunctionalIdentifierCode: string;
  AK1GroupControlNumber	: string;
  AK1VersionReleaseIndustryIdenti: string;
  AK9FunctionalGroupAcknowledgeCo	: string;
  AK9NumberofTransactionSetsInclu	: string;
  AK9NumberofAcceptedTransactionS	: string;
  x12Data: string;
}

