import { BehaviorSubject } from 'rxjs'
import { Injectable } from '@angular/core'
import publicRegionsJson from '../../assets/data/regions.json'
import { RegionModel } from '../models'

@Injectable({
  providedIn: 'root'
})
export class RegionService {
  private selectedRegionsSubject = new BehaviorSubject<RegionModel[]>([])
  selectedRegions$ = this.selectedRegionsSubject.asObservable()

  updateSelectedRegions(regions: RegionModel[]) {
    this.selectedRegionsSubject.next(regions)
  }

  getAllRegions(): RegionModel[] {
    return publicRegionsJson
      .filter((region) => !region.restricted)
      .map((regionData) => {
        // Use a single storage account name for all regions
        // This should match the AZURE_STORAGE_ACCOUNT_NAME environment variable
        return {
          ...regionData,
          storageAccountName: 'azurespeedteststorage'
        }
      })
  }

  clearRegions() {
    this.selectedRegionsSubject.next([])
  }
}
