export interface WorkFlowEntry {
  id: string;
  InterchangeSenderID: string;
  InterchangeReceiverID: string;
  TransactionType: string;
  CreateDtTm: string;
  ResolveDtTm: string;
  WorkStatus: string;
  WorkUser: string;
  ErrorType: string;
  Error: string;
  Resent: string;
  x12Data: string;
}

export interface IrisUsers {
id: string;
UserName: string;
FullName: string;
GrantedRoles: string;
}






