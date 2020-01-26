# subidx = '0 1,2, 3 -1 A 2b'
# demo_subs = 'All All_that_are_not_installed KC YAB YAD YAF YAH YAI YAJ YAK'
.libPaths(Sys.getenv('R_LIBS_USER'))

demo_subs = unlist(strsplit(demo_subs, ' '))
subidx = dipsaus::parse_svec(subidx, sep = "[, ]")
subidx = subidx[!is.na(subidx)]
if(length(subidx)){ subidx = subidx + 1 }

skip_installed = FALSE

if( 1 %in% subidx ){
  subidx = seq(3, length(demo_subs), 1)
}

if( 2 %in% subidx ){
  skip_installed = TRUE
  subidx = seq(3, length(demo_subs), 1)
}

# install
demo_subs = demo_subs[ subidx ]
subs = rave::get_subjects('demo')
if( skip_installed ){
  demo_subs = demo_subs[ !demo_subs %in% subs ]
}

if(length(demo_subs)){
  cat("Installing demo subject(s): ", paste(demo_subs, sep = ', '), '\n')
  
  for( sub in demo_subs ){
    rave::download_sample_data(sub, replace_if_exists = TRUE)
    try({
      brain = rave::rave_brain2(sprintf('demo/%s', sub))
    })
  }
}

# install group data
dirs = rave::get_dir(subject_code = '_project_data', project_name = 'demo')
if(!dir.exists(dirs$subject_dir)){
  rave::download_sample_data('_group_data')
}

print('Finished')

