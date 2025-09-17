// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: true,
  org:'RCO',
  tpDevUrl: 'https://itf-webapache-dev.co.ihc.com:8443/EdiRestProv/TpManage/',
  rtDevTransUrl: '',
  batchDevTransUrl: 'https://itf-webapache-dev.co.ihc.com:8443/EdiRestProv/Transactions/',
  batchDevWFUrl:'https://itf-webapache-dev.co.ihc.com:8443/EdiRestProv/WorkFlow/',
  rtDevWFUrl: '',

  tpQaUrl: 'https://itf-webapache-qa.co.ihc.com:8443/EdiRest/TpManage/',
  rtQaTransUrl: 'https://itf-webapache-qa.co.ihc.com:8443/Rest/RtTransactions/',
  batchQaTransUrl: 'https://itf-webapache-qa.co.ihc.com:8443/Rest/BatchTransactions/',

  tpUatUrl: 'https://itf-webapache-test.co.ihc.com:8443/EdiRest/TpManage/',
  rtUatTransUrl: 'https://itf-webapache-test.co.ihc.com:8443/Rest/RtTransactions/',
  batchUatTransUrl: 'https://itf-webapache-test.co.ihc.com:8443/Rest/BatchTransactions/',

  tpType: 'Payer',
  logo:'ih-rco.jpg'

};


