export interface CommonColumns {
  isSelected: boolean;
  isTableExpanded:boolean;
  id: string;
  CaseNumber: string;
  ItemNumber: string;

  hl7Data: string;

  ProcessDtTm: string;

}

export const CommonColumnsDisplayColumns = [
{key: 'MessageType',
  Order: '1',
  label:'Message Type', TransactionCode: 'All', detail: 'NA'},
  {key: 'ProcessDtTm',
  Order: '2',
  label:'Process Date Time', TransactionCode: 'All', detail: 'NA'},
  {key: 'CaseNumber',
  Order: '3',
  label:'Case Number', TransactionCode: 'All', detail: 'Y'},
  {key: 'ItemNumber',
  Order: '4',
  label:'Item Number', TransactionCode: 'All', detail: 'NA'},

  {key: 'PurchaseOrder',
  Order: '5',
  label:'Purchase Order', TransactionCode: 'All', detail: 'NA'},
  {key: 'MedicalRecordNumber',
  Order: '6',
  label:'Medical Record Number', TransactionCode: 'All', detail: 'NA'},

  {key: 'PatientAccount',
  Order: '7',
  label:'Patient Account', TransactionCode: 'All', detail: 'NA'},
  {key: 'MessageControlId',
  Order: '8',
  label:'Message Control ID', TransactionCode: 'All', detail: 'Y'},
  {key: 'SessionID',
  Order: '9',
  label:'Session ID', TransactionCode: 'All', detail: 'Y'},
  {key: 'SequenceID',
  Order: '10',
  label:'Sequence ID', TransactionCode: 'All', detail: 'Y'},
  {key: 'TriggerName',
  Order: '11',
  label:'Trigger Name', TransactionCode: 'All', detail: 'NA'},
  {key: 'SendingApplication',
  Order: '12',
  label:'Sending Application', TransactionCode: 'All', detail: 'NA'},
   {key: 'ReceivingApplication',
  Order: '13',
  label:'Receiving Application', TransactionCode: 'All', detail: 'NA'},
   {key: 'SendingFacility',
  Order: '14',
  label:'Sending Facility', TransactionCode: 'All', detail: 'NA'},
   {key: 'ReceivingFacility',
  Order: '15',
  label:'Receiving Facility', TransactionCode: 'All', detail: 'NA'},


];
