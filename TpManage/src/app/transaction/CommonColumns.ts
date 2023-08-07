export interface CommonColumns {
  isSelected: boolean;
  isTableExpanded:boolean;
  id: string;
  ApplicationReceiversCode: string;
  ApplicationSendersCode: string;
  BHTRefId: string;
  FileName: string;
  GroupControlNumber: string;
  InterchangeControlNumber: string;
  InterchangeDate: string;
  InterchangeReceiverID: string;
  InterchangeSenderID: string;
  InterchangeTime: string;
  ProcessDtTm: string;
  SegmentNum: string;
  Status: string;
}

export const CommonColumnsDisplayColumns = [
  {key: 'InterchangeControlNumber',
  type: 'text',
  label:'Interchange ControlNumber'},
  {key: 'InterchangeSenderID',
  type: 'text',
  label:'Interchange SenderID'},
  {key: 'InterchangeReceiverID',
  type: 'text',
  label:'Interchange ReceiverID'},
  {key: 'InterchangeDate',
  type: 'text',
  label:'InterchangeDate'},
  {key: 'InterchangeTime',
  type: 'text',
  label:'InterchangeTime'},
  {key: 'ProcessDtTm',
  type: 'text',
  label:'ProcessDtTm'},
  {key: 'GroupControlNumber',
  type: 'text',
  label:'GroupControlNumber'},

  {key: 'ApplicationSendersCode',
  type: 'text',
  label:'ApplicationSendersCode'},
  {key: 'ApplicationReceiversCode',
  type: 'text',
  label:'ApplicationReceiversCode'},
  {key: 'BHTRefId',
  type: 'text',
  label:'Batch Control Number'},
  {key: 'Status',
  type: 'text',
  label:'Status'},
  {key: 'FileName',
  type: 'text',
  label:'FileName'}

];
