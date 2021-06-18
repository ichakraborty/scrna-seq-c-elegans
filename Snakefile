# Snakefile for c.elegans
#
# See README.md for more information.

# Configuration
configfile: 'config.yaml'

# Convenience variables
working_dir = config['working_dir']

eqtl_window_size = 500000

rule results:
  input:
    results_dir + 

rule eqtl_analysis:
  input:
    eqtl_dir + 

rule preprocess_data:
  input:
    working_dir + 

rule get_data:
  input:
    expand(fastq_dir +  '/{sample}.{string}_1.fastq.gz', zip,
           sample=config['samples'], string=config['samples'].values()), 
    bed_file,
    config['gtf_file'],
    config['transcript_fa'],
    config['data_dir'] + '/EUR373.gene.cis.FDR5.best.rs137.txt.gz',
    config['data_dir'] + '/YRI89.gene.cis.FDR5.best.rs137.txt.gz'

rule ffq:
  output:
    config['transcript_fa']
  shell:
    ' '.join([
      'ffq', '-t','SRP', 'SRP279842', '-o', 'runs.json'
    ])

## Rules for pulling data
rule get_transcript_fa:
  output:
    config['transcript_fa']
  shell:
    ' '.join([
      'wget', '-O', config['transcript_fa'],
      'ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_27/gencode.v27.pc_transcripts.fa.gz'])

## Kallisto rules
rule kallisto_make_index:
  input:
    config['transcript_fa']
  output:
    kallisto_idx
  shell:
    'kallisto index -i {output} {input}'
 
rule kallisto_quant:
  input:
    idx = kallisto_idx,
    r1 = fastq_dir + '/{sample}.{string}_1.fastq.gz',
    r2 = fastq_dir + '/{sample}.{string}_2.fastq.gz'
  output:
    tsv = abundance_dir + '/{sample}.{string}/abundance.tsv'
  threads: 4
  shell:
    ' '.join(['kallisto quant -i', kallisto_idx, '-o',
              abundance_dir + '/{wildcards.sample}.{wildcards.string}',
              '-t', '{threads}', '{input.r1}', '{input.r2}'])

