import { Injectable } from '@angular/core';

type Row = { id: string; value: string };

@Injectable({ providedIn: 'root' })
export class CodeValueLookupService {
  // prefix (3 letters) -> map(id -> value)
  private lookups = new Map<string, Map<string, string>>();
  // prefix -> rows array
  private rowsMap = new Map<string, Row[]>();
  // default prefix used by legacy callers
  private defaultPrefix = 'HL3';

  constructor() {
    // start background load of all CSV lookups
    void this.loadAllCsvLookups();
  }

  // Public API
  getPrefixes(): string[] {
    return Array.from(this.lookups.keys());
  }

  getRows(prefix?: string): Row[] {
    const p = this.normalizePrefix(prefix || this.defaultPrefix);
    return (this.rowsMap.get(p) || []).slice();
  }

  getName(id: string, prefix?: string): string | null {
    if (!id) return null;
    const p = this.normalizePrefix(prefix || this.defaultPrefix);
    return this.lookups.get(p)?.get(id) ?? null;
  }

  getDescription(id: string, prefix?: string): string | null {
    return this.getName(id, prefix);
  }

  // Load all CSV files found under /assets (tries manifest then directory index).
  async loadAllCsvLookups(): Promise<void> {
    const files = await this.findCsvFilesInAssets();
    for (const f of files) {
      try {
        const resp = await fetch(f);
        if (!resp.ok) continue;
        const txt = await resp.text();
        const filename = this.basename(f);
        const prefix = this.normalizePrefix(filename.substring(0, 3));
        this.parseCsvInto(prefix, txt);
      } catch (e) {
        // ignore and continue
        continue;
      }
    }
  }

  // Attempt to discover CSV files. First try a manifest (/assets/lookup-manifest.json),
  // otherwise attempt to fetch /assets/ and parse the HTML for .csv links.
  private async findCsvFilesInAssets(): Promise<string[]> {
    const candidates: string[] = [];
    try {
      const m = await fetch('/assets/lookup-manifest.json');
      if (m.ok) {
        const list = await m.json();
        if (Array.isArray(list)) {
          for (const it of list) {
            if (typeof it === 'string' && it.toLowerCase().endsWith('.csv')) {
              candidates.push(`/assets/${it}`);
            }
          }
          return candidates;
        }
      }
    } catch (e) {
      // manifest not present — fallthrough
    }

    try {
      const resp = await fetch('/assets/');
      if (!resp.ok) return [];
      const ct = resp.headers.get('content-type') || '';
      if (!ct.includes('html')) return [];
      const body = await resp.text();
      const re = /href=\"([^\"]+\.csv)\"/gi;
      const found = new Set<string>();
      let m2: RegExpExecArray | null;
      while ((m2 = re.exec(body)) !== null) {
        let url = m2[1];
        // normalize relative paths
        if (!url.startsWith('/')) url = `/assets/${url.replace(/^\.\/?/, '')}`;
        if (url.toLowerCase().endsWith('.csv')) found.add(url);
      }
      return Array.from(found.values());
    } catch (e) {
      return [];
    }
  }

  private basename(path: string) {
    const p = path.split('/').pop() || path;
    return p;
  }

  private normalizePrefix(p: string) {
    return (p || '').toString().substring(0, 3).toUpperCase();
  }

  private parseCsvInto(prefix: string, text: string) {
    const lines = text.split(/\r?\n/).map(l => l.trim()).filter(l => l.length > 0);
    let startIndex = 0;
    if (lines.length > 0) {
      const first = lines[0].toLowerCase();
      if (first.includes('id(') || first.includes('name(') || first.startsWith('id,')) startIndex = 1;
    }
    const rows: Row[] = [];
    const map = new Map<string, string>();
    for (let i = startIndex; i < lines.length; i++) {
      const parts = lines[i].split(',').map(p => p.replace(/^\s*"|"\s*$|^\s*'|'\s*$/g, '').trim());
      const id = (parts[0] || '').toString();
      const val = (parts[1] || '').toString();
      if (id) {
        map.set(id, val || '');
        rows.push({ id, value: val || '' });
      }
    }
    this.lookups.set(prefix, map);
    this.rowsMap.set(prefix, rows);
  }

  // Legacy helper: try to load a single prefix by name (keeps compatibility with prior API)
  async loadLookupForPrefix(prefix: string): Promise<boolean> {
    const p = this.normalizePrefix(prefix);
    const candidates = [`/assets/${p}Values.csv`, `/assets/${p}.csv`, `/assets/${p}_lookup.csv`, `/assets/${p}-lookup.csv`, `/assets/${p}Lookup.csv`];
    for (const url of candidates) {
      try {
        const resp = await fetch(url);
        if (!resp.ok) continue;
        const txt = await resp.text();
        this.parseCsvInto(p, txt);
        return true;
      } catch (e) {
        continue;
      }
    }
    return false;
  }
}
