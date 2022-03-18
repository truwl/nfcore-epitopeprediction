version 1.0

workflow epitopeprediction {
	input{
		File samplesheet
		String outdir = "./results"
		String? email
		String? multiqc_title
		String genome_version = "GRCh37"
		String? proteome
		Boolean? igenomes_ignore
		Boolean? filter_self
		Int mhc_class = 1
		Int max_peptide_length = 11
		Int min_peptide_length = 8
		String tools = "syfpeithi"
		String? tool_thresholds
		Boolean? wild_type
		Boolean? fasta_output
		Boolean? show_supported_models
		Int peptides_split_maxchunks = 100
		Int peptides_split_minchunksize = 5000
		String netmhcpan_path = "None"
		String netmhc_path = "None"
		String netmhciipan_path = "None"
		String netmhcii_path = "None"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda

	}

	call make_uuid as mkuuid {}
	call touch_uuid as thuuid {
		input:
			outputbucket = mkuuid.uuid
	}
	call run_nfcoretask as nfcoretask {
		input:
			samplesheet = samplesheet,
			outdir = outdir,
			email = email,
			multiqc_title = multiqc_title,
			genome_version = genome_version,
			proteome = proteome,
			igenomes_ignore = igenomes_ignore,
			filter_self = filter_self,
			mhc_class = mhc_class,
			max_peptide_length = max_peptide_length,
			min_peptide_length = min_peptide_length,
			tools = tools,
			tool_thresholds = tool_thresholds,
			wild_type = wild_type,
			fasta_output = fasta_output,
			show_supported_models = show_supported_models,
			peptides_split_maxchunks = peptides_split_maxchunks,
			peptides_split_minchunksize = peptides_split_minchunksize,
			netmhcpan_path = netmhcpan_path,
			netmhc_path = netmhc_path,
			netmhciipan_path = netmhciipan_path,
			netmhcii_path = netmhcii_path,
			custom_config_version = custom_config_version,
			custom_config_base = custom_config_base,
			config_profile_name = config_profile_name,
			config_profile_description = config_profile_description,
			config_profile_contact = config_profile_contact,
			config_profile_url = config_profile_url,
			max_cpus = max_cpus,
			max_memory = max_memory,
			max_time = max_time,
			help = help,
			email_on_fail = email_on_fail,
			plaintext_email = plaintext_email,
			max_multiqc_email_size = max_multiqc_email_size,
			monochrome_logs = monochrome_logs,
			multiqc_config = multiqc_config,
			tracedir = tracedir,
			validate_params = validate_params,
			show_hidden_params = show_hidden_params,
			enable_conda = enable_conda,
			outputbucket = thuuid.touchedbucket
            }
		output {
			Array[File] results = nfcoretask.results
		}
	}
task make_uuid {
	meta {
		volatile: true
}

command <<<
        python <<CODE
        import uuid
        print("gs://truwl-internal-inputs/nf-epitopeprediction/{}".format(str(uuid.uuid4())))
        CODE
>>>

  output {
    String uuid = read_string(stdout())
  }
  
  runtime {
    docker: "python:3.8.12-buster"
  }
}

task touch_uuid {
    input {
        String outputbucket
    }

    command <<<
        echo "sentinel" > sentinelfile
        gsutil cp sentinelfile ~{outputbucket}/sentinelfile
    >>>

    output {
        String touchedbucket = outputbucket
    }

    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task fetch_results {
    input {
        String outputbucket
        File execution_trace
    }
    command <<<
        cat ~{execution_trace}
        echo ~{outputbucket}
        mkdir -p ./resultsdir
        gsutil cp -R ~{outputbucket} ./resultsdir
    >>>
    output {
        Array[File] results = glob("resultsdir/*")
    }
    runtime {
        docker: "google/cloud-sdk:latest"
    }
}

task run_nfcoretask {
    input {
        String outputbucket
		File samplesheet
		String outdir = "./results"
		String? email
		String? multiqc_title
		String genome_version = "GRCh37"
		String? proteome
		Boolean? igenomes_ignore
		Boolean? filter_self
		Int mhc_class = 1
		Int max_peptide_length = 11
		Int min_peptide_length = 8
		String tools = "syfpeithi"
		String? tool_thresholds
		Boolean? wild_type
		Boolean? fasta_output
		Boolean? show_supported_models
		Int peptides_split_maxchunks = 100
		Int peptides_split_minchunksize = 5000
		String netmhcpan_path = "None"
		String netmhc_path = "None"
		String netmhciipan_path = "None"
		String netmhcii_path = "None"
		String custom_config_version = "master"
		String custom_config_base = "https://raw.githubusercontent.com/nf-core/configs/master"
		String? config_profile_name
		String? config_profile_description
		String? config_profile_contact
		String? config_profile_url
		Int max_cpus = 16
		String max_memory = "128.GB"
		String max_time = "240.h"
		Boolean? help
		String? email_on_fail
		Boolean? plaintext_email
		String max_multiqc_email_size = "25.MB"
		Boolean? monochrome_logs
		String? multiqc_config
		String tracedir = "./results/pipeline_info"
		Boolean validate_params = true
		Boolean? show_hidden_params
		Boolean? enable_conda

	}
	command <<<
		export NXF_VER=21.10.5
		export NXF_MODE=google
		echo ~{outputbucket}
		/nextflow -c /truwl.nf.config run /epitopeprediction-2.0.0  -profile truwl,nfcore-epitopeprediction  --input ~{samplesheet} 	~{"--samplesheet '" + samplesheet + "'"}	~{"--outdir '" + outdir + "'"}	~{"--email '" + email + "'"}	~{"--multiqc_title '" + multiqc_title + "'"}	~{"--genome_version '" + genome_version + "'"}	~{"--proteome '" + proteome + "'"}	~{true="--igenomes_ignore  " false="" igenomes_ignore}	~{true="--filter_self  " false="" filter_self}	~{"--mhc_class " + mhc_class}	~{"--max_peptide_length " + max_peptide_length}	~{"--min_peptide_length " + min_peptide_length}	~{"--tools '" + tools + "'"}	~{"--tool_thresholds '" + tool_thresholds + "'"}	~{true="--wild_type  " false="" wild_type}	~{true="--fasta_output  " false="" fasta_output}	~{true="--show_supported_models  " false="" show_supported_models}	~{"--peptides_split_maxchunks " + peptides_split_maxchunks}	~{"--peptides_split_minchunksize " + peptides_split_minchunksize}	~{"--netmhcpan_path '" + netmhcpan_path + "'"}	~{"--netmhc_path '" + netmhc_path + "'"}	~{"--netmhciipan_path '" + netmhciipan_path + "'"}	~{"--netmhcii_path '" + netmhcii_path + "'"}	~{"--custom_config_version '" + custom_config_version + "'"}	~{"--custom_config_base '" + custom_config_base + "'"}	~{"--config_profile_name '" + config_profile_name + "'"}	~{"--config_profile_description '" + config_profile_description + "'"}	~{"--config_profile_contact '" + config_profile_contact + "'"}	~{"--config_profile_url '" + config_profile_url + "'"}	~{"--max_cpus " + max_cpus}	~{"--max_memory '" + max_memory + "'"}	~{"--max_time '" + max_time + "'"}	~{true="--help  " false="" help}	~{"--email_on_fail '" + email_on_fail + "'"}	~{true="--plaintext_email  " false="" plaintext_email}	~{"--max_multiqc_email_size '" + max_multiqc_email_size + "'"}	~{true="--monochrome_logs  " false="" monochrome_logs}	~{"--multiqc_config '" + multiqc_config + "'"}	~{"--tracedir '" + tracedir + "'"}	~{true="--validate_params  " false="" validate_params}	~{true="--show_hidden_params  " false="" show_hidden_params}	~{true="--enable_conda  " false="" enable_conda}	-w ~{outputbucket}
	>>>
        
    output {
        File execution_trace = "pipeline_execution_trace.txt"
        Array[File] results = glob("results/*/*html")
    }
    runtime {
        docker: "truwl/nfcore-epitopeprediction:2.0.0_0.1.0"
        memory: "2 GB"
        cpu: 1
    }
}
    