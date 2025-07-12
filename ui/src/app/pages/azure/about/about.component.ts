import { Component } from '@angular/core'
import { SeoService } from '../../../services'

@Component({
  selector: 'app-about',
  templateUrl: './about.component.html',
  styleUrls: ['./about.component.css']
})
export class AboutComponent {
  constructor(private seoService: SeoService) {
    this.initializeSeoProperties()
  }

  private initializeSeoProperties(): void {
    this.seoService.setMetaTitle('Azure AWS Latency Testing - 111221007')
    this.seoService.setMetaDescription(
      'Web-based tool designed to measure network latency to various AWS regions worldwide. Test AWS latency from your local machine with real-time results and interactive charts.'
    )
    this.seoService.setCanonicalUrl('https://azure-speed-test-taiwan-da1c936d2d74.herokuapp.com/Azure/About')
  }
}
