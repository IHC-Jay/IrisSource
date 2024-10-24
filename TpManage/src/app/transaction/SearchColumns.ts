export interface SearchColumns  {
  id: string;
  TransactionCode: string;
  key: string;
  Setting: string;
  Mode: string;
}

export interface SearchColumnsArray {
  SearchColumns: SearchColumns [];
  User: string;
}
