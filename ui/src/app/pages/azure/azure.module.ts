import { CommonModule, NgOptimizedImage } from '@angular/common'
import { NgModule } from '@angular/core'
import { FormsModule, ReactiveFormsModule } from '@angular/forms'
import { LineChartModule } from '@swimlane/ngx-charts'
import { SharedModule } from '../shared/shared.module'
import { AzureRoutingModule } from './azure-routing.module'
import { AzureComponent } from './azure.component'
import {
  AboutComponent,
  LatencyComponent
} from './index'

@NgModule({
  bootstrap: [],
  declarations: [
    AboutComponent,
    LatencyComponent,
    AzureComponent
  ],
  exports: [],
  imports: [
    CommonModule,
    AzureRoutingModule,
    SharedModule,
    LineChartModule,
    FormsModule,
    ReactiveFormsModule,
    NgOptimizedImage
  ],
  providers: []
})
export class AzureModule {}
