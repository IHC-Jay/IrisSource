import { Component,OnInit } from '@angular/core';

import { FormsModule,  FormBuilder, FormGroup, FormControl, Validators } from '@angular/forms';
import {TradingPartner} from '../tradingPartners/TradingPartner';
import {TpId, TpIdColumns} from '../tradingPartners/tpIds/TpId';
import {tpLinks} from '../tradingPartners/tpIds/tp-links/tp-links';
import {RestServiceComponent} from '../services/rest-service.component';
import { MatTableDataSource, MatTableDataSourcePaginator } from '@angular/material/table';
import {
  AUTO_STYLE,
  animate,
  state,
  style,
  transition,
  trigger
} from '@angular/animations';
const DEFAULT_DURATION = 300;
@Component({
  selector: 'app-search',
  templateUrl: './search.component.html',
  styleUrls: ['./search.component.css'],
  animations: [
    trigger('collapse', [
      state('false', style({ height: AUTO_STYLE, visibility: AUTO_STYLE })),
      state('true', style({ height: '0', visibility: 'hidden' })),
      transition('false => true', animate(DEFAULT_DURATION + 'ms ease-in')),
      transition('true => false', animate(DEFAULT_DURATION + 'ms ease-out'))
    ])
  ]
})

export class SearchComponent implements OnInit {

  selectedTp = '';
  selectedTpId ='';
  form!: FormGroup;
  canRender = false;
  canRenderDetails = false;
  tpArray = new MatTableDataSource<TradingPartner>();
  dataSource: TpId[] = [];
  loadedPosts: tpLinks[] = [];

  constructor(private TradingPartnerService: RestServiceComponent,
    private formBuilder: FormBuilder
  ){

    this.form =new FormGroup({
      tpId: new FormControl()
    });

  }

  async ngOnInit() {

    this.form = this.formBuilder.group({
      searchTpId: ['', Validators.required]

  });

      this.TradingPartnerService.fetchTradingPartners().subscribe((res: any) => {
        this.tpArray.data = res;
        console.log('fetchTradingPartners got rows: ' + this.tpArray.data.length);
        this.canRender = true;

    });



      let myPromise = () => new Promise((resolve, reject) => {
        setTimeout(function(){
          resolve('Count')
        }, 1000)
      })

      for (let index = 0; index < 5; index++) {
        let count = await myPromise()

        if(this.canRender)
          break;
      }

    }



  onTpChange(event) {
    console.info(event.value);

    this.selectedTpId = '';

    this.loadedPosts = [];
    this.dataSource = [];
    this.collapse();

    this.TradingPartnerService.getTpIds(event.value).subscribe((res: any) => {

      this.dataSource = res;
      console.info('dataSource: ')
      console.info(this.dataSource.length);

      this.dataSource.forEach(element => {


      this.TradingPartnerService.fetchTpLinks(element.TPID).subscribe(
        tpLinksData => {
          this.loadedPosts = tpLinksData;
          this.canRenderDetails = true;
        },
        error => {
          console.error( error.message);
        }
      );

      });
    });

  }
    onTpIdChange()
    {
      console.info('TpId changed');
     let searchTpIdVal = this.form.controls.searchTpId.value.toString().trim();

     console.info('searchTpIdVal: ' + searchTpIdVal);
    console.info(searchTpIdVal);
    this.selectedTp = '';

    this.loadedPosts = [];
    this.dataSource = [];
    this.collapse();

    this.TradingPartnerService.fetchTPforTpId(searchTpIdVal).subscribe((res: any) => {
      console.info('onTpIdChange: ' + res.Name);
      this.selectedTp = res.Name;
      var tp:TpId  = {id:'0', Name:'1', TPID: searchTpIdVal, Type:'BOTH', isEdit:false, isSelected:false};

      this.dataSource.push( tp);

      this.TradingPartnerService.fetchTpLinks(searchTpIdVal).subscribe(
        tpLinksData => {
          this.loadedPosts = tpLinksData;
          this.canRenderDetails = true;
        },
        error => {
          console.error( error.message);
        }
      );

    });


    }
    clearDetails()
    {
      this.canRenderDetails = false;
    }

    collapsed = true;

    toggle() {
      this.collapsed = !this.collapsed;
    }

    expand() {
      this.collapsed = false;
    }

    collapse() {
      this.collapsed = true;
      window.scrollTo(0, 0);
    }

}
