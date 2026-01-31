import { Component } from '@angular/core';
import { PdfReaderService } from './pdf-reader.service';
import { ViewChild, ElementRef } from '@angular/core';

@Component({
  selector: 'app-pdf-reader',
  templateUrl: './pdf-reader.component.html',
  styleUrls: ['./pdf-reader.component.css'],
  standalone: false
})
export class PdfReaderComponent {
  fileSrc: ArrayBuffer | null = null;
  extractedText = '';
  isLoading = false;
  // per-page text cache for searching
  pageTexts: string[] = [];
  // search state
  searchQuery = '';
  matches: number[] = []; // page numbers with matches
  currentMatchIndex = -1;
  @ViewChild('pdfCanvas', { static: false }) pdfCanvas!: ElementRef<HTMLCanvasElement>;
  selectedFileName: string | null = null;
  selectedFileSize: string | null = null;
  selectedFilePages: number | null = null;
  startPage = 1;
  endPage = 1;
  errorMessage: string | null = null;
  currentPage = 1;
  // Zoom scale (passed to pdf.js viewport)
  scale = 1.5;
  readonly minScale = 0.2;
  readonly maxScale = 4.0;

  // Page control helpers
  private clampPages() {
    if (this.selectedFilePages === null) return;
    if (this.startPage < 1) this.startPage = 1;
    if (this.startPage > this.selectedFilePages) this.startPage = this.selectedFilePages;
    if (this.endPage < this.startPage) this.endPage = this.startPage;
    if (this.endPage > this.selectedFilePages) this.endPage = this.selectedFilePages;
    if (this.currentPage < this.startPage) this.currentPage = this.startPage;
    if (this.currentPage > this.endPage) this.currentPage = this.endPage;
  }

  onStartInputChange(val: number) {
    this.startPage = Number(val) || 1;
    this.clampPages();
  }

  onEndInputChange(val: number) {
    this.endPage = Number(val) || this.startPage;
    this.clampPages();
  }

  incStart() { this.startPage = Math.min(this.startPage + 1, this.selectedFilePages || this.startPage); this.clampPages(); }
  decStart() { this.startPage = Math.max(1, this.startPage - 1); this.clampPages(); }
  incEnd() { this.endPage = Math.min((this.endPage || 1) + 1, this.selectedFilePages || this.endPage); this.clampPages(); }
  decEnd() { this.endPage = Math.max(this.startPage, (this.endPage || this.startPage) - 1); this.clampPages(); }
  setToFirst() { this.startPage = 1; this.clampPages(); }
  setToLast() { if (this.selectedFilePages) { this.endPage = this.selectedFilePages; this.clampPages(); } }

  // Page navigation
  prevPage() {
    if (this.currentPage > 1) { this.currentPage--; this.renderToCanvas(); }
  }
  nextPage() {
    if (this.selectedFilePages && this.currentPage < this.selectedFilePages) { this.currentPage++; this.renderToCanvas(); }
  }
  async goToPage(n: number) {
    if (!this.selectedFilePages) return;
    const p = Math.max(1, Math.min(this.selectedFilePages, Math.floor(n || 1)));
    this.currentPage = p;
    await this.renderToCanvas();
    this.updateRangeFromCurrent();
  }

  constructor(private pdfService: PdfReaderService) {}

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) return;
    const file = input.files[0];
    this.errorMessage = null;
    this.selectedFileName = file.name;
    this.selectedFileSize = this.formatBytes(file.size);
    const reader = new FileReader();
    reader.onload = async () => {
      this.fileSrc = reader.result as ArrayBuffer;
      this.extractedText = '';
      // update page count
      try {
        this.selectedFilePages = await this.pdfService.getNumPages(this.fileSrc);
        this.startPage = 1;
        this.endPage = this.selectedFilePages;
      } catch (e) {
        console.warn('Could not read page count', e);
        this.selectedFilePages = null;
      }
      // build page text cache for quick search (non-blocking)
      this.buildPageTextCache();
      try {
        // allow the canvas to render into the DOM
        await new Promise((res) => setTimeout(res, 0));
        await this.renderToCanvas();
        this.updateRangeFromCurrent();
      } catch (err) {
        console.error('Error rendering PDF to canvas', err);
        this.errorMessage = err?.message || String(err);
      }
    };
    reader.readAsArrayBuffer(file);
  }

  // Keep extract range synced with the currently viewed page (default behavior)
  private updateRangeFromCurrent() {
    this.startPage = Math.max(1, Math.floor(this.currentPage || 1));
    this.endPage = Math.min((this.selectedFilePages || this.startPage), this.startPage + 1);
    this.clampPages();
  }

  async extractText() {
    if (!this.fileSrc) return;
    // Set extract range to current viewing page and the next page by default
    this.startPage = this.currentPage;
    this.endPage = Math.min(this.currentPage + 1, this.selectedFilePages || this.currentPage);
    this.isLoading = true;
    try {
      this.errorMessage = null;
      this.extractedText = await this.pdfService.extractTextRange(this.fileSrc, this.startPage, this.endPage);
      if (!this.extractedText || this.extractedText.trim() === '') {
        this.extractedText = 'No selectable text found in the PDF (it may be a scanned image).';
      }
    } catch (err) {
      console.error('Error extracting text', err);
      this.errorMessage = err?.message || String(err);
    } finally {
      this.isLoading = false;
    }
  }

  async renderToCanvas() {
    if (!this.fileSrc || !this.pdfCanvas) return;
    this.isLoading = true;
    try {
      this.errorMessage = null;
      await this.pdfService.renderPageToCanvas(this.fileSrc, this.pdfCanvas.nativeElement, this.currentPage, this.scale);
    } finally {
      this.isLoading = false;
    }
  }

  // --- Quick search (client-side) ---
  async buildPageTextCache() {
    if (!this.fileSrc) return;
    try {
      this.pageTexts = await this.pdfService.extractTextPerPage(this.fileSrc);
    } catch (err) {
      console.warn('Could not build page text cache', err);
      this.pageTexts = [];
    }
  }

  runSearch() {
    this.matches = [];
    this.currentMatchIndex = -1;
    const q = (this.searchQuery || '').trim();
    if (!q || !this.pageTexts || this.pageTexts.length === 0) return;
    const lower = q.toLowerCase();
    for (let i = 0; i < this.pageTexts.length; i++) {
      const t = this.pageTexts[i] || '';
      if (t.toLowerCase().includes(lower)) this.matches.push(i + 1);
    }
    if (this.matches.length > 0) {
      this.currentMatchIndex = 0;
      this.goToPage(this.matches[0]);
    }
  }

  nextMatch() {
    if (!this.matches || this.matches.length === 0) return;
    this.currentMatchIndex = (this.currentMatchIndex + 1) % this.matches.length;
    this.goToPage(this.matches[this.currentMatchIndex]);
  }

  prevMatch() {
    if (!this.matches || this.matches.length === 0) return;
    this.currentMatchIndex = (this.currentMatchIndex - 1 + this.matches.length) % this.matches.length;
    this.goToPage(this.matches[this.currentMatchIndex]);
  }

  clearSearch() {
    this.searchQuery = '';
    this.matches = [];
    this.currentMatchIndex = -1;
  }

  zoomIn() {
    this.scale = Math.min(this.maxScale, +(this.scale + 0.1).toFixed(2));
    this.renderToCanvas();
  }

  zoomOut() {
    this.scale = Math.max(this.minScale, +(this.scale - 0.1).toFixed(2));
    this.renderToCanvas();
  }

  setZoom(v: number) {
    if (!v || isNaN(v)) return;
    this.scale = Math.max(this.minScale, Math.min(this.maxScale, v));
    this.renderToCanvas();
  }

  // Load a PDF file from the app assets folder (place the PDF in src/assets/)
  async loadAssetPdf(assetFileName: string) {
    this.isLoading = true;
    try {
      this.errorMessage = null;
      const url = `/assets/${encodeURIComponent(assetFileName)}`;
      const resp = await fetch(url);
      if (!resp.ok) throw new Error('Failed to fetch asset: ' + url);
      const buf = await resp.arrayBuffer();
      this.fileSrc = buf;
      this.extractedText = '';
      this.selectedFileName = assetFileName;
      const len = resp.headers.get('content-length');
      this.selectedFileSize = len ? this.formatBytes(Number(len)) : null;
      await this.renderToCanvas();
    } finally {
      this.isLoading = false;
    }
  }

  private formatBytes(bytes: number, decimals = 2): string {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }
}
