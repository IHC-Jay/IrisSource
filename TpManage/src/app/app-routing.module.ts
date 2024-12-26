import { Component, NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HeaderComponent } from './header/header.component';
import { AuthGuard } from './login/auth.guard';
import { TradingPartnersComponent } from './tradingPartners/tradingPartners.component';
import { copyTPComponent } from './tradingPartners/copyTP.component';
import { TpIdComponent } from './tradingPartners/tpIds/tpIds.component';
import { tpLinksComponent } from './tradingPartners/tpIds/tp-links/tp-links.component';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule } from '@angular/forms';
import {AddEditComponent} from './tradingPartners/tpIds/tp-links/add-edit.component';
import {BulkAddComponents} from './tradingPartners/tpIds/tp-links/bulk-add.components';
import { SearchComponent } from './search/search.component';
import {TransactionComponent} from './transaction/transaction.component'
import {TransactionDetailComponent} from './transaction/transaction-details/transaction-details.component';
import {TransactionSettingsComponent} from "./transaction/transaction-settings/transaction-settings.component"
import { WorkflowComponent } from './workflow/workflow.component';
import {WorkflowDetailsComponent} from './workflow/workflowDetails/workflowDetails.component';


const appRoutes: Routes = [
  {path: '/', component: HeaderComponent},
  {path: 'TradingPartners', component: TradingPartnersComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/copyTP', component: copyTPComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/:tpId', component: TpIdComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/:tpId', component: tpLinksComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/tp-add/:tp', component: AddEditComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/tp-bulkAdd/:tp', component: BulkAddComponents, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/tp-edit/:tpId/:tpLink', component: AddEditComponent, canActivate: [AuthGuard]},
  {path: 'search', component: SearchComponent, canActivate: [AuthGuard]},
  {path: 'transaction', component: TransactionComponent, canActivate: [AuthGuard]},
  {path: 'transaction/transaction-settings', component: TransactionSettingsComponent, canActivate: [AuthGuard]},
  {path: 'transaction/transaction-details', component: TransactionDetailComponent, canActivate: [AuthGuard]},
  {path: 'workflow', component: WorkflowComponent, canActivate: [AuthGuard]},
  {path: 'workflow/workflowDetails', component: WorkflowDetailsComponent, canActivate: [AuthGuard]}
];

@NgModule({
imports: [BrowserModule,
  ReactiveFormsModule,
  RouterModule.forRoot(appRoutes)],
exports: [RouterModule]
})

export class AppRoutingModule{

}
