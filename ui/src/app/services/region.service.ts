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
      .map((regionData, index) => {
        // Create unique storage account name for each region for chart purposes
        // This ensures each region gets its own line in the chart
        return {
          ...regionData,
          storageAccountName: `${regionData.name}-${index}-azurespeed`
        }
      })
  }

  clearRegions() {
    this.selectedRegionsSubject.next([])
  }
}
