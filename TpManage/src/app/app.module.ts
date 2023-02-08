// app.module.ts

import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { Routes, RouterModule } from '@angular/router';

import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatTableModule } from '@angular/material/table';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatSort, MatSortModule } from '@angular/material/sort';

import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';

import { MatTabsModule } from '@angular/material/tabs';

import { AppRoutingModule } from './app-routing.module';
import { HeaderComponent } from './header/header.component';

import { RestServiceComponent } from './services/rest-service.component';
import { TradingPartnersComponent } from './tradingPartners/tradingPartners.component';
import { ConfirmDialogComponent } from './confirm-dialog/confirm-dialog.component';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import {MatSelectModule} from '@angular/material/select'

import { MatDialogModule } from '@angular/material/dialog';
import { TpIdComponent } from './tradingPartners/tpIds/tpIds.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { AddEditComponent } from './tradingPartners/tpIds/tp-links/add-edit.component';
import { tpLinksComponent } from './tradingPartners/tpIds/tp-links/tp-links.component';
import { SearchComponent } from './search/search.component';
import {AuthInterceptor} from './login/auth-interceptor';
import {ErrorInterceptor} from './login/error.interceptor';


@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    RestServiceComponent,
    TradingPartnersComponent,
    ConfirmDialogComponent,
    TpIdComponent,
    tpLinksComponent,
    AddEditComponent,
    SearchComponent,

  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    MatMenuModule,
    MatTableModule,
    MatPaginatorModule,
    MatListModule,
    MatButtonModule,
    MatTabsModule,
    MatCheckboxModule,
    MatDialogModule,
    HttpClientModule,
    AppRoutingModule,
    MatButtonModule,
    MatIconModule,
    FormsModule,
    ReactiveFormsModule,
    MatSortModule,
    MatSelectModule,
    MatFormFieldModule,
    MatInputModule
  ],
  exports:[
    MatTableModule,
    MatSortModule,
    MatPaginatorModule
  ],
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },

  ],
  bootstrap: [AppComponent]
})
export class AppModule {

public cors = require('cors');


 }
