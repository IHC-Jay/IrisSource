import {CommonColumns, CommonColumnsDisplayColumns} from './CommonColumns';

export interface EligibilityRequest extends CommonColumns {

  TransactionSetControlNumber: string;
  VersionReleaseIndustryIdenti: string;
  loop2100ANM1IdentificationCode: string;
  loop2100ANM1NameLastorOrganizationName: string;
  loop2100BNM1IdentificationCode: string;
  loop2100BNM1NameLastorOrganizationName: string;
  loop2100CDMGDateTimePeriod: string;
  loop2100CDMGGenderCode: string;
  loop2100CDTP1DateTimePeriod: string;
  loop2100CNM1EntityIdentifierCode: string;
  loop2100CNM1IdentificationCode: string;
  loop2100CNM1NameFirst: string;
  loop2100CNM1NameLastorOrganizationName: string;
  loop2100DDMGDateTimePeriod: string;
  loop2100DDMGGenderCode: string;
  loop2100DNM1NameFirst: string;
  loop2100DNM1NameLastorOrganizationName: string;
  loopCHLHierarchicalChildCode: string;
  loopDHLHierarchicalParentIDNumber: string;
  X12DataParentId: string;
  x12Data: string;
}

export const EligibilityRequestDisplayColumns = [

  {
    key: 'ApplicationSendersCode',
    type: 'text',
    label: 'Application SendersCode'
  },
  {
    key: 'loop2100CNM1NameLastorOrganizationName',
    type: 'text',
    label: 'loop2100C NameLastorOrganizationName'
  },
  {
    key: 'loop2100CNM1IdentificationCode',
    type: 'text',
    label: 'loop2100C NM1IdentificationCode'
  },
  {
    key: 'BHTRefId',
    type: 'text',
    label: 'Batch RefId'
  },
  {
    key: 'loopCHLHierarchicalIDNumber',
    type: 'text',
    label: 'Hierarchical ID'
  },
  {key: 'loopCHLHierarchicalParentIDNumber',
    type: 'text',
    label:'Hierarchical ParentID'},
  {key: 'InterchangeDate',
    type: 'text',
    label:'InterchangeDate'},

    {key: 'loopCHLHierarchicalChildCode',
    type: 'text',
    label:'Has ChildCode'},
{key: 'FileName',
type: 'text',
label:'FileName'}
];
