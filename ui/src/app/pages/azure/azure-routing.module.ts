import { NgModule } from '@angular/core'
import { RouterModule, Routes } from '@angular/router'
import {
  AboutComponent,
  AzureComponent,
  LatencyComponent
} from './index'

const routes: Routes = [
  {
    path: '',
    component: AzureComponent,
    children: [
      {
        path: 'About',
        component: AboutComponent
      },
      {
        path: 'Latency',
        component: LatencyComponent
      },
      {
        path: '',
        redirectTo: 'Latency',
        pathMatch: 'full'
      },
      {
        path: '**',
        redirectTo: 'Latency',
        pathMatch: 'full'
      }
    ]
  }
]

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class AzureRoutingModule {}
