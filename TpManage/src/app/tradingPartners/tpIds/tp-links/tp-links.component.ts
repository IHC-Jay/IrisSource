
import { Component, OnInit, OnDestroy, ViewChild, Inject } from '@angular/core';
import { animate, state, style, transition, trigger } from '@angular/animations';
import { MatTableModule, MatTableDataSource, MatTableDataSourcePaginator } from '@angular/material/table';
import { Router, ActivatedRoute } from '@angular/router';
import { map } from 'rxjs/operators';
import { Subscription } from 'rxjs';
import { tpLinks } from './tp-links';
import { RestServiceComponent } from '../../../services/rest-service.component';
import { Injectable } from '@angular/core';
import * as _ from 'lodash';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort, MatSortHeader } from '@angular/material/sort';
import { RouterLinkWithHref } from '@angular/router';
import { TpId } from '../TpId';
import { TradingPartner } from '../../TradingPartner';
import { MatDialog } from '@angular/material/dialog';
import { ConfirmDialogComponent } from '../../../confirm-dialog/confirm-dialog.component';

@Injectable({
  providedIn: 'root'
})

@Component({
  selector: 'app-tp-links',
  templateUrl: './tp-links.component.html',
  styleUrls: ['./tp-links.component.css'],
  animations: [
    trigger('tpLinkExpand', [
      state('collapsed', style({ height: '0px', minHeight: '0' })),
      state('expanded', style({ height: '*' })),
      transition('expanded <=> collapsed', animate('225ms cubic-bezier(0.4, 0.0, 0.2, 1)')),
    ]),
  ],
})


export class tpLinksComponent implements OnInit, OnDestroy {

  public size = 5;
  public pageNumber = 0;


  tpIdToLink:String;
  tpId:String;

  isTableExpanded = false;

  loadedPosts: tpLinks[] = [];

  isFetching = false;
  mySelect = '1';
  error = null;

  private errorSub: Subscription;

  @ViewChild(MatSort) sort: MatSort;
  @ViewChild(MatPaginator) paginator: MatTableDataSourcePaginator;

  tpIdLinksList = new MatTableDataSource<tpLinks>();

  displayedtpLinksColumnsList: string[] = ['id', 'Link', 'IsaSenderId', 'IsaReceiverId', 'TransType', 'TransactionSetId', 'actions'];

  tpLinksArray: tpLinks[] = [];

  constructor(public dialog: MatDialog, private router: Router, private route: ActivatedRoute, private tpLinksService: RestServiceComponent
  ) {
    this.tpIdToLink = this.tpId;

  }

  ngOnInit() {

    console.info("ngOnInit tpLinksService.fetchTpLinks");
    const routeParams = this.route.snapshot.paramMap;
    this.tpId = routeParams.get('tpId');
    console.info("tpLink init:" + this.tpId);
    this.errorSub = this.tpLinksService.error.subscribe(errorMessage => {
      this.error = errorMessage;
    });
    this.Refresh();


    this.errorSub = this.tpLinksService.error.subscribe(errorMessage => {
      this.error = errorMessage;
    });
  }

  ngAfterViewInit() {
    this.tpIdLinksList.paginator = this.paginator;
    this.tpIdLinksList.sort = this.sort;
  }

  Refresh()
  {


    this.isFetching = true;


    this.tpLinksService.fetchTpLinks(this.tpId).subscribe(
      tpLinksData => {
        this.isFetching = false;
        this.loadedPosts = tpLinksData;
        this.tpIdLinksList.data = this.loadedPosts;
      },
      error => {
        this.isFetching = false;
        this.error = error.message;
      }
    );


    console.debug("Got TPLink records");

  }


  // Toggel Rows
  toggleTableRows() {
    this.isTableExpanded = !this.isTableExpanded;

    this.tpIdLinksList.data.forEach((row: any) => {
      row.isExpanded = this.isTableExpanded;
    })
  }

  onHandleError() {
    this.error = null;
  }

  ngOnDestroy() {
    this.errorSub.unsubscribe();
  }

  SelecttpLinks(nm: String) {
    console.info("fetchtp-links: " + nm);

    this.tpIdLinksList.data.forEach((row: any) => {

      if(row.Link == nm )
      {
        row.isExpanded = ! row.isExpanded;
      }
    })

  }

  addRow()
  {
    console.info("Call add for: " + this.tpId);
    // this.router.navigate(["/tp-add/" + this.tpId] );
    this.router.navigate(["/TradingPartners/tpIds/tp-links/tp-add/" + this.tpId] );
  }

  delete(tpLink: string) {

    try
    {

      this.dialog
      .open(ConfirmDialogComponent)
      .afterClosed()
      .subscribe((confirm) => {
        if (confirm) {

          this.tpLinksService.deleteTpLink(tpLink).subscribe(
            {
              next: (res) =>
              {
                if (res["Status"] !== undefined) {
                  this.Refresh();
                }
                else if(res["Error"] !== undefined) {
                  alert(res["Error"])
                }
                console.info('deleteTpLink: Json: ' + JSON.stringify(res));
                return;
              },
              error: (e) => {
                alert('deleteTpLink catchError: ' + e);
                return;
              }
            })
    }
    });



    }
    catch(e)
    {
      console.error('Exception: ' + e)
    }



  }


}



