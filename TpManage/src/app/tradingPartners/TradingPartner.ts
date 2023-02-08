export interface TradingPartner {
  isSelected: boolean;
  tpid: string;
  Name: string;
  TPtype: string;
  ContactName: string;
  ContactPhone: string;
  ContactEmail: string;
  isEdit: boolean;
}

export const TradingPartnerColumns = [
   {
    key: 'Name',
    type: 'text',
    label: 'Trading Partner',
    required: true,
  },
  {
    key: 'TPtype',
    type: 'text',
    label: 'Trading Type',
    required: true,
  },
  {
    key: 'ContactName',
    type: 'text',
    label: 'Contact Name',
  },
  {
    key: 'ContactPhone',
    type: 'string',
    label: 'Phone',
    required: true,
  },
  {
    key: 'ContactEmail',
    type: 'text',
    label: 'Email',
    pattern: '.+@.+'
  },
  {
    key: 'isEdit',
    type: 'isEdit',
    label: '',
  },
];
