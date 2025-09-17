import { Component, OnInit, ViewChild } from '@angular/core';
import { ActivatedRoute, RouteReuseStrategy } from '@angular/router';

import {TpRestServiceComponent} from '../../services/tprest-service.component';
import { MatTableDataSource, MatTableDataSourcePaginator } from '@angular/material/table';
import { MatPaginator, MatPaginatorModule } from '@angular/material/paginator';
import { MatDialog } from '@angular/material/dialog';
import { TpId, TpIdColumns } from './TpId';
import { ConfirmDialogComponent } from '../../confirm-dialog/confirm-dialog.component';

@Component({
  selector: 'app-tpIds',
  templateUrl: './tpIds.component.html',
  styleUrls: ['./tpIds.component.css']
})

export class TpIdComponent implements OnInit {
  tpId: string;

  public size = 5;
  public pageNumber = 0;

  displayedColumns: string[] = TpIdColumns.map((col) => col.key);
  columnsSchema: any = TpIdColumns;

  dataSource = new MatTableDataSource<TpId>();
  valid: any = {};
  @ViewChild(MatPaginator, {static: true}) paginator: MatPaginator;

  constructor(public dialog: MatDialog, private route: ActivatedRoute,  private tpIdService: TpRestServiceComponent) { }

  ngOnInit() {
    // First get the product id from the current route.
    const routeParams = this.route.snapshot.paramMap;
    this.tpId = routeParams.get('tpId');
    this.RefreshRows();
    }

    ngAfterViewInit() {
      this.dataSource.paginator = this.paginator;
    }

    addRow() {
      const newRow: TpId = {
        id: '-1',
        Name: this.tpId,
        TPID: '',
        Type: 'ISA',
        isEdit: true,
        isSelected: false,
        User:''
      };
      this.dataSource.data = [newRow, ...this.dataSource.data];
    }

    editRow(row: TpId) {

      if (row.id === '-1') {
        console.info('Add a TP ' + row.id);
        if (row.TPID !== '')
        {
          let res = this.tpIdService.addTPID(row).subscribe((res) => {
            row.isEdit = false;
            row.id = res.id;
            row.isEdit = false;
            console.info('Added TP: ' + row.TPID +", ID: " + row.id);
          });

        }
        else
        {
          let ind = this.dataSource.data.indexOf(row)
          this.dataSource.data.splice(ind, 1);
          this.dataSource.data = [...this.dataSource.data];
          row.isEdit = false;
          alert("Required fields missing");
        }

      } else {
        console.info('Edit a TP ' + row.Name +", " + row.id);
        this.tpIdService.updateTPID(row).subscribe((res) => {
          row.isEdit = false;
        });
      }

    }
    cancelRow(row: TpId)  {
      this.RefreshRows();
    }

    removeRow(row: TpId)  {
      let tpid = row.TPID;
      console.log('removeRow: ' + tpid);
      try
      {

        this.dialog
        .open(ConfirmDialogComponent)
        .afterClosed()
        .subscribe((confirm) => {
          if (confirm) {

            this.tpIdService.deleteTPID(tpid).subscribe( {
              next: (res) =>
              {
                if (res["Status"] !== undefined) {
                  this.RefreshRows();
                }
                else if(res["Error"] !== undefined) {
                  alert(res["Error"])
                }
                console.info('deleteTPID: Json: ' + JSON.stringify(res));
                return;
              },
              error: (e) => {
                alert('deleteTPID catchError: ' + e);
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

    RefreshRows()
    {
      console.info('RefreshRows')
      this.tpIdService.getTpIds(this.tpId).subscribe((res: any) => {
        this.dataSource.data = res;
      });
    }

    inputHandler(e: any, id: string, key: string) {
      if (!this.valid[id]) {
        this.valid[id] = {};
      }
      this.valid[id][key] = e.target.validity.valid;
    }

    disableSubmit(id: string) {
      if (this.valid[id]) {
        return Object.values(this.valid[id]).some((item) => item === false);
      }
      return false;
    }

}
