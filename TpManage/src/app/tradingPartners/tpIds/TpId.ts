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
  },
  {
    key: 'TPID',
    type: 'string',
    label: 'TPID',
    required: true,
  },
  {
    key: 'Type',
    type: 'string',
    label: 'Type',
  },
  {
    key: 'isEdit',
    type: 'isEdit',
    label: '',
  }
];
