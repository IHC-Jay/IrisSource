// app.module.ts

import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { Routes, RouterModule } from '@angular/router';
import { formatDate} from '@angular/common'

import { AppComponent } from './app.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { MatPaginatorModule } from '@angular/material/paginator';

import { MatTableModule } from '@angular/material/table';
import { MatListModule } from '@angular/material/list';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatSort, MatSortModule } from '@angular/material/sort';

import { HTTP_INTERCEPTORS, provideHttpClient, withInterceptorsFromDi } from '@angular/common/http';

import { MatTabsModule } from '@angular/material/tabs';
import { MatCard, MatCardModule } from '@angular/material/card';
import { AppRoutingModule } from './app-routing.module';
import { HeaderComponent } from './header/header.component';

import { TpRestServiceComponent } from './services/tprest-service.component';
import { TransRestServiceComponent } from './services/transrest-service.component';
import { TradingPartnersComponent } from './tradingPartners/tradingPartners.component';
import { AddEditTP } from './tradingPartners/add-edit.TP';
import { ConfirmDialogComponent } from './confirm-dialog/confirm-dialog.component';
import { MatInputModule } from '@angular/material/input';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import {MatSelectModule} from '@angular/material/select';
import {MatTooltipModule} from '@angular/material/tooltip';
import { MatMenu, MatMenuTrigger } from '@angular/material/menu';


import { MatDialogModule } from '@angular/material/dialog';
import { TpIdComponent } from './tradingPartners/tpIds/tpIds.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { AddEditComponent } from './tradingPartners/tpIds/tp-links/add-edit.component';
import { tpLinksComponent } from './tradingPartners/tpIds/tp-links/tp-links.component';
import { SearchComponent } from './search/search.component';
import {TransactionComponent} from './transaction/transaction.component'
import {AuthInterceptor} from './login/auth-interceptor';
import {ErrorInterceptor} from './login/error.interceptor';

import { TransactionDetailComponent } from './transaction/transaction-details/transaction-details.component';
import { NgMultiSelectDropDownModule } from 'ng-multiselect-dropdown';
import {MatExpansionModule, MatExpansionPanel} from '@angular/material/expansion';
import { ModalErpComponent } from './transaction/transaction-details/modal/modal-erp.component';
import { ModalHelperService } from './transaction/transaction-details/modal/modal-helper.service';

import {MatNativeDateModule} from '@angular/material/core';
import { MatDatepickerModule, MatDatepicker, MatDateRangePicker} from '@angular/material/datepicker';

import { AngularSplitModule } from 'angular-split';
import { WorkflowComponent } from './workflow/workflow.component';
import {WorkflowDetailsComponent} from './workflow/workflowDetails/workflowDetails.component';

@NgModule({ declarations: [
        AppComponent,
        HeaderComponent,
        TpRestServiceComponent,
        TransRestServiceComponent,
        TradingPartnersComponent,
        AddEditTP,
        ConfirmDialogComponent,
        TpIdComponent,
        tpLinksComponent,
        AddEditComponent,
        SearchComponent,
        TransactionComponent,
        ModalErpComponent,
        TransactionDetailComponent,
        WorkflowComponent,
        WorkflowDetailsComponent
    ],
    exports: [
        MatTableModule,
        MatSortModule,
        MatPaginatorModule
    ],
    bootstrap: [AppComponent], imports: [BrowserModule,
        BrowserAnimationsModule,
        MatMenuModule,
        MatTableModule,
        MatPaginatorModule,
        MatListModule,
        MatButtonModule,
        MatTabsModule,
        MatCheckboxModule,
        MatDialogModule,
        AppRoutingModule,
        MatButtonModule,
        MatIconModule,
        FormsModule,
        ReactiveFormsModule,
        MatSortModule,
        MatSelectModule,
        MatFormFieldModule,
        MatInputModule,
        MatTooltipModule,
        NgMultiSelectDropDownModule.forRoot(),
        MatExpansionModule,
        MatNativeDateModule,
        MatDatepickerModule,
        AngularSplitModule,
        MatCardModule,
        ], providers: [
        { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
        { provide: HTTP_INTERCEPTORS, useClass: ErrorInterceptor, multi: true },
        ModalHelperService,
        provideHttpClient(withInterceptorsFromDi())
    ] })
export class AppModule {

public cors = require('cors');


 }
