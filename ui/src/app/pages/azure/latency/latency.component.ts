import { Component, Inject, OnDestroy, OnInit, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import axios from 'axios';
import { Subject, timer } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { curveBasis } from 'd3-shape';
import { colorSets, DataItem, MultiSeries, LegendPosition } from '@swimlane/ngx-charts';

import { RegionService, SeoService } from '../../../services';
import { RegionModel } from '../../../models';

interface ChartRawData {
  name: string;
  storageAccountName: string;
  series: { name: number; value: number }[];
}

interface LatencyTestResult {
  geography: string;
  displayName: string;
  physicalLocation: string;
  storageAccountName: string;
  averageLatency: number;
}

@Component({
  selector: 'app-azure-latency',
  templateUrl: './latency.component.html'
})
export class LatencyComponent implements OnInit, OnDestroy {
  private static readonly MAX_PING_ATTEMPTS = 180;
  private static readonly PING_INTERVAL_MS = 2000;
  private static readonly CHART_UPDATE_INTERVAL_MS = 1000;
  private static readonly CHART_X_AXIS_LENGTH = 60

  public tableData: LatencyTestResult[] = [];
  public tableDataTop3: LatencyTestResult[] = [];
  public chartDataSeries: MultiSeries = [];
  public colorScheme = colorSets.find(s => s.name === 'picnic') || colorSets[0];
  public curve = curveBasis;
  public xAxisTicks: string[] = [];
  public legendPosition: LegendPosition = LegendPosition.Below;

  private destroy$ = new Subject<void>();
  private regions: RegionModel[] = [];
  private pingAttemptCount = 0;
  private pingHistory = new Map<string, number[]>();
  private latestPingTime = new Map<string, number>();
  private chartRawData: ChartRawData[] = [];
  private pingTimerStarted = false;

  constructor(
    private regionService: RegionService,
    private seoService: SeoService,
    @Inject(PLATFORM_ID) private platformId: object
  ) {
    this.seoService.setMetaTitle(
      'Azure Latency Test - Measure Latency to Azure Datacenters Worldwide'
    );
    this.seoService.setMetaDescription(
      'Test latency from your location to Azure datacenters worldwide. Measure the latency to various Azure regions and find the closest Azure datacenters.'
    );
    this.seoService.setCanonicalUrl('https://www.azurespeed.com/Azure/Latency');
  }

  ngOnInit(): void {
    if (isPlatformBrowser(this.platformId)) {
      this.regionService.selectedRegions$
        .pipe(takeUntil(this.destroy$))
        .subscribe(regions => {
          this.regions = regions;
          this.resetPingData();
          if (!this.pingTimerStarted) {
            this.startPingTimer();
            this.pingTimerStarted = true;
          }
        });

      timer(0, LatencyComponent.CHART_UPDATE_INTERVAL_MS)
        .pipe(takeUntil(this.destroy$))
        .subscribe(() => this.updateChart());
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private resetPingData(): void {
    this.pingAttemptCount = 0;
    this.pingHistory.clear();
    this.latestPingTime.clear();
    this.chartRawData = [];
    this.tableData = [];
    this.tableDataTop3 = [];
    this.chartDataSeries = [];
    this.xAxisTicks = [];
  }

  private startPingTimer(): void {
    timer(0, LatencyComponent.PING_INTERVAL_MS)
      .pipe(takeUntil(this.destroy$))
      .subscribe(async () => {
        if (this.pingAttemptCount < LatencyComponent.MAX_PING_ATTEMPTS) {
          await this.pingAllRegions();
          this.pingAttemptCount++;
        }
      });
  }

  private async pingAllRegions(): Promise<void> {
    const concurrency = 4;
    const tasks: Promise<void>[] = [];

    for (const region of this.regions) {
      if (tasks.length >= concurrency) {
        await Promise.race(tasks);
      }
      // Name and type the promise so TS can track it
      const pingPromise: Promise<void> = this.pingRegion(region).then((): void => {
        const idx = tasks.indexOf(pingPromise);
        if (idx >= 0) tasks.splice(idx, 1);
      });
      tasks.push(pingPromise);
    }

    await Promise.all(tasks);
  }

  private async pingRegion(region: RegionModel): Promise<void> {
    const url = `https://${region.storageAccountName}.blob.core.windows.net/public/latency-test.json`;
    const start = isPlatformBrowser(this.platformId) ? performance.now() : Date.now();

    try {
      await axios.head(url, { timeout: 2000, params: { _: Date.now() } });
      const end = isPlatformBrowser(this.platformId) ? performance.now() : Date.now();
      this.recordPing(region.storageAccountName!, Math.round(end - start));
    } catch {
      // ignore timeouts / errors
    }
  }

  private recordPing(storageAccountName: string, duration: number): void {
    if (duration <= 500) {
      this.latestPingTime.set(storageAccountName, duration);
      const history = this.pingHistory.get(storageAccountName) || [];
      history.push(duration);
      this.pingHistory.set(storageAccountName, history);
      this.refreshTable();
    }
  }

  private refreshTable(): void {
    this.tableData = this.regions
      .filter(r => this.latestPingTime.has(r.storageAccountName!))
      .map(r => {
        const hist = [...(this.pingHistory.get(r.storageAccountName!) || [])];
        hist.sort((a, b) => a - b);
        hist.pop(); // drop the highest outlier
        const avg = hist.length
          ? Math.floor(hist.reduce((a, b) => a + b, 0) / hist.length)
          : 0;
        return {
          geography: r.geography,
          displayName: r.displayName,
          physicalLocation: r.physicalLocation,
          storageAccountName: r.storageAccountName!,
          averageLatency: avg
        } as LatencyTestResult;
      })
      .sort((a, b) => a.averageLatency - b.averageLatency);

    this.tableDataTop3 = this.tableData.filter(d => d.averageLatency > 0).slice(0, 3);
  }

 private updateChart(): void {
    const now = new Date()
    const currentSecond = now.getTime()
    const secondArr = Array.from({ length: LatencyComponent.CHART_X_AXIS_LENGTH }, (_j, i) => {
      return currentSecond - i * 1000
    }).reverse()
    this.tableData.forEach(({ storageAccountName, displayName }) => {
      if (storageAccountName) {
        let isNew = true

        this.chartRawData.forEach((item: ChartRawData) => {
          if (storageAccountName === item.storageAccountName) {
            isNew = false
          }
        })
        if (isNew) {
          this.chartDataSeries.push({
            name: displayName,
            series: secondArr.map((i) => ({
              name: this.formatXAxisTick(i),
              value: 0
            }))
          })
          this.chartRawData.push({
            storageAccountName,
            name: displayName,
            series: secondArr.map((i) => ({ name: i, value: 0 }))
          })
        }
      }
    })

    this.updateChartRawData(currentSecond)
    this.updateChartData()
    this.updateXAxisTicks()
  }
  private updateChartRawData(currentSecond: number) {
    this.chartRawData.forEach((item: ChartRawData) => {
      const { storageAccountName, series } = item
      const pingTime = this.latestPingTime.get(storageAccountName) || 0
      const isRemove = !this.tableData.some((td) => storageAccountName === td.storageAccountName)
      if (series.length > LatencyComponent.CHART_X_AXIS_LENGTH - 1) {
        series.shift()
      }

      series.push({
        name: currentSecond,
        value: isRemove ? 0 : pingTime
      })
    })
  }

  private updateChartData(): void {
    const arr = this.chartRawData.map((item: ChartRawData) => {
      return {
        name: item.name,
        series: item.series.map((seriesItem: DataItem) => ({
          name: this.formatXAxisTick(Number(seriesItem.name)),
          value: seriesItem.value
        }))
      }
    })
    this.chartDataSeries = [...arr]
  }

  private updateXAxisTicks(): void {
    this.xAxisTicks = this.chartRawData[0]
      ? this.chartRawData[0].series
          .filter((seriesItem: DataItem) => {
            const timestamp = parseInt(String(seriesItem.name), 10)
            const s = new Date(timestamp).getSeconds()
            return s % 5 === 0
          })
          .map((seriesItem: DataItem) =>
            this.formatXAxisTick(parseInt(String(seriesItem.name), 10))
          )
      : []
  }

  private formatTimeLabel(ts: number): string {
    const d = new Date(ts);
    const h = String(d.getHours()).padStart(2, '0');
    const m = String(d.getMinutes()).padStart(2, '0');
    const s = String(d.getSeconds()).padStart(2, '0');
    return `${h}:${m}:${s}`;
  }

    private formatXAxisTick(ts: number): string {
    const d = new Date(ts);
    const h = String(d.getHours()).padStart(2, '0');
    const m = String(d.getMinutes()).padStart(2, '0');
    const s = String(d.getSeconds()).padStart(2, '0');
    return `${h}:${m}:${s}`;
  }
}
