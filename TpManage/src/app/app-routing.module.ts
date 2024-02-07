import { Component, NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { HeaderComponent } from './header/header.component';
import { AuthGuard } from './login/auth.guard';
import { TradingPartnersComponent } from './tradingPartners/tradingPartners.component';
import { TpIdComponent } from './tradingPartners/tpIds/tpIds.component';
import { tpLinksComponent } from './tradingPartners/tpIds/tp-links/tp-links.component';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule } from '@angular/forms';
import {AddEditComponent} from './tradingPartners/tpIds/tp-links/add-edit.component';
import {BulkAddComponents} from './tradingPartners/tpIds/tp-links/bulk-add.components';
import { SearchComponent } from './search/search.component';
import {TransactionComponent} from './transaction/transaction.component'
import {TransactionDetailComponent} from './transaction/transaction-details/transaction-details.component';



const appRoutes: Routes = [
  {path: 'TradingPartners', component: TradingPartnersComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/:tpId', component: TpIdComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/:tpId', component: tpLinksComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/tp-add/:tp', component: AddEditComponent, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/tp-bulkAdd/:tp', component: BulkAddComponents, canActivate: [AuthGuard]},
  {path: 'TradingPartners/tpIds/tp-links/tp-edit/:tpId/:tpLink', component: AddEditComponent, canActivate: [AuthGuard]},
  {path: 'search', component: SearchComponent, canActivate: [AuthGuard]},
  {path: 'transaction', component: TransactionComponent, canActivate: [AuthGuard]},
  {path: 'transaction/transaction-details', component: TransactionDetailComponent, canActivate: [AuthGuard]}
];

@NgModule({
imports: [BrowserModule,
  ReactiveFormsModule,
  RouterModule.forRoot(appRoutes)],
exports: [RouterModule]
})

export class AppRoutingModule{

}
