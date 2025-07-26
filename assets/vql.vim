" Vim syntax file
" VQL (Velociraptor Query Language)

if exists("b:current_syntax")
  finish
endif

syn case ignore

" The VQL reserved words, defined as keywords.
syn keyword Keyword explain select from where group by order limit as null let 

syn keyword Special not and or in

syn match Operator /[A-Za-z_]\+=/

syn match Operator "+"
syn match Operator "-"
syn match Operator "*"
syn match Operator "/"
syn match Operator "!="
syn match Operator "="
syn match Operator "<"
syn match Operator "<="
syn match Operator ">"
syn match Operator ">="
syn match Operator "=\~"

" syn keyword vqlStatement create update alter select insert contained
" syn keyword vqlType smallint real timestamp urowid varchar varchar2 varray
" Strings:
syn region String matchgroup=Quote start=+n\?"+     end=+"+
syn region String matchgroup=Quote start=+n\?'+     end=+'+
syn region String matchgroup=Quote start=+n\?q'\z([^[(<{]\)+    end=+\z1'+
syn region String matchgroup=Quote start=+n\?q'<+   end=+>'+
syn region String matchgroup=Quote start=+n\?q'{+   end=+}'+
syn region String matchgroup=Quote start=+n\?q'(+   end=+)'+
syn region String matchgroup=Quote start=+n\?q'\[+  end=+]'+

" Numbers:
syn match Number "-\=\<\d*\.\=[0-9_]\>"

" Comments:
syn region Comment start="/\*"  end="\*/" contains=vqlTodo,@Spell fold 
syn match Comment "--.*$" contains=vqlTodo,@Spell
syn match Comment "^rem.*$" contains=vqlTodo,@Spell

syn sync ccomment Comment

" Functions:
" Frequent functions
syn keyword Function atoi basename chain column_filter count dict execve
syn keyword Function expand filter flatten foreach format get glob http_client
syn keyword Function humanize if info int items join len log lowcase memoize
syn keyword Function netstat now plist process_tracker_get process_tracker_pslist
syn keyword Function pslist range read_file regex_transform scope set sigma split
syn keyword Function stat str substr switch tempdir tempfile timestamp to_dict unzip upload 
" Windows functions
syn keyword Function amsi appcompatcache authenticode certificates etw_sessions
syn keyword Function handles interfaces lookupSID modules partitions proc_dump
syn keyword Function proc_yara read_reg_key reg_rm_key reg_rm_value reg_set_value
syn keyword Function srum_lookup_id threads token users vad winobj winpmem wmi 
" Linux functions
syn keyword Function audit connections ebpf_events sysinfo watch_ebpf 
" Server functions
syn keyword Function add_client_monitoring add_server_monitoring artifact_definitions
syn keyword Function artifact_delete artifact_set artifact_set_metadata backup backup_restore cancel_flow
syn keyword Function client_create client_delete client_info client_metadata client_set_metadata clients
syn keyword Function collect_client create_flow_download create_hunt_download create_notebook_download
syn keyword Function delete_events delete_flow enumerate_flow favorites_delete favorites_save file_store
syn keyword Function file_store_delete flow_logs flow_results flows get_client_monitoring get_flow get_server_monitoring
syn keyword Function gui_users hunt hunt_add hunt_delete hunt_flows hunt_info hunt_results hunt_update hunts import
syn keyword Function import_collection inventory inventory_add inventory_get killkillkill label link_to logging mail
syn keyword Function monitoring monitoring_logs notebook_create notebook_delete notebook_export notebook_get notebook_update
syn keyword Function notebook_update_cell org org_create org_delete orgs parallelize passwd query repack rm_client_monitoring
syn keyword Function rm_server_monitoring send_event server_frontend_cert server_metadata server_set_metadata
syn keyword Function set_server_monitoring source timeline timeline_add timeline_delete timelines upload_directory
syn keyword Function uploads user user_create user_delete user_grant user_options vfs_ls whoami set_client_monitoring
" Parser functions
syn keyword Function carve_usn commandline_split grok leveldb olevba parse_auditd parse_binary parse_csv
syn keyword Function parse_ese parse_ese_catalog parse_evtx parse_float parse_journald parse_json parse_json_array
syn keyword Function parse_json_array parse_jsonl parse_lines parse_mft parse_ntfs parse_ntfs_i30 parse_ntfs_ranges
syn keyword Function parse_pe parse_pkcs7 parse_records_with_regex parse_recyclebin parse_string_with_regex parse_usn
syn keyword Function parse_x509 parse_xml parse_yaml path_split pathspec plist prefetch regex_replace
syn keyword Function relpath split_records vqlite starl yara yara_lint 
" Encode / Decode functions
syn keyword Function base64decode base64encode base85decode compress crypto_rc4 encode entropy gunzip
syn keyword Function hash lzxpress_decompress pk_decrypt pk_encrypt rot13 tlsh_hash unhex utf16 utf16_encode xor 
" Event plugins 
syn keyword Function clock diff fifo watch_auditd watch_csv watch_etw watch_evtx watch_journald
syn keyword Function watch_jsonl watch_monitoring watch_syslog watch_usn wmi_events 
" Experimental functions
syn keyword Function js js_call js_get js_set sequence xattr 
" Developer functions
syn keyword Function mock mock_check mock_clear mock_replay panic profile profile_goroutines profile_memory trace 
" Other functions
syn keyword Function alert all any array atexit batch cache cache_dns cidr_contains collect combine
syn keyword Function copy dedup delay dirname efivariables elastic_upload enumerate environ environ
syn keyword Function eval favorites_list filesystems for gcs_pubsub_publish generate geoip getpid help
syn keyword Function host ip lazy_dict logscale_upload lru magic mail max min netcat parse_pst patch
syn keyword Function path_join pe_dump pipe process_tracker process_tracker_all process_tracker_callchain
syn keyword Function process_tracker_children process_tracker_tree process_tracker_updates pskill rand
syn keyword Function rate read_crypto_file rekey remap rm rsyslog sample secret_define secret_modify
syn keyword Function secrets serialize sigma_log_sources similarity sleep slice splunk_upload vql stat
syn keyword Function strip sum timestamp_format typeof upcase upload_azure upload_gcs upload_s3 upload_sftp
syn keyword Function upload_smb upload_webdav url uuid version write_crypto_file write_csv write_jsonl 

let b:current_syntax = "vql"
" vim: ts=8
