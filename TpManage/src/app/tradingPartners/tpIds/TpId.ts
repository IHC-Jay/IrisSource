export interface TpId {
  isSelected: boolean;
  id: string;
  Name: string;
  TPID: string;
  Type: string;
  isEdit: boolean;
}

export const TpIdColumns = [

  {
    key: 'Name',
    type: 'string',
    label: 'Description',
    required: true,
    help: 'TP Name'
  },
  {
    key: 'TPID',
    type: 'string',
    label: 'TPID',
    required: true,
    help:'TPID value in X12 message'
  },
  {
    key: 'Type',
    type: 'drop',
    label: 'X12 Segment',
    help: 'Value used in ISA, GS or BOTH segments'
  },
  {
    key: 'isEdit',
    type: 'isEdit',
    label: '',
    help:''
  }
];
