#!/usr/bin/env python3
import json, sys, re, argparse

def parse_fastp_json(path):
    with open(path) as f:
        d = json.load(f)
    raw  = d['summary']['before_filtering']['total_reads'] // 2
    kept = d['summary']['after_filtering']['total_reads']  // 2
    return raw, kept

def parse_flagstat(path):
    content = open(path).read()
    # Format: "96077 + 0 primary mapped (91.32% : N/A)"
    m1 = re.search(r'primary mapped \(([\d.]+)%', content)
    # Format: "61338 + 0 properly paired (74.90% : N/A)"
    m2 = re.search(r'properly paired \(([\d.]+)%', content)
    mapped = float(m1.group(1)) if m1 else None
    pp     = float(m2.group(1)) if m2 else None
    return mapped, pp

def parse_seqkit(path):
    lines = [l.strip() for l in open(path) if l.strip()]
    if len(lines) < 2:
        return None
    header = lines[0].split()
    data   = lines[1].split()
    return int(data[header.index('num_seqs')].replace(',',''))

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--sample',       required=True)
    p.add_argument('--fastp-json',   required=True, dest='fastp_json')
    p.add_argument('--flagstat',     required=True)
    p.add_argument('--seqkit-r1',    required=True, dest='seqkit_r1')
    p.add_argument('--seqkit-r2',    required=True, dest='seqkit_r2')
    p.add_argument('--min-retained', required=True, type=float, dest='min_retained')
    p.add_argument('--min-mapped',   required=True, type=float, dest='min_mapped')
    p.add_argument('--output',       required=True)
    args = p.parse_args()

    raw, kept       = parse_fastp_json(args.fastp_json)
    mapped, pp      = parse_flagstat(args.flagstat)
    r1              = parse_seqkit(args.seqkit_r1)
    r2              = parse_seqkit(args.seqkit_r2)
    retained_pct    = (kept / raw * 100) if raw > 0 else 0.0

    mapped_ok   = mapped is not None and mapped >= args.min_mapped
    retained_ok = retained_pct >= args.min_retained
    reads_equal = (r1 == r2)

    status = 'ACCEPT' if (reads_equal and retained_ok and mapped_ok) else 'REVIEW'

    with open(args.output, 'w') as out:
        out.write('\t'.join(['sample','raw_read_pairs','retained_read_pairs',
                             'retained_percentage','mapped_percentage',
                             'properly_paired_percentage','status']) + '\n')
        out.write('\t'.join([
            args.sample, str(raw), str(kept),
            f'{retained_pct:.2f}',
            f'{mapped:.2f}' if mapped is not None else 'NA',
            f'{pp:.2f}'     if pp     is not None else 'NA',
            status
        ]) + '\n')

    print(f"[{args.sample}] retained={retained_pct:.1f}% "
          f"mapped={mapped:.1f}% status={status}", file=sys.stderr)

if __name__ == '__main__':
    main()
