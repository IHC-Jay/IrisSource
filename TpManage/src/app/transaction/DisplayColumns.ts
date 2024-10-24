export interface DisplayColumns {
  id: string;
  TransactionCode: string;
  key: string;
  Order: number;
  Setting: string;
  Mode: string;
}

export interface DisplayColumnsArray {
  displayColumns: DisplayColumns[];
  User: string;
}
