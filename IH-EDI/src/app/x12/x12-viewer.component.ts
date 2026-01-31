import { Component, Input, OnChanges, SimpleChanges, OnInit } from '@angular/core';
import { NestedTreeControl } from '@angular/cdk/tree';
import { MatTreeNestedDataSource } from '@angular/material/tree';
import { elementLabel, ensureElementLabels, txFriendlyName, TX_FRIENDLY_MAP, SEGMENT_LABELS } from './x12-metadata';
import * as SAMPLE_DATA from './sample-x12-data';
import { CodeValueLookupService } from '../codeValue-lookup/codeValue-lookup.service';

interface X12Node {
  name: string;
  value?: string;
  children?: X12Node[];
  label?: string;
}

@Component({
  selector: 'app-x12-viewer',
  templateUrl: './x12-viewer.component.html',
  styleUrls: ['./x12-viewer.component.css'],
  standalone: false
})
export class X12ViewerComponent implements OnChanges, OnInit {
  @Input() x12Text = '';
  @Input() title = 'X12 Message';
  @Input() showControls = true;
  messageHeading = this.title;
  collapsed = false;
  viewMode: 'tree' | 'raw' = 'tree';

  transactions: Array<{ code: string; label: string }> = [];
  selectedTx = '';

  treeControl = new NestedTreeControl<X12Node>(node => node.children);
  dataSource = new MatTreeNestedDataSource<X12Node>();

  constructor(private valueLookup: CodeValueLookupService) {}

  ngOnChanges(changes: SimpleChanges) {
    if (changes['x12Text']) {
      void this.buildTree();
    }
  }

  ngOnInit(): void {
    // initialize transactions list for dropdown
    this.transactions = Object.keys(TX_FRIENDLY_MAP).map(k => ({ code: k, label: TX_FRIENDLY_MAP[k] }));
    if (this.transactions.length) this.selectedTx = this.transactions[0].code;

    if (this.x12Text) void this.buildTree();
  }

  toggle() {
    this.collapsed = !this.collapsed;
  }

  get formatted(): string {
    if (!this.x12Text) return '';
    const text = this.x12Text.replace(/\r?\n/g, '');
    const segments = text.split('~').map(s => s.trim()).filter(Boolean);
    return segments.map(s => s + '~').join('\n');
  }

  private async buildTree() {
    if (!this.x12Text) {
      this.dataSource.data = [];
      return;
    }

    const normalized = this.x12Text.replace(/\r?\n/g, '');
    // detect separators from ISA: element separator (char after 'ISA'),
    // component separator is the 104th character (1-based), and segment
    // terminator is often at position 106 in fixed ISA formatting.
    let compSep = ':';
    let segSep = '~';
    let elementSep = '*';
    const isaIndex = normalized.indexOf('ISA');
    if (isaIndex >= 0) {
      if (normalized.length > isaIndex + 103) {
        compSep = normalized.charAt(isaIndex + 103);
      }
      if (normalized.length > isaIndex + 105) {
        segSep = normalized.charAt(isaIndex + 105);
      }
      if (normalized.length > isaIndex + 3) {
        elementSep = normalized.charAt(isaIndex + 3);
      }
    }
    const rawSegments = normalized.split(segSep).map(s => s.trim()).filter(Boolean);

    // Ensure important lookups are available before mapping labels
    try {
      await this.valueLookup.loadLookupForPrefix('HL3');
    } catch (e) {}
    try {
      await this.valueLookup.loadLookupForPrefix('NM1');
    } catch (e) {}
    try {
      await this.valueLookup.loadLookupForPrefix('DTP');
    } catch (e) {}


    const segmentToNode = (seg: string): X12Node => {
      const elements = seg.split(elementSep);
      const tag = elements[0] || 'SEG';
      // ensure there are labels for all element positions in this segment
      ensureElementLabels(tag, Math.max(0, elements.length - 1));
      const children: X12Node[] = elements.slice(1).map((el, idx) => {
        const comps = (el || '').split(compSep).map(c => c.trim()).filter(Boolean);
        const label = elementLabel(tag, idx);
        if (comps.length > 1) {
          return {
            name: label,
            value: comps.join(compSep),
            children: comps.map((c, ci) => ({ name: `C${ci + 1}`, value: c }))
          } as X12Node;
        }
        return { name: label, value: el } as X12Node;
      });

      const node = { name: tag, label: SEGMENT_LABELS[tag] || '', value: elements.slice(1).join(elementSep), children } as X12Node;
      // If this is an NM1 segment, try to augment with a description from NM1Values.csv
      if (tag === 'NM1' && children && children.length) {
        const first = (children[0].value || '').toString();
        if (first) {
          const desc = this.valueLookup.getDescription(first, 'NM1');
          if (desc) node.label = desc;
        }
      }
      // If this is a DTP segment, try to augment with a description from DTPValues.csv
      if (tag === 'DTP' && children && children.length) {
        const first = (children[0].value || '').toString();
        if (first) {
          const desc = this.valueLookup.getDescription(first, 'DTP');
          if (desc) node.label = desc;
        }
      }
      return node;
    };

    const nodes: X12Node[] = [];
    const txIds: string[] = [];
    let i = 0;
    while (i < rawSegments.length) {
      const seg = rawSegments[i];
      const tag = seg.split(elementSep)[0] || '';

      if (tag === 'ST') {
        // start a transaction grouping from ST ... SE
        const stElements = seg.split(elementSep);
        // capture Transaction Set Identifier Code (ST01)
        const stCode = (stElements[1] || '').toString();
        if (stCode) txIds.push(stCode);
        // prefer friendly name when available
        const friendly = txFriendlyName(stCode) || '';
        const txLabel = friendly ? `TRANSACTION ${stCode} - ${friendly}` : `TRANSACTION ${stElements.slice(1, 3).join(' ')}`.trim();
        const txChildren: X12Node[] = [];
        // include ST segment as first child
        txChildren.push(segmentToNode(seg));
        i++;
        while (i < rawSegments.length) {
          const innerSeg = rawSegments[i];
          const innerTag = innerSeg.split(elementSep)[0] || '';
          const innerNode = segmentToNode(innerSeg);
          txChildren.push(innerNode);
          i++;
          if (innerTag === 'SE') {
            break;
          }
        }

        // For HL segments: if any element has component children, flatten them
        // into a single value so HL fields render in the element table.
        txChildren.forEach(n => {
          if ((n.name || '').toString() === 'HL' && n.children) {
            n.children = n.children.map(ch => {
                if (ch.children && ch.children.length) {
                const combined = ch.children.map(cc => cc.value || '').join(compSep);
                return { name: ch.name, value: combined } as X12Node;
              }
              return ch;
            });
          }
        });

        // Transform flat txChildren into nested HL hierarchy where applicable.
        const nestByHL = (children: X12Node[]): X12Node[] => {
          const roots: X12Node[] = [];
          const hlMap: Record<string, X12Node> = {};
          let hlStack: X12Node[] = [];

          const getHLIds = (node: X12Node) => {
            let id = '';
            let parent = '';
            if (node.children && node.children.length > 0) {
              id = (node.children[0].value || '').toString();
              parent = node.children[1] ? (node.children[1].value || '').toString() : '';
            } else if (node.value) {
              const parts = node.value.split(elementSep);
              id = parts[0] || '';
              parent = parts[1] || '';
            }
            return { id, parent };
          };

          children.forEach((child) => {
              const childTag = (child.name || '').toString();
              // Keep SE at transaction root so it doesn't inherit HL indentation
              if (childTag === 'SE') {
                roots.push(child);
                // clear HL stack so subsequent nodes don't attach to previous HL
                hlStack = [];
                return;
              }

              if (childTag === 'HL') {
                // separate HL element nodes from structural children so we can
                // replace element display with a single label while preserving
                // nested structural children.
                const elemNodes = child.children ? child.children.slice() : [];
                (child as any)._elements = elemNodes;
                child.children = [];

                const { id, parent } = getHLIds({ name: child.name, children: elemNodes, value: child.value } as X12Node);
                // register HL node
                if (id) hlMap[id] = child;

                // attach to parent HL if known
                if (parent && hlMap[parent]) {
                  hlMap[parent].children = hlMap[parent].children || [];
                  hlMap[parent].children.push(child);
                } else {
                  roots.push(child);
                }

                // rebuild current HL stack path by following parent chain
                const chain: X12Node[] = [];
                let p = parent;
                while (p) {
                  const pn = hlMap[p];
                  if (!pn) break;
                  chain.unshift(pn);
                  const gp = (pn as any)._elements && (pn as any)._elements[1] ? ((pn as any)._elements[1].value || '').toString() : '';
                  p = gp;
                }
                hlStack = chain.concat([child]);
            } else {
              // non-HL nodes belong to the most recent HL in the stack, if any
              if (hlStack.length > 0) {
                const parentHL = hlStack[hlStack.length - 1];
                parentHL.children = parentHL.children || [];
                parentHL.children.push(child);
              } else {
                roots.push(child);
              }
            }
          });

          return roots;
        };

        let nested = nestByHL(txChildren);

        // Ensure HL3 lookup is loaded before mapping labels (so descriptions are available)
        try {
          await this.valueLookup.loadLookupForPrefix('HL3');
        } catch (e) {
          // ignore errors; mapping will proceed without descriptions
        }

        // Map HL element values to friendly labels and replace element display
        // with a single label node while keeping nested children.
        const mapHLLabels = (arr: X12Node[]) => {
          arr.forEach(n => {
            if ((n.name || '').toString() === 'HL') {
              const elems: X12Node[] = (n as any)._elements || [];
              const id = elems[0] ? (elems[0].value || '').toString() : '';
              const parent = elems[1] ? (elems[1].value || '').toString() : '';
              let label = '';
              if (id === '1') label = '2000A';
              else if (parent === '1') label = '2000B';
              else if (parent === '2') label = '2000C';
              else label = 'TBD';

              if (label) {
                // show loop label inline on the HL node rather than as a child

                // also attempt to lookup the 3rd HL field (if present) and include its description
                const thirdField = elems[2] ? (elems[2].value || '').toString() : '';
                const desc3 = thirdField ? this.valueLookup.getDescription(thirdField, 'HL3') : null;
                // include the raw thirdField code in parentheses after the Loop label
                const labelText = thirdField ? `Loop ${label} (${thirdField})` : `Loop ${label}`;
                n.label = desc3 ? `${labelText}  — ${desc3}` : labelText;

              } else if (elems.length) {
                // fallback: show elements as children if no mapping
                n.children = elems.concat(n.children || []);
              }
            }
            if (n.children && n.children.length) mapHLLabels(n.children);
          });
        };

        mapHLLabels(nested);

        // Add one more grouping level for specific transaction types
        const groupBySegment = (childrenArr: X12Node[], segTag: string, labelIdx = 1) => {
          const out: X12Node[] = [];
          let currentGroup: X12Node | null = null;

          const startNewGroup = (labelVal: string, firstNode: X12Node) => {
            const g: X12Node = { name: `${segTag} ${labelVal || ''}`, children: [firstNode] };
            out.push(g);
            currentGroup = g;
          };

          for (const ch of childrenArr) {
            if ((ch.name || '').toString() === segTag) {
              const labelVal = (ch.children && ch.children[labelIdx]) ? (ch.children[labelIdx].value || '') : (ch.value || '');
              startNewGroup(labelVal, ch);
              continue;
            }

            // if the segment appears inside this node's children, start group and include this node
            const innerIdx = ch.children ? ch.children.findIndex(c => (c.name || '').toString() === segTag) : -1;
            if (innerIdx >= 0) {
              const segNode = ch.children![innerIdx];
              const labelVal = (segNode.children && segNode.children[labelIdx]) ? (segNode.children[labelIdx].value || '') : (segNode.value || '');
              startNewGroup(labelVal, ch);
              continue;
            }

            if (currentGroup) {
              currentGroup.children = currentGroup.children || [];
              currentGroup.children.push(ch);
            } else {
              out.push(ch);
            }
          }

          return out;
        };

        // transaction-specific grouping rules
        const txCode = stCode;
        if (txCode === '270' || txCode === '271' || txCode === '276' || txCode === '277') {
          // group by TRN, use ReferenceID (element index 1)
          nested = groupBySegment(nested, 'TRN', 1);
        } else if (txCode.startsWith('837')) {
          // group by CLM for claims transactions, CLM first element is claim id (index 0)
          nested = groupBySegment(nested, 'CLM', 0);
        } else if (txCode === '835') {
          // group by CLP for payment lines, use first element
          nested = groupBySegment(nested, 'CLP', 0);
        }

        nodes.push({ name: txLabel, children: nested });
      } else {
        nodes.push(segmentToNode(seg));
        i++;
      }
    }

    this.dataSource.data = nodes;
    // append ST01 codes and friendly names to the heading (show all found transaction set IDs)
    const unique = Array.from(new Set(txIds));
    const headingParts = unique.map(c => {
      const f = txFriendlyName(c);
      return f ? `${c}:${f}` : c;
    });
    this.messageHeading = this.title + (headingParts.length ? ` [${headingParts.join(', ')}]` : '');

    // Collapse ISA/GS by default; expand transaction nodes and their ST child segments
    this.dataSource.data.forEach(n => {
      // transaction group nodes were created with names like 'TRANSACTION ...'
      if (n.name && n.name.toString().startsWith('TRANSACTION')) {
        this.treeControl.expand(n);
        if (n.children) {
          const stChild = n.children.find(c => (c.name || '').toString().startsWith('ST'));
          if (stChild) this.treeControl.expand(stChild);
        }
      } else if ((n.name || '').toString().startsWith('ST')) {
        // standalone ST at top-level
        this.treeControl.expand(n);
      }
      // leave ISA and GS collapsed
    });

    // Expand all HL nodes so loop hierarchies are visible initially
    const expandHLNodes = (node: X12Node) => {
      if (!node) return;
      if ((node.name || '').toString() === 'HL') {
        this.treeControl.expand(node);
      }
      if (node.children && node.children.length) {
        node.children.forEach(child => expandHLNodes(child));
      }
    };
    this.dataSource.data.forEach(root => expandHLNodes(root));
  }

  displaySelectedTransaction() {
    if (!this.selectedTx) return;
    const key = `SAMPLE_${this.selectedTx}_TEXT`;
    this.x12Text = (SAMPLE_DATA as any)[key] || '';
    this.buildTree();
  }

  // chunk children into rows for compact display (size default 5)
  chunkChildren(node: X12Node, size = 5): X12Node[][] {
    if (!node.children) return [];
    const rows: X12Node[][] = [];
    for (let i = 0; i < node.children.length; i += size) {
      rows.push(node.children.slice(i, i + size));
    }
    return rows;
  }

  // chunk only children that have non-empty values (skip empty fields)
  chunkNonEmptyChildren(node: X12Node, size = 5): X12Node[][] {
    if (!node.children) return [];
    const filtered = node.children.filter(c => {
      const v = (c.value || '').toString();
      return v != null && v.toString().trim().length > 0;
    });
    const rows: X12Node[][] = [];
    for (let i = 0; i < filtered.length; i += size) {
      rows.push(filtered.slice(i, i + size));
    }
    return rows;
  }

  // return true when all children of a node are leaves (no grandchildren)
  isLeafArray(node: X12Node): boolean {
    return !!node.children && node.children.length > 0 && node.children.every(c => !c.children);
  }

  hasChild = (_: number, node: X12Node) => !!node.children && node.children.length > 0;
}
