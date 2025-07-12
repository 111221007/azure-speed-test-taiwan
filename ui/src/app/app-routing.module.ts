import { NgModule } from '@angular/core'
import { RouterModule, Routes } from '@angular/router'

const routes: Routes = [
  {
    path: 'Azure',
    loadChildren: () => import('./pages/azure/azure.module').then((_) => _.AzureModule)
  },
  {
    path: '',
    redirectTo: 'Azure/Latency',
    pathMatch: 'full'
  },
  {
    path: '**',
    redirectTo: 'Azure/Latency',
    pathMatch: 'full'
  }
]

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
